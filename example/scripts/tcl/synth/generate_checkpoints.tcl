############################ Packages ############################
package require json
# Load config.json
set ROOT_PATH [exec sh -c {cd ../../../; pwd}]
set cfg [read [open "$ROOT_PATH/global_config.json" r]]
set global_config [json::json2dict $cfg] 
############################ Setup  #############################
# Setup Project
set PROJECT_NAME [dict get $global_config design design_name]
puts "Setting up $PROJECT_NAME..."
# Setup Device
set DEVICE_PART [dict get $global_config project project_device device]
set DEVICE_BOARD [dict get $global_config project project_device board]
# Setup Configs (RTL)
set MODE_LIST [list]
dict for {mode modes} [dict get $global_config design design_mode] {
    puts "Mode: $mode"
    foreach item [dict keys $modes configs] {
        set value [dict get $modes $item]
        puts $value
    }

}
