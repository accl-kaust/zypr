mount /dev/sdd1 /media/alex/boot 
mount /dev/sdd2 /media/alex/rootfs

tar -vxf /home/alex/GitHub/zycap2/zycap/test/demo/build/example.linux/kernel/zycap/images/linux/rootfs.tar.gz -C /media/alex/rootfs
cp dma.dtbo /media/alex/rootfs/lib/firmware/base
cp sobel.dtbo /media/alex/rootfs/lib/firmware/base

cp /home/alex/GitHub/zycap2/zycap/test/demo/build/example.linux/kernel/zycap/images/linux/system.dtb /media/alex/boot
cp /home/alex/GitHub/zycap2/zycap/test/demo/build/example.linux/kernel/zycap/images/linux/BOOT.BIN /media/alex/boot/boot.bin
cp /home/alex/GitHub/zycap2/zycap/test/demo/build/example.linux/kernel/zycap/images/linux/image.ub /media/alex/boot

sync

umount /media/alex/boot
umount /media/alex/rootfs