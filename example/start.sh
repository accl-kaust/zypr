#!/bin/bash

ERROR='\e[0;31m'
SUCCESS="\e[0;32m"
WARNING="\e[0;33m"
INFO="\e[0;34m"
NONE="\e[0m"

ZYCAP_ROOT_PATH=$(pwd)
BOARD=$(jq .project.project_device.family global_config.json | tr -d \")
DESIGN_NAME=$(jq .design.design_name global_config.json | tr -d \")
INSTALL_DEPS=$(jq .config.config_settings.check_dependencies global_config.json | tr -d \")
VIVADO_PATH=$(jq .config.config_vivado.vivado_path global_config.json | tr -d \")
VIVADO_PARAMS=$(jq .config.config_vivado.vivado_params global_config.json | tr -d \")

cd $ZYCAP_ROOT_PATH/rtl && make clean-meta
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.logs" ]; then
    mkdir $ZYCAP_ROOT_PATH/rtl/.logs
fi

# if [ ${1} == "clean" ]; then
#     make clean
# fi

check_error() {
    local error=$( grep "^ERROR" $1 )
    if [ -n "$error" ]; then
        echo -e "${ERROR}$1 - $error${NONE}"
    fi
}

show_spinner()
{
  local -r pid="${1}"
  local -r delay='0.75'
  local spinstr='\|/-'
  local temp
  while ps a | awk '{print $1}' | grep -q "${pid}"; do
    temp="${spinstr#?}"
    printf " [%c]  " "${spinstr}"
    spinstr=${temp}${spinstr%"${temp}"}
    sleep "${delay}"
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

install_python_deps()
{
    if command -v python3 &>/dev/null; then
        echo -e "${INFO}Installing Python libraries...${NONE}"
        pip3 install -r ../scripts/python/requirements.txt > "$ZYCAP_ROOT_PATH/rtl/.logs/python_install.log" &
        show_spinner $!
    else
        echo -e "${ERROR}Error - Python 3 is missing.${NONE}"
        exit 1
    fi
}

install_perl_deps()
{
    if command -v perl &>/dev/null; then
        echo -e "${INFO}Installing Perl libraries...${NONE}"
        ../scripts/perl/install.sh > "$ZYCAP_ROOT_PATH/rtl/.logs/perl_install.log" &
        show_spinner $!
    else
        echo -e "${ERROR}Error - Perl is missing.${NONE}"
        exit 1
    fi
}

install_board_files()
{
    local BOARD_NAME=$(jq .project.project_device.name ../global_config.json | tr -d \")
    local BOARD_VER=$(jq .project.project_device.version ../global_config.json | tr -d \")

    cd ../board
    echo -e "${WARNING}May requires root for adding board files to Xilinx tool paths...${NONE}"
    sudo bash install.sh ${VIVADO_PATH} ${BOARD_NAME} ${BOARD_VER}
    cd ../rtl
}

echo "Checking Dependencies..."
if [ $INSTALL_DEPS == "true" ]; then
    echo -e "${WARNING}Dependencies not found, install...${NONE}"
    install_board_files
    install_python_deps
    install_perl_deps
    $(jq -r '.config.config_settings.check_dependencies=false' "$ZYCAP_ROOT_PATH/global_config.json" > tmp.$$.json && mv tmp.$$.json "$ZYCAP_ROOT_PATH/global_config.json")
    echo -e "${SUCCESS}Installed dependencies \u2713 ${NONE}"
else
    echo -e "${SUCCESS}Finished \u2713 ${NONE}"
fi

echo "Extracting Modules..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.json" ]; then
    echo -e "${WARNING}Not found, generating...${NONE}"
    perl $ZYCAP_ROOT_PATH/scripts/perl/extract_modules.pl "$ZYCAP_ROOT_PATH/rtl" > "$ZYCAP_ROOT_PATH/rtl/.logs/extract_modules.log"
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/extract_modules.log"
fi
echo -e "${SUCCESS}Finished \u2713 ${NONE}"

echo "Generating Black Boxes..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.blackbox" ]; then
    echo -e "${WARNING}Not found, generating...${NONE}"
    python $ZYCAP_ROOT_PATH/scripts/python/generate_blackbox.py > "$ZYCAP_ROOT_PATH/rtl/.logs/generate_bb.log"
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/generate_bb.log"
fi
echo -e "${SUCCESS}Finished \u2713 ${NONE}"

echo "Constructing Configs & Modes..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.modes" ]; then
    echo -e "${WARNING}Not found, generating...${NONE}"
    python $ZYCAP_ROOT_PATH/scripts/python/generate_interface.py > "$ZYCAP_ROOT_PATH/rtl/.logs/construct_pr.log"
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/construct_pr.log"
fi
echo -e "${SUCCESS}Finished \u2713${NONE}"

echo "Synthesising PR Configs & Modes..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.checkpoint_prj" ]; then
    echo -e "${WARNING}Not found, generating...${NONE}"
    exec $VIVADO_PATH $VIVADO_PARAMS -mode batch -source $ZYCAP_ROOT_PATH/scripts/tcl/synth/generate_checkpoints.tcl -tclargs $ZYCAP_ROOT_PATH > "$ZYCAP_ROOT_PATH/rtl/.logs/bd_output.log" &
    show_spinner $!
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/pr_synth.log"
fi
echo -e "${SUCCESS}Finished \u2713${NONE}"

echo "Building Block Diagram..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/$DESIGN_NAME" ]; then
    echo -e "${WARNING}Not found, generating...${NONE}"
    exec $VIVADO_PATH $VIVADO_PARAMS -mode batch -source $ZYCAP_ROOT_PATH/scripts/tcl/boards/$BOARD/gen_bd.tcl -tclargs $ZYCAP_ROOT_PATH > "$ZYCAP_ROOT_PATH/rtl/.logs/bd_output.log" &
    show_spinner $!
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/bd_output.log"
fi
echo -e "${SUCCESS}Finished \u2713${NONE}"

