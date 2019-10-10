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
set DEVICE_PART [dict get $global_config project project_device device]
set DEVICE_BOARD [dict get $global_config project project_device board]

create_project system_top ./$PROJECT_NAME -part $DEVICE_PART -force
set_property BOARD_PART $DEVICE_BOARD [current_project]
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
            puts $rtl_list
            add_files $rtl_list
        }
        synth_design -top $top_module_name
        write_checkpoint $ROOT_PATH/rtl/.modes/$mode/.checkpoints/static.dcp -force
    }
}
