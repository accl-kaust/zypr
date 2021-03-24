#!/usr/bin/tclsh

# 'try if gmake not installed' - sudo ln -s /usr/bin/make /usr/bin/gmake

set app_name          "dts"
#set app_type          "zynqmp_fsbl"
set project_name      [lindex $argv 0] 
set hwspec_file       "${project_name}.xsa"
set proc_name         [lindex $argv 2]
set repo_name         [lindex $argv 3]
set project_dir       [file join [pwd] [lindex $argv 1]]
set sdk_workspace     [file join $project_dir "${project_name}.sdk"]
set app_dir           [file join ${sdk_workspace}/device_tree $app_name]

puts [file join $sdk_workspace $hwspec_file]
set hw_design         [hsi::open_hw_design [file join $sdk_workspace $hwspec_file]]

#hsi::generate_app -hw $hw_design -os standalone -proc $proc_name -app $app_type -compile -dir $app_dir
#file copy -force [file join $app_dir "executable.elf"] [file join $sdk_workspace $app_release_elf]

#set hdf path/to/hdf-file.hdf
#open_hw_design $hdf

hsi::set_repo_path $repo_name
hsi::create_sw_design device-tree -os device_tree -proc $proc_name
hsi::set_property CONFIG.dt_overlay true [hsi::get_os]
hsi::generate_target -dir $app_dir
hsi::close_hw_design [hsi::current_hw_design]