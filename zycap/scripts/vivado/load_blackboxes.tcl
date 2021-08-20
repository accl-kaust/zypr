
# Set PR cells to HD.RECONFIGURABLE
set bb_inst [get_cells -hier -filter IS_BLACKBOX]
foreach i $bb_inst {
    set_property HD.RECONFIGURABLE true [get_cells $i]
}


open_run synth_1 -name synth_1


read_checkpoint ../modes/mode1.dcp -cell system_i/partial_led_test_0

# Generate pBlock