/*  Author   :   Alex B
 *  File     :   zycap_linux.h
 *  Project  :   ZyCAP User-level application for Linux
 *  Dcpr.    :   Management of bitstreams and buffers.
 */
#define bitsize 151072
#define UDMABUF "/dev/udmabuf0"

typedef struct bit_info{
   char name[128];
   int  size;
   int  addr;
   struct bit_info *prev;
   struct bit_info *next;
} bs_info;

typedef struct buffer{
        char bitbuffer[bitsize+1];
} buffertype;


typedef struct globalvars{
   int memfd;
   FILE *fd;
} globals;

globals glbs;
int init_zycap();
int Config_PR_Bitstream(char *bs_name);
int conf_bit (char *bs_name);
int Prefetch_PR_Bitstream(char *bs_name);