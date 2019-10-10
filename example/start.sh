ZYCAP_ROOT_PATH=$(pwd)
VIVADO="/opt/Xilinx/Vivado/2018.2/bin/vivado"

cd $ZYCAP_ROOT_PATH/rtl && make clean-meta

if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.json" ]; then
    echo "Extracting Modules..."
    perl $ZYCAP_ROOT_PATH/scripts/perl/extract_modules.pl 
fi

if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.blackbox" ]; then
    echo "Generating Black Boxes..."
    python $ZYCAP_ROOT_PATH/scripts/python/generate_blackbox.py
fi

if [ ! -d "$ZYCAP_ROOT_PATH/rtl/.modes" ]; then
    echo "Generating Configs & Modes..."
    python $ZYCAP_ROOT_PATH/scripts/python/generate_interface.py
fi

exec $VIVADO -mode batch -source $ZYCAP_ROOT_PATH/scripts/tcl/boards/zynq-ultrascale/gen_bd.tcl -tclargs $ZYCAP_ROOT_PATH
# exec $ZYCAP_ROOT_PATH/scripts/tcl/synth/synth.sh $VIVADO $ZYCAP_ROOT_PATH/scripts/tcl/synth/generate_checkpoints.tcl $ZYCAP_ROOT_PATH