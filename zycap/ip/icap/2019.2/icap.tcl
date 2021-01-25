set_property source_mgmt_mode All [current_project]

create_bd_cell -type module -reference icap icap_0
connect_bd_intf_net [get_bd_intf_pins icap_0/m_axis] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins icap_0/s_axis] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
connect_bd_net [get_bd_pins icap_0/clk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]