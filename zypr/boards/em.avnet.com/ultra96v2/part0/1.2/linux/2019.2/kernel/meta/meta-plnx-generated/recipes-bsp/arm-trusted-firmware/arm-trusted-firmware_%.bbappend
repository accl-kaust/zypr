
SRC_URI_append ="\
    file://config\
"
EXTRA_OEMAKE_append = " ${extra_settings} PRELOADED_BL33_BASE=${atf_bl33_load}"
atf_bl33_load = "0x8000000"
extra_settings = ""
sysconf = "${TOPDIR}/../project-spec/configs"
ATF_CONSOLE_zynqmp = "cadence1"
FILESEXTRAPATHS_append := ":${sysconf}"
