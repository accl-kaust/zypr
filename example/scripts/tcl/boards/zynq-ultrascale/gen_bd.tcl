###################################################
# Generate Base Block Diagram for - Zynq Ultrascale
###################################################
package require json
set ROOT_PATH "[lindex $argv 0]"

# Check the version of Vivado used
# set version_required "2018.2"
# set ver [lindex [split $::env(XILINX_VIVADO) /] end]
# if {![string equal $ver $version_required]} {
#   puts "###############################"
#   puts "### Failed to build project ###"
#   puts "###############################"
#   puts "This project was designed for use with Vivado $version_required."
#   puts "You are using Vivado $ver. Please install Vivado $version_required,"
#   puts "or download the project sources from a commit of the Git repository"
#   puts "that was intended for your version of Vivado ($ver)."
#   return
# }
# set_param board.repoPaths [list "<extracted path>/vivado-boards/new/board_files"]

set_param board.repoPaths [list "../board"]

set cfg [read [open "$ROOT_PATH/global_config.json" r]]
set global_config [json::json2dict $cfg] 

# set DEVICE_PART [dict get $global_config project project_device device]
set board_name [dict get $global_config project project_device name]
set board_part [dict get $global_config project project_device board]
set board_device [dict get $global_config project project_device device]
set board_family [dict get $global_config project project_device family]
set board_package [dict get $global_config project project_device package]
set board_speed [dict get $global_config project project_device speed]
set board_option [dict get $global_config project project_device option]
set board_version [dict get $global_config project project_device version]
set board_constraint [dict get $global_config project project_device constraint]

set fpga_part $board_device$board_package$board_speed$board_option
set design_name [dict get $global_config design design_name]

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir $ROOT_PATH
puts $origin_dir
# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/rtl/$design_name"]"

# Set function for CPU threads
source $origin_dir/scripts/tcl/utils/cpu_threads.tcl
set log_dir $origin_dir/rtl/.logs

# Create project
create_project $design_name "$origin_dir/rtl/$design_name" -part $fpga_part -force

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $design_name]
set_property -name "board_part" -value $board_part -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/$design_name.cache/ip" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property ip_repo_paths {../ip} [current_project]
update_ip_catalog

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property "top" "${design_name}_wrapper" $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/board/$board_name/$board_version/constraints/$board_constraint"]"
set file_added [add_files -norecurse -fileset $obj $file]
set file "$origin_dir/board/$board_name/$board_version/constraints/$board_constraint"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "XDC" $file_obj

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]
set_property "target_constrs_file" "[file normalize "$origin_dir/board/$board_name/$board_version/constraints/$board_constraint"]" $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "top" "${design_name}_wrapper" $obj

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part $fpga_part -flow {Vivado Synthesis 2018} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2018" [get_runs synth_1]
}
set obj [get_runs synth_1]

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part $fpga_part -flow {Vivado Implementation 2018} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2018" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "INFO: Project created:${design_name}"

# Input arguments for block design script
set threads [numberOfCPUs]

# Create block design
source $origin_dir/board/$board_name/$board_version/bd/bd.tcl -notrace

###################################################
# Add ZyCAP to Block Diagram
###################################################
source $origin_dir/scripts/tcl/boards/$board_family/zycap_bd.tcl -notrace

###################################################
# Add PR Modules to Block Diagram
###################################################
set top_mod_file [dict get $global_config config config_settings top_file]
source $origin_dir/scripts/tcl/boards/$board_family/pr_module_bd.tcl -notrace

# Generate the wrapper
make_wrapper -files [get_files *${design_name}.bd] -top
set_property top ${design_name}_wrapper [current_fileset]

add_files -norecurse ${design_name}/${design_name}.srcs/sources_1/bd/${design_name}/hdl/${design_name}_wrapper.v

# Update the compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Ensure parameter propagation has been performed
close_bd_design [current_bd_design]
open_bd_design [get_files ${design_name}.bd]
validate_bd_design -force
save_bd_design

###################################################
# Synthesis 
###################################################
# source $origin_dir/scripts/tcl/boards/$board_family/synth.tcl

# Set output logs
# link_design > $log_dir/vivado_bd_link.log
# opt_design > $log_dir/vivado_bd_opt.log
# place_design > $log_dir/vivado_bd_place.log
# route_design > $log_dir/vivado_bd_route.log


# SYNTH SCRIPT GOES HERE


# open_run synth_1 -name synth_1
# set_property HD.RECONFIGURABLE true [get_cells base_design_i/partial_led_test_v1_0_0]

# manually load the checkpoint
# read_checkpoint $origin_dir/rtl/.modes/$modes/$configs/.checkpoints/pr_module.dcp -cell base_design_i/partial_led_test_0