#!/bin/bash

DIRECTORY=$1
VERSION=$2

git clone -b xilinx-v${VERSION} https://github.com/Xilinx/device-tree-xlnx ${DIRECTORY}/dtg