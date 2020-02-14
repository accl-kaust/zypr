///*  Author   :   Alex Bucknall
// *  File     :   zycap_linux.c
// *  Project  :   ZyCAP User-level driver for Linux
// *  Dcpr.    :   Management of bitstreams and buffers.
// */
//
//#include <stdio.h>
//#include <fcntl.h>
//#include <string.h>
//#include <dirent.h>
//#include <stdlib.h>
//#include <sys/time.h>
//#include <stdlib.h>
//#include <sys/mman.h>
//#include "zycap.h"
//#include <sys/types.h>
//#include <sys/mman.h>
//#include <sys/utsname.h>
//#include <sys/stat.h>
//#include <sys/types.h>
//#include <errno.h>
//#include <time.h>
//#include <sys/resource.h>
//
//#define CSU_BASE_ADDRESS 0xFFCA0000
//#define PCAP_CTRL 0x00003008
//#define MAP_SIZE 4096UL
//#define MAP_MASK (MAP_SIZE - 1)
//#define BS_BASEADDR
//#define MAX_BS_NUM 5
//#define DATE "27/12/19"
//
//
//static int check_bs_present(bs_info *bs_list,char *bs_name);
//static int find_first_bs(bs_info *bs_list);
//static int find_last_bs(bs_info *bs_list);
//static void print_schedule(bs_info *bs_list);
//bs_info *bs_list;
//buffertype *bufferIn;
//
//
//unsigned long gettime(){
//	struct timeval temp;
//
//	gettimeofday(&temp, NULL);
//
//	return temp.tv_sec * 1000 * 1000 + temp.tv_usec;
//}
//
//static int check_bs_present(bs_info *bs_list,char *bs_name)
//{
//    int i;
//    for(i=0;i<MAX_BS_NUM;i++)
//    {
//        if(strcmp(bs_list[i].name,bs_name) == 0)
//            return i;
//    }
//    return -1;
//}
//
//bs_info * init_bs_list(int num_bs)
//{
//    int i;
//    bs_info *bs_list;
//    bs_list = (bs_info *)malloc(num_bs*sizeof(bs_info));
//    bufferIn = (buffertype *)malloc(num_bs*sizeof(buffertype));
//    for(i=0;i<num_bs;i++)
//    {
//        strcpy(bs_list[i].name,"Dummy");
//        bs_list[i].size = -1;
//        if(i==0)
//            bs_list[i].prev = NULL;
//        else
//            bs_list[i].prev = &bs_list[i-1];
//        if(i==num_bs-1)
//            bs_list[i].next = NULL;
//        else
//            bs_list[i].next = &bs_list[i+1];
//       // bs_list[i].addr = (char *) malloc(bitsize+1);
//       bs_list[i].addr = (int)bufferIn[i].bitbuffer;
//    }
//    return bs_list;
//}
//
//
//int find_first_bs(bs_info *bs_list)
//{
//    int i;
//    for(i=0;i<MAX_BS_NUM;i++)
//    {
//        if(bs_list[i].prev == NULL)
//            return i;
//    }
//    return -1;
//}
//
//int find_last_bs(bs_info *bs_list)
//{
//    int i;
//    for(i=0;i<MAX_BS_NUM;i++)
//    {
//        if(bs_list[i].next== NULL)
//            return i;
//    }
//    return -1;
//}
//
//
//void print_schedule(bs_info *bs_list)
//{
//    bs_info *current_bs;
//    int i;
//    for(i=0;i<MAX_BS_NUM;i++)
//    {
//        current_bs = &bs_list[i];
//        printf("BS Num : %d BS Name : %s  BS Prev %s BS Next %s BS Addr %x \n",i,current_bs->name,current_bs->prev,current_bs->next, current_bs->addr);
//    }
//}
//
//// used to verify bitstream file sizes
//off_t fsize(const char *filename) {
//    struct stat st;
//
//    if (stat(filename, &st) == 0)
//        return st.st_size;
//
//    fprintf(stderr, "Cannot determine size of %s: %s\n",
//            filename, strerror(errno));
//
//    return -1;
//}
//
//// check udmabuf for errors
//int check_buf(unsigned char* buf, unsigned int size)
//{
//    int m = 256;
//    int n = 10;
//    int i, k;
//    int error_count = 0;
//    while(--n > 0) {
//      for(i = 0; i < size; i = i + m) {
//        m = (i+256 < size) ? 256 : (size-i);
//        for(k = 0; k < m; k++) {
//          buf[i+k] = (k & 0xFF);
//        }
//        for(k = 0; k < m; k++) {
//          if (buf[i+k] != (k & 0xFF)) {
//            error_count++;
//          }
//        }
//      }
//    }
//    return error_count;
//}
//
//unsigned int get_uio_size()
//{
//	FILE *size_fp;
//	unsigned int size;
//
//	/* Step 2, open the file that describes the memory range needed to map the TTC into
//	 * this address space, this is the range of the TTC in the device tree
//	 */
//	size_fp = fopen("/sys/class/uio/uio1/maps/map0/size", "r");
//
//	if (!size_fp) {
//		printf("unable to open the uio size file\n");
//		exit(-1);
//	}
//
//	/* Step 3, get the size which is an ASCII string such as 0xXXXXXXXX and then be stop
//	 * using the file
//	 */
//
//	fscanf(size_fp, "0x%16X", &size);
//	fclose(size_fp);
//
//	return size;
//}
//
//char* concat(const char *s1, const char *s2)
//{
//    char *result = malloc(strlen(s1) + strlen(s2) + 1); // +1 for the null-terminator
//    // in real code you would check for errors in malloc here
//    strcpy(result, s1);
//    strcat(result, s2);
//    return result;
//}
//
//char *get_filename_ext(const char *filename) {
//    const char *dot = strrchr(filename, '.');
//    if(!dot || dot == filename) return "";
//    return dot + 1;
//}
//
//int calculate_buf_size(char * dir_name){
//	DIR *dir;
//	struct dirent *ent;
//	off_t total_size = 0;
//	if ((dir = opendir (dir_name)) != NULL) {
//	  /* print all the bitstreams within directory */
//	  printf("available bitstreams:\n");
//	  while ((ent = readdir (dir)) != NULL) {
//		  char * ext = get_filename_ext(ent->d_name);
//		  if (strcmp(ext,"bin") == 0) {
//			 char* s = concat(dir_name, ent->d_name);
//			 printf ("- %s : %d\n", ent->d_name, fsize(s));
//			 total_size += fsize(s);
//			 free(s); // deallocate the string
//		  }
//	  }
//	  closedir (dir);
//	} else {
//	  /* could not open directory */
//	  perror ("");
//	  return EXIT_FAILURE;
//	}
//	ubuf.buf_size = (unsigned int) total_size;
//    printf("allocating %d for udmabuf\n", (int) total_size);
//	return 0;
//}
//
//unsigned int zycap_set(unsigned int* zycap_address, int offset, unsigned int value) {
//    zycap_address[offset>>2] = value;
//}
//
//unsigned int zycap_get(unsigned int* zycap_address, int offset) {
//    return zycap_address[offset>>2];
//}
//
//void zycap_status(unsigned int* zycap_address) {
//    unsigned int status = zycap_get(zycap_address, MM2S_STATUS_REGISTER);
//    printf("Memory-mapped to stream status (0x%08x@0x%02x):", status, MM2S_STATUS_REGISTER);
//    if (status & 0x00000001) printf(" halted"); else printf(" running");
//    if (status & 0x00000002) printf(" idle");
//    if (status & 0x00000008) printf(" SGIncld");
//    if (status & 0x00000010) printf(" DMAIntErr");
//    if (status & 0x00000020) printf(" DMASlvErr");
//    if (status & 0x00000040) printf(" DMADecErr");
//    if (status & 0x00000100) printf(" SGIntErr");
//    if (status & 0x00000200) printf(" SGSlvErr");
//    if (status & 0x00000400) printf(" SGDecErr");
//    if (status & 0x00001000) printf(" IOC_Irq");
//    if (status & 0x00002000) printf(" Dly_Irq");
//    if (status & 0x00004000) printf(" Err_Irq");
//    printf("\n");
//}
//
//int zycap_sync(unsigned int* zycap_address) {
//    unsigned int mm2s_status =  zycap_get(zycap_address, MM2S_STATUS_REGISTER);
//    while(!(mm2s_status & 1<<12) || !(mm2s_status & 1<<1) ){
//        zycap_status(zycap_address);
//
//        mm2s_status =  zycap_get(zycap_address, MM2S_STATUS_REGISTER);
//    }
//}
//
//int config_csu(){
//	int mem, data;
//    void * mem_address;
//    void * mapped_mem_address;
//    unsigned int size = get_uio_size();
//    off_t csu_base = CSU_BASE_ADDRESS;
//
//    if ((mem = open("/dev/mem", O_RDWR)) != -1) {
//        if (mem == -1) {
//			printf("Can't open uio.\n");
//			exit(0);
//        }
//    }
//
//
//    mem_address = mmap(0, size, PROT_READ | PROT_WRITE, MAP_SHARED, mem, 0);
//        if (!mem_address) {
//            printf("err");
//            exit(0);
//        }
//
//    mapped_mem_address = mem_address + (csu_base & 0x00003008);
//	*((volatile unsigned long *) (mapped_mem_address))=0x00000000;
//	data = *((volatile unsigned long *) (mapped_mem_address));
//
//	printf("data: %d\n",data);
//
//	return 0;
//}
//
//void memdump(void* virtual_address, int byte_count) {
//    char *p = virtual_address;
//    int offset;
//    for (offset = 0; offset < byte_count; offset++) {
//        printf("%02x", p[offset]);
//        if (offset % 4 == 3) { printf(" "); }
//    }
//    printf("\n");
//}
//
//unsigned long memCpy_DMA(FILE *fd, char *bufferIn, unsigned long elems)
//
//{
//    #define FIFO_LEN 4*1024*1024
//	unsigned long byteMoved  = 0;
//	unsigned long byteToMove = elems;
//	int i;
//
//	while(byteMoved < elems){
//		byteToMove = elems - byteMoved > FIFO_LEN ? FIFO_LEN : elems - byteMoved;
//		fwrite((char *)bufferIn, byteToMove, 1, fd);
//		byteMoved += byteToMove;
//	}
//
//	close(fd);
//
//	printf("finished transfer\n");
//
//	return byteMoved;
//}
//
//int init_zycap()
//{
//    int data;
//    int memfd,uio;
//    unsigned int buf_size;
//    char filename [100];
//    unsigned int* buf;
//    unsigned long  buf_addr;
//
//    int error_count;
//    unsigned char * uio_address;
//
//    FILE *fd;
//    void *mapped_base, *mapped_dev_base;
//    ubuf.sync_direction = 1;
//
//	size_t filesize = fsize("/home/root/mode.bin");
//
//
//    // calculate buffer required for bitstreams
//    if(calculate_buf_size("/home/root/") != 0){
//    	printf("Failed to read dir.\n");
//    	exit(0);
//    };
//
//    // configure udmabuf for sync
//    if ((fd  = open("/sys/class/udmabuf/udmabuf0/sync_direction", O_WRONLY)) != -1) {
//        sprintf(ubuf.attr, "%d", ubuf.sync_direction);
//        write(fd, ubuf.attr, strlen(ubuf.attr));
//        printf("configured udmabuf.\n");
//        close(fd);
//    }
//
//    if ((fd  = open("/sys/class/udmabuf/udmabuf0/size", O_RDONLY)) != -1) {
//      read(fd, ubuf.attr, 1024);
//      sscanf(ubuf.attr, "%d", &buf_size);
//      close(fd);
//    }
//
//    if ((fd  = open("/sys/class/udmabuf/udmabuf0/phys_addr", O_RDONLY)) != -1) {
//        read(fd, ubuf.attr, 1024);
//        sscanf(ubuf.attr, "%x", &buf_addr);
//        close(fd);
//    }
//
//    if(ubuf.buf_size > buf_size){
//    	printf("udmabuf (%d) not large enough for bitstreams (%d)...", buf_size, ubuf.buf_size);
//    	exit(0);
//    }
//
//    if ((fd  = open("/dev/udmabuf0", O_RDWR | O_SYNC)) != -1) {
//          buf = mmap(NULL, buf_size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
////          unsigned int* virtual_source_address  = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, 0x0e000000); // Memory map source address
//          // Write into bitstream
//          if (buf == (void *) -1) {
//                 printf("Can't map the memory to user space.\n");
//                 exit(0);
//          }
//          error_count = check_buf(buf, buf_size);
//          buf[0] = 0x23;
//
//          printf("errors: %d\n",error_count);
//    } else {
//    	printf("failed");
//    	exit(0);
//    }
//
//    config_csu();
//    // Check for ZyCAP mapped under UIO driver and available
//
//    unsigned int size = get_uio_size();
//
//
//    if ((uio = open("/dev/uio2", O_RDWR | O_SYNC)) != -1) {
//        if (uio == -1) {
//			printf("Can't open UIO.\n");
//			exit(0);
//        } else {
//            printf("preparing UIO\n");
//            printf("%08x\n",size);
//
////            uio_address = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, uio, 0x00A0000000);
////        	if (!uio_address) {
////        		printf("err");
////        		exit(0);
////        	}
//        }
//    }
//
//    int dh = open("/dev/mem", O_RDWR | O_SYNC); // Open /dev/mem which represents the whole physical memory
//    unsigned int* zycap = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, uio, 0x0); // Memory map AXI Lite register block
////    unsigned int* virtual_source_address  = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, uio, 0x0e000000); // Memory map source address
////    unsigned int* zycap_address = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, uio, 0x0000000000); // Memory map destination address
//
//
//	int bitstream = open("/home/root/mode.bin", O_RDONLY);
//	        if (bitstream == -1) {
//	        printf("Can't open bitsream.\n");
//	        exit(0);
//	    }
//
//
//	printf("Seeking %d...\n", bitstream);
//	unsigned int*src = mmap(NULL, filesize, PROT_READ, MAP_PRIVATE, bitstream, 0);
//	printf("Writing %d...\n",filesize);
//	memcpy(buf,src,filesize);
//
//
//	 printf("Source memory block:      "); memdump(buf, 128);
//	 printf("Buffer address: %x\n", buf_addr);
//		printf("Start timing...\n");
//
////	     unsigned long timestart = gettime();
//	     struct timespec start, finish;
//	     clock_gettime(CLOCK_REALTIME, &start);
//
////	 	int i = 0;
////	 	while(ubuf.buf_size > 0){
////	 		unsigned int length = 8192;
////	 		if(ubuf.buf_size < 8192){
////	 			length = ubuf.buf_size;
////	 		}
////
////	 		printf("Resetting DMA\n");
////	 		zycap_set(zycap, MM2S_CONTROL_REGISTER, 4);
////	 		zycap_status(zycap);
////
////	 		printf("Halting DMA\n");
////	 		zycap_set(zycap, MM2S_CONTROL_REGISTER, 0);
////	 		zycap_status(zycap);
////
////	 		printf("Writing source address...\n");
////	 		zycap_set(zycap, MM2S_START_ADDRESS, (buf_addr + i)); // Write source address
////	 //		zycap_set(zycap, MM2S_START_ADDRESS_MSB, buf_addr); // Write source address
////	 		zycap_status(zycap);
////
////	 		printf("Starting MM2S channel with all interrupts masked...\n");
////	 		zycap_set(zycap, MM2S_CONTROL_REGISTER, 0xf001);
////	 		zycap_status(zycap);
////
////	 		printf("Writing MM2S transfer length...\n");
////	 		printf("Buffer: %d\n",ubuf.buf_size);
////
////	 		zycap_set(zycap, MM2S_LENGTH, length);
////	 		printf("LENGTH: %d\n",zycap_get(zycap, MM2S_LENGTH));
////	 		zycap_status(zycap);
////
////	 		printf("Waiting for MM2S synchronization...\n");
////	 		zycap_sync(zycap);
////	 		zycap_status(zycap);
////
////	 		ubuf.buf_size = (ubuf.buf_size - length);
////	 		i += length;
////	 		printf("buf size: %d\n", ubuf.buf_size);
////	 	}
//
//	printf("Resetting DMA\n");
//	zycap_set(zycap, MM2S_CONTROL_REGISTER, 4);
//	zycap_status(zycap);
//
//	printf("Halting DMA\n");
//	zycap_set(zycap, MM2S_CONTROL_REGISTER, 0);
//	zycap_status(zycap);
//
//	printf("Writing source address...\n");
//	zycap_set(zycap, MM2S_START_ADDRESS, buf_addr); // Write source address
//	zycap_set(zycap, MM2S_START_ADDRESS_MSB, buf_addr); // Write source address
//	zycap_status(zycap);
//
//	printf("Starting MM2S channel with all interrupts masked...\n");
//	zycap_set(zycap, MM2S_CONTROL_REGISTER, 0xf001);
//	zycap_status(zycap);
//
//	printf("Writing MM2S transfer length...\n");
//	printf("Buffer: %d\n",ubuf.buf_size);
//	zycap_set(zycap, MM2S_LENGTH, 8192);
//	printf("LENGTH: %d\n",zycap_get(zycap, MM2S_LENGTH));
//	zycap_status(zycap);
//
//	printf("Waiting for MM2S synchronization...\n");
//	zycap_sync(zycap);
//	zycap_status(zycap);
//
//    clock_gettime(CLOCK_REALTIME, &finish);
//
//    long seconds = finish.tv_sec - start.tv_sec;
//    long ns = finish.tv_nsec - start.tv_nsec;
//
//    if (start.tv_nsec > finish.tv_nsec) { // clock underflow
//	--seconds;
//	ns += 1000000000;
//    }
//    printf("seconds without ns: %ld\n", seconds);
//    printf("nanoseconds: %ld\n", ns);
//    printf("total seconds: %e\n", (double)seconds + (double)ns/(double)1000000000);
//
//    printf("\nEND\n");
//
//	return memfd;
//}
//
//void cmpr (char *buffer1, char *buffer2)
//{
//    int ret;
//    ret = strcmp (buffer1, buffer2);
//    if (ret == 0)
//       printf("Both reads are identical\r\n");
//    else
//       printf("Failed!\r\n");
//}
//
//
//int Config_PR_Bitstream(char *bs_name)
//{
//    int bs_pres;
//    int pres_first;
//    int pres_last;
//    int size;
//	int bytesMoved;
//    bs_pres = check_bs_present(bs_list,bs_name);
//	char fname[100];
//	FILE *fd,*fp;
//	char *buffersaved;
//    if (bs_pres != -1 && bs_list[bs_pres].prev != NULL)            //The bitstream is already in the list and is not the most recently used
//    {
//    //	printf("bitstream in the list\n\r");
//        bs_list[bs_pres].prev->next = bs_list[bs_pres].next;
//        if(bs_list[bs_pres].next != NULL)
//        {
//            bs_list[bs_pres].next->prev = bs_list[bs_pres].prev;
//        }
//        pres_first = find_first_bs(bs_list);
//        bs_list[bs_pres].prev = NULL;
//        bs_list[bs_pres].next = &bs_list[pres_first];
//        bs_list[pres_first].prev = &bs_list[bs_pres];
//    }
//    else if(bs_pres == -1)
//    {
//    //	printf("bitstream not in the list\n\r");
//    	pres_last = find_last_bs(bs_list);
//		strcpy (fname,bs_name);
//		strcat (fname,".bin");
//		fp = fopen(fname,"rb");
//		if(!fp){
//			printf("Unable to open PR file\n");
//			return -1;
//		}
//    //printf("Reading PR file from flash\n\r");
//		fseek(fp,0,SEEK_END);
//		size=ftell(fp);
//		fseek(fp,0,SEEK_SET);
//
//
//		fread(bufferIn[pres_last].bitbuffer,1,size,fp);
//    //fseek(fp,0,SEEK_SET);
//    //buffersaved = (char *) malloc(size+1);
//	  //fread(buffersaved,1,size,fp);
//    close(fp);
//		//printf("Successfully transferred PR files from flash to DDR\n\r");
//    //cmpr(buffersaved, bufferIn[pres_last].bitbuffer);
//		pres_first = find_first_bs(bs_list);
//		bs_list[pres_last].prev->next = NULL;   //make the second last element as the last element
//		strcpy(bs_list[pres_last].name,bs_name);
//		bs_list[pres_last].size = size;
//		bs_list[pres_last].prev = NULL;
//		bs_list[pres_last].next = &bs_list[pres_first];
//		bs_list[pres_first].prev = &bs_list[pres_last];
//	}
////   print_schedule(bs_list);
//    pres_first = find_first_bs(bs_list);
//    //printf("Current bs %s , Size %d, Address %x \r\n",bs_list[pres_first].name,bs_list[pres_first].size,bs_list[pres_first].addr);
//	fd = glbs.fuio;
////  unsigned long timestart = gettime();
////	bytesMoved = memCpy_DMA(fd,bufferIn[pres_first].bitbuffer,bs_list[pres_first].size);
////	unsigned long timeend = gettime();
////  unsigned long time = timeend - timestart;
////  printf("%s\t%ld\t%ld\t%f\t\n", "DMA:Op", bs_list[pres_first].size, time, bs_list[pres_first].size * 1.0 / time);
//	return bytesMoved;
//}
//
//int conf_bit (char *bs_name)
//{
//
//    int size;
//	int bytesMoved;
//	char fname[100];
//	FILE *fd,*fp;
//	char *buffersaved;
//
//		strcpy (fname,bs_name);
//		strcat (fname,".bin");
//		fp = fopen(fname,"rb");
//		if(!fp){
//			printf("Unable to open PR file\n");
//			return -1;
//		}
//    printf("Reading PR file from flash\n\r");
//		fseek(fp,0,SEEK_END);
//		size=ftell(fp);
//		fseek(fp,0,SEEK_SET);
//		//bufferIn = (char *) malloc(size+1);
//
//		/*if(!bufferIn){
//			printf("Unable to allocate buffer for data\n");
//			fclose(fp);
//			return -1;
//		}*/
//
//		fread(buffersaved,1,size,fp);
//    close(fp);
//
//		printf("Successfully transferred PR files from flash to DDR\n\r");
//
//   	fd = fopen("/dev/zycap-vivado", "w+");
//    if(fd < 0)
//    {
//       printf("\n cannot get the file descriptor \n");
//       return -1;
//    }
////  	bytesMoved = memCpy_DMA(fd,buffersaved,size);
//    return bytesMoved;
//}
//
//
//int close_zycap ()
//{
//  int i;
//	free (bs_list);
//  free (bufferIn);
//	return 1;
//}
//
//int Prefetch_PR_Bitstream(char *bs_name)
//{
//    int bs_pres;
//    int pres_first;
//    int pres_last;
//    int size;
//	  FILE *fd,*fp;
//	  char fname[100];
//    bs_pres = check_bs_present(bs_list,bs_name);
//    if (bs_pres != -1 && bs_list[bs_pres].prev != NULL)            //The bitstream is already in the list and is not the most recently used
//    {
//        bs_list[bs_pres].prev->next = bs_list[bs_pres].next;
//        if(bs_list[bs_pres].next != NULL)
//        {
//            bs_list[bs_pres].next->prev = bs_list[bs_pres].prev;
//        }
//        pres_first = find_first_bs(bs_list);
//        bs_list[bs_pres].prev = NULL;
//        bs_list[bs_pres].next = &bs_list[pres_first];
//        bs_list[pres_first].prev = &bs_list[bs_pres];
//    }
//    else if(bs_pres == -1)
//    {
//    	pres_last = find_last_bs(bs_list);
//    	strcpy (fname,bs_name);
//		  strcat (fname,".bin");
//		  fp = fopen(fname,"rb");
//		  if(!fp){
//		  	printf("Unable to open PR file\n");
//			  return -1;
//		  }
//    //printf("Reading PR file from flash\n\r");
//		  fseek(fp,0,SEEK_END);
//		  size=ftell(fp);
//		  fseek(fp,0,SEEK_SET);
//
//		  fread(bufferIn[pres_last].bitbuffer,1,size,fp);
//      close(fp);
//	  	//printf("Successfully transferred PR files from flash to DDR\n\r");
//      //cmpr(buffersaved, bufferIn[pres_last].bitbuffer);
//	  	pres_first = find_first_bs(bs_list);
//  		bs_list[pres_last].prev->next = NULL;   //make the second last element as the last element
//	  	strcpy(bs_list[pres_last].name,bs_name);
//  		bs_list[pres_last].size = size;
//  		bs_list[pres_last].prev = NULL;
//  		bs_list[pres_last].next = &bs_list[pres_first];
//  		bs_list[pres_first].prev = &bs_list[pres_last];
//    }
//	return 1;
//}
//
//int Check_Available_Bitstreams(char *path){
//	int file_count = 0;
//	DIR * dirp;
//	struct dirent * entry;
//
//	dirp = opendir(path); /* There should be error handling after this */
//	while ((entry = readdir(dirp)) != NULL) {
//	    if (entry->d_type == DT_REG) { /* If the entry is a regular file */
//	    	printf("Name: %s\n", entry->d_name);
//	         file_count++;
//	    }
//	}
//	closedir(dirp);
//	return file_count;
//}
//
//
//int main(int argc, char *argv[])
//{
//    printf("ZyCAP v0.0.2\n");
//
//    init_zycap();
//
//    printf("%d",argc);
//	return 0;
//}
//

/**
 * Proof of concept offloaded memcopy using AXI Direct Memory Access v7.1
 */

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/mman.h>

#define MM2S_CONTROL_REGISTER 0x00
#define MM2S_STATUS_REGISTER 0x04
#define MM2S_START_ADDRESS 0x18
#define MM2S_LENGTH 0x28

#define S2MM_CONTROL_REGISTER 0x30
#define S2MM_STATUS_REGISTER 0x34
#define S2MM_DESTINATION_ADDRESS 0x48
#define S2MM_LENGTH 0x58

unsigned int dma_set(unsigned int* dma_virtual_address, int offset, unsigned int value) {
    dma_virtual_address[offset>>2] = value;
}

unsigned int dma_get(unsigned int* dma_virtual_address, int offset) {
    return dma_virtual_address[offset>>2];
}

int dma_mm2s_sync(unsigned int* dma_virtual_address) {
    unsigned int mm2s_status =  dma_get(dma_virtual_address, MM2S_STATUS_REGISTER);
    while(!(mm2s_status & 1<<12) || !(mm2s_status & 1<<1) ){
//        dma_s2mm_status(dma_virtual_address);
        dma_mm2s_status(dma_virtual_address);

        mm2s_status =  dma_get(dma_virtual_address, MM2S_STATUS_REGISTER);
    }
}

void dma_s2mm_status(unsigned int* dma_virtual_address) {
    unsigned int status = dma_get(dma_virtual_address, S2MM_STATUS_REGISTER);
    printf("Stream to memory-mapped status (0x%08x@0x%02x):", status, S2MM_STATUS_REGISTER);
    if (status & 0x00000001) printf(" halted"); else printf(" running");
    if (status & 0x00000002) printf(" idle");
    if (status & 0x00000008) printf(" SGIncld");
    if (status & 0x00000010) printf(" DMAIntErr");
    if (status & 0x00000020) printf(" DMASlvErr");
    if (status & 0x00000040) printf(" DMADecErr");
    if (status & 0x00000100) printf(" SGIntErr");
    if (status & 0x00000200) printf(" SGSlvErr");
    if (status & 0x00000400) printf(" SGDecErr");
    if (status & 0x00001000) printf(" IOC_Irq");
    if (status & 0x00002000) printf(" Dly_Irq");
    if (status & 0x00004000) printf(" Err_Irq");
    printf("\n");
}

void dma_mm2s_status(unsigned int* dma_virtual_address) {
    unsigned int status = dma_get(dma_virtual_address, MM2S_STATUS_REGISTER);
    printf("Memory-mapped to stream status (0x%08x@0x%02x):", status, MM2S_STATUS_REGISTER);
    if (status & 0x00000001) printf(" halted"); else printf(" running");
    if (status & 0x00000002) printf(" idle");
    if (status & 0x00000008) printf(" SGIncld");
    if (status & 0x00000010) printf(" DMAIntErr");
    if (status & 0x00000020) printf(" DMASlvErr");
    if (status & 0x00000040) printf(" DMADecErr");
    if (status & 0x00000100) printf(" SGIntErr");
    if (status & 0x00000200) printf(" SGSlvErr");
    if (status & 0x00000400) printf(" SGDecErr");
    if (status & 0x00001000) printf(" IOC_Irq");
    if (status & 0x00002000) printf(" Dly_Irq");
    if (status & 0x00004000) printf(" Err_Irq");
    printf("\n");
}

void memdump(void* virtual_address, int byte_count) {
    char *p = virtual_address;
    int offset;
    for (offset = 0; offset < byte_count; offset++) {
        printf("%02x", p[offset]);
        if (offset % 4 == 3) { printf(" "); }
    }
    printf("\n");
}


int main() {
//    int dh = open("/dev/uio", O_RDWR | O_SYNC); // Open /dev/mem which represents the whole physical memory
    int fh = open("/dev/mem", O_RDWR | O_SYNC); // Open /dev/mem which represents the whole physical memory

    unsigned int* virtual_address = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, fh, 0xa0000000); // Memory map AXI Lite register block
    unsigned int* virtual_source_address  = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, fh, 0x6fd00000); // Memory map source address
//    unsigned int* virtual_destination_address = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, 0x0f000000); // Memory map destination address

    virtual_source_address[0]= 0x11223344; // Write random stuff to source block
//    memset(virtual_destination_address, 0, 32); // Clear destination block

    printf("Source memory block:      "); memdump(virtual_source_address, 256);
//    printf("Destination memory block: "); memdump(virtual_destination_address, 32);

    printf("Resetting DMA\n");
//    dma_set(virtual_address, S2MM_CONTROL_REGISTER, 4);
    char * ctl = 4;
    dma_set(virtual_address, MM2S_CONTROL_REGISTER, ctl);
//    dma_s2mm_status(virtual_address);
    dma_mm2s_status(virtual_address);

    printf("Halting DMA\n");
//    dma_set(virtual_address, S2MM_CONTROL_REGISTER, 0);
    dma_set(virtual_address, MM2S_CONTROL_REGISTER, (char *) 0);
//    dma_s2mm_status(virtual_address);
    dma_mm2s_status(virtual_address);

//    printf("Writing destination address\n");
//    dma_set(virtual_address, S2MM_DESTINATION_ADDRESS, 0x0f000000); // Write destination address
//    dma_s2mm_status(virtual_address);

    printf("Writing source address...\n");
    dma_set(virtual_address, MM2S_START_ADDRESS, (char *) 0x0e000000); // Write source address
    dma_mm2s_status(virtual_address);

//    printf("Starting S2MM channel with all interrupts masked...\n");
//    dma_set(virtual_address, S2MM_CONTROL_REGISTER, 0xf001);
//    dma_s2mm_status(virtual_address);

    printf("Starting MM2S channel with all interrupts masked...\n");
    dma_set(virtual_address, MM2S_CONTROL_REGISTER, (char *) 0xf001);
    dma_mm2s_status(virtual_address);

//    printf("Writing S2MM transfer length...\n");
//    dma_set(virtual_address, S2MM_LENGTH, 32);
//    dma_s2mm_status(virtual_address);

    printf("Writing MM2S transfer length...\n");
    dma_set(virtual_address, MM2S_LENGTH, (char *) 9000);
    dma_mm2s_status(virtual_address);

    printf("Waiting for MM2S synchronization...\n");
    dma_mm2s_sync(virtual_address);

//    printf("Waiting for S2MM sychronization...\n");
//    dma_s2mm_sync(virtual_address); // If this locks up make sure all memory ranges are assigned under Address Editor!

//    dma_s2mm_status(virtual_address);
    dma_mm2s_status(virtual_address);

    printf("\nCompleted\n");
}
