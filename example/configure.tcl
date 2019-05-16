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
        set x 0
        dict for {mods mod} [dict get [dict get $top_module_json modules]] {
            incr x
            if {$x == 1} {
                set top_module_inst [dict keys [dict get $mod cells]]
                dict set hierarchy $configs $regions $top_file $top_module               
            }
        }
        dict for {regions_c region_c} [dict get $local_config configs config_region] {
            dict for {modules module} [dict get $region_c] {
                dict for {modes mode} [dict get $module] {
                    set variant [lindex $mode  0]
                    set variant_inst [lindex $mode  1]
                    puts "-> $variant"
                    puts "---> $variant_inst"
                    dict set hierarchy $configs $regions $variant $variant_inst               
                }
            }
        }
    }
}

puts $hierarchy
puts "Number of configs: [dict size [dict get $hierarchy]]"
puts "Number of regions: [dict size [dict get $hierarchy $configs]]"
dict for {configs regions} $hierarchy {
    puts "--------- \033\[34m$configs\033\[0m ----------"
    puts "-> \033\[34mConfig\033\[0m:     $configs"
    dict for {region tops} $regions {
        puts "--> \033\[31mRegion\033\[0m:    $region"
        dict for {top name} $tops {
            puts "---> \033\[36mTop\033\[0m:      $top"
            puts "---> \033\[33mRM\033\[0m:       $name"
        }
        dict for {top variants} $tops {
            puts "---> \033\[35mRM $top\033\[0m: $variants"
        }
    }
}










# set rp1 "shift"
# set rm_variants($rp1) "shift_right shift_left"
# set rp2 "count"
# set rm_variants($rp2) "count_up count_down"

########################################################################
### RM Configurations (Valid combinations of RM variants)
### 1. Define initial configuration: rm_config(initial)
### 2. Define additional configurations: rm_config(xyz)
########################################################################
set module1_variant1 "shift_right"
set module2_variant1 "count_up"
set rm_config(initial)   "$rp1 $module1_variant1 $rp2 $module2_variant1"
set module1_variant2 "shift_left"
set module2_variant2 "count_down"
set rm_config(reconfig1) "$rp1 $module1_variant2 $rp2 $module2_variant2"

########################################################################
### Task / flow portion
########################################################################
# Build the designs
# source ./advanced.tcl
# source $tclDir/run.tcl

#exit ;#uncomment if running in batch mode