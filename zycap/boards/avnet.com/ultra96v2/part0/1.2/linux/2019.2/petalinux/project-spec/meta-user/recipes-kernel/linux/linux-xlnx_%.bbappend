FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://devtool-fragment.cfg"
SRC_URI += "file://bsp.cfg"
SRC_URI += "file://zycap.cfg"
SRC_URI_append = " file://fix_u96v2_pwrseq_simple.patch"