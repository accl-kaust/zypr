
SRC_URI_append ="\
    file://config\
"
export PETALINUX
sysconf = "${TOPDIR}/../project-spec/configs"
YAML_CONSOLE_DEVICE_CONFIG_forcevariable = "psu_uart_1"
YAML_ENABLE_DT_OVERLAY = "1"
YAML_MAIN_MEMORY_CONFIG_forcevariable = "PSU_DDR_0"
DT_PADDING_SIZE = "0x1000"
DEVICETREE_FLAGS += ""
XSCTH_WS = "${TOPDIR}/../components/plnx_workspace/device-tree"
KERNEL_DTS_INCLUDE = "${STAGING_KERNEL_DIR}/include"
FILESEXTRAPATHS_append := ":${sysconf}"
do_configure_append () {
	script="${PETALINUX}/etc/hsm/scripts/petalinux_hsm_bridge.tcl"
	data=${PETALINUX}/etc/hsm/data/
	eval xsct -sdx -nodisp ${script} -c ${WORKDIR}/config \
	-hdf ${DT_FILES_PATH}/hardware_description.${HDF_EXT} -repo ${S}\
	-data ${data} -sw ${DT_FILES_PATH} -o ${DT_FILES_PATH} -a "soc_mapping"
}
