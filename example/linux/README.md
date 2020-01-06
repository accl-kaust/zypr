# Notes

`udmabuf.ko` is generated into `/lib/modules/4.14.0-xilinx-v2018.3/extra`

> :warning: Do not forget to run `--config-hardware`

Enable settings for USB to Ethernet:

```bash
petalinux-config -c kernel
```

Kernel Config GUI:

```bash
Device Drivers
   -> USB Support
          <*> USB Modem (CDC ACM) support

Device Drivers
   -> USB Support
            -> USB Gadget Support
                     <m> CDC Composite Device (Ethernet and ACM)

Device Drivers
    -> Network device support
              -> USB Network Adapters
                        <*> Multipurpose USB Networking Framework
                                 ... add your chipset if you see it
```

Add to `petalinuxbsp.conf` - `MACHINE_FEATURES_remove_ultra96-zynqmp = "mipi"`

https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842279/Build+Device+Tree+Blob#BuildDeviceTreeBlob-GenerateaDeviceTreeSource(.dts/.dtsi)filesfromSDK