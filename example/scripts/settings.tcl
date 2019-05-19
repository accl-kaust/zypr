###############################################################
### Advanced Settings
###############################################################
# Load vivado utilities
if {[file exists "./scripts"]} { 
   set tclDir  "./scripts"
} else {
   error "ERROR: Missing scripts dir."
}

####Source required Tcl Procs
source $tclDir/design_utils.tcl
source $tclDir/log_utils.tcl
source $tclDir/synth_utils.tcl
source $tclDir/impl_utils.tcl
source $tclDir/hd_utils.tcl
source $tclDir/pr_utils.tcl

################################################################
#### Configure Device
################################################################

set device  [dict get $global_config project project_device device];
set package [dict get $global_config project project_device package];
set speed   [dict get $global_config project project_device speed];
set part    $device$package$speed
check_part  $part

# # ###############################################################
# # ### Static Module Definition
# # ###############################################################
# set static "Static"
# add_module $static
# set_attribute module $static moduleName    $top
# set_attribute module $static top_level     1
# set_attribute module $static vlog          [list [glob $rtlDir/$top/*.v]]
# set_attribute module $static synth         ${run.topSynth}

####################################################################
### RP Module Definitions
####################################################################
# foreach rp [dict get $hierarchy $configs $regions] {
#   foreach rm $rm_variants($rp) {
#     set variant $rm
#     add_module $variant
#     set_attribute module $variant moduleName   $rp
#     set_attribute module $variant vlog         [list $rtlDir/$variant/$variant.v]
#     set_attribute module $variant synth        ${run.rmSynth}
#   }
# }