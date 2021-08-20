# Notes

## Video streaming 

[capture video stream from C](https://gist.github.com/mike168m/6dd4eb42b2ec906e064d)

## Boot sequence

http://lucaceresoli.net/wp-content/uploads/zynqmp-linux.pdf

## UIO

https://forums.xilinx.com/t5/Embedded-Linux/Custom-Hardware-with-UIO/td-p/804303

## Petalinux Commands

```bash
# HWDEF
petalinux-config --get-hw-description=../
petalinux-build
petalinux-package --boot --fsbl /home/plnx/project/fsbl.elf --u-boot /home/plnx/project/u-boot.elf --pmufw /home/plnx/project/pmufw.elf --atf /home/plnx/project/bl31.elf --fpga --force
petalinux-build --sdk
petalinux-package --sysroot
```

```bash
petalinux-package --boot --fsbl ./images/linux/zynqmp_fsbl.elf --u-boot ./images/linux/u-boot.elf --pmufw ../pmufw.elf --atf ./images/linux/bl31.elf --fpga --force
```

## DTG Overlay

https://joshis1.github.io/embedded_linux/2020/04/01/Linux-Device-tree-overlay.html

## R/W Register

```bash
# read
devmem $ADDRESS $WIDTH
# write
devmem $ADDRESS $WIDTH $VALUE
```

## Set AXI Stream Interconnect

```bash
# For M00 -> S00
devmem 0xa0010040 32 0x0 
devmem 0xa0010044 32 0x80000000
devmem 0xa0010000 32 0x2 

# For S00 -> M00
devmem 0xa0020040 32 0x0 
devmem 0xa0020044 32 0x80000000
devmem 0xa0020000 32 0x2 

# For M00 -> S01
devmem 0xa0010040 32 0x80000000
devmem 0xa0010044 32 0x0 
devmem 0xa0010000 32 0x2 

# For S00 -> M01
devmem 0xa0020040 32 0x1 
devmem 0xa0020000 32 0x2 

# IP Core
devmem 0xa0030000 32 0x81
devmem 0xa0030010 32 1080  # Rows
devmem 0xa0030018 32 1920 # Cols
devmem 0xa0030020 32 2160
devmem 0xa0030028 32 3840

# Demux
devmem 0xa0030040 32 0x0
devmem 0xa0030000 32 0x2

# Mux
devmem 0xa0040040 32 0x0
devmem 0xa0040044 32 0x80000000
devmem 0xa0040000 32 0x2

```
## Generate PR Bitstreams

```bash
#
bootgen -arch zynqmp -image bitstream.bif -w -process_bitstream bin
```

```bash
# load default bitstream
fpgautil -b example.bit.bin -o base.dtbo

# clear overlay
fpgautil -R

# load new overlay fragment
fpgautil -b example.bit.bin -o check.dtbo

# Set AXI demux
devmem 0xa0020040 32 0x1
devmem 0xa0020000 32 0x2

# Set AXI mux
devmem 0xa0030040 32 0x80000000
devmem 0xa0030044 32 0x1
devmem 0xa0030000 32 0x2

# Check target IP register for default
devmem 0xa0050000 32

# Swap to ICAP control
echo 0xFFCA3008 0xFFFFFFFF 0 > /sys/firmware/zynqmp/config_reg
echo 0xFFCA3008 > /sys/firmware/zynqmp/config_reg

# Load bitstream
./axidma_transfer mode_b.bin test.bin

# Check target IP register for change
devmem 0xa0020000 32
```



## Enable AP_START

```bash
devmem 0xa0050000 32 0x1
devmem 0xa0050010 32 1080
devmem 0xa0050018 32 1920

devmem 0xa0040000 32 0x1
devmem 0xa0040010 32 1080
devmem 0xa0040018 32 1920
```

devmem 0xa0010010 32 1080
devmem 0xa0010018 32 1920
devmem 0xa0010000 32 0x1

## HLS AXIS

https://forums.xilinx.com/t5/High-Level-Synthesis-HLS/Vitis-Vision-cores-AXI4-Stream-buggy/m-p/1168941