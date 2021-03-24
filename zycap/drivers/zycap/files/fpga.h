#ifndef FPGA_H_
#define GPGA_H_

#include <fcntl.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>				// Timer functions

#define FPGA_RB_IGNORE_BYTES_CONTROL 48;
#define FPGA_RB_IGNORE_BYTES_DATA 44;

#define init_module(module_image, len, param_values) syscall(__NR_init_module, module_image, len, param_values)

enum {
  FPGA_WR_FLAG_FULL_BS = 0,
  FPGA_WR_FLAG_PARTIAL_BS = 1
};

enum {
  FPGA_RB_FLAG_TYPE_CONTROL = 0,
  FPGA_RB_FLAG_TYPE_DATA = 1
};


struct FPGAManager
{
   char * name;
   char * sysfsFirm;
   char * sysfsFlags;
   int mode;
};

int initFPGAManager(struct FPGAManager* fpga, const char* name, int mode);
int testFPGAManager(struct FPGAManager* fpga);
int setFPGAManager_Mode(struct FPGAManager* fpga, int mode);


#endif /* FPGA_H_ */

