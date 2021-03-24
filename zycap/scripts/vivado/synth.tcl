set design_name [get_property NAME [current_project]]
logger "Starting ${design_name}_wrapper synth" SUCCESS
set_property top ${design_name}_wrapper [current_fileset]

if { [get_property PROGRESS [get_runs synth_1]] != "100%"} {
  launch_runs synth_1
  wait_on_run synth_1
  logger "Synthesis completed" SUCCESS
} else {
  logger "Synthesis already complete" INFO
}

