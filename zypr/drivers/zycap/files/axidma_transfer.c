///**
// * @file axidma_transfer.c
// * @date Sunday, November 29, 2015 at 12:23:43 PM EST
// * @author Brandon Perez (bmperez)
// * @author Jared Choi (jaewonch)
// *
// * This program performs a simple AXI DMA transfer. It takes the input file,
// * loads it into memory, and then sends it out over the PL fabric. It then
// * receives the data back, and places it into the given output file.
// *
// * By default it uses the lowest numbered channels for the transmit and receive,
// * unless overriden by the user. The amount of data transfered is automatically
// * determined from the file size. Unless specified, the output file size is
// * made to be 2 times the input size (to account for creating more data).
// *
// * This program also handles any additional channels that the pipeline
// * on the PL fabric might depend on. It starts up DMA transfers for these
// * pipeline stages, and discards their results.
// *
// * @bug No known bugs.
// **/

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <assert.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/mman.h>

#include <fcntl.h>              // Flags for open()
#include <sys/stat.h>           // Open() system call
#include <sys/types.h>          // Types for open()
#include <unistd.h>             // Close() system call
#include <string.h>             // Memory setting and copying
#include <getopt.h>             // Option parsing
#include <errno.h>              // Error codes
#include <time.h>				// Timer functions


#include "util.h"               // Miscellaneous utilities
#include "conversion.h"         // Convert bytes to MiBs
#include "libaxidma.h"          // Interface ot the AXI DMA library
#include "fpga.h"

/*----------------------------------------------------------------------------
 * Internal Definitions
 *----------------------------------------------------------------------------*/

// A convenient structure to carry information around about the transfer
struct dma_transfer {
    int input_fd;           // The file descriptor for the input file
    int input_channel;      // The channel used to send the data
    int input_size;         // The amount of data to send
    void *input_buf;        // The buffer to hold the input data
    int output_fd;          // The file descriptor for the output file
    int output_channel;     // The channel used to receive the data
    int output_size;        // The amount of data to receive
    void *output_buf;       // The buffer to hold the output
};

struct udmabuf {
    char           name[128];
    int            file;
    unsigned char* buf;
    unsigned int   buf_size;
    unsigned long  phys_addr;
    unsigned long  debug_vma;
    unsigned long  sync_mode;
    int            cache_on;
};

/*----------------------------------------------------------------------------
 * udambuf Line Interface
 *----------------------------------------------------------------------------*/

int udmabuf_open(struct udmabuf* udmabuf, const char* name, int cache_on)
{
    char           file_name[1024];
    int            fd;
    unsigned char  attr[1024];

    strcpy(udmabuf->name, name);
    udmabuf->file = -1;
    udmabuf->cache_on = cache_on;

    sprintf(file_name, "/sys/class/udmabuf/%s/phys_addr", name);
    if ((fd  = open(file_name, O_RDONLY)) == -1) {
        printf("Can not open %s\n", file_name);
        return (-1);
    }
    read(fd, (void*)attr, 1024);
    sscanf(attr, "%lx", &udmabuf->phys_addr);
    close(fd);

    sprintf(file_name, "/sys/class/udmabuf/%s/size", name);
    if ((fd  = open(file_name, O_RDONLY)) == -1) {
        printf("Can not open %s\n", file_name);
        return (-1);
    }
    read(fd, (void*)attr, 1024);
    sscanf(attr, "%d", &udmabuf->buf_size);
    close(fd);

    sprintf(file_name, "/dev/%s", name);
    if ((udmabuf->file = open(file_name, O_RDWR | ((cache_on == 0)? O_SYNC : 0))) == -1) {
        printf("Can not open %s\n", file_name);
        return (-1);
    }

    udmabuf->buf = mmap(NULL, udmabuf->buf_size, PROT_READ|PROT_WRITE, MAP_SHARED, udmabuf->file, 0);
    udmabuf->debug_vma = 0;
    udmabuf->sync_mode = 1;

    return 0;
}

/*----------------------------------------------------------------------------
 * Command Line Interface
 *----------------------------------------------------------------------------*/

// Prints the usage for this program
static void print_usage(bool help)
{
    FILE* stream = (help) ? stdout : stderr;

    fprintf(stream, "Usage: axidma_transfer <input path> <output path> "
            "[-t <DMA tx channel>] [-r <DMA rx channel>] [-s <Output file size>"
            " | -o <Output file size>].\n");
    if (!help) {
        return;
    }

    fprintf(stream, "\t<input path>:\t\tThe path to file to send out over AXI "
            "DMA to the PL fabric. Can be a relative or absolute path.\n");
    fprintf(stream, "\t<output path>:\t\tThe path to place the received data "
            "from the PL fabric into. Can be a relative or absolute path.\n");
    fprintf(stream, "\t-t <DMA tx channel>:\tThe device id of the DMA channel "
            "to use for transmitting the file. Default is to use the lowest "
            "numbered channel available.\n");
    fprintf(stream, "\t-r <DMA rx channel>:\tThe device id of the DMA channel "
            "to use for receiving the data from the PL fabric. Default is to "
            "use the lowest numbered channel available.\n");
    fprintf(stream, "\t-s <Output file size>:\tThe size of the output file in "
            "bytes. This is an integer value that must be at least the number "
            "of bytes received back. By default, this is the same as the size "
            "of the input file.\n");
    fprintf(stream, "\t-o <Output file size>:\tThe size of the output file in "
            "Mibs. This is a floating-point value that must be at least the "
            "number of bytes received back. By default, this is the same "
            "the size of the input file.\n");
    return;
}

/* Parses the command line arguments overriding the default transfer sizes,
 * and number of transfer to use for the benchmark if specified. */
static int parse_args(int argc, char **argv, char **input_path,
    char **output_path, int *input_channel, int *output_channel, int *output_size)
{
    char option;
    int int_arg;
    double double_arg;
    bool o_specified, s_specified;
    int rc;

    // Set the default values for the arguments
    *input_channel = -1;
    *output_channel = -1;
    *output_size = -1;
    o_specified = false;
    s_specified = false;
    rc = 0;

    while ((option = getopt(argc, argv, "t:r:s:o:h")) != (char)-1)
    {
        switch (option)
        {
            // Parse the transmit channel device id
            case 't':
                rc = parse_int(option, optarg, &int_arg);
                if (rc < 0) {
                    print_usage(false);
                    return rc;
                }
                *input_channel = int_arg;
                break;

            // Parse the receive channel device id
            case 'r':
                rc = parse_int(option, optarg, &int_arg);
                if (rc < 0) {
                    print_usage(false);
                    return rc;
                }
                *output_channel = int_arg;
                break;

            // Parse the output file size (in bytes)
            case 's':
                rc = parse_int(option, optarg, &int_arg);
                if (rc < 0) {
                    print_usage(false);
                    return rc;
                }
                *output_size = int_arg;
                s_specified = true;
                break;

            // Parse the output file size (in MiBs)
            case 'o':
                rc = parse_double(option, optarg, &double_arg);
                if (rc < 0) {
                    print_usage(false);
                    return rc;
                }
                *output_size = MIB_TO_BYTE(double_arg);
                o_specified = true;
                break;

            case 'h':
                print_usage(true);
                exit(0);

            default:
                print_usage(false);
                return -EINVAL;
        }
    }

    // If one of -t or -r is specified, then both must be
    if ((*input_channel == -1) ^ (*output_channel == -1)) {
        fprintf(stderr, "Error: Either both -t and -r must be specified, or "
                "neither.\n");
        print_usage(false);
        return -EINVAL;
    }

    // Only one of -s and -o can be specified
    if (s_specified && o_specified) {
        fprintf(stderr, "Error: Only one of -s and -o can be specified.\n");
        print_usage(false);
        return -EINVAL;
    }

    // Check that there are enough command line arguments
    if (optind > argc-2) {
        fprintf(stderr, "Error: Too few command line arguments.\n");
        print_usage(false);
        return -EINVAL;
    }

    // Check if there are too many command line arguments remaining
    if (optind < argc-2) {
        fprintf(stderr, "Error: Too many command line arguments.\n");
        print_usage(false);
        return -EINVAL;
    }

    // Parse out the input and output paths
    *input_path = argv[optind];
    *output_path = argv[optind+1];
    return 0;
}

/*----------------------------------------------------------------------------
 * DMA File Transfer Functions
 *----------------------------------------------------------------------------*/

static int transfer_file(axidma_dev_t dev, struct dma_transfer *trans,
                         char *output_path)
{
    int rc;

    // Allocate a buffer for the input file, and read it into the buffer
    printf("***********Allocating Bitstream Buffer************\n");

    struct timespec start_1, finish_1;
    trans->input_buf = axidma_malloc(dev, trans->input_size);
    if (trans->input_buf == NULL) {
        fprintf(stderr, "Failed to allocate the input buffer.\n");
        rc = -ENOMEM;
        goto ret;
    }
    rc = robust_read(trans->input_fd, trans->input_buf, trans->input_size);
    if (rc < 0) {
        perror("Unable to read in input buffer.\n");
        axidma_free(dev, trans->input_buf, trans->input_size);
        return rc;
    }

    // Allocate a buffer for the output file
    clock_gettime(CLOCK_REALTIME, &start_1);

    trans->output_buf = axidma_malloc(dev, trans->output_size);
    clock_gettime(CLOCK_REALTIME, &finish_1);

    if (trans->output_buf == NULL) {
        rc = -ENOMEM;
        goto free_input_buf;
    }

    long seconds = finish_1.tv_sec - start_1.tv_sec;
    long ns = finish_1.tv_nsec - start_1.tv_nsec;

    if (start_1.tv_nsec > finish_1.tv_nsec) { // clock underflow
 	--seconds;
 	ns += 1000000000;
    }
    printf("seconds without ns: %ld\n", seconds);
    printf("nanoseconds: %ld\n", ns);
    printf("total seconds: %e\n", (double)seconds + (double)ns/(double)1000000000);
    printf("***********Setting CSU Registers************\n");

    struct timespec start_0, finish_0;
    clock_gettime(CLOCK_REALTIME, &start_0);
	system("echo 0xFFCA3008 0xFFFFFFFF 0 > /sys/firmware/zynqmp/config_reg");
	system("echo 0xFFCA3008 > /sys/firmware/zynqmp/config_reg");
    clock_gettime(CLOCK_REALTIME, &finish_0);

    seconds = finish_0.tv_sec - start_0.tv_sec;
    ns = finish_0.tv_nsec - start_0.tv_nsec;

    if (start_0.tv_nsec > finish_0.tv_nsec) { // clock underflow
 	--seconds;
 	ns += 1000000000;
    }
    printf("seconds without ns: %ld\n", seconds);
    printf("nanoseconds: %ld\n", ns);
    printf("total seconds: %e\n", (double)seconds + (double)ns/(double)1000000000);

    printf("***********Running ZyCAP Test************\n");
	system("devmem 0xA0001000");

    // Perform the transfer
    // Perform the main transaction
    struct timespec start, finish;
    clock_gettime(CLOCK_REALTIME, &start);


    rc = axidma_oneway_transfer(dev, trans->input_channel, trans->input_buf,
            trans->input_size, true);



//    rc = axidma_twoway_transfer(dev, trans->input_channel, trans->input_buf,
//            trans->input_size, NULL, trans->output_channel, trans->output_buf,
//            trans->output_size, NULL, true);


    clock_gettime(CLOCK_REALTIME, &finish);

    seconds = finish.tv_sec - start.tv_sec;
    ns = finish.tv_nsec - start.tv_nsec;

    if (start.tv_nsec > finish.tv_nsec) { // clock underflow
 	--seconds;
 	ns += 1000000000;
    }
    printf("seconds without ns: %ld\n", seconds);
    printf("nanoseconds: %ld\n", ns);
    printf("total seconds: %e\n", (double)seconds + (double)ns/(double)1000000000);


	system("devmem 0xA0001000");

    if (rc < 0) {
        fprintf(stderr, "DMA read write transaction failed.\n");
        goto free_output_buf;
    }

    // Write the data to the output file
//    printf("Writing output data to `%s`.\n", output_path);
    rc = robust_write(trans->output_fd, trans->output_buf, trans->output_size);

free_output_buf:
    axidma_free(dev, trans->output_buf, trans->output_size);
free_input_buf:
    axidma_free(dev, trans->input_buf, trans->input_size);
ret:
    return rc;
}

int loadDMA (){
    int fd,err;
    size_t image_size;
    struct stat st;
    void *image;

    if ((fd = open("/lib/modules/4.14.0-xilinx-v2018.3/extra/xilinx-axidma.ko", O_RDONLY)) == -1) {
        printf("Can not load DMA Driver\n");
        return EXIT_FAILURE;
    }
    fstat(fd, &st);
    image_size = st.st_size;
    image = malloc(image_size);
    read(fd, image, image_size);
    close(fd);
    if (init_module(image, image_size, "") != 0) {
        perror("init_module");
        return EXIT_FAILURE;
    }
    free(image);
    return 0;
}

/*----------------------------------------------------------------------------
 * Main
 *----------------------------------------------------------------------------*/

int main(int argc, char **argv)
{
    int rc;
    char *input_path, *output_path;
    axidma_dev_t axidma_dev;
    struct stat input_stat;
    struct dma_transfer trans;
    const array_t *tx_chans, *rx_chans;

    struct FPGAManager fpga;

    int            uio_fd;
    unsigned int*  virtual_address;
    struct udmabuf src_buf;
    unsigned int*  virtual_source_address;
    unsigned int   test_size = 32;
    int            buf_cache_on = 1;



    // Parse the input arguments
    memset(&trans, 0, sizeof(trans));
    if (parse_args(argc, argv, &input_path, &output_path, &trans.input_channel,
                   &trans.output_channel, &trans.output_size) < 0) {
        rc = 1;
        goto ret;
    }
//    struct timespec start, finish;
//    clock_gettime(CLOCK_REALTIME, &start);
    loadDMA();
//    clock_gettime(CLOCK_REALTIME, &finish);

//    long seconds = finish.tv_sec - start.tv_sec;
//    long ns = finish.tv_nsec - start.tv_nsec;

//    if (start.tv_nsec > finish.tv_nsec) { // clock underflow
// 	--seconds;
// 	ns += 1000000000;
//    }
//    printf("seconds without ns: %ld\n", seconds);
//    printf("nanoseconds: %ld\n", ns);
//    printf("total seconds: %e\n", (double)seconds + (double)ns/(double)1000000000);

    initFPGAManager(&fpga, "fpga0", 0);

    if (udmabuf_open(&src_buf, "udmabuf0", buf_cache_on) == -1) {
        printf("Can not open /dev/udmabuf0\n");
        exit(1);
    }

    // Try opening the input and output images
    trans.input_fd = open(input_path, O_RDONLY);
    if (trans.input_fd < 0) {
        perror("Error opening input file");
        rc = 1;
        goto ret;
    }
    trans.output_fd = open(output_path, O_WRONLY|O_CREAT|O_TRUNC,
                     S_IWUSR|S_IRUSR|S_IRGRP|S_IWGRP|S_IROTH);
    if (trans.output_fd < 0) {
        perror("Error opening output file");
        rc = -1;
        goto close_input;
    }

    // Initialize the AXIDMA device
    axidma_dev = axidma_init();
    if (axidma_dev == NULL) {
        fprintf(stderr, "Error: Failed to initialize the AXI DMA device.\n");
        rc = 1;
        goto close_output;
    }

    // Get the size of the input file
    if (fstat(trans.input_fd, &input_stat) < 0) {
        perror("Unable to get file statistics");
        rc = 1;
        goto destroy_axidma;
    }

    // If the output size was not specified by the user, set it to the default
    trans.input_size = input_stat.st_size;
    if (trans.output_size == -1) {
        trans.output_size = 8000000;
    }

    // Get the tx and rx channels if they're not already specified
    tx_chans = axidma_get_dma_tx(axidma_dev);
    if (tx_chans->len < 1) {
        fprintf(stderr, "Error: No transmit channels were found.\n");
        rc = -ENODEV;
        goto destroy_axidma;
    }
    rx_chans = axidma_get_dma_rx(axidma_dev);
    if (rx_chans->len < 1) {
        fprintf(stderr, "Error: No receive channels were found.\n");
        rc = -ENODEV;
        goto destroy_axidma;
    }


    /* If the user didn't specify the channels, we assume that the transmit and
     * receive channels are the lowest numbered ones. */
    if (trans.input_channel == -1 && trans.output_channel == -1) {
        trans.input_channel = tx_chans->data[0];
        trans.output_channel = rx_chans->data[0];
    }
//    printf("AXI DMA File Transfer Info:\n");
//    printf("\tTransmit Channel: %d\n", trans.input_channel);
//    printf("\tReceive Channel: %d\n", trans.output_channel);
    printf("\tInput File Size: %.2f MiB\n", BYTE_TO_MIB(trans.input_size));
    printf("\tOutput File Size: %.2f MiB\n\n", BYTE_TO_MIB(trans.output_size));

    // Transfer the file over the AXI DMA
    rc = transfer_file(axidma_dev, &trans, output_path);
    rc = (rc < 0) ? -rc : 0;

    rc = testFPGAManager(&fpga);

destroy_axidma:
    axidma_destroy(axidma_dev);
close_output:
    assert(close(trans.output_fd) == 0);
close_input:
    assert(close(trans.input_fd) == 0);
ret:
    return rc;
}
