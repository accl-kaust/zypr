
# WARNING THIS WILL ERASE YOUR DISK, CHOOSE CAREFULLY!
DRIVE=${1}
sudo sfdisk -d /dev/${DRIVE} > ${DRIVE}.sfdisk

if ! cmp ${DRIVE}.sfdisk SD.sfdisk > /dev/null 2>&1
then
    echo "Disk requires formatting."
    sudo sfdisk /dev/${DRIVE} < SD.sfdisk --force
    sudo mkfs.vfat -F 32 -n boot /dev/${DRIVE}1
    sudo mkfs.ext4 -L root /dev/${DRIVE}2
else
    echo "Disk already formatted correctly."
fi

sudo mount /dev/${DRIVE}1 /media/$(whoami)/boot
sudo mount /dev/${DRIVE}2 /media/$(whoami)/root

cd /media/$(whoami)/boot/
sudo cp /home/alex/GitHub/zycap2/example/linux/base_design/images/linux/BOOT.BIN .
sudo cp /home/alex/GitHub/zycap2/example/linux/base_design/images/linux/image.ub .

cd /media/$(whoami)/root/
sudo cp /home/alex/GitHub/zycap2/example/linux/base_design/images/linux/rootfs.tar.gz .
sudo tar xvf rootfs.tar.gz -C .
sudo rm rootfs.tar.gz

sync

sudo umount /media/$(whoami)/boot/
sudo umount /media/$(whoami)/root/