/**
 * @file zycap.hpp
 * @date Saturday, December 05, 2015 at 10:14:44 AM EST
 * @author Alex Bucknall (Bucknalla)
 *
 * This file defines the ZyCAP interface.
 **/

#pragma once

#include <json.hpp>
#include <string>
#include <libaxidma.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <assert.h>

#include <fcntl.h>	   // Flags for open()
#include <sys/stat.h>  // Open() system call
#include <sys/types.h> // Types for open()
#include <unistd.h>	   // Close() system call
#include <string.h>	   // Memory setting and copying
#include <iostream>
#include <unordered_map>
#include <getopt.h> // Option parsing
#include <errno.h>	// Error codes

using namespace std;
using json = nlohmann::json;

class Util
{
public:
	inline bool checkExists(const string &path);
};

class DMA
{
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

public:
	char *input_path, *output_path;
	struct dma_transfer trans;

	/* Constructors */
	DMA();

	int setup(int in_channel, int out_channel);

	int transfer();

	int loadBitstream(string bitstream);
	int allocateBuffers(char *buf_in, int size_in, char *buf_out, int size_out);
	int transferData();
	int setInput(char *&buf);
	int setOutput(char *&buf);
	void *setRegisters(const char *filepath, long offset, long size);

private:
	/* Variables */

	Util util;
	int rc;
	axidma_dev_t axidma_dev;
	struct stat input_stat;
	const array_t *tx_chans, *rx_chans;
};

class Config
{
	enum Type
	{
		partial,
		full
	};

	struct configuration
	{
		string slug;
		string overlay;
		string bitstream;
		bool state;
		Type type;
	};

public:
	unordered_map<string, configuration> config_store;

	int load(configuration &config);
	int unload(configuration config, bool remove = false);
	int loadJson(ifstream &file);
	int listConfigs();

	bool state(configuration config);

	Config();

private:
	Util util;
	string hardware_dir = "/lib/firmware";
	int checkExists(const string &path);
	int loadOverlay(const string &overlay);
	int removeOverlay();
	int loadBitstream(ifstream &file);
	int unloadJson(ifstream &file);
};

class Zycap
{

public:
	/* Variables */

	string hardware_dir;
	string config_dir;
	int loaded;

	/* Constructors */
	Zycap(string hardware_dir = "/lib/firmware", string config_dir = "/lib/configs");
	~Zycap();

	/* Methods */
	int configCSU(bool mode);
	vector<string> listConfigs();
	int load(string config);

	DMA dma;

private:
	Util util;
	Config config;
	short slave_axis = 0;
	short master_axis = 0;

	int setupLogging(int level = 0);
	int setupConfigs();
	int setupOverlays();
	int loadKernel();
	int setAXISSwitch(short slave, short master);
};
