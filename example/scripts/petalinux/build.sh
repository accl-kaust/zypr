#!/bin/bash

# Pass root dir into script
# ROOT_DIR=$1
DESIGN_NAME=$1

ERROR='\e[0;31m'
SUCCESS="\e[0;32m"
WARNING="\e[0;33m"
INFO="\e[0;34m"
NONE="\e[0m"

# Check for correct shell:
if ! [ -z $PETALINUX ]; then
  if [ $(readlink /proc/$$/exe) != "/bin/bash" ]; then
    echo -e "${ERROR}Incorrect shell, please use bin/bash.${NONE}"
    exit 1
  fi
  source <petalinux-install-dir>/settings.sh
  source <vivado-install-dir>/settings64.sh
fi
# Get a list of all the exported projects
pwd
project_name=(`find ${DESIGN_NAME} -name "*.sdk"`)

# Iterate through all of those files

# Get the project name
proj=$(echo $project_name | tr "/" "\n" | sed -n '3p')
echo "INFO: Exported Vivado project found: $proj"
echo "> Export location [$project_name]"

# Name of the HDF file
hdf="$project_name/${proj}_wrapper.hdf"
if [ -f "$hdf" ]; then
  echo "> HDF file exists [$hdf]"
else
  echo "> HDF file does not exist"
  echo "> PetaLinux will not be built for this project"
  echo
  continue
fi

# Name of the BIT file
runs=$(echo $project_name | sed -e "s/.sdk/.runs/g")
bit="$runs/impl_1/${proj}_wrapper.bit"
if [ -f "$bit" ]; then
  echo "> BIT file exists [$bit]"
else
  echo "> BIT file does not exist"
  echo "> PetaLinux will not be built for this project"
  echo
  continue
fi

# Get the port configuration
if [[ $proj == "axi_eth" ]]; then
  portconfig="ports-0123-axieth"
else
  portconfig="ports-0123"
fi

# CPU type is ZynqMP
cpu_type="zynqMP"
fsbl_option="--fsbl ./images/linux/zynqmp_fsbl.elf"

echo "> CPU_TYPE: $cpu_type"

# Create PetaLinux project if it does not exists
if [ -d "./$proj" ]; then
  echo "> PetaLinux project already exists"
else
  echo "> Creating PetaLinux project"
  petalinux-create --type project --template $cpu_type --name $proj
fi

cd $proj

# Configure PetaLinux project with hardware description if 'components' dir doesn't exist
if [ -d "./components" ]; then
  echo "> PetaLinux project already configured with hardware description"
else
  echo "> Configuring PetaLinux project with hardware description"
  petalinux-config --get-hw-description ../$project_name --oldconfig
fi

# Copy PetaLinux config files
if [[ -f "configdone.txt" ]]; then
  echo "> PetaLinux config files already transferred"
else
  echo "> Transferring PetaLinux config files"
  cp -R ../src/common/* .
  cp -R ../src/$portconfig/* .
  # Append mods to config file
  config_mod_list=(`find ./project-spec/configs/ -name "config_*.append"`)
  for project_name in ${config_mod_list[*]}
  do
    cat $project_name >> ./project-spec/configs/config
  done
  # Append mods to rootfs_config file
  rootfs_config_mod_list=(`find ./project-spec/configs/ -name "rootfs_config_*.append"`)
  for project_name in ${rootfs_config_mod_list[*]}
  do
    cat $project_name >> ./project-spec/configs/rootfs_config
  done
  # File to indicate that config files have been transferred
  touch configdone.txt
  # Run petalinux-config again to register the config files
  petalinux-config --oldconfig
fi

# Build PetaLinux project if not built already
if [ -d "./images" ]; then
  echo "> PetaLinux project already built"
else
  echo "> Building PetaLinux project"
  petalinux-build
fi

# Package PetaLinux project if not packaged
if [[ -f "./images/linux/BOOT.BIN" && -f "./images/linux/image.ub" ]]; then
  echo "> PetaLinux project already packaged"
else
  echo "> Packaging PetaLinux project"
  petalinux-package --boot $fsbl_option --fpga ../$bit --u-boot
fi
cd ..

echo "PetaLinux build script completed"

