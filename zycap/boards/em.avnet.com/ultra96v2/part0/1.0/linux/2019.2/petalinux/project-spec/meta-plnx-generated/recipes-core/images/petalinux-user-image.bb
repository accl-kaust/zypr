DESCRIPTION = "PETALINUX image definition for Xilinx boards"
LICENSE = "MIT"

require recipes-core/images/petalinux-image-common.inc 

inherit extrausers 
COMMON_FEATURES = "\
		ssh-server-dropbear \
		hwcodecs \
		debug-tweaks \
		"
IMAGE_LINGUAS = " "

IMAGE_INSTALL = "\
		kernel-modules \
		haveged \
		i2c-tools \
		mtd-utils \
		canutils \
		dropbear \
		openssh-sftp-server \
		rsync \
		wget \
		pciutils \
		run-postinsts \
		bluez5 \
		opencv \
		udev-extraconf \
		packagegroup-core-boot \
		packagegroup-core-ssh-dropbear \
		tcf-agent \
		watchdog-init \
		bridge-utils \
		wpa-supplicant \
		hellopm \
		packagegroup-petalinux \
		packagegroup-petalinux-display-debug \
		packagegroup-petalinux-matchbox \
		packagegroup-petalinux-networking-stack \
		packagegroup-petalinux-opencv \
		packagegroup-petalinux-v4lutils \
		packagegroup-petalinux-x11 \
		sds-lib \
		ultra96-radio-leds \
		ultra96-wpa \
		usb-gadget-ethernet \
		zycap \
		axidma \
		led-brightness \
		udmabuf \
		wilc \
		libftdi \
		bonnie++ \
		cmake \
		iperf3 \
		iw \
		lmsensors-sensorsdetect \
		nano \
		packagegroup-base-extended \
		python-pyserial \
		python3-pip \
		ultra96-misc \
		wilc3000-fw \
		"
EXTRA_USERS_PARAMS ?= "usermod -P root root;"
