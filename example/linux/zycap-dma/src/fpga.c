/**
 * @file fpga.c
 * @date Saturday, December 05, 2015 at 10:10:39 AM EST
 * @author Brandon Perez (bmperez)
 * @author Jared Choi (jaewonch)
 *
 * This is a simple library that wraps around the AXI DMA module,
 * allowing for the user to abstract away from the finer grained details.
 *
 * @bug No known bugs.
 **/

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>             // Memset and memcpy functions
#include <fcntl.h>              // Flags for open()
#include <sys/stat.h>           // Open() system call
#include <sys/types.h>          // Types for open()
#include <sys/mman.h>           // Mmap system call
#include <sys/ioctl.h>          // IOCTL system call
#include <unistd.h>             // Close() system call
#include <errno.h>              // Error codes
#include <signal.h>             // Signal handling functions

#include "fpga.h"          // Local definitions

int calculateMBps(long * seconds, int * file_size){

	return 0;
}

int setFPGAManager_Mode(struct FPGAManager* fpga, int mode){
    int            fd,err;
    char mode_str [2];
    sprintf(mode_str, "%d", mode);

    if ((fd  = open(fpga->sysfsFlags, O_WRONLY)) == -1) {
        printf("Can not open fpga.\n");
        return EXIT_FAILURE;
    }

    err = write(fd, mode_str, strlen(mode_str)+1); //    Set mode
    if(err == -1){
        close(fd);
        return EXIT_FAILURE;
    }

//    echo 0xFFCA3008 0xFFFFFFFF 0 > /sys/firmware/zynqmp/config_reg
//    echo 0xFFCA3008 > /sys/firmware/zynqmp/config_reg
//    cat /sys/firmware/zynqmp/config_reg


	return 0;
}

int initFPGAManager(struct FPGAManager* fpga, const char* name, int mode)
{

    char           file_name[1024];
    int            fd,err;
    unsigned char  attr[1024];
    size_t image_size;
    struct stat st;
    void *image;

    printf("Initalizing FPGA Manager\n");

    fpga->name = malloc(strlen(name)+1);
    fpga->sysfsFlags = malloc(strlen("/sys/class/fpga_manager//flags")+strlen(name)+1);
    fpga->sysfsFlags = malloc(strlen("/sys/class/fpga_manager//firmware")+strlen(name)+1);

    strcpy(fpga->name, name);
    sprintf(fpga->sysfsFlags, "/sys/class/fpga_manager/%s/flags", fpga->name);
    sprintf(fpga->sysfsFirm, "/sys/class/fpga_manager/%s/firmware", fpga->name);
    fpga->mode = mode;

    setFPGAManager_Mode(fpga, mode);

    return 0;
}

int testFPGAManager(struct FPGAManager* fpga){
    struct timespec start, finish;

    printf("********Running FPGA Manager Test********\n");
	system("dmesg -n 1"); // Enable/Disable to add kernel logging
	system("echo 0xFFCA3008 0xFFFFFFFF 1 > /sys/firmware/zynqmp/config_reg");
	system("echo 0xFFCA3008 > /sys/firmware/zynqmp/config_reg");

    setFPGAManager_Mode(fpga,1);

	system("cp /mnt/mode_a-config_* /lib/firmware/");
	system("echo mode_a-config_b.bin > /sys/class/fpga_manager/fpga0/firmware");
	system("devmem 0xA0001000");

    clock_gettime(CLOCK_REALTIME, &start);
	system("echo mode_a-config_a.bin > /sys/class/fpga_manager/fpga0/firmware");
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

	system("devmem 0xA0001000");

	return 0;
}

//  void setFPGAFlags(int flags) {
////    std::ofstream flagfile(sysfsFlags);
////    flagfile << flags;
////    flagfile.close();
////    if (!flagfile)
////      throw std::runtime_error("Could not write fpga flags");
//  }
//
//  void setFPGAFirmware(const char &firmware) {
////    std::ofstream firmfile(sysfsFirm);
////    firmfile << firmware;
////    firmfile.close();
////    if (!firmfile)
////      throw std::runtime_error("Could not write fpga firmware");
//  }
//
//  void setFPGAReadbackFlags(int flags) {
////    std::ofstream flagfile(sysfsRBFlags);
////    flagfile << flags;
////    flagfile.close();
////    if (!flagfile)
////      throw std::runtime_error("Could not write readback flags");
//  }
//
//  std::vector<char> performFPGAReadback(int seekoffset) {
////    std::ifstream readbackfile(sysfsRBImage, std::ios::binary);
////    readbackfile.ignore(seekoffset);
////    std::vector<char> filedata((std::istreambuf_iterator<char>(readbackfile)),
////                               std::istreambuf_iterator<char>());
////    readbackfile.close();
////    if (!readbackfile)
////      throw std::runtime_error("Could not open readback file");
////    return filedata;
//  }
//
//public:
//  FPGAManager(int fpga_id) {
////    std::string sysfsRoot = "/sys/class/fpga_manager/fpga" + std::to_string(fpga_id);
////    sysfsFirm = sysfsRoot + "/firmware";
////    sysfsFlags = sysfsRoot + "/flags";
////    sysfsRBImage  = "/sys/kernel/debug/fpga/fpga" + std::to_string(fpga_id) + "/image";
////    sysfsRBFlags = "/sys/module/zynqmp_fpga/parameters/readback_type";
//  }
//
//  std::vector<char> readbackImage() {
////    setFPGAReadbackFlags(FPGA_RB_FLAG_TYPE_DATA);
////    return performFPGAReadback(FPGA_RB_IGNORE_BYTES_DATA);
//  }
//
//  std::vector<char> readbackConfig() {
////    setFPGAReadbackFlags(FPGA_RB_FLAG_TYPE_CONTROL);
////    return performFPGAReadback(FPGA_RB_IGNORE_BYTES_CONTROL);
//  }
//
//  void loadFull(const std::string &firmware) {
////    setFPGAFlags(FPGA_WR_FLAG_FULL_BS);
////    setFPGAFirmware(firmware);
//  }
//
//  void loadPartial(const std::string &firmware) {
////    setFPGAFlags(FPGA_WR_FLAG_PARTIAL_BS);
////    setFPGAFirmware(firmware);
//  }
