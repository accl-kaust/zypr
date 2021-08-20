#file copy -force [file join $work_directory $design_name.runs "impl_1" ${design_name}_wrapper.hwdef] [file join $work_directory $design_name.sdk $design_name.hwdef]

# load logging library
source [lindex $argv 1]

logger "Generating HWDef files..." INFO
open_project [lindex $argv 0]

set work_directory [get_property DIRECTORY [current_project]]
set design_name [get_property NAME [current_project]]
set output_xsa [file join $work_directory $design_name.sdk $design_name.xsa]

write_hw_platform -fixed -force -include_bit -file $output_xsa 