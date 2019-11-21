#!/bin/bash

ERROR='\e[0;31m'
SUCCESS="\e[0;32m"
WARNING="\e[0;33m"
INFO="\e[0;34m"
NONE="\e[0m"

VIVADO_ROOT=$1
BOARD_NAME=$2
BOARD_VER=$3

VIVADO_BOARD_FILES="$(echo $VIVADO_ROOT | rev | cut -d"/" -f3- | tr -d '\n' | rev)/data/boards/board_files/${BOARD_NAME}/${BOARD_VER}"
#ls ${VIVADO_BOARD_FILES}
if [ ! -d "${VIVADO_BOARD_FILES}" ]; then
    mkdir -p $VIVADO_BOARD_FILES
    find "${BOARD_NAME}/${BOARD_VER}" -name \*.xml -exec cp {} $VIVADO_BOARD_FILES \;
    echo -e "${SUCCESS}Finished \u2713.${NONE}"
else
    echo -e "${SUCCESS}Board files already exist \u2713.${NONE}"
fi


