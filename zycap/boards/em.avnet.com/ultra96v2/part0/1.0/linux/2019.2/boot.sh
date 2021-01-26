#!/bin/bash

bootgen -arch zynqmp -image boot.bif -w -o boot.bin
bootgen -arch zynqmp -image boot_outer_shareable.bif -w -o boot_outer_shareable.bin