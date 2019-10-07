ROOT="~/GitHub/zycap2/example/"


if [ ! -d "$ROOT/rtl/.json" ]; then
    echo "Extracting Modules..."
    perl ../scripts/perl/extract_modules.pl 
fi

if [ ! -d "$ROOT/rtl/.blackbox" ]; then
    echo "Generating Black Boxes..."
    python ../scripts/python/generate_blackbox.py
fi

if [ ! -d "$ROOT/rtl/.modes" ]; then
    echo "Generating Configs & Modes..."
    python ../scripts/python/generate_interface.py
fi

exec ../scripts/tcl/synth/synth.sh ../scripts/tcl/synth/generate_checkpoints.tcl