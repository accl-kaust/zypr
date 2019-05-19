###############################################################
package require json
set cfg [read [open "./global_config.json" r]]
set global_config [json::json2dict $cfg] 
###############################################################
###  Minimum settings required to run PR flow:
###  1. Specify flow steps
###  2. Define target board
###  3. Identify source directories
###  4. Define static module
###  5. Define RPs, and their RM variants
###############################################################
####flow control (1 = run step , 0 = skip step)
set run.static_synth   [dict get $global_config config config_run static_synth];#synthesize static
set run.rm_synth       [dict get $global_config config config_run rm_synth];#synthesize RM variants
set run.pr_impl        [dict get $global_config config config_run pr_impl];#implement each static + RM configuration
set run.pr_verify      [dict get $global_config config config_run pr_verify];#verify RMs are compatible with static
set run.gen_bitstream  [dict get $global_config config config_run gen_bitstream];#generate full and partial bitstreams

set settings(top)       [dict get $global_config config config_settings top_file];
###############################################################
### Define target demo board (select one)
### Valid values: kc705 (default), vc707, vc709, ac701
###############################################################
set xboard             [dict get $global_config project project_device board]
###############################################################
###  Run Settings
###############################################################
####Input Directories
set srcDir     "./Sources"
set rtlDir     "$srcDir/hdl"
set prjDir     "$srcDir/prj"
set xdcDir     "$srcDir/xdc"
set coreDir    "$srcDir/cores"
set netlistDir "$srcDir/netlist"

####Output Directories
set synthDir  "./Synth"
set implDir   "./Implement"
set dcpDir    "./Checkpoint"
set bitDir    "./Bitstreams"

###############################################################
### Static Module Definition
###############################################################
set top "top"

###############################################################
### RP & RM Definitions (Repeat for each RP)
### 1. Define Reconfigurable Partition (RP) name
### 2. Associate Reconfigurable Modules (RMs) to the RP
###############################################################
set CONFIG_LIST [list]
dict for {project_configuration configuration} [dict get $global_config project project_config] {
    lappend CONFIG_LIST "$configuration"
}

foreach configs $CONFIG_LIST {
    set local_cfg [read [open "./configs/$configs/config.json" r]]
    set local_config [json::json2dict $local_cfg] 
    set REGION_LIST [list]
    dict for {regions region} [dict get $local_config configs config_region] {
        lappend REGION_LIST $regions
    }   
    set MODULE_LIST [list]
    dict for {regions region} [dict get $local_config configs config_region] {
        dict for {modules module} [dict get $region] {
            dict for {modes mode} [dict get $module] {
                set variant [lindex $mode  0]
                set variant_inst [lindex $mode  1]
            }
        }
    }   

    foreach regions $REGION_LIST {
        set MODULE_LIST [list]


        set top_file [lindex [dict get $local_config configs config_region $regions region_top] 0]
        set top_module [lindex [dict get $local_config configs config_region $regions region_top] 1]
        set top [string trimright $top_file ".v"]
        set top_module_json [json::json2dict [read [open "./configs/$configs/$regions/rtl/.json/$top.json" r]]]
        set module_files [glob -dir ./configs/$configs/$regions/rtl/ *.v]
        dict set hierarchy $configs $regions files $module_files               
        set mode_list {}
        foreach file $module_files {
            set file [file tail $file]
            set filebase [file rootname $file]
            if {[string compare $filebase [file rootname $settings(top)]] != 0} {
                dict set hierarchy $configs $regions variants $filebase $file               
                # lappend mode_list $filebase
            } else {
                dict set hierarchy $configs $regions top_module $filebase         
                dict set hierarchy $configs $regions top_file $file                     
            }
        }
        # dict set hierarchy $configs $regions variants $mode_list               
        set x 0
        dict for {mods mod} [dict get [dict get $top_module_json modules]] {
            incr x
            set top_module_inst [dict keys [dict get $mod cells]]
            if {$x == 1} {
                # puts $top_module_inst
                dict set hierarchy $configs $regions top_inst $top_module_inst               
            }
        }
        dict for {regions_c region_c} [dict get $local_config configs config_region] {
            dict for {modules module} [dict get $region_c] {
                dict for {modes mode} [dict get $module] {
                    # puts "MODE: $mode"
                    # puts "MODES: $modes"
                    # set variant [lindex $mode  0]
                    # set variant_inst [lindex $mode  1]
                    # puts "-> $variant"
                    # puts "---> $variant_inst"
                    # dict set hierarchy $configs $regions $variant $variant_inst               
                }
            }
        }
    }
}

puts $hierarchy
puts "Number of configs: [dict size [dict get $hierarchy]]"
puts "Number of regions: [dict size [dict get $hierarchy $configs]]"
# puts [dict keys $hierarchy $configs $region]
dict for {configs regions} $hierarchy {
    puts "--------- \033\[34m$configs\033\[0m ----------"
    puts "-> \033\[34mconfig\033\[0m:    $configs"
    dict for {region keys} $regions {
        puts "--> \033\[31mregion\033\[0m:    $region"
        set x 1
        dict for {key value} $keys {
            switch $key {
                variants    {
                    puts [dict values $value]
                    puts [dict keys $value]

                    puts $value

                    set rm_variants(${configs}_${region}) [dict keys $value]
                    set rm_files(${configs}_${region}) [dict values $value]
                }
                files   {   
                    puts "---> \033\[3[incr x]m$key\033\[0m:    $value"
                    # set rm_files(${configs}_${region}) [dict create files $variant $value ting]
                    # puts $rm_files(${configs}_${region})
                }
                a*              {expr {2}}
                default {
                    puts "---> \033\[3[incr x]m$key\033\[0m:    $value"
                }
            }
        }
    }
}

source ./scripts/settings.tcl

foreach rp [array names rm_variants] {
    puts $rp
    foreach rm $rm_variants($rp) {
        puts "RM: $rm"
        puts [dict values $rm_files($rp)] 
        # set variant $rm
        # add_module $variant
        # set_attribute module $variant moduleName   $rp
        # set_attribute module $variant vlog         [list $rtlDir/$variant/$variant.v]
        # set_attribute module $variant synth        ${run.rm_synth}
    }
}
# source ./scripts/run.tcl







# set rp1 "shift"
# set rm_variants($rp1) "shift_right shift_left"
# set rp2 "count"
# set rm_variants($rp2) "count_up count_down"

########################################################################
### RM Configurations (Valid combinations of RM variants)
### 1. Define initial configuration: rm_config(initial)
### 2. Define additional configurations: rm_config(xyz)
########################################################################
# set module1_variant1 "shift_right"
# set module2_variant1 "count_up"
# set rm_config(initial)   "$rp1 $module1_variant1 $rp2 $module2_variant1"
# set module1_variant2 "shift_left"
# set module2_variant2 "count_down"
# set rm_config(reconfig1) "$rp1 $module1_variant2 $rp2 $module2_variant2"

########################################################################
### Task / flow portion
########################################################################
# Build the designs
# source ./advanced.tcl
# source $tclDir/run.tcl

#exit ;#uncomment if running in batch mode