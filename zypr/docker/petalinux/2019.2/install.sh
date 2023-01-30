#!/usr/bin/env bash

source /opt/petalinux/settings.sh
petalinux-config --get-hw-description=../
petalinux-build
