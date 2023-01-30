/home/alex/GitHub/usbsdmux/venv/bin/usbsdmux /dev/sg2 host

sleep 3

mount /dev/sdc1 /media/alex/boot 
mount /dev/sdc2 /media/alex/rootfs

tar -xf /home/alex/GitHub/zycap2/zycap/test/demo/build/example.linux/kernel/zycap/images/linux/rootfs.tar.gz -C /media/alex/rootfs
cp dma.dtbo /media/alex/rootfs/lib/firmware/base

dtc -O dtb -o check.dtbo -b 0 -@ check.dtsi
cp check.dtbo /media/alex/rootfs/lib/firmware/base

cp /home/alex/GitHub/zycap2/zycap/test/demo/build/example.linux/kernel/zycap/images/linux/system.dtb /media/alex/boot
cp /home/alex/GitHub/zycap2/zycap/test/demo/build/example.linux/kernel/zycap/images/linux/BOOT.BIN /media/alex/boot/boot.bin
cp /home/alex/GitHub/zycap2/zycap/test/demo/build/example.linux/kernel/zycap/images/linux/image.ub /media/alex/boot

sync

umount /media/alex/boot
umount /media/alex/rootfs

/home/alex/GitHub/usbsdmux/venv/bin/usbsdmux /dev/sg2 dut