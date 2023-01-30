if { [get_property PROGRESS [get_runs impl_1]] != "100%"} {
  launch_runs impl_1 -to_step write_bitstream
  wait_on_run impl_1
  logger "Bitstream generation completed" SUCCESS
} else {
  logger "Bitstream generation already complete" INFO
}