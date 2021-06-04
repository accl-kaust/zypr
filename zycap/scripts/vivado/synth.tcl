set design_name [get_property NAME [current_project]]
logger "Starting ${design_name}_wrapper synth..." SUCCESS
set_property top ${design_name}_wrapper [current_fileset]

set current_runs [get_runs -regexp -filter {IS_SYNTHESIS}]
# logger $current_runs INFO
# if { [get_property PROGRESS [get_runs synth_1]] != "100%"} {
#   launch_runs synth_1
#   wait_on_run synth_1
#   logger "Synthesis completed" SUCCESS
# } else {
#   logger "Synthesis already complete" INFO
# }

if { [get_property PROGRESS [get_runs synth_1]] != "100%"} {
    set start [clock seconds]
    # # launch_runs synth_1
    # foreach tcl_obj $current_runs {
    #     if { "BlockSrcs" == [get_property FILESET_TYPE [get_property SRCSET [get_runs $tcl_obj]]] } {
    #         logger "Starting ${tcl_obj} synthesis..." INFO
    #         launch_runs $tcl_obj
    #         wait_on_run $tcl_obj
    #         if { "synth_design Complete!" != [get_property STATUS [get_runs $tcl_obj]] } {
    #             logger "Synthesis for ${tcl_obj} failed. \u2717" ERROR
    #             exit 1
    #         }
    #         else {
    #             set time [expr {[clock seconds] - $start}]
    #             logger "Synthesis for ${tcl_obj} completed @ [clock format $time -format {%H:%M:%S}  -gmt true] \u2713" SUCCESS
    #         }
    #     } 
    # }
    # # launch_runs synth_1
    # set mylist [lreplace $current_runs 0 0]
    launch_runs $current_runs -jobs 8
    wait_on_run synth_1
    foreach synth_run $current_runs {
        if { "BlockSrcs" == [get_property FILESET_TYPE [get_property SRCSET [get_runs $synth_run]]] } {
            set time [get_property STATS.ELAPSED [get_runs $synth_run]]
            set pass [ expr { [ regexp -nocase -- { synth_design (Complete) } [ get_property STATUS [ get_runs $synth_run ] ] match ] == 1 ? "ERROR" : "SUCCESS" } ]
            logger "$time - $pass - $synth_run" $pass
            if { $pass == "ERROR" } {
                exit [regexp -nocase -- {synth_design (error|failed)} [get_property STATUS [get_runs $synth_run]] match]
            }
        } 
    }
    set finish [clock seconds]
    set total [expr {$finish - $start}]
    logger "Synthesis completed in [clock format $total -format {%H:%M:%S}  -gmt true] \u2713" SUCCESS
} else {
    logger "Synthesis already complete" INFO
}