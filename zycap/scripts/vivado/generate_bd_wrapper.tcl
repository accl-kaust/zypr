set work_directory [get_property DIRECTORY [current_project]]

set_property source_mgmt_mode All [current_project]

update_compile_order -fileset sources_1

create_bd_cell -type module -reference icap icap_0
connect_bd_intf_net [get_bd_intf_pins icap_0/m_axis] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins icap_0/s_axis] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
connect_bd_net [get_bd_pins icap_0/clk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]


make_wrapper -files [get_files $work_directory/$design_name.srcs/sources_1/bd/$design_name/$design_name.bd] -top
add_files -norecurse $work_directory/$design_name.srcs/sources_1/bd/$design_name/hdl/${design_name}_wrapper.v

set_property source_mgmt_mode None [current_project]
update_compile_order -fileset sources_1
