package require json
set ROOT_PATH "[lindex $argv 0]"
set log_dir "$ROOT_PATH/rtl/.logs"

set cfg [read [open "$ROOT_PATH/global_config.json" r]]
set global_config [json::json2dict $cfg] 

source "$ROOT_PATH/scripts/tcl/utils/cpu_threads.tcl"
source "$ROOT_PATH/scripts/tcl/utils/log_colors.tcl"

set design_name [dict get $global_config design design_name]

open_project "$ROOT_PATH/rtl/${design_name}/${design_name}.xpr"

# reset_run synth_1


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

file mkdir "$ROOT_PATH/rtl/${design_name}/${design_name}.checkpoints"

write_checkpoint -force "$ROOT_PATH/rtl/${design_name}/${design_name}.checkpoints/base.dcp"

close_design
# set_property HD.RECONFIGURABLE true [get_cells ${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst]

# # manually load the checkpoint
# read_checkpoint "$ROOT_PATH/rtl/.modes/mode_a/config_a/.checkpoints/pr_module.dcp -cell ${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst"

###################################################
# P & R (For each mode & config)
###################################################

set design_checkpoints {}

dict for {mode modes} [dict get $global_config design design_mode] {
    dict for {configuration configurations} [dict get $global_config design design_mode $mode configs] {

        # puts "$INFO Generating for $mode $configuration... $NONE"
        if { ![info exists initial_checkpoint] } {
            set initial_checkpoint "$ROOT_PATH/rtl/${design_name}/${design_name}.checkpoints/$mode-$configuration.dcp"
            set initial_mode "$mode-$configuration"
        }

        if { ![file exists "$ROOT_PATH/rtl/${design_name}/${design_name}.checkpoints/static.dcp"] } {

            puts "${WARNING}No static logic exists, generating... $NONE"

            open_checkpoint "$ROOT_PATH/rtl/${design_name}/${design_name}.checkpoints/base.dcp"

            # update_design -cell ${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst -black_box

            set_property HD.RECONFIGURABLE true [get_cells ${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst]

            read_checkpoint "$ROOT_PATH/rtl/.modes/$mode/$configuration/.checkpoints/pr_module.dcp" -cell "${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst"

            if {[get_pblocks] eq ""} {
                puts "${INFO}Generating pblock... ${NONE}"
                startgroup
                create_pblock pblock_1
                # Could use Vipin's work to generate this
                resize_pblock pblock_1 -add CLOCKREGION_X0Y1:CLOCKREGION_X0Y1
                add_cells_to_pblock pblock_1 [get_cells [list ${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst]] -clear_locs
                endgroup
            } else {
                add_cells_to_pblock pblock_1 [get_cells [list base_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst]] -clear_locs
            } 

            file mkdir "$ROOT_PATH/rtl/.modes/$mode/$configuration/.constraint"
            write_xdc -force "$ROOT_PATH/rtl/.modes/$mode/$configuration/.constraint/top.xdc"

            puts "${INFO}Generating $mode $configuration checkpoint... $NONE"

            opt_design > $log_dir/vivado_cp_$mode-$configuration-opt.log
            place_design > $log_dir/vivado_cp_$mode-$configuration-place.log
            file mkdir "$ROOT_PATH/rtl/${design_name}/${design_name}.hardware"
            write_hwdef -force "$ROOT_PATH/rtl/${design_name}/${design_name}.hardware/${design_name}.hdf"
            route_design > $log_dir/vivado_cp_$mode-$configuration-route.log

            write_checkpoint -force "$ROOT_PATH/rtl/${design_name}/${design_name}.checkpoints/$mode-$configuration.dcp"

            # Generate static logic

            update_design -cell ${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst -black_box

            lock_design -level routing

            puts "${INFO}Generating static checkpoint... $NONE"

            write_checkpoint -force "$ROOT_PATH/rtl/${design_name}/${design_name}.checkpoints/static.dcp"

        } else {

            puts "${INFO}Generating $mode $configuration checkpoint... $NONE"

            open_checkpoint "$ROOT_PATH/rtl/${design_name}/${design_name}.checkpoints/static.dcp"

            read_checkpoint "$ROOT_PATH/rtl/.modes/$mode/$configuration/.checkpoints/pr_module.dcp" -cell "${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst"

            # file mkdir "$ROOT_PATH/rtl/.modes/$mode/$configuration/.constraint"
            # write_xdc -force "$ROOT_PATH/rtl/.modes/$mode/$configuration/.constraint/top.xdc"
            
            opt_design > $log_dir/vivado_cp_$mode-$configuration-opt.log
            place_design > $log_dir/vivado_cp_$mode-$configuration-place.log
            route_design > $log_dir/vivado_cp_$mode-$configuration-route.log

            # write_checkpoint $ROOT_PATH/rtl/.modes/$mode/$configuration/.checkpoints/pr_module.dcp -force
            write_checkpoint -force "$ROOT_PATH/rtl/${design_name}/${design_name}.checkpoints/$mode-$configuration.dcp"

            lappend design_checkpoints "$ROOT_PATH/rtl/${design_name}/${design_name}.checkpoints/$mode-$configuration.dcp"

        }

        if {[current_design] ne ""} {
            close_design
        }

    }
}

puts "$INFO[pr_verify -initial $initial_checkpoint -additional $design_checkpoints]$NONE"

file mkdir "$ROOT_PATH/rtl/${design_name}/${design_name}.bitstreams"

dict for {mode modes} [dict get $global_config design design_mode] {
    dict for {configuration configurations} [dict get $global_config design design_mode $mode configs] {
        open_checkpoint "$ROOT_PATH/rtl/${design_name}/${design_name}.checkpoints/$mode-$configuration.dcp"
        write_bitstream -force "$ROOT_PATH/rtl/${design_name}/${design_name}.bitstreams/$mode-$configuration.bit"
        if { "$mode-$configuration" eq $initial_mode } {
            puts "${INFO}Writing sysdef for ${mode}-${configuration}...${NONE}"
            write_sysdef -force -hwdef "$ROOT_PATH/rtl/${design_name}/${design_name}.hardware/${design_name}.hdf" -bitfile "$ROOT_PATH/rtl/${design_name}/${design_name}.bitstreams/$mode-$configuration.bit" "$ROOT_PATH/rtl/${design_name}/${design_name}.bitstreams/$mode-$configuration.sysdef"
        }
        if {[current_design] ne ""} {
            close_design
        }
    }
}

# file copy -force /home/alex/Documents/PhD/Labs/ES3F1/Zybo-Z7-20-pcam-5c-2018.2-2/vivado_proj/Zybo-Z7-20-pcam-5c/Zybo-Z7-20-pcam-5c.runs/impl_1/system_wrapper.sysdef /home/alex/Documents/PhD/Labs/ES3F1/Zybo-Z7-20-pcam-5c-2018.2-2/vivado_proj/Zybo-Z7-20-pcam-5c/Zybo-Z7-20-pcam-5c.sdk/system_wrapper.hdf
