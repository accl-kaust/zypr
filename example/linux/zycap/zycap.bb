#
# This file is the libsample recipe.
#
  
SUMMARY = "ZyCAP PR Manager"
SECTION = "libs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
  
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
  
SRC_URI = " \
          file://zycap.c \
          file://zycap.h \
          file://Makefile \
         "
  
S = "${WORKDIR}"
  
PACKAGE_ARCH = "${MACHINE_ARCH}"
PROVIDES = "sample"
TARGET_CC_ARCH += "${LDFLAGS}"
  
do_install() {
    install -d ${D}${libdir}
    install -d ${D}${includedir}
    oe_libinstall -so libsample ${D}${libdir}
    # This is optional and depends if you have any headers to copied along with libraries
    # This example includes sample.h to to copied to <TARGET_ROOTFS>/usr/lib/SAMPLE/sample.h
    install -d -m 0655 ${D}${includedir}/SAMPLE
    install -m 0644 ${S}/*.h ${D}${includedir}/SAMPLE/
}
  
FILES_${PN} = "${libdir}/*.so.* ${includedir}/*"
FILES_${PN}-dev = "${libdir}/*.so"