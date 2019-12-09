package require json
set ROOT_PATH "[lindex $argv 0]"
set log_dir "$ROOT_PATH/rtl/.logs"

set cfg [read [open "$ROOT_PATH/global_config.json" r]]
set global_config [json::json2dict $cfg] 

source "$ROOT_PATH/scripts/tcl/generic/cpu_threads.tcl"

open_project "$ROOT_PATH/rtl/base_design/base_design.xpr"

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    set threads [numberOfCPUs]
    reset_run synth_1
    update_compile_order -fileset sources_1
    launch_runs synth_1 -jobs $threads
    wait_on_run synth_1 
    if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
        error "ERROR: synth_1 failed"
    }
}

open_run synth_1 -name synth_1

file mkdir "$ROOT_PATH/rtl/base_design/base_design.checkpoints"

write_checkpoint -force "$ROOT_PATH/rtl/base_design/base_design.checkpoints/base.dcp"

close_design
# set_property HD.RECONFIGURABLE true [get_cells base_design_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst]

# # manually load the checkpoint
# read_checkpoint "$ROOT_PATH/rtl/.modes/mode_a/config_a/.checkpoints/pr_module.dcp -cell base_design_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst"

###################################################
# P & R (For each mode & config)
###################################################

dict for {mode modes} [dict get $global_config design design_mode] {
    dict for {configuration configurations} [dict get $global_config design design_mode $mode configs] {
        open_checkpoint "$ROOT_PATH/rtl/base_design/base_design.checkpoints/base.dcp"

        # update_design -cell base_design_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst -black_box

        set_property HD.RECONFIGURABLE true [get_cells base_design_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst]

        read_checkpoint "$ROOT_PATH/rtl/.modes/$mode/$configuration/.checkpoints/pr_module.dcp" -cell "base_design_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst"

        if {[get_pblocks] eq ""} {
            startgroup
            create_pblock pblock_1
            resize_pblock pblock_1 -add CLOCKREGION_X0Y1:CLOCKREGION_X0Y1
            add_cells_to_pblock pblock_1 [get_cells [list base_design_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst]] -clear_locs
            endgroup
        }

        file mkdir "$ROOT_PATH/rtl/.modes/$mode/$configuration/.constraint"
        write_xdc -force "$ROOT_PATH/rtl/.modes/$mode/$configuration/.constraint/top.xdc"
        
        opt_design > $log_dir/vivado_cp_$mode-$configuration-opt.log
        place_design > $log_dir/vivado_cp_$mode-$configuration-place.log
        route_design > $log_dir/vivado_cp_$mode-$configuration-route.log

        # write_checkpoint $ROOT_PATH/rtl/.modes/$mode/$configuration/.checkpoints/pr_module.dcp -force
        write_checkpoint -force "$ROOT_PATH/rtl/base_design/base_design.checkpoints/$mode-$configuration.dcp"
        close_design
    }
}


# update_design -cell base_design_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst -black_box

# # link_design > $log_dir/vivado_bd_link.log
# opt_design > $log_dir/vivado_cp_SPECIFIC_opt.log
# place_design > $log_dir/vivado_cp_SPECIFIC_place.log
# route_design > $log_dir/vivado_cp_SPECIFIC_route.log

# write_checkpoint -force "$ROOT_PATH/rtl/base_design/base_design.checkpoints/mode_a_config_a.dcp"

# # generate static region
# update_design -cell base_design_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst -black_box

# lock_design -level routing

# write_checkpoint -force "$ROOT_PATH/rtl/base_design/base_design.checkpoints/static.dcp"

close_design