/**
 * @file util.c
 * @date Sunday, December 06, 2015 at 01:10:08 AM EST
 * @author Brandon Perez (bmperez)
 * @author Jared Choi (jaewonch)
 *
 * This file contains miscalaneous utilities for out system.
 *
 * @bug No known bugs.
 **/

#ifndef UTIL_H_
#define UTIL_H_

#include <sys/time.h> // Timing functions and definitions

// Command-line parsing utilities
int parse_int(char option, char *arg_str, int *data);
int parse_double(char option, char *arg_str, double *data);
int parse_resolution(char option, char *arg_str, int *height, int *width,
					 int *depth);

// File operation utilities
int robust_read(int fd, char *buf, int buf_size);
int robust_write(int fd, char *buf, int buf_size);

// A convenient structure to carry information around about the transfer
struct dma_transfer
{
	int input_fd;		// The file descriptor for the input file
	int input_channel;	// The channel used to send the data
	int input_size;		// The amount of data to send
	char *input_buf;	// The buffer to hold the input data
	int output_fd;		// The file descriptor for the output file
	int output_channel; // The channel used to receive the data
	int output_size;	// The amount of data to receive
	char *output_buf;	// The buffer to hold the output
};

// Converts a tval struct to a double value of the time in seconds
#define TVAL_TO_SEC(tval) \
	(((double)(tval).tv_sec) + (((double)(tval).tv_usec) / 1000000.0))

// Converts a byte (integral) value to mebibytes (floating-point)
#define BYTE_TO_MIB(size) (((double)(size)) / (1024.0 * 1024.0))

// Converts a mebibyte (floating-point) value to bytes (integral)
#define MIB_TO_BYTE(size) ((size_t)((size)*1024.0 * 1024.0))

#endif /* UTIL_H_ */
