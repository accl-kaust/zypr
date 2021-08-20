#!/bin/bash

# insert="\/include\/ \"udmabuf.dtsi\""

function insert_dtsi(){
    match="\/include\/ \"system-conf.dtsi\""
    # file='system-user.dtsi'
    file="$2/files/system-user.dtsi"

    sed -i "s/${match}/${match}\n$1/" $file
    echo 'SRC_URI += "file://udmabuf.dtsi"' >> "${2}/device-tree.bbappend"
}
# sed '/\[option\]/a Hello World' input


function compress_bitstreams() {
    find ${ZYCAP_ROOT_PATH}/rtl/${DESIGN_NAME}/${DESIGN_NAME}.bitstreams -type f -name '*.bin' -exec tar -czvf ${ZYCAP_ROOT_PATH}/linux/zycap/bitstreams.tar.gz '{}' ';'
    # cp ${ZYCAP_ROOT_PATH}/rtl/${DESIGN_NAME}/${DESIGN_NAME}.bitstreams
}