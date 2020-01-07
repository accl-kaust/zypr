/*
 * zycap.h
 *
 *  Created on: 30 Dec 2019
 *      Author: alex
 */

#ifndef SRC_ZYCAP_H_
#define SRC_ZYCAP_H_

/*  Author   :   Alex B
 *  File     :   zycap_linux.h
 *  Project  :   ZyCAP User-level application for Linux
 *  Dcpr.    :   Management of bitstreams and buffers.
 */
#define bitsize 151072
#define UDMABUF "/dev/udmabuf0"
#define MAP_SIZE 8192UL
#define MAP_MASK (MAP_SIZE - 1)

#define MM2S_CONTROL_REGISTER 0x00
#define MM2S_STATUS_REGISTER 0x04
#define MM2S_START_ADDRESS 0x18
#define MM2S_START_ADDRESS_MSB 0x1C
#define MM2S_LENGTH 0x28

#define S2MM_CONTROL_REGISTER 0x30
#define S2MM_STATUS_REGISTER 0x34
#define S2MM_DESTINATION_ADDRESS 0x48
#define S2MM_LENGTH 0x58

#define ZYCAP_INIT 0x10

typedef struct bit_info{
   char name[128];
   int  size;
   int  addr;
   struct bit_info *prev;
   struct bit_info *next;
} bs_info;

typedef struct udma_config{
    unsigned char  attr[1024];
    unsigned long  sync_direction;
    unsigned int   buf_size;
} udmabuf;

typedef struct buffer{
        char bitbuffer[bitsize+1];
} buffertype;


typedef struct globalvars{
// uio
   int memudma;
   FILE *fudma;
   // udma
   int memuio;
   FILE *fuio;

} globals;

globals glbs;
udmabuf ubuf;
int init_zycap();
int Config_PR_Bitstream(char *bs_name);
int conf_bit (char *bs_name);
int Prefetch_PR_Bitstream(char *bs_name);

#endif /* SRC_ZYCAP_H_ */
