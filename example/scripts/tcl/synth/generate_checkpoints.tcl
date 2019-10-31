############################ Packages ############################
package require json
# Load config.json
set ROOT_PATH [lindex $argv 0]
# set ROOT_PATH [exec sh -c {cd ../../; pwd}]
set cfg [read [open "$ROOT_PATH/global_config.json" r]]
set global_config [json::json2dict $cfg] 
############################ Setup  #############################
# Setup Project
set PROJECT_NAME [dict get $global_config design design_name]
puts "Setting up $PROJECT_NAME..."
puts $ROOT_PATH
# Setup Device
set board_name [dict get $global_config project project_device name]
set board_part [dict get $global_config project project_device board]
set board_device [dict get $global_config project project_device device]
set board_package [dict get $global_config project project_device package]
set board_speed [dict get $global_config project project_device speed]
set board_option [dict get $global_config project project_device option]
set board_version [dict get $global_config project project_device version]
set board_constraint [dict get $global_config project project_device constraint]

set fpga_part $board_device$board_package$board_speed$board_option
set design_name "base_design"

create_project system_top "./.checkpoint_prj" -part $fpga_part -force
set_property BOARD_PART $board_part [current_project]
set_property ip_repo_paths ../../../../ip [current_fileset]
update_ip_catalog

# Setup Configs (RTL)
set MODE_LIST [list]
set work_directory "$ROOT_PATH/rtl/.blackbox/"
dict for {mode modes} [dict get $global_config design design_mode] {
    # puts "Mode: $mode"
    foreach config [dict keys $modes configs] {
        set data [dict get $modes $config]
        puts "Mode :$data"
        # Generate Static Regions
        foreach item [dict keys $data] {
            set top_module_file [dict get $data $item top_module]
            set top_module_file_trim [string trim $top_module_file ".v"]
            set top_module_json [read [open "$ROOT_PATH/rtl/.json/$top_module_file_trim.json" r]]
            set top_module_json [json::json2dict $top_module_json] 
            puts "-Top Module File :$top_module_file"
            puts $top_module_json
            set top_module_name [dict get $top_module_json TOP_MODULE]
            puts "--Top Module :$top_module_name"
            set rtl [dict get $data $item rtl]
            puts "--RTL Files :$rtl"
            set rtl_list [list]
            foreach item $rtl {
                puts "test: $item"
                lappend rtl_list $work_directory$item
            }
            set idx [lsearch $rtl_list $work_directory$top_module_file]
            set rtl_list_clean [lreplace $rtl_list $idx $idx]
            puts "files added : $rtl_list_clean"
            add_files $rtl_list_clean
            set top_file [json::json2dict [read [open "$ROOT_PATH/rtl/.modes/$mode/hier.json" r]]]
            synth_design -top_module top_module_name [dict get $top_module_name vhier modules files]
            write_checkpoint $ROOT_PATH/rtl/.modes/$mode/.checkpoints/static.dcp -force
        }
       
    }
}
