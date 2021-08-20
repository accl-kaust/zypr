
VIVADO_PATH=$1
PETALINUX_PATH=$2

source ${VIVADO_PATH}/settings64.sh

echo "alias xilsource="source ${PETALINUX_PATH}/settings64.sh" >> ~/.bashrc