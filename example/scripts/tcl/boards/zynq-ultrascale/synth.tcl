package require json
set ROOT_PATH "[lindex $argv 0]"
set log_dir "$ROOT_PATH/rtl/.logs"

set cfg [read [open "$ROOT_PATH/global_config.json" r]]
set global_config [json::json2dict $cfg] 

source "$ROOT_PATH/scripts/tcl/utils/cpu_threads.tcl"
source "$ROOT_PATH/scripts/tcl/utils/log_colors.tcl"

set design_name [dict get $global_config design design_name]

open_project "$ROOT_PATH/rtl/${design_name}/${design_name}.xpr"

# set_property PR_FLOW 1 [current_project] 


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


            if {[get_pblocks] eq ""} {
                puts "${INFO}Generating pblock... ${NONE}"
                startgroup
                create_pblock pblock_1
                # Could use Vipin's work to generate this
                # resize_pblock pblock_1 -add CLOCKREGION_X0Y1:CLOCKREGION_X0Y1
                # resize_pblock pblock_1 -add CLOCKREGION_X0Y1:CLOCKREGION_X0Y1 

                # resize_pblock [get_pblocks pblock_1] -add {SLICE_X5Y65:SLICE_X20Y108}
                # resize_pblock [get_pblocks pblock_1] -add {DSP48E2_X0Y26:DSP48E2_X1Y41}
                # resize_pblock [get_pblocks pblock_1] -add {RAMB18_X1Y26:RAMB18_X2Y41}
                # resize_pblock [get_pblocks pblock_1] -add {RAMB36_X1Y13:RAMB36_X2Y20}
                # resize_pblock [get_pblocks pblock_1] -add {SLICE_X5Y0:SLICE_X23Y130}
                # resize_pblock [get_pblocks pblock_1] -add {DSP48E2_X0Y0:DSP48E2_X1Y51}
                # resize_pblock [get_pblocks pblock_1] -add {RAMB18_X1Y0:RAMB18_X2Y51}
                # resize_pblock [get_pblocks pblock_1] -add {RAMB36_X1Y0:RAMB36_X2Y25}
                # resize_pblock pblock_1 -add {SLICE_X5Y1:SLICE_X26Y125 DSP48E2_X1Y2:DSP48E2_X1Y49 RAMB18_X1Y2:RAMB18_X2Y49 RAMB36_X1Y1:RAMB36_X2Y24}
                # Largest Bitstream
                # resize_pblock [get_pblocks pblock_1] -add {SLICE_X2Y66:SLICE_X48Y115}
                # resize_pblock [get_pblocks pblock_1] -add {DSP48E2_X0Y28:DSP48E2_X4Y45}
                # resize_pblock [get_pblocks pblock_1] -add {RAMB18_X0Y28:RAMB18_X5Y45}
                # resize_pblock [get_pblocks pblock_1] -add {RAMB36_X0Y14:RAMB36_X5Y22}
                # Medium Bitstream
                resize_pblock [get_pblocks pblock_1] -add {SLICE_X2Y67:SLICE_X36Y116}
                resize_pblock [get_pblocks pblock_1] -add {DSP48E2_X0Y28:DSP48E2_X2Y45}
                resize_pblock [get_pblocks pblock_1] -add {RAMB18_X0Y28:RAMB18_X4Y45}
                resize_pblock [get_pblocks pblock_1] -add {RAMB36_X0Y14:RAMB36_X4Y22}
            } 
            # else {
            #     puts "${INFO}pblock exists, appending... ${NONE}"
            #     add_cells_to_pblock pblock_1 [get_cells [list base_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst]] -clear_locs
            # } 
            read_checkpoint "$ROOT_PATH/rtl/.modes/$mode/$configuration/.checkpoints/pr_module.dcp" -cell "${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst"

            set_property HD.RECONFIGURABLE true [get_cells ${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst]

            add_cells_to_pblock pblock_1 [get_cells [list ${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst]] -clear_locs

            create_drc_ruledeck ruledeck_1
            add_drc_checks -ruledeck ruledeck_1 [get_drc_checks {HDPRA-62 HDPRA-60 HDPRA-58 HDPRA-57 HDPRA-56 HDPRA-55 HDPRA-54 HDPRA-53 HDPRA-52 HDPRA-51 HDPRA-21 HDPR-43 HDPR-20 HDPR-88 HDPR-41 HDPR-30 HDPR-95 HDPR-94 HDPR-93 HDPR-92 HDPR-91 HDPR-90 HDPR-87 HDPR-86 HDPR-85 HDPR-84 HDPR-83 HDPR-74 HDPR-73 HDPR-72 HDPR-71 HDPR-70 HDPR-69 HDPR-68 HDPR-67 HDPR-66 HDPR-65 HDPR-64 HDPR-63 HDPR-62 HDPR-61 HDPR-60 HDPR-59 HDPR-58 HDPR-57 HDPR-54 HDPR-50 HDPR-49 HDPR-48 HDPR-47 HDPR-46 HDPR-44 HDPR-42 HDPR-38 HDPR-37 HDPR-35 HDPR-34 HDPR-33 HDPR-32 HDPR-29 HDPR-28 HDPR-25 HDPR-23 HDPR-22 HDPR-18 HDPR-17 HDPR-16 HDPR-14 HDPR-13 HDPR-12 HDPR-11 HDPR-6 HDPR-5 HDPR-4 HDPR-3 HDPR-2 HDPR-1}]
            report_drc -name drc_2 -ruledecks {ruledeck_1}

            # if {[get_pblocks] eq ""} {
            #     puts "${INFO}Generating pblock... ${NONE}"
            #     startgroup
            #     create_pblock pblock_1
            #     # Could use Vipin's work to generate this
            #     ### TEST 1
            #     resize_pblock pblock_1 -add CLOCKREGION_X0Y1:CLOCKREGION_X0Y1 
            #     # resize_pblock pblock_1 -add CLOCKREGION_X0Y1:CLOCKREGION_X0Y2

            #     ### TEST 2
            #     # resize_pblock pblock_1 -add {SLICE_X0Y32:SLICE_X48Y120 DSP48E2_X0Y14:DSP48E2_X4Y47 RAMB18_X0Y14:RAMB18_X5Y47 RAMB36_X0Y7:RAMB36_X5Y23} -locs keep_all -replace
            #     # set_property SNAPPING_MODE OFF [get_pblocks pblock_1]
            #     # resize_pblock pblock_1 -add {SLICE_X8Y60:SLICE_X48Y138 DSP48E2_X1Y24:DSP48E2_X4Y53 RAMB18_X1Y24:RAMB18_X5Y53 RAMB36_X1Y12:RAMB36_X5Y26}


            #     ### TEST 3
            #     # resize_pblock pblock_1 -add {SLICE_X1Y0:SLICE_X48Y175 DSP48E2_X0Y0:DSP48E2_X4Y69 RAMB18_X0Y0:RAMB18_X5Y69 RAMB36_X0Y0:RAMB36_X5Y34} -locs keep_all -replace
            #     add_cells_to_pblock pblock_1 [get_cells [list ${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst]] -clear_locs
            #     endgroup
            # } else {
            #     # set_property SNAPPING_MODE OFF [get_pblocks pblock_1]
            #     # resize_pblock pblock_1 -add {SLICE_X2Y0:SLICE_X48Y174 DSP48E2_X0Y0:DSP48E2_X4Y69 RAMB18_X0Y0:RAMB18_X5Y69 RAMB36_X0Y0:RAMB36_X5Y34}
            #     puts "${INFO}pblock exists, appending... ${NONE}"
            #     add_cells_to_pblock pblock_1 [get_cells [list ${design_name}_i/partial_led_test_v1_0_0/inst/partial_led_test_v1_0_S00_AXI_inst]] -clear_locs
            # } 

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
            
            report_utilization -hierarchical -hierarchical_depth 3 -file "$log_dir/resources_$mode-$configuration.log"
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
            report_utilization -hierarchical -hierarchical_depth 3 -file "$log_dir/resources_$mode-$configuration.log"
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