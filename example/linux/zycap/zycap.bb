#
# This file is the ZyCAP recipe.
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

#CPPFLAGS += "-DSOME_MACRO"
  
#PACKAGE_ARCH = "${MACHINE_ARCH}"
#PROVIDES = "sample"
#TARGET_CC_ARCH += "${LDFLAGS}"
  
do_compile() {
	     oe_runmake
}

do_install() {
	     install -d ${D}${bindir}
	     install -m 0755 zycap ${D}${bindir}
}