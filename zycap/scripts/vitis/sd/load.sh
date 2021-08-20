#!/bin/bash

DIR=$1
MACHINE=$2

cp boot.scr ${DIR}/boot
cp ${MACHINE}-system.dtb ${DIR}/boot/system.dtb
tar xf petalinux-image-minimal-${MACHINE}.tar.gz -C ${DIR}/rootfs/