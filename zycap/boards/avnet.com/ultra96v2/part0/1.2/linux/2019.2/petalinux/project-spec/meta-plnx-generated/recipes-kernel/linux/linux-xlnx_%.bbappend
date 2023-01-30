
SRC_URI += "file://plnx_kernel.cfg"
RDEPENDS_${KERNEL_PACKAGE_NAME}-base = ""
do_configure[depends] += "kern-tools-native:do_populate_sysroot"
FILESEXTRAPATHS_prepend := "${THISDIR}/configs:"
do_deploy_append () {
	install -m 0644 ${D}/boot/System.map-${KERNEL_VERSION} ${DEPLOYDIR}/System.map.linux
}
