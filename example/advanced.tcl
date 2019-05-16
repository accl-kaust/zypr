###############################################################
### Advanced Settings
###############################################################
# Load utilities
#Define location for "Tcl" directory. Defaults to "./tcl_HD"
if {[file exists "./Tcl_HD"]} { 
   set tclDir  "./Tcl_HD"
} else {
   error "ERROR: No valid location found for required Tcl scripts. Set \$tclDir in design.tcl to a valid location."
}
puts "Setting TCL dir to $tclDir"

####Source required Tcl Procs
source $tclDir/design_utils.tcl
source $tclDir/log_utils.tcl
source $tclDir/synth_utils.tcl
source $tclDir/impl_utils.tcl
source $tclDir/hd_utils.tcl
source $tclDir/pr_utils.tcl

###############################################################
### Board Settings
### -Board: default device, package and speed for selected board
###############################################################
switch $xboard {
vc707 {
 set device       "xc7vx485t"
 set package      "ffg1761"
 set speed        "-2"
}
vc709 {
 set device       "xc7vx690t"
 set package      "ffg1761"
 set speed        "-2"
}
ac701 {
 set device       "xc7a200t"
 set package      "fbg676"
 set speed        "-2"
}
default {
 #kc705
 set device       "xc7k325t"
 set package      "ffg900"
 set speed        "-2"
}
}
set part         $device$package$speed
check_part $part

###############################################################
###  Run Settings
###############################################################
####Report and DCP controls - values: 0-required min; 1-few extra; 2-all
set verbose      1
set dcpLevel     1

###############################################################
### Static Module Definition
###############################################################
set static "Static"
add_module $static
set_attribute module $static moduleName    $top
set_attribute module $static top_level     1
if {$xboard == "ac701"} {
   set_attribute module $static vlog          [list [glob $rtlDir/$top/$xboard/*.v]]
} else {
   set_attribute module $static vlog          [list [glob $rtlDir/$top/*.v]]
} 
set_attribute module $static synth         ${run.topSynth}

####################################################################
### RP Module Definitions
####################################################################
foreach rp [array names rm_variants] {
  foreach rm $rm_variants($rp) {
    set variant $rm
    add_module $variant
    set_attribute module $variant moduleName   $rp
    set_attribute module $variant vlog         [list $rtlDir/$variant/$variant.v]
    set_attribute module $variant synth        ${run.rmSynth}
  }
}

########################################################################
### Configuration (Implementation) Definition 
########################################################################
foreach cfg_name [array names rm_config] {
  if {$cfg_name=="initial"} {set state "implement"} else {set state "import"}
    
  set config "Config"
  set partition_list [list [list $static $top $state]]

  foreach {rp rm_variant} $rm_config($cfg_name) {
    set module_inst inst_${rp}
    set config "${config}_${rm_variant}"
    set partition [list $rm_variant $module_inst implement]
    lappend partition_list $partition
  }
 set config "${config}_${state}"
  
  add_implementation $config
  set_attribute impl $config top             $top
  set_attribute impl $config implXDC         [list $xdcDir/${top}_$xboard.xdc]

  set_attribute impl $config partitions      $partition_list
  set_attribute impl $config pr.impl         1 
  set_attribute impl $config impl            ${run.prImpl} 
  set_attribute impl $config verify     	    ${run.prVerify} 
  set_attribute impl $config bitstream  	    ${run.writeBitstream} 
  #set_attribute impl $config bitstream_settings [list <options_go_here>]
}