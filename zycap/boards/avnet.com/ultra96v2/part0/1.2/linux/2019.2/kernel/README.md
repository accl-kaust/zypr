### Yocto Launch
```bash
docker run -it --rm -v /home/alex/GitHub/zycap2/zycap/test/demo/build/example.linux/yocto:/home/zycap/build v2019 bash
```

### Notes

append conf/local.conf:

```bash
KERNEL_CLASSES += "kernel-fitimage"
KERNEL_IMAGETYPES_append = " fitImage"
 
UBOOT_ENTRYPOINT_zynqmp = "0x8000000"
UBOOT_LOADADDRESS_zynqmp = "0x8000000"
```

