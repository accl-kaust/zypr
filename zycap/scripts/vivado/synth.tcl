set design_name [get_property NAME [current_project]]
logger "Starting ${design_name}_wrapper synth" SUCCESS
set_property top ${design_name}_wrapper [current_fileset]
launch_runs synth_1
wait_on_run synth_1