#!/bin/bash

if [ $(whoami) != 'root' ]; then
echo "Must be root to run "
exit 1;
fi

#Make sure that a drive has been specified
DRIVE=$1
if [ ! -n "$1" ]; then
echo "Please specify a card, for example: # sh formatSDCard sde"
exit 1;
fi

#Make sure that the hard-drive isn't accidentaly annihilated
if [ $DRIVE = 'sda' ]; then
echo "Do not format drive sda!"
exit 1;
fi

#Unmount any partitions on the drive
echo "Checking to make sure all partitions are unmounted…"

i=1
while [ ! -z `ls /dev/ | grep ${DRIVE}${i}` ]; do
umount /dev/${DRIVE}${i}
i=$(( $i + 1 ))
done
sleep 2s

echo "Beginning format"

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/${DRIVE}
  o     # clear the in-memory partition table
  n     # new partition
  p     # primary partition
  1     # partition number 1
        # default - start at beginning of disk
  +1G # 100 MB boot partition
  t     # type partition
  b     # VFAT to type of partition number 1
  n     # new partition
  p     # primary partition
  2     # partition number 2
        # default - start immediately after preceding partition
        # default - extend partition to end of disk
  p     # print the in-memory partition table
  w     # write the partition table
  q     # and we're done
EOF

# mkfs.vfat /dev/${DRIVE}1
mkfs.vfat -F 32 -n boot /dev/${DRIVE}1
# mkfs.ext3 /dev/${DRIVE}2
mkfs.ext4 -L root /dev/${DRIVE}2

i=1
while [ ! -z `ls /dev/ | grep ${DRIVE}${i}` ]; do
umount /dev/${DRIVE}${i}
i=$(( $i + 1 ))
done
sleep 2s

mount -t vfat /dev/${DRIVE}1 /media/boot/
mount -t ext4 /dev/${DRIVE}2 /media/rootfs/