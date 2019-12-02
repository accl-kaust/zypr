#/bin/bash

ROOT_DIR=$1
LINUX_PROJ=$2

# build module project
if ! [ -d "${ROOT_DIR}/linux/${LINUX_PROJ}/project-spec/meta-user/recipes-apps/zycap" ]; then
    echo "Generating Petalinux module..."
    petalinux-create -t modules -n udmabuf --enable
fi

# copy local source into Petalinux project
cp "${ROOT_DIR}/linux/${LINUX_PROJ}/zycap/zycap.c" "${ROOT_DIR}/linux/${LINUX_PROJ}/project-spec/meta-user/recipes-apps/zycap/files/zycap.c"
cp "${ROOT_DIR}/linux/${LINUX_PROJ}/zycap/zycap.h" "${ROOT_DIR}/linux/${LINUX_PROJ}/project-spec/meta-user/recipes-apps/zycap/files/zycap.h"
cp "${ROOT_DIR}/linux/${LINUX_PROJ}/zycap/Makefile" "${ROOT_DIR}/linux/${LINUX_PROJ}/project-spec/meta-user/recipes-apps/zycap/files/Makefile"