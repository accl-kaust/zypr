#!/bin/bash

# Pass root dir into script
# ROOT_DIR=$1
INITIAL_BITSTREAM=$1

BOARD=$(jq .project.project_device.family global_config.json | tr -d \")
DESIGN_NAME=$(jq .design.design_name global_config.json | tr -d \")
INSTALL_DEPS=$(jq .config.config_settings.check_dependencies global_config.json | tr -d \")
VIVADO_PATH=$(jq .config.config_vivado.vivado_path global_config.json | tr -d \")
VIVADO_VER=$(jq .config.config_vivado.vivado_version global_config.json | tr -d \")
VIVADO_PARAMS=$(jq .config.config_vivado.vivado_params global_config.json | tr -d \")
VIVADO_PROXY=$(jq .config.config_vivado.vivado_proxy global_config.json | tr -d \")
PETALINUX_PATH=$(jq .config.config_petalinux.petalinux_path global_config.json | tr -d \")

source "$(pwd)/scripts/bash/logger.sh"
source "$(pwd)/scripts/bash/spinner.sh"
source "$(pwd)/scripts/petalinux/sd.sh"

ZYCAP_ROOT_PATH=$(pwd)

mkdir -p "${ZYCAP_ROOT_PATH}/linux/.logs"
LOG_DIR="${ZYCAP_ROOT_PATH}/linux/.logs"

pyenv local 2.7.15

# Check for correct shell:
if [ $(readlink /proc/$$/exe) != "/bin/bash" ]; then
  echo -e "${ERROR}Incorrect shell, please use bin/bash.${NONE}"
  exit 1
fi

# Ensure that petalinux and vivado tools are in PATH
VIVADO_PATH_SETTING=$(echo ${VIVADO_PATH} | rev | cut -d '/' -f 3,4,5,6 | rev)
log_none "Petalinux Build Script"
source "/${VIVADO_PATH_SETTING}/settings64.sh"

# Get the exported project

hardware_dir=(`find ${ZYCAP_ROOT_PATH}/rtl/${DESIGN_NAME}/ -name "*.hardware"`)
bitstream_dir=(`find ${ZYCAP_ROOT_PATH}/rtl/${DESIGN_NAME}/ -name "*.bitstreams"`)
log_success "- Exported hardware found: [$hardware_dir] \u2713"


# Name of the HDF file
hdf="${hardware_dir}/${DESIGN_NAME}.hdf"
if [ -f "$hdf" ]; then
  log_success "- HDF file exists [`basename "$hdf"`] \u2713"
else
  log_err "- HDF file does not exist"
  log_err "- PetaLinux will not be built for this project"
  echo
  continue
fi

# Name of the BIT file
bit="${bitstream_dir}/${INITIAL_BITSTREAM}.bit"
if [ -f "$bit" ]; then
  log_success "- BIT file exists [`basename "$bit"`] \u2713"
else
  log_err "- BIT file does not exist"
  log_err "- PetaLinux will not be built for this project"
  echo
  continue
fi

# set CPU type
case "$BOARD" in
  zynq-ultrascale)  
      ARCH="zynqMP"
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

fsbl_option="--fsbl ./images/linux/$(echo "${ARCH}" | tr '[:upper:]' '[:lower:]')_fsbl.elf"
echo $fsbl_option
log_info "- SOC Type: [$ARCH]"

############################ Generate Project ############################

# Create PetaLinux project if it does not exists
if [ -d "${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}" ]; then
  log_success "- PetaLinux project already exists \u2713"
else
  log_info "- Creating PetaLinux project..."
  echo -e "${INFO}$(petalinux-create --type project --template $ARCH --name "linux/${DESIGN_NAME}")${NONE}"
  log_success "- PetaLinux project created \u2713"
fi

cd "${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}"

############################ Generate Hardware ############################

# Configure PetaLinux project with hardware description if 'components' dir doesn't exist
if [ -d "${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/components" ]; then
  log_success "- PetaLinux project already configured with hardware description \u2713"
else
  log_info "- Configuring PetaLinux project with hardware description..."
  petalinux-config --get-hw-description ${hardware_dir}
  # echo -e "${INFO}$(petalinux-config --get-hw-description ${hardware_dir} --oldconfig)${NONE}" > "$ZYCAP_ROOT_PATH/rtl/.logs/petalinux_hdf.log" &
  # show_spinner $!
  log_success "- PetaLinux project configured with hardware description \u2713"
fi

############################ Generate Config ############################

# Copy PetaLinux config files
if [[ -f "${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/configdone.txt" ]]; then
  log_success "- PetaLinux config files already transferred \u2713"
else
  log_info "- Transferring PetaLinux config files"
  cp -R ${ZYCAP_ROOT_PATH}/board/ultra96/1.2/linux/configs/* ${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/project-spec/configs
  # Append mods to config file
  config_mod_list=(`find ${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/project-spec/configs -name "config_*.append"`)
  for project_name in ${config_mod_list[*]}
  do
    echo $project_name
    cat $project_name
    cat $project_name >> ${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/project-spec/configs/config
  done
  # Append mods to rootfs_config file
  # rootfs_config_mod_list=(`find ${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/project-spec/configs -name "rootfs_config_*.append"`)
  # for project_name in ${rootfs_config_mod_list[*]}
  # do
  #   echo $project_name
  #   cat $project_name
  #   cat $project_name >> ${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/project-spec/configs/rootfs_config
  # done
  # File to indicate that config files have been transferred
  touch ${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/configdone.txt
  # Run petalinux-config again to register the config files
  petalinux-config --oldconfig
  log_success "- PetaLinux config prepared \u2713"
fi

############################ Custom Modules ############################

# Generate UDMABUF module
if ! [ -d "${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/project-spec/meta-user/recipes-modules/udmabuf" ]; then
  log_info "Generating Petalinux module..."
  petalinux-create -t modules -n udmabuf --enable
  cp ${ZYCAP_ROOT_PATH}/linux/udmabuf/udmabuf.c ${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/project-spec/meta-user/recipes-modules/udmabuf/files/udmabuf.c
  # cp ${ZYCAP_ROOT_PATH}/linux/udmabuf/Makefile ${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/project-spec/meta-user/recipes-modules/udmabuf/files/Makefile
fi

############################ Build Project ############################

# Build PetaLinux project if not built already
# if [ -d "${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/images" ]; then
#   log_success "- PetaLinux project already built \u2713"
# else
  log_info "- Building PetaLinux project..."
  petalinux-build > "${LOG_DIR}/petalinux_build.log" &
  show_spinner $!
  log_success "- PetaLinux project built \u2713"
# fi

############################ Psackage Project ############################

# Package PetaLinux project if not packaged
if [[ -f "${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/images/linux/BOOT.BIN" && -f "${ZYCAP_ROOT_PATH}/linux/${DESIGN_NAME}/images/linux/image.ub" ]]; then
  log_success "- PetaLinux project already packaged \u2713"
else
  log_info "- Packaging PetaLinux project..."
  exec petalinux-package --boot $fsbl_option --fpga $bit --u-boot  > "${LOG_DIR}/petalinux_package.log" &
  show_spinner $!
  log_success "- PetaLinux packaged \u2713"
fi

cd ..

log_success "PetaLinux build script completed \u2713"

echo -n -e "Select boot option: \n"
log_info "1) JTAG"
log_info "2) SD"
log_info "3) None"
read option
case $option in
1 )
        log_info "Booting via JTAG..."
        petalinux-boot --jtag --fpga
        petalinux-boot --jtag --kernel
        ;;

2 )
        log_info "Preparing SD card..."
        prepare_sd
        ;;
3 )
        log_warn "Exiting..."
        ;;
*) 
        echo "Invalid input"
        ;;
esac

