#!/bin/bash

INSTALL_PATH="/media/rootfs/"
USER_NAME="zycap"

apt-get install -y qemu-user-static 
wget http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.5-base-arm64.tar.gz

if [ -d $INSTALL_PATH ] 
then
    echo "Directory ${INSTALL_PATH} exists."
    tar xfvp  ./ubuntu-base-18.04.5-base-arm64.tar.gz -C ${INSTALL_PATH} 
else
    echo "Error: Directory ${INSTALL_PATH} does not exists."
fi

cp -av /usr/bin/qemu-aarch64-static ${INSTALL_PATH}/usr/bin
cp -av /run/systemd/resolve/stub-resolv.conf ${INSTALL_PATH}/etc/resolv.conf

chroot ${INSTALL_PATH}

useradd -G sudo -m -s /bin/bash $USER_NAME
echo $USER_NAME:$USER_NAME | chpasswd

apt-get update
apt-get upgrade
apt-get -y install locales
apt-get -y install dialog perl
apt-get -y install sudo ifupdown net-tools ethtool udev wireless-tools iputils-ping resolvconf wget apt-utils wpasupplicant nano

apt-get -y install kmod openssh-client openssh-server

apt install -y build-essential cmake git
ln -s /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@ttyPS0.service

exit