#include "zycap.hpp"

#include <fstream>
#include <iostream>
#include <dirent.h>
#include <iostream>
#include <sys/stat.h>
#include <logging.hpp>
#include <util.h>
#include <sys/mman.h>
#include <algorithm>
#include <cstddef> // std::size_t
#include <uio.hpp>
/*----------------------------------------------------------------------------
 * Utilities
 *----------------------------------------------------------------------------*/

inline bool Util::checkExists(const string &path)
{
    LOG_F(INFO, "Checking %s", path.c_str());
    struct stat buffer;
    return (stat(path.c_str(), &buffer) == 0);
}

/*----------------------------------------------------------------------------
 * DMA
 *----------------------------------------------------------------------------*/

DMA::DMA()
{
    LOG_F(INFO, "DMA Class Loaded");
    //    this->setup(0,0);
}

int DMA::setInput(char *&buf)
{
    this->trans.input_buf = buf;

    return 0;
};

int DMA::setOutput(char *&buf)
{
    this->trans.output_buf = buf;

    return 0;
};

//int DMA::

int DMA::setup(int in_channel, int out_channel)
{
    int status = 0;
    const array_t *tx_chans, *rx_chans;

    this->axidma_dev = axidma_init();
    if (this->axidma_dev == NULL)
    {
        LOG_F(ERROR, "Error: Failed to initialize the AXI DMA device.\n");
        assert(close(trans.input_fd) == 0);
        return 1;
    }
    // Get the tx and rx channels if they're not already specified
    tx_chans = axidma_get_dma_tx(this->axidma_dev);
    if (tx_chans->len < 1)
    {
        LOG_F(ERROR, "Error: No tx channels were found.\n");
        axidma_destroy(this->axidma_dev);
        status = 1;
    }
    rx_chans = axidma_get_dma_rx(this->axidma_dev);
    if (rx_chans->len < 1)
    {
        LOG_F(ERROR, "Error: No rx channels were found.\n");
        axidma_destroy(this->axidma_dev);
        status = 1;
    }
    LOG_F(INFO, "TX: %d | RX: %d\n", tx_chans->data[0], rx_chans->data[0]);

    //    if (this->trans.input_channel == -1 && this->trans.output_channel == -1) {
    this->trans.input_channel = tx_chans->data[0];
    this->trans.output_channel = rx_chans->data[0];
    //        LOG_F(INFO, "TX: %d | RX: %d\n", tx_chans->data[0], rx_chans->data[0]);
    //    }

    return status;
}

int DMA::allocateBuffers(char *buf_in, int size_in, char *buf_out, int size_out)
{

    this->setup(0, 0);
    this->trans.input_buf = (char *)axidma_malloc(this->axidma_dev, size_in);
    this->trans.input_size = size_in;
    memcpy(this->trans.input_buf, buf_in, size_in);
    if (this->trans.input_buf == NULL)
    {
        fprintf(stderr, "Failed to allocate the input buffer.\n");
        rc = -ENOMEM;
        return rc;
    }

    // Allocate a buffer for the output file
    this->trans.output_buf = (char *)axidma_malloc(this->axidma_dev, size_out);
    this->trans.output_size = size_out;
    memcpy(this->trans.output_buf, buf_out, size_out);
    if (this->trans.output_buf == NULL)
    {
        rc = -ENOMEM;
        axidma_free(this->axidma_dev, this->trans.input_buf, this->trans.input_size);
        return 1;
    }

    return 0;
}

int DMA::transfer()
{
    int rc;
    rc = axidma_twoway_transfer(this->axidma_dev, this->trans.input_channel, this->trans.input_buf,
                                this->trans.input_size, NULL, this->trans.output_channel, this->trans.output_buf,
                                this->trans.output_size, NULL, true);
    if (rc < 0)
    {
        fprintf(stderr, "DMA read write transaction failed.\n");
        return 1;
    }
    return 0;
}

void *DMA::setRegisters(const char *filepath, long offset, long size)
{
    int fd = open(filepath, O_RDWR | O_SYNC);
    LOG_F(INFO, "Mapping filepath: %s, offset: %ld, size: %ld\n", filepath, offset, size);
    if (fd < 0)
    {
        LOG_F(ERROR, "Couldn't load file");
        exit(-1);
    }
    return mmap(NULL, size, PROT_WRITE | PROT_READ, MAP_SHARED, fd, offset);
}

int DMA::loadBitstream(string bitstream)
{
    int rc;
    struct stat input_stat;
    const array_t *tx_chans;

    cout << bitstream << endl;

    cout << "Page size: " << sysconf(_SC_PAGE_SIZE) << endl;

    this->trans.input_fd = open(bitstream.c_str(), O_RDONLY);
    if (this->trans.input_fd < 0)
    {
        LOG_F(ERROR, "Error opening input file.");
        rc = 1;
        return 1;
    }

    // Get the size of the input file
    if (fstat(trans.input_fd, &input_stat) < 0)
    {
        LOG_F(ERROR, "Unable to get file statistics.");
        rc = 1;
        return rc;
    }

    if (input_stat.st_size <= 0)
    {
        LOG_F(ERROR, "File is empty.");
        rc = 1;
        return rc;
    }

    this->trans.input_size = input_stat.st_size;

    // Allocate a buffer for the input file, and read it into the buffer
    this->trans.input_buf = (char *)axidma_malloc(this->axidma_dev, this->trans.input_size);
    if (this->trans.input_buf == NULL)
    {
        LOG_F(ERROR, "Failed to allocate the input buffer.");
        rc = -ENOMEM;
        return rc;
    }

    tx_chans = axidma_get_dma_tx(this->axidma_dev);
    if (tx_chans->len < 1)
    {
        LOG_F(ERROR, "No transmit channels were found.");
        rc = -ENODEV;
        return rc;
    }

    if (this->trans.input_channel == -1)
    {
        LOG_F(INFO, "Using default input tx channel.");
        this->trans.input_channel = tx_chans->data[0];
    }

    LOG_F(INFO, "Transmit Channel: %d", this->trans.input_channel);
    LOG_F(INFO, "Input File Size: %.2f MiB", BYTE_TO_MIB(this->trans.input_size));

    rc = robust_read(this->trans.input_fd, this->trans.input_buf, this->trans.input_size);
    if (rc < 0)
    {
        LOG_F(ERROR, "Unable to read in input buffer.");
        axidma_free(this->axidma_dev, this->trans.input_buf, this->trans.input_size);
        return rc;
    }

    rc = axidma_oneway_transfer(this->axidma_dev, 0, this->trans.input_buf, this->trans.input_size, true);

    //    rc = axidma_twoway_transfer(this->axidma_dev, trans->input_channel, trans->input_buf,
    //             trans->input_size, NULL, trans->output_channel, trans->output_buf,
    //             trans->output_size, NULL, true);

    if (rc < 0)
    {
        LOG_F(ERROR, "DMA read write transaction failed.\n");
        axidma_free(this->axidma_dev, this->trans.input_buf, this->trans.input_size);
    }

    axidma_destroy(this->axidma_dev);
    assert(close(trans.input_fd) == 0);

    return 0;
};

int DMA::transferData()
{
    int rc;

    // Allocate a buffer for the input file, and read it into the buffer
    this->trans.input_buf = (char *)axidma_malloc(this->axidma_dev, this->trans.input_size);
    if (this->trans.input_buf == NULL)
    {
        fprintf(stderr, "Failed to allocate the input buffer.\n");
        rc = -ENOMEM;
        goto ret;
    }
    rc = robust_read(this->trans.input_fd, this->trans.input_buf, this->trans.input_size);
    if (rc < 0)
    {
        perror("Unable to read in input buffer.\n");
        axidma_free(this->axidma_dev, this->trans.input_buf, this->trans.input_size);
        return rc;
    }

    // Allocate a buffer for the output file
    this->trans.output_buf = (char *)axidma_malloc(this->axidma_dev, this->trans.output_size);
    if (this->trans.output_buf == NULL)
    {
        rc = -ENOMEM;
        goto free_input_buf;
    }

    // Perform the transfer
    // Perform the main transaction
    rc = axidma_twoway_transfer(this->axidma_dev, this->trans.input_channel, this->trans.input_buf,
                                this->trans.input_size, NULL, this->trans.output_channel, this->trans.output_buf,
                                this->trans.output_size, NULL, true);
    if (rc < 0)
    {
        fprintf(stderr, "DMA read write transaction failed.\n");
        goto free_output_buf;
    }

    // Write the data to the output file
    printf("Writing output data to `%s`.\n", output_path);
    rc = robust_write(this->trans.output_fd, this->trans.output_buf, this->trans.output_size);

free_output_buf:
    axidma_free(this->axidma_dev, this->trans.output_buf, this->trans.output_size);
free_input_buf:
    axidma_free(this->axidma_dev, this->trans.input_buf, this->trans.input_size);
ret:
    return rc;
}

/*----------------------------------------------------------------------------
 * Configuration
 *----------------------------------------------------------------------------*/

Config::Config()
{
    LOG_F(INFO, "Configuration Class Loaded.");
}

/* Public */

int Config::load(configuration &config)
{

    this->loadOverlay((this->hardware_dir + "/" + config.overlay));

    config.state = true;
    return 0;
}

int Config::loadOverlay(const string &overlay)
{
    struct stat sb;
    char cmd[512];

    size_t found = overlay.find_last_of("/\\");
    string overlay_file = overlay.substr(found + 1);
    found = overlay_file.find_last_of(".");
    string overlay_name = overlay_file.substr(0, found);

    string folder = "/configfs/device-tree/overlays/full";
    if (((stat(folder.c_str(), &sb) == 0) && S_ISDIR(sb.st_mode)))
    {
        LOG_F(ERROR, "Error: Overlay already exists in the live tree\n\r");
        return 1;
    }

    folder = "/configfs/device-tree/";
    if (((stat(folder.c_str(), &sb) == 0) && S_ISDIR(sb.st_mode)))
    {
    }
    else
    {
        system("mkdir -p /configfs");
        system("mount -t configfs configfs /configfs");
    }

    cout << overlay << endl;

    snprintf(cmd, sizeof(cmd), "mkdir -p /sys/kernel/config/device-tree/overlays/%s", overlay_name.c_str());
    system(cmd);

    snprintf(cmd, sizeof(cmd), "cat %s > /sys/kernel/config/device-tree/overlays/%s/dtbo", overlay.c_str(), overlay_name.c_str());
    system(cmd);

    return 0;
};

int Config::unload(configuration config, bool remove)
{

    return 0;
}

int Config::listConfigs()
{
    for (auto x : this->config_store)
        LOG_F(INFO, "Config: %s Bitstream: %s", x.first.c_str(), x.second.bitstream.c_str());
    // cout << "Config: " << x.first << " Bitstream: " << x.second.bitstream << endl;
    return 0;
}

bool Config::state(configuration config)
{
    return config.state;
};

/* Private */

int Config::loadJson(ifstream &file)
{
    try
    {
        json jf = json::parse(file);
        Type tmp_type;
        bool valid;

        if (jf["slug"] == "partial")
        {
            tmp_type = partial;
        }
        else
        {
            tmp_type = full;
        }

        configuration tmp = {
            jf["slug"],
            jf["overlay"],
            jf["bitstream"],
            false,
            tmp_type};

        this->config_store[jf["slug"]] = tmp;
        valid = util.checkExists(this->hardware_dir + "/" + jf["bitstream"].get<std::string>());

        if (valid != true)
        {
            throw std::runtime_error("Could not find bitstream!");
        }
        // it = this->config_store.begin();
    }
    catch (json::exception &e)
    {
        LOG_F(ERROR, "JSON Error: %s", e.what());
        return 1;
    }
    catch (std::runtime_error &e)
    {
        LOG_F(ERROR, "File Error: %s", e.what());
        return 1;
    }
    return 0;
};

int Config::unloadJson(ifstream &file)
{

    return 0;
};

int Config::removeOverlay()
{
    struct stat sb;
    const string folder = "/configfs/device-tree/overlays/full";
    if (((stat(folder.c_str(), &sb) == 0) && S_ISDIR(sb.st_mode)))
    {
        system("rmdir /configfs/device-tree/overlays/full");
    }
    return 0;
};

/*----------------------------------------------------------------------------
 * ZyCAP
 *----------------------------------------------------------------------------*/

// Zycap constructor, configures CSU for ICAP and prepares drivers
Zycap::Zycap(string hardware_dir, string config_dir) : hardware_dir(hardware_dir), config_dir(config_dir)
{
    int status;

    this->setupLogging(true);
    LOG_F(INFO, "Starting ZyCAP PR Manager (C++)");

    status = this->configCSU(false); // todo: change this back to true
    if (status != 0)
    {
        LOG_F(ERROR, "Failed to configure CSU!");
    }

    status = this->setupConfigs();
    if (status != 0)
    {
        LOG_F(ERROR, "Failed to load configurations!");
    }

    status = this->setupOverlays();
    if (status != 0)
    {
        LOG_F(ERROR, "Failed to prepare overlays!");
    }
}

// Zycap deconstructor
Zycap::~Zycap(){

};

int Zycap::load(string target)
{
    vector<string> available_configs = this->listConfigs();
    //    cout << "\nSize : " << available_configs.size();

    if (find(available_configs.begin(), available_configs.end(), target) != available_configs.end())
    {
        LOG_F(INFO, "Found %s!", target.c_str());

        auto it = this->config.config_store.find(target);

        if (it == this->config.config_store.end())
        {
            LOG_F(ERROR, "Could not find %s in config store!", target.c_str());
            return 1;
        }
        else
        {
            cout << it->second.overlay << endl;
            cout << (this->hardware_dir + "/" + it->second.bitstream) << endl;
            // load bitstream first
            this->dma.setup(0, 0);
            this->dma.loadBitstream((this->hardware_dir + it->second.bitstream));
            //			this->dma.transfer(bitstream);
            this->config.load(it->second);
        }
    }
    else
    {
        LOG_F(ERROR, "Could not find %s!", target.c_str());
        return 1;
    }
    return 0;
}

// Set Logging Level
int Zycap::setupLogging(int level)
{
    int argc = 2;
    char argv0[] = "-v";
    char argv1[] = "0";
    char *argv[] = {argv0, argv1, NULL};

    loguru::init(argc, argv);

    return 0;
}

int Zycap::setAXISSwitch(short slave, short master)
{

    return 0;
}

int Zycap::setupConfigs()
{
    string ext(".json");
    LOG_F(INFO, "Setting up Configs");
    LOG_F(INFO, "Searching in: %s", this->config_dir.c_str());
    if (auto dir = opendir(this->config_dir.c_str()))
    {
        while (auto f = readdir(dir))
        {
            if (!f->d_name || f->d_name[0] == '.')
                continue; // Skip hidden files
            else
            {
                LOG_F(INFO, "Found config: %s", f->d_name);
                ifstream jsonConfig((this->config_dir + f->d_name), ifstream::in);

                if (jsonConfig.is_open())
                {
                    LOG_F(INFO, "Parsing config: %s", (this->config_dir + f->d_name).c_str());
                    config.loadJson(jsonConfig);
                }
                else
                {
                    return 1;
                }
                jsonConfig.close();
            }
        }
        closedir(dir);
    }

    config.listConfigs();
    return 0;
}

int Zycap::setupOverlays()
{
    struct stat sb;
    const string folder = "/configfs/device-tree/";

    LOG_F(INFO, "Setting up DT Overlays");
    if (((stat(folder.c_str(), &sb) == 0) && S_ISDIR(sb.st_mode)))
    {
    }
    else
    {
        system("mkdir /configfs");
        system("mount -t configfs configfs /configfs");
    }
    return 0;
}

int Zycap::loadKernel()
{
    if (util.checkExists("/dev/axidma") != 1)
    {
        // prepare for DT overlay
        system("mount -t configfs none /sys/kernel/config");
        if (system("insmod /lib/modules/4.19.0-xilinx-v2019.2/extra/xilinx-axidma.ko") == -1)
        {
            return 1;
        }
    }
    else
    {
        system("lsmod | grep axi");
    }
    return 0;
}

vector<string> Zycap::listConfigs()
{
    vector<string> configs;
    for (auto x : this->config.config_store)
    {
        configs.insert(configs.end(), x.first);
    }

    return configs;
}

int Zycap::configCSU(bool mode)
{
    string res, data, pcap_mode;
    string csu_reg = "/sys/firmware/zynqmp/config_reg";
    pcap_mode = to_string(mode);

    ifstream pcap_in(csu_reg.c_str());
    if (pcap_in.is_open())
    {
        system(("echo 0xffca3008 0xff " + pcap_mode + " > " + csu_reg).c_str());
        pcap_in >> res;
        LOG_F(INFO, "PCAP set to %s", res.c_str());
        //        cout << "PCAP set to: "<< res << endl;
        pcap_in.close();
    }
    else
    {
        cout << "Failed to open csu!\n";
        return -1;
    }

    return 0;
}
