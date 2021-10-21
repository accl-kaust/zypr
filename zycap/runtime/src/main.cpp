#include <iostream>
#include <string>
#include <udma.h>

// ZyCAP Library
#include "zycap.hpp"

// User's Application
#include "opencv2/opencv.hpp"

#include "util.h"       // Miscellaneous utilities
#include "conversion.h" // Convert bytes to MiBs
#include "libaxidma.h"  // Interface ot the AXI DMA library
#include "udma.h"

#include <time.h>				// Timer functions
#include <cstdio>
#include <memory>
#include <stdexcept>
#include <array>

#define WIDTH 1920
#define HEIGHT 1080

#define WIDTH_OUT 1920
#define HEIGHT_OUT 1080

using namespace std;

cv::Mat takePhoto(struct dma_transfer *trans)
{
//    unsigned int width = WIDTH;
//    unsigned int height = HEIGHT;
    //    memcpy(output.data, trans->output_buf, size);

    cv::Mat image(cv::Size(WIDTH, HEIGHT), CV_8UC1);
    if (image.isContinuous())
        memcpy(image.data, trans->output_buf, image.total() * image.elemSize());
    else
    {
        printf("err\n");
    }

    return image;
}

static int transfer_file(axidma_dev_t dev, struct dma_transfer *trans, cv::Mat *in, int size)
{
    int rc;

    // Allocate a buffer for the input file, and read it into the buffer
    trans->input_buf = (char *)axidma_malloc(dev, trans->input_size);
    if (trans->input_buf == NULL)
    {
        fprintf(stderr, "Failed to allocate the input buffer.\n");
        rc = -ENOMEM;
        return rc;
    }

    //    memcpy(trans->input_buf, buf_in, size);

    if (in->isContinuous())
        memcpy(trans->input_buf, in->ptr(0), in->cols * in->rows);
    else
    {
        printf("err\n");
    }

    uchar *p;
    for (int i = 0; i < in->rows; ++i)
    {
        p = in->ptr<uchar>(i);
        for (int j = 0; j < in->cols; ++j)
        {
            trans->input_buf[i * in->cols + j] = p[j];
        }
    }

    //    rc = read_r(trans->input_fd, trans->input_buf, trans->input_size);
    //    if (rc < 0) {
    //        perror("Unable to read in input buffer.\n");
    //        axidma_free(dev, trans->input_buf, trans->input_size);
    //        return rc;
    //    }

    // Allocate a buffer for the output file
    trans->output_buf = (char *)axidma_malloc(dev, trans->output_size);
    if (trans->output_buf == NULL)
    {
        rc = -ENOMEM;
        axidma_free(dev, trans->input_buf, trans->input_size);
        return rc;
    }

    // Perform the transfer
    // Perform the main transaction
    rc = axidma_twoway_transfer(dev, trans->input_channel, trans->input_buf,
                                trans->input_size, NULL, trans->output_channel, trans->output_buf,
                                trans->output_size, NULL, true);
    if (rc < 0)
    {
        fprintf(stderr, "DMA read write transaction failed.\n");
        axidma_free(dev, trans->output_buf, trans->output_size);
        return rc;
    }

    printf("transferred.\n");

    // Write the data to the output file
    //    printf("Writing output data to `%s`.\n", output_path);
    //    rc = robust_write(trans->output_fd, trans->output_buf, trans->output_size);

    //    memcpy(out->data, trans->output_buf, size);

    //    cv::Mat img( 1080, 1920, CV_16U, trans->output_buf);

    cv::Mat img = takePhoto(trans);

    cv::imwrite("nope.png", img);

    img.release(); // free mem


    printf("copied.\n");

    axidma_free(dev, trans->input_buf, trans->input_size);
    axidma_free(dev, trans->output_buf, trans->output_size);
    printf("cleaning up.\n");

    return rc;
}

std::string exec(const char* cmd) {
    std::array<char, 128> buffer;
    std::string result;
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
    if (!pipe) {
        throw std::runtime_error("popen() failed!");
    }
    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
        result += buffer.data();
    }
    return result;
}

int testFPGAManager(string bitstream){
    struct timespec start, finish;

    printf("********Running FPGA Manager Test********\n");
	system("dmesg -n 1"); // Enable/Disable to add kernel logging
    printf("Setting PCAP registers\n");
	system("echo 0xFFCA3008 0xFFFFFFFF 1 > /sys/firmware/zynqmp/config_reg");
	system("echo 0xFFCA3008 > /sys/firmware/zynqmp/config_reg");

//    setFPGAManager_Mode(fpga,1);

	system("cp /home/root/mem_a.bin /lib/firmware/");
//	system("echo full_a.bin > /sys/class/fpga_manager/fpga0/firmware");
//	system("devmem 0xA0001000");
    printf("Loading bitstream...\n");

    clock_gettime(CLOCK_REALTIME, &start);
	system("echo mem_a.bin > /sys/class/fpga_manager/fpga0/firmware");
    clock_gettime(CLOCK_REALTIME, &finish);

    long seconds = finish.tv_sec - start.tv_sec;
    long ns = finish.tv_nsec - start.tv_nsec;

    if (start.tv_nsec > finish.tv_nsec) { // clock underflow
 	--seconds;
 	ns += 1000000000;
    }
    printf("seconds without ns: %ld\n", seconds);
    printf("nanoseconds: %ld\n", ns);
    printf("total seconds: %e\n", (double)seconds + (double)ns/(double)1000000000);

//	system("devmem 0xA0001000");

	return 0;
}

static int load_bitstream(axidma_dev_t dev, struct dma_transfer *trans){
    int rc;
    struct timespec start_1, finish_1;

    printf("********Running ZyCAP Test********\n");

    // Allocate a buffer for the input file, and read it into the buffer
    trans->input_buf = (char *)axidma_malloc(dev, trans->input_size);
    if (trans->input_buf == NULL)
    {
        fprintf(stderr, "Failed to allocate the input buffer.\n");
        rc = -ENOMEM;
        return rc;
    }

	rc = robust_read(trans->input_fd, trans->input_buf, trans->input_size);
	if (rc < 0) {
		perror("Unable to read in input buffer.\n");
		axidma_free(dev, trans->input_buf, trans->input_size);
		return rc;
	}

    printf("setting icap.\n");

	system("echo 0xFFCA3008 0xFFFFFFFF 0 > /sys/firmware/zynqmp/config_reg");
	system("echo 0xFFCA3008 > /sys/firmware/zynqmp/config_reg");

    string output = exec("cat /sys/firmware/zynqmp/config_reg");

    printf("%s",output.c_str());
    printf("transferring to icap.\n");

    clock_gettime(CLOCK_REALTIME, &start_1);
    rc = axidma_oneway_transfer(dev, trans->input_channel, trans->input_buf,
            trans->input_size, true);
    clock_gettime(CLOCK_REALTIME, &finish_1);

    long seconds = finish_1.tv_sec - start_1.tv_sec;
    long ns = finish_1.tv_nsec - start_1.tv_nsec;

    if (start_1.tv_nsec > finish_1.tv_nsec) { // clock underflow
 	--seconds;
 	ns += 1000000000;
    }

    printf("seconds without ns: %ld\n", seconds);
    printf("nanoseconds: %ld\n", ns);
    printf("total seconds: %e\n", (double)seconds + (double)ns/(double)1000000000);

    if (rc < 0)
    {
        fprintf(stderr, "DMA read write transaction failed.\n");
        axidma_free(dev, trans->output_buf, trans->output_size);
        return rc;
    }

    printf("transferred.\n");

    output = exec("devmem 0xa0020000 32");
    printf("%s",output.c_str());


    axidma_free(dev, trans->input_buf, trans->input_size);
    printf("cleaning up.\n");

    return rc;
}

int main(int argc, char **argv)
{
    int rc;
//	char *input_path = "test.bin";
    string input_path = "/home/root/mem_a.bin";
    axidma_dev_t axidma_dev;
	struct stat input_stat;
    struct dma_transfer trans;
    const array_t *tx_chans, *rx_chans;

    // Parse the input arguments
    memset(&trans, 0, sizeof(trans));

    UdmaRepo repo;

    UdmaDevice *device = repo.device(0);

    trans.input_fd = open(input_path.c_str(), O_RDONLY);
    if (trans.input_fd < 0) {
        perror("Error opening input file");
        rc = 1;
        goto ret;
    }

    // Initialize the AXIDMA device
    axidma_dev = axidma_init();
    if (axidma_dev == NULL)
    {
        fprintf(stderr, "Error: Failed to initialise the AXI DMA device.\n");
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
    //    if (trans.output_size == -1) {
//    trans.output_size = trans.input_size;
    //    }

    // Get the tx and rx channels if they're not already specified
    tx_chans = axidma_get_dma_tx(axidma_dev);
    if (tx_chans->len < 1)
    {
        fprintf(stderr, "Error: No transmit channels were found.\n");
        rc = -ENODEV;
        goto destroy_axidma;
    }
    rx_chans = axidma_get_dma_rx(axidma_dev);
    if (rx_chans->len < 1)
    {
        fprintf(stderr, "Error: No receive channels were found.\n");
        rc = -ENODEV;
        goto destroy_axidma;
    }

    /* If the user didn't specify the channels, we assume that the transmit and
     * receive channels are the lowest numbered ones. */
    //    if (trans.input_channel == -1 && trans.output_channel == -1) {
    trans.input_channel = tx_chans->data[0];
//    trans.output_channel = rx_chans->data[0];
    //    }
    printf("AXI DMA File Transfer Info:\n");
    printf("\tTransmit Channel: %d\n", trans.input_channel);
//    printf("\tReceive Channel: %d\n", trans.output_channel);
    printf("\tInput File Size: %.2f MiB\n", BYTE_TO_MIB(trans.input_size));
//    printf("\tOutput File Size: %.2f MiB\n\n", BYTE_TO_MIB(trans.output_size));

    rc = load_bitstream(axidma_dev, &trans);

//    rc = testFPGAManager(input_path);

    rc = (rc < 0) ? -rc : 0;

    device->unmap();

    printf("done.\n");

destroy_axidma:
    axidma_destroy(axidma_dev);
close_output:
    assert(close(trans.output_fd) == 0);
close_input:
    assert(close(trans.input_fd) == 0);
ret:
    return rc;
}

// OpenCV Demo
//int main(int argc, char **argv)
//{
//    int rc;
//    //    char *input_path;
//    string output_path = "test.png";
//    axidma_dev_t axidma_dev;
//    //    struct stat input_stat;
//    struct dma_transfer trans;
//    const array_t *tx_chans, *rx_chans;
//
//    // Parse the input arguments
//    memset(&trans, 0, sizeof(trans));
//    //    if (parse_args(argc, argv, &input_path, &output_path, &trans.input_channel,
//    //                   &trans.output_channel, &trans.output_size) < 0) {
//    //        rc = 1;
//    //        goto ret;
//    //    }
//    UdmaRepo repo;
//
//    UdmaDevice *device = repo.device(0);
//
//    // Start camera
//    cout << "Starting Camera" << endl;
//    cv::VideoCapture cap(0);
//
//    // Check if camera opened successfully
//    if (!cap.isOpened())
//    {
//        cout << "Error opening video stream or file" << endl;
//        return -1;
//    }
//
//    cap.set(CV_CAP_PROP_FRAME_WIDTH, WIDTH);
//    cap.set(CV_CAP_PROP_FRAME_HEIGHT, HEIGHT);
//    //  while(1){
//    cv::Mat frame(HEIGHT, WIDTH, CV_8UC1);
//    // Capture frame-by-frame
//    //        cv::Mat frame = cv::imread("input.png", 4);
//
//    cap >> frame;
//    frame.convertTo(frame, CV_8UC1);
//    cv::cvtColor(frame, frame, CV_BGRA2GRAY);
//
//    int height = frame.rows;
//    int width = frame.cols;
//    printf("height: %d width: %d\n", height, width);
//    int size = height * width * frame.elemSize();
//
//    printf("size: %d\n", size);
//
//    if (frame.empty())
//        return 1;
//
//    cv::imwrite("input.png", frame);
//
//    trans.output_fd = open(output_path.c_str(), O_WRONLY | O_CREAT | O_TRUNC,
//                           S_IWUSR | S_IRUSR | S_IRGRP | S_IWGRP | S_IROTH);
//    if (trans.output_fd < 0)
//    {
//        perror("Error opening output file");
//        rc = -1;
//        goto close_input;
//    }
//
//    // Initialize the AXIDMA device
//    axidma_dev = axidma_init();
//    if (axidma_dev == NULL)
//    {
//        fprintf(stderr, "Error: Failed to initialize the AXI DMA device.\n");
//        rc = 1;
//        goto close_output;
//    }
//
//    // Get the size of the input file
//    //    if (fstat(trans.input_fd, &input_stat) < 0) {
//    //        perror("Unable to get file statistics");
//    //        rc = 1;
//    //        goto destroy_axidma;
//    //    }
//
//    // If the output size was not specified by the user, set it to the default
//    trans.input_size = size;
//    //    if (trans.output_size == -1) {
//    trans.output_size = trans.input_size;
//    //    }
//
//    // Get the tx and rx channels if they're not already specified
//    tx_chans = axidma_get_dma_tx(axidma_dev);
//    if (tx_chans->len < 1)
//    {
//        fprintf(stderr, "Error: No transmit channels were found.\n");
//        rc = -ENODEV;
//        goto destroy_axidma;
//    }
//    rx_chans = axidma_get_dma_rx(axidma_dev);
//    if (rx_chans->len < 1)
//    {
//        fprintf(stderr, "Error: No receive channels were found.\n");
//        rc = -ENODEV;
//        goto destroy_axidma;
//    }
//
//    /* If the user didn't specify the channels, we assume that the transmit and
//     * receive channels are the lowest numbered ones. */
//    //    if (trans.input_channel == -1 && trans.output_channel == -1) {
//    trans.input_channel = tx_chans->data[0];
//    trans.output_channel = rx_chans->data[0];
//    //    }
//    printf("AXI DMA File Transfer Info:\n");
//    printf("\tTransmit Channel: %d\n", trans.input_channel);
//    printf("\tReceive Channel: %d\n", trans.output_channel);
//    printf("\tInput File Size: %.2f MiB\n", BYTE_TO_MIB(trans.input_size));
//    printf("\tOutput File Size: %.2f MiB\n\n", BYTE_TO_MIB(trans.output_size));
//
//    // Transfer the file over the AXI DMA
//    rc = transfer_file(axidma_dev, &trans, &frame, size);
//    rc = (rc < 0) ? -rc : 0;
//
//    //    out.convertTo(out,CV_8UC1);
//    //
//    //        cv::imwrite("cv.png", thing);
//    device->unmap();
//
//    frame.release();
//
//    //    cv::imwrite("cv.png", out);
//
//    printf("done.\n");
//    //    axidma_destroy(axidma_dev);
//    //    assert(close(trans.output_fd) == 0);
//    //    assert(close(trans.input_fd) == 0);
//
//destroy_axidma:
//    axidma_destroy(axidma_dev);
//close_output:
//    assert(close(trans.output_fd) == 0);
//close_input:
//    assert(close(trans.input_fd) == 0);
//ret:
//    return rc;
//}



// Test ICAPE is working
//int main(int argc, char **argv)
//{
//    string hardware = "/lib/firmware/";
//    string configs = "/lib/configs/";
//
//    Zycap z(hardware, configs);
//    z.load("sobel_a");
//
//    UdmaRepo repo;
//    UdmaDevice *device = repo.device(0);
//
//    // Start camera
//    cout << "Starting Camera" << endl;
//    cv::VideoCapture cap(0);
//
//    // Check if camera opened successfully
//    if (!cap.isOpened())
//    {
//        cout << "Error opening video stream or file" << endl;
//        return -1;
//    }
//
//    cap.set(CV_CAP_PROP_FRAME_WIDTH, 1920);
//    cap.set(CV_CAP_PROP_FRAME_HEIGHT, 1080);
//
//    //  while(1){
//    cv::Mat frame;
//    // Capture frame-by-frame
//    cap >> frame;
//    int height = frame.rows;
//    int width = frame.cols;
//    int size = height * width;
//
//    char *buf0 = device->map();
//    char *buf1 = device->map() + size;
//
//    z.dma.allocateBuffers(buf0, size, buf1, size);
//
//    //		z.dma.allocateBuffers(input_path, output_path);
////    memcpy(buf0, frame.data, size);
//
//    // If the frame is empty, break immediately
//    if (frame.empty())
//        return 1;
//
//    z.dma.transfer();
//
//
//    // Display the resulting frame
//    imshow("Frame", frame);
//    cv::imwrite("test.png", frame);
//
//    // When everything done, release the video capture object
//    cap.release();
//
//    cout << "finishing..." << endl;
//
//    device->unmap();
//
//    return 0;
//}
