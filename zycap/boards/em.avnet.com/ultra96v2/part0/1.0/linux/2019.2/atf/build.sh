#!/bin/bash

proj_name=$1
build_dir=$2

git clone https://github.com/Xilinx/arm-trusted-firmware.git ${build_dir}/${proj_name}.sdk/atf || true
cd ${build_dir}/${proj_name}.sdk/atf
git checkout -b xilinx-v2019.2-ultra96 refs/tags/xilinx-v2019.2 || true

sed -i '/#warning "Using deprecated console implementation. Please migrate to MULTI_CONSOLE_API"/c\\/* #warning "Using deprecated console implementation. Please migrate to MULTI_CONSOLE_API" *\/' \
drivers/console/aarch64/deprecated_console.S
make ERROR_DEPRECATED=1 RESET_TO_BL31=1 CROSS_COMPILE=aarch64-linux-gnu- PLAT=zynqmp ZYNQMP_CONSOLE=cadence1 bl31

cp build/zynqmp/release/bl31/bl31.elf ../bl31.elf