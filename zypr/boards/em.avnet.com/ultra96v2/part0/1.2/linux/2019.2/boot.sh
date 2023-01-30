#!/bin/bash

DIR=$1

echo -e "Using ${DIR} for bootgen"
cd ${DIR}
bootgen -arch zynqmp -image boot.bif -w -o boot.bin

# bootgen -arch zynqmp -image boot_outer_shareable.bif -w -o boot_outer_shareable.bin

# zycap/test/demo/build/example.sdk/boot.bif