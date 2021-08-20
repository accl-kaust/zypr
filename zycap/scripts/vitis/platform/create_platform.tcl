platform create -name {zycap} -hw {/home/alex/GitHub/zycap2/zycap/test/demo/build/example.sdk/example.xsa} -proc {psu_cortexa53} -os {linux} -out {/home/alex/workspace};platform write
platform read {/home/alex/workspace/zycap/platform.spr}
platform active {zycap}
domain active {zynqmp_fsbl}
::scw::get_hw_path
::scw::regenerate_psinit /home/alex/workspace/zycap/hw/example.xsa
::scw::get_mss_path
domain active {zynqmp_pmufw}
::scw::get_hw_path
::scw::regenerate_psinit /home/alex/workspace/zycap/hw/example.xsa
::scw::get_mss_path
domain active {linux_domain}
domain config -bif {/home/alex/GitHub/zycap2/zycap/test/demo/build/example.sdk/boot.bif}
platform write
domain config -boot {/home/alex/GitHub/zycap2/zycap/test/demo/build/example.sdk}
platform write
domain config -image {/home/alex/GitHub/zycap2/zycap/test/demo/build/example.linux/kernel/zycap/images/linux}
platform write
domain config -sysroot {/home/alex/GitHub/zycap2/zycap/test/demo/build/example.linux/kernel/zycap/images/linux/sdk/sysroots/aarch64-xilinx-linux}
platform write
