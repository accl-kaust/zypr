#!/bin/bash

ZYCAP_ROOT_PATH=$(pwd)
BOARD=$(jq .project.project_device.family global_config.json | tr -d \")
DESIGN_NAME=$(jq .design.design_name global_config.json | tr -d \")
INSTALL_DEPS=$(jq .config.config_settings.check_dependencies global_config.json | tr -d \")
VIVADO_PATH=$(jq .config.config_vivado.vivado_path global_config.json | tr -d \")
VIVADO_VER=$(jq .config.config_vivado.vivado_version global_config.json | tr -d \")
VIVADO_PARAMS=$(jq .config.config_vivado.vivado_params global_config.json | tr -d \")
VIVADO_PROXY=$(jq .config.config_vivado.vivado_proxy global_config.json | tr -d \")

source "$(pwd)/scripts/bash/logger.sh"
source "$(pwd)/scripts/bash/spinner.sh"

log_info "Checking Petalinux is in PATH..."
source "/home/alex/petalinux/settings.sh" > /dev/null

cd $ZYCAP_ROOT_PATH/rtl && make clean-meta >/dev/null
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.logs" ]; then
    mkdir $ZYCAP_ROOT_PATH/rtl/.logs
fi

print_proj_info() {
    log_info "PROJECT: ${DESIGN_NAME}"
    log_info "VIVADO_VER: ${VIVADO_VER}"
    log_info "VIVADO_PROXY: ${VIVADO_PROXY}"
}


check_error() {
    local error=$( grep "^ERROR" $1 )
    if [ -n "$error" ]; then
        echo -e "${ERROR}$1 - $error${NONE}"
    fi
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

bootgen_bitstreams()
{
    if command -v bootgen &>/dev/null; then
        echo -e "${INFO}Converting bit to bin...${NONE}"
        case "$BOARD" in
            zynq-ultrascale)  
                ARCH="zynqmp"
                ;;
            zynq) 
                ARCH="zynq"
                ;;
            fpga)  
                ARCH="fpga"
                ;;
            *) 
                ARCH="zynqmp"
                ;;
        esac
        for i in ${1}/*_partial.bit; do
            echo -e "${INFO}Generating ${i: 0 : ${#i}-21 }.bin...${NONE}" 
            echo -e "the_ROM_image:\r{\r${i}\r}" >> "${i}.bif"
            bootgen -arch ${ARCH} -image ${i}.bif -w -process_bitstream bin >/dev/null
            mv "${i}.bin" "${i: 0 : ${#i}-21 }.bin" 
        done
        rm ${1}/*.bif
        echo -e "${SUCCESS}Finished \u2713 ${NONE}"
    else
        echo -e "${ERROR}Error - Bootgen not in PATH.${NONE}"
        exit 1
    fi
}

# Entry Point
# -----------
# This Tcl script will create an SDK workspace with software applications for each of the
# exported hardware designs in the ../Vivado directory.

print_proj_info

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
    perl $ZYCAP_ROOT_PATH/scripts/perl/extract_modules.pl "$ZYCAP_ROOT_PATH/rtl" > "$ZYCAP_ROOT_PATH/rtl/.logs/perl_mod_extract.log"
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/perl_mod_extract.log"
fi
echo -e "${SUCCESS}Finished \u2713 ${NONE}"

echo "Generating Black Boxes..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.blackbox" ]; then
    echo -e "${WARNING}Not found, generating...${NONE}"
    python $ZYCAP_ROOT_PATH/scripts/python/generate_blackbox.py > "$ZYCAP_ROOT_PATH/rtl/.logs/python_bb_generate.log"
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/python_bb_generate.log"
fi
echo -e "${SUCCESS}Finished \u2713 ${NONE}"

echo "Constructing Configs & Modes..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.modes" ]; then
    echo -e "${WARNING}Not found, generating...${NONE}"
    python $ZYCAP_ROOT_PATH/scripts/python/generate_interface.py > "$ZYCAP_ROOT_PATH/rtl/.logs/python_pr_construct.log"
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/python_pr_construct.log"
fi
echo -e "${SUCCESS}Finished \u2713${NONE}"

echo "Synthesising PR Configs & Modes..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.checkpoint_prj" ]; then
    echo -e "${WARNING}Not found, generating...${NONE}"
    # exec $VIVADO_PATH $VIVADO_PARAMS -mode batch -source $ZYCAP_ROOT_PATH/scripts/tcl/synth/generate_checkpoints.tcl -tclargs $ZYCAP_ROOT_PATH
    exec $VIVADO_PATH $VIVADO_PARAMS -mode batch -source $ZYCAP_ROOT_PATH/scripts/tcl/synth/generate_checkpoints.tcl -tclargs $ZYCAP_ROOT_PATH > "$ZYCAP_ROOT_PATH/rtl/.logs/vivado_pr_synth.log" &
    show_spinner $!
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/vivado_pr_synth.log"
fi
echo -e "${SUCCESS}Finished \u2713${NONE}"

echo "Building Block Design..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/${DESIGN_NAME}/${DESIGN_NAME}.srcs" ]; then
    echo -e "${WARNING}Not found, generating...${NONE}"
    exec $VIVADO_PATH $VIVADO_PARAMS -mode batch -source $ZYCAP_ROOT_PATH/scripts/tcl/boards/$BOARD/gen_bd.tcl -tclargs $ZYCAP_ROOT_PATH > "$ZYCAP_ROOT_PATH/rtl/.logs/vivado_bd_diagram.log" &
    # exec $VIVADO_PATH $VIVADO_PARAMS -mode batch -source $ZYCAP_ROOT_PATH/scripts/tcl/boards/$BOARD/gen_bd.tcl -tclargs $ZYCAP_ROOT_PATH
    show_spinner $!
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/vivado_bd_diagram.log"
fi
echo -e "${SUCCESS}Finished \u2713${NONE}"

echo "Synthesize Design..."
# if [ ! -d "$ZYCAP_ROOT_PATH/rtl/$DESIGN_NAME" ]; then
    echo -e "${WARNING}Not found, generating...${NONE}"
    # exec $VIVADO_PATH $VIVADO_PARAMS -mode batch -source $ZYCAP_ROOT_PATH/scripts/tcl/boards/$BOARD/synth.tcl -tclargs $ZYCAP_ROOT_PATH > "$ZYCAP_ROOT_PATH/rtl/.logs/vivado_bd_design.log" &
    exec $VIVADO_PATH $VIVADO_PARAMS -mode batch -source $ZYCAP_ROOT_PATH/scripts/tcl/boards/$BOARD/synth.tcl -tclargs $ZYCAP_ROOT_PATH || true
    # show_spinner $!
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/vivado_bd_design.log"
# fi
echo -e "${SUCCESS}Finished \u2713${NONE}"

echo "Generate Bitstreams..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/${DESIGN_NAME}.bitstreams" ]; then
    echo -e "${WARNING}Not found, generating...${NONE}"
    bootgen_bitstreams "$ZYCAP_ROOT_PATH/rtl/${DESIGN_NAME}.bitstreams"
fi
echo -e "${SUCCESS}Finished \u2713${NONE}"

echo "Build Petalinux..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/${DESIGN_NAME}.bitstreams" ]; then
    log_warn "Not found, generating..."
    bootgen_bitstreams "$ZYCAP_ROOT_PATH/rtl/${DESIGN_NAME}.bitstreams"
fi
echo -e "${SUCCESS}Finished \u2713${NONE}"

echo "Deploying Petalinux..."
echo -e "${SUCCESS}Finished \u2713${NONE}"