#file copy -force [file join $work_directory $design_name.runs "impl_1" ${design_name}_wrapper.hwdef] [file join $work_directory $design_name.sdk $design_name.hwdef]

open_project [lindex $argv 0]

set work_directory [get_property DIRECTORY [current_project]]
set design_name [get_property NAME [current_project]]

write_hw_platform -fixed -force -file [file join $work_directory $design_name.sdk $design_name.xsa] -include_bit [file join $work_directory $design_name.runs "impl_1" ${design_name}_wrapper.bit]