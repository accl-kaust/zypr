logger "Generating Build Reports..." INFO

set work_directory [get_property DIRECTORY [current_project]]
set design_name [get_property NAME [current_project]]


# Open implementation
set checkpoints [glob $work_directory/$design_name.checkpoint/final/*.dcp]

foreach i $checkpoints { 
    # Open Checkpoint
    open_checkpoint $i

    # Get filename
    set fbasename [file rootname [file tail $i]]

    # Create report directory
    set rptdir $work_directory/$design_name.reports/$fbasename
    file mkdir $rptdir

    # Create a datasheet for the current design
    report_datasheet -file [file join $rptdir datasheet.txt]

    # Report utilization of the current device
    set rptutil [file join $rptdir utilization.txt]
    report_utilization -hierarchical -file $rptutil

    # Report information about clock nets in the design
    report_clock_utilization -file $rptutil -append

    # Report the RAM resources utilized in the implemented design
    report_ram_utilization -file $rptutil -append -detail

    # Report timing summary for a max of 10 paths per group
    report_timing_summary -file [file join $rptdir timing.txt] -max_paths 10

    # Report the highest fanout of nets in the implemented design
    report_high_fanout_nets -file [file join $rptdir fanout.txt] -timing -load_types -max_nets 25

    # Run DRC
    report_drc -file [file join $rptdir drc.txt]

    # Report details of the IO banks in the design
    report_io -file [file join $rptdir io.txt]

    # Report a table of all clocks in the design
    report_clocks -file [file join $rptdir clocks.txt]

    # Close Checkpoint
    close_design
}