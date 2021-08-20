############################ Packages ############################
package require json
# Load config.json
set ROOT_PATH [lindex $argv 0]
# set ROOT_PATH [exec sh -c {cd ../../; pwd}]
set cfg [read [open "$ROOT_PATH/global_config.json" r]]
set global_config [json::json2dict $cfg] 
############################ Setup  #############################

set DEVICE_PART [dict get $global_config project project_device device]
set DEVICE_BOARD [dict get $global_config project project_device board]

create_project system_top ./$PROJECT_NAME -part $DEVICE_PART -force
set_property BOARD_PART $DEVICE_BOARD [current_project]
set_property ip_repo_paths ../../../../ip [current_fileset]
update_ip_catalog