ZYCAP_ROOT_PATH=$(pwd)
VIVADO="/opt/Xilinx/Vivado/2018.2/bin/vivado"
BOARD="zynq-ultrascale"
DESIGN_NAME="dynamic-peripheral"

cd $ZYCAP_ROOT_PATH/rtl && make clean-meta
mkdir $ZYCAP_ROOT_PATH/rtl/.logs

function check_error {
    local error=$( grep "^ERROR" $1 )
    if [ -n "$error" ]; then
        echo -e "\e[31m$1 - $error\e[39m"
        exit 1
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

echo "Extracting Modules..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.json" ]; then
    echo -e "\e[33mNot found, generating...\e[39m"
    perl $ZYCAP_ROOT_PATH/scripts/perl/extract_modules.pl "$ZYCAP_ROOT_PATH/rtl" > "$ZYCAP_ROOT_PATH/rtl/.logs/extract_modules.log"
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/extract_modules.log"
fi
echo -e "\e[32mFinished \u2713\e[39m"

echo "Generating Black Boxes..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.blackbox" ]; then
    echo -e "\e[33mNot found, generating...\e[39m"
    python $ZYCAP_ROOT_PATH/scripts/python/generate_blackbox.py > "$ZYCAP_ROOT_PATH/rtl/.logs/generate_bb.log"
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/generate_bb.log"
fi
echo -e "\e[32mFinished \u2713\e[39m"

echo "Constructing Configs & Modes..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.modes" ]; then
    echo -e "\e[33mNot found, generating...\e[39m"
    python $ZYCAP_ROOT_PATH/scripts/python/generate_interface.py > "$ZYCAP_ROOT_PATH/rtl/.logs/construct_pr.log"
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/construct_pr.log"
fi
echo -e "\e[32mFinished \u2713\e[39m"

echo "Synthesising PR Configs & Modes..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.checkpoint_prj" ]; then
    echo -e "\e[33mNot found, generating...\e[39m"
    exec $ZYCAP_ROOT_PATH/scripts/tcl/synth/synth.sh $VIVADO $ZYCAP_ROOT_PATH/scripts/tcl/synth/generate_checkpoints.tcl $ZYCAP_ROOT_PATH > "$ZYCAP_ROOT_PATH/rtl/.logs/pr_synth.log" &
    show_spinner $!
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/pr_synth.log"
fi
echo -e "\e[32mFinished \u2713\e[39m"

echo "Building Block Diagram..."
if [ ! -d "$ZYCAP_ROOT_PATH/rtl/$DESIGN_NAME" ]; then
    echo -e "\e[33mNot found, generating...\e[39m"
    exec $VIVADO -mode batch -source $ZYCAP_ROOT_PATH/scripts/tcl/boards/$BOARD/gen_bd.tcl -tclargs $ZYCAP_ROOT_PATH > "$ZYCAP_ROOT_PATH/rtl/.logs/bd_output.log" &
    show_spinner $!
    check_error "$ZYCAP_ROOT_PATH/rtl/.logs/bd_output.log"
fi
echo -e "\e[32mFinished \u2713\e[39m"

