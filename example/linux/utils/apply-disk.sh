# WARNING THIS WILL ERASE YOUR DISK, CHOOSE CAREFULLY!
DRIVE=${1}
USER=$(whoami)

# sudo sfdisk -d /dev/${DRIVE} > ${DRIVE}.sfdisk

if ! cmp ${DRIVE}.sfdisk SD.sfdisk > /dev/null 2>&1
then
    echo "Disk requires formatting."
    sudo sfdisk /dev/${DRIVE} < SD.sfdisk --force
    sudo mkfs.vfat -F 32 -n boot /dev/${DRIVE}1
    sudo mkfs.ext4 -L root /dev/${DRIVE}2
else
    echo "Disk already formatted correctly."
fi

# sudo mkdir /media/$(whoami)/boot
# sudo mkdir /media/$(whoami)/root
if mount | grep /media/${USER}/boot > /dev/null; then
    echo "Already mounted."
else
    sudo mount /dev/${DRIVE}1 /media/${USER}/boot
fi
# sudo mount /dev/${DRIVE}p2 /media/${USER}/root

echo "Copying BOOT.BIN and image.ub into boot partition..."
sudo cp /home/alex/GitHub/zycap2/example/linux/base_design/images/linux/BOOT.BIN /media/${USER}/boot/BOOT.BIN
sudo cp /home/alex/GitHub/zycap2/example/linux/base_design/images/linux/image.ub /media/${USER}/boot/image.ub 

echo "Unzipping rootfs into root partition..."
sudo dd if=/home/alex/GitHub/zycap2/example/linux/base_design/images/linux/rootfs.ext4 of=/dev/${DRIVE}2

# sudo cp /home/alex/GitHub/zycap2/example/linux/base_design/images/linux/rootfs.tar.gz .
# sudo tar xvf rootfs.tar.gz -C /media/${USER}/root/
# sudo rm rootfs.tar.gz

sync

sudo umount /media/${USER}/boot/
# sudo umount /media/${USER}/root/
