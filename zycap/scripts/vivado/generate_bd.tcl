open_bd_design {$work_directory/$design_name.srcs/sources_1/bd/$design_name/$design_name.bd}

make_wrapper -files [get_files $work_directory/$design_name.srcs/sources_1/bd/$design_name/$design_name.bd] -top
add_files -norecurse $work_directory/$design_name.srcs/sources_1/bd/$design_name/hdl/${design_name}_wrapper.v