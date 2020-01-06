############################ Packages ############################
package require json
# Load config.json
set ROOT_PATH [lindex $argv 0]
# set ROOT_PATH [exec sh -c {cd ../../; pwd}]
set cfg [read [open "$ROOT_PATH/global_config.json" r]]
set global_config [json::json2dict $cfg] 
############################ Setup  #############################

set_param board.repoPaths [list "../board"]

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
set design_name [dict get $global_config design design_name]

create_project system_top "./.checkpoint_prj" -part $fpga_part -force
set_property BOARD_PART $board_part [current_project]
set_property ip_repo_paths ../../../../ip [current_fileset]
update_ip_catalog

# Setup Configs (RTL)
set MODE_LIST [list]
set work_directory "$ROOT_PATH/rtl/"
dict for {mode modes} [dict get $global_config design design_mode] {
    # puts "Mode: $mode"
    dict for {configuration configurations} [dict get $global_config design design_mode $mode configs] {
        puts "Mode : $mode"
        puts "Config : $configuration"
        set top_module_file [dict get $configurations top_module]
        set top_module_file_trim [string trim $top_module_file ".v"]
        set top_module_json [read [open "$ROOT_PATH/rtl/.json/$top_module_file_trim.json" r]]
        set top_module_json [json::json2dict $top_module_json] 
        puts "Top Module File : $top_module_file"
        # puts $top_module_json
        set top_module_name [dict get $top_module_json TOP_MODULE]
        puts "Top Module : $top_module_name"
        # Generate Static Regions
        set rtl_list [list]
        foreach item [dict get $configurations rtl] {
            puts "RTL : $item"
            lappend rtl_list $work_directory$item
        }
        set idx [lsearch $rtl_list $work_directory$top_module_file]
        set rtl_list_clean [lreplace $rtl_list $idx $idx]
        puts "Files added to RTL : $rtl_list_clean"
        # add_files $rtl_list_clean
        set top_file [json::json2dict [read [open "$ROOT_PATH/rtl/.modes/$mode/$configuration/hier.json" r]]]
        puts [lindex [split [string trimright [dict get $top_file vhier module_files file] '.v'] '/'] end]
        set top_module [dict get [json::json2dict [read [open "$ROOT_PATH/rtl/.json/[lindex [split [string trimright [dict get $top_file vhier module_files file] '.v'] '/'] end].json" r]]] TOP_MODULE]
        puts $top_module
        add_files $rtl_list_clean
        synth_design -top $top_module -mode out_of_context -part $fpga_part
        write_checkpoint $ROOT_PATH/rtl/.modes/$mode/$configuration/.checkpoints/pr_module.dcp -force
    }
}
