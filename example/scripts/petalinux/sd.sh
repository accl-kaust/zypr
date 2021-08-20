

# Plug the SD card into your computer and find it’s device name using the dmesg command. The SD card should be found at the end of the log, and it’s device name should be something like /dev/sdX, where X is a letter such as a,b,c,d, etc. Note that you should replace the X in the following instructions.

# Run fdisk by typing the command 

prepare_sd () {
    log_warn "May require root permission!"
    log_info "Available drives:"
    log_success "NAME         SIZE"
    log_success "$(sudo lsblk -o name,size | grep "sd.")"

    
    exit 0
}



# sudo fdisk /dev/sdX

# Make the boot partition: typing n to create a new partition, then type p to make it primary, then use the default partition number and first sector. For the last sector, type +1G to allocate 1GB to this partition.

# Make the boot partition bootable by typing a

# Make the root partition: typing n to create a new partition, then type p to make it primary, then use the default partition number, first sector and last sector.

# Save the partition table by typing w

# Format the boot partition (FAT32) by typing sudo mkfs.vfat -F 32 -n boot /dev/sdX1

# Format the root partition (ext4) by typing sudo mkfs.ext4 -L root /dev/sdX2
