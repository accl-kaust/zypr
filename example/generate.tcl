############################ Packages ############################
package require json
# Load config.json
set cfg [read [open "./global_config.json" r]]
set global_config [json::json2dict $cfg] 
set ROOT_PATH [exec sh -c {cd ../; pwd}]
############################ Setup  #############################
# Setup Project
set PROJECT_NAME [dict get $global_config project project_name]
puts "Setting up $PROJECT_NAME..."
# Setup Device
set DEVICE_PART [dict get $global_config project project_device part]
set DEVICE_BOARD [dict get $global_config project project_device board]
# Setup Configs (RTL)
set CONFIG_LIST [list]
dict for {project_configuration configuration} [dict get $global_config project project_config] {
    lappend CONFIG_LIST "$configuration"
}

###################### Generate Configs #########################

foreach config $CONFIG_LIST {
    puts "Generating $config configuration..."
    # cd ./configs/$config/.vivado
    set local_cfg [read [open "./configs/$config/config.json" r]]
    set local_config [json::json2dict $local_cfg] 
    set REGION_LIST [list]
    dict for {regions region} [dict get $local_config config config_region] {
        lappend REGION_LIST $regions
    }   
    foreach region $REGION_LIST {
        puts "Generating $config $region region..."
        create_project -part $DEVICE_PART $config-$region ./configs/$config/$region/.vivado/ -force
        set_property BOARD_PART $DEVICE_BOARD [current_project]
        set top_file [lindex [dict get $local_config config config_region $region region_top] 0]
        set top_module [lindex [dict get $local_config config config_region $region region_top] 1]
        add_files ./configs/$config/$region/rtl/
        set_property top_file ./configs/$config/$region/rtl/$top_file [current_fileset]
        set_property top $top_module [current_fileset]

        update_compile_order -fileset sources_1
        set_property source_mgmt_mode All [current_project]        
        # Partial Reconfiguration
        set_property PR_FLOW 1 [current_project] 

        set MODE_LIST [dict create]
        dict for {mode modes} [dict get $local_config config config_region $region region_mode] {
            dict set MODE_LIST $mode [lindex $modes 0] [lindex $modes 1]
        }
        create_partition_def -name $region -module [lindex [lindex [dict get $MODE_LIST] 1] 1]

        foreach {mode info} $MODE_LIST {
            incr i
            create_reconfig_module -name $mode -partition_def [get_partition_defs $region]  -define_from  [lindex $info 1] -define_from_file ./configs/$config/$region/rtl/[lindex $info 0]
            import_files -norecurse ./configs/$config/$region/rtl/[lindex $info 0]  -of_objects [get_reconfig_modules $mode]
            create_pr_configuration -name "config_$i" -partitions [list partial_led_test_v1_0_S00_AXI_inst:$mode ]
        }



        setup_pr_configurations
        # set_property PR_CONFIGURATION config-1 [get_runs impl_1]
        # create_run child_0_impl_1 -parent_run impl_1 -flow {Vivado Implementation 2018} -pr_config config-2

        # create_reconfig_module -name region_2 -partition_def [get_partition_defs mode_1 ] 
        # create_pr_configuration -name config_1 -partitions [list partial_led_test_v1_0_S00_AXI_inst:region_1 ]
        # create_pr_configuration -name config_2 -partitions [list partial_led_test_v1_0_S00_AXI_inst:region_2 ]
        # set_property PR_CONFIGURATION config_1 [get_runs impl_1]
        # create_run child_0_impl_1 -parent_run impl_1 -flow {Vivado Implementation 2018} -pr_config config_2
        #         puts "test"

        launch_runs synth_1 -jobs 4
        puts "test"

        write_checkpoint -force "./configs/.checkpoints/$config-$region.dcp"
        close_project
    }
    cd $ROOT_PATH/$PROJECT_NAME/
}
# add_files ./src/
# # Enable PR Flow

# set REGION_NAMES [dict keys [dict get [dict create region [dict get $config partials regions]] region]]

# puts [dict get $REGIONS]