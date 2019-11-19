#!/bin/bash

ERROR='\e[0;31m'
SUCCESS="\e[0;32m"
NONE="\e[0m"
ROOT_DIR=$1

BOARD_NAME=$(jq .project.project_device.name $ROOT_DIR/global_config.json | tr -d \")
BOARD_VERSION=$(jq .project.project_device.version $ROOT_DIR/global_config.json | tr -d \")
VIVADO_VERSION=$(jq .config.config_vivado.vivado_version $ROOT_DIR/global_config.json | tr -d \")
BSP_LOCATION=$(jq .bsp_url $ROOT_DIR/board/$BOARD_NAME/$BOARD_VERSION/data.json | tr -d \")

function pause(){
   read -p "$*"
}

function download_offical_bsp(){
    # Prompt User to download their BSP
    BSP_URL=$(echo "$BSP_LOCATION" | sed -r "s/[$]+/${VIVADO_VERSION}/g")
    BSP_URL_VALID=$(curl -o /dev/null -u myself:XXXXXX -Isw '%{http_code}\n' $BSP_URL)
    if ! { [ $BSP_URL_VALID == "200" ] || [ $BSP_URL_VALID == "302" ]; };
    then
        echo -e "${ERROR}BSP URL is not valid, please check BSP URL in $ROOT_DIR/board/$BOARD_NAME/$BOARD_VERSION/data.json $NONE"
    fi
    echo -e "Note - You will need to register and sign in with you Xilinx account"
    pause "Press [Enter] key to continue and download board BSP - $BOARD_NAME - $VIVADO_VERSION"
    xdg-open $BSP_URL
}
