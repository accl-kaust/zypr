#/bin/bash

ROOT_DIR=$1
LINUX_PROJ=$2

# build module project
if ! [ -d "${ROOT_DIR}/linux/${LINUX_PROJ}/project-spec/meta-user/recipes-modules/udmabuf" ]; then
    echo "Generating Petalinux module..."
    petalinux-create -t modules -n udmabuf --enable
fi

# copy local source into Petalinux project
cp "${ROOT_DIR}/linux/${LINUX_PROJ}/udmabuf/udmabuf.c" "${ROOT_DIR}/linux/${LINUX_PROJ}/project-spec/meta-user/recipes-modules/udmabuf/files/udmabuf.c"