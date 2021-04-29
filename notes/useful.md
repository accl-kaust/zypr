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
# For S00 -> M00
devmem 0xa0020040 32 0x0 
devmem 0xa0020000 32 0x2 

# For S00 -> M00
devmem 0xa0030040 32 0x0 
devmem 0xa0030000 32 0x2 

# For S00 -> M01
devmem 0xa0020040 32 0x80000000
devmem 0xa0020044 32 0x0 
devmem 0xa0020000 32 0x2 

# For S00 -> M01
devmem 0xa0030040 32 0x1 
devmem 0xa0030000 32 0x2 
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
