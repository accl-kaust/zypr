# Notes

`udmabuf.ko` is generated into `/lib/modules/4.14.0-xilinx-v2018.3/extra`

> :warning: Do not forget to run `--config-hardware`

Enable settings for USB to Ethernet:

```bash
petalinux-config -c kernel
```

Kernel Config GUI:

```bash
Device Drivers
   -> USB Support
          <*> USB Modem (CDC ACM) support

Device Drivers
   -> USB Support
            -> USB Gadget Support
                     <m> CDC Composite Device (Ethernet and ACM)

Device Drivers
    -> Network device support
              -> USB Network Adapters
                        <*> Multipurpose USB Networking Framework
                                 ... add your chipset if you see it
```

Add to `petalinuxbsp.conf` - `MACHINE_FEATURES_remove_ultra96-zynqmp = "mipi"`

https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842279/Build+Device+Tree+Blob#BuildDeviceTreeBlob-GenerateaDeviceTreeSource(.dts/.dtsi)filesfromSDK

### Configuring Application

Ensure PMU firmware is compiled with `SECURE_VAL_ACCESS` enabled.

``` bash
# Set ICAP control by releasing PCAP control
echo 0xFFCA3008 0xFFFFFFFF 0 > /sys/firmware/zynqmp/config_reg
echo 0xFFCA3008 > /sys/firmware/zynqmp/config_reg
cat /sys/firmware/zynqmp/config_reg
# Load xilinx_axidma driver
insmod /lib/modules/4.14.0-xilinx-v2018.3/extra/xilinx-axidma.ko
# Create output file for buffer
touch output.bin
# Check reg for mode_a-config_a @ 0xA0001000
devmem 0xA0001000
# Run reconfig
./xilinx-dma.elf mode2.bin output.bin
# Check reg for mode_a-config_b @ 0xA0001000
devmem 0xA0001000
```


Add Dynamic DTC overlays with https://github.com/ikwzm/dtbocfg