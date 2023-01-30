#!/bin/bash

proj_name=$1
build_dir=$2

git clone --depth=1 -b xilinx-v2019.2 https://github.com/Xilinx/u-boot-xlnx.git ${build_dir}/${proj_name}.sdk/uboot/uboot || true
cd ${build_dir}/${proj_name}.sdk/uboot/uboot
git checkout -b xilinx-v2019.2-ultra96 || true

# Get cores
cores=$(($(grep -c ^processor /proc/cpuinfo)-1))

# Patch Ultra96-V2
patch -p1 < ../src/u-boot-xlnx-v2019.2-ultra96-of_embed.diff
git add --update
git commit -m "patch for embedded device tree"
git tag -a xilinx-v2019.2-ultra96-0 -m "release xilinx-v2019.2-ultra96 release 0"

# Patch bootmenu
patch -p1 < ../src/u-boot-xlnx-v2019.2-ultra96-bootmenu.diff
git add --update
git commit -m "[update] for boot menu command"
git tag -a xilinx-v2019.2-ultra96-1 -m "release xilinx-v2019.2-ultra96 release 1"

# Build
# cd uboot
export ARCH=arm
export CROSS_COMPILE=aarch64-linux-gnu-
make avnet_ultra96_rev1_defconfig -j ${cores}
make -j ${cores}

cp u-boot.elf ../../u-boot.elf