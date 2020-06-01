
################################################################
# Connect and attach ZyCAP
################################################################

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0
set_property -dict [list CONFIG.c_include_sg {1} CONFIG.c_sg_length_width {23} CONFIG.c_addr_width {32} CONFIG.c_sg_include_stscntrl_strm {0} CONFIG.c_include_mm2s_dre {1} CONFIG.c_include_s2mm {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_dma_0]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/axi_dma_0/M_AXI_MM2S} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC0_FPD} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HPC0_FPD]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_slave {Auto} Clk_xbar {Auto} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_dma_0/S_AXI_LITE} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_dma_0/S_AXI_LITE]

connect_bd_net [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]

# Generate AXIS interface for DMA stream
# dict for {mode modes} [dict get $global_config design design_mode] {
#     set axi_stream_ports [llength [dict get $global_config design design_mode $mode interfaces master axi_stream port]]
#     set axi_stream_width [dict get $global_config design design_mode $mode interfaces master axi_stream width]
# }

# connect_bd_intf_net [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]

# COMMENT THIS \/

set axi_stream_width 32
set axi_stream_ports 4
set axi_ports 5

exec python ${ROOT_PATH}/scripts/tcl/boards/generic/scripts/axis_demux_wrap.py -w ${axi_stream_width} -o ${ROOT_PATH}/scripts/tcl/boards/generic/axis_dmux_wrapper.v -n axis_dmux_wrapper -p ${axi_stream_ports}
exec python ${ROOT_PATH}/scripts/tcl/boards/generic/scripts/axis_mux_wrap.py -w ${axi_stream_width} -o ${ROOT_PATH}/scripts/tcl/boards/generic/axis_mux_wrapper.v -n axis_mux_wrapper -p ${axi_stream_ports}
exec python ${ROOT_PATH}/scripts/tcl/boards/generic/scripts/gpio_split.py -o ${ROOT_PATH}/scripts/tcl/boards/generic/gpio_split.v -n split -p ${axi_stream_ports}

import_files -files ${ROOT_PATH}/scripts/tcl/boards/generic/
update_compile_order -fileset sources_1

create_bd_cell -type module -reference axis_dmux_wrapper axis_dmux_wrapper_0
create_bd_cell -type module -reference axis_mux_wrapper axis_mux_wrapper_0

# Connect AXIS interfaces
# Add loop for IP AXIS Cores
# DMA -> MUX
connect_bd_intf_net [get_bd_intf_pins axis_mux_wrapper_0/m_axis] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
# DEMUX -> DMA
connect_bd_intf_net [get_bd_intf_pins axis_dmux_wrapper_0/s_axis] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
# DEMUX -> CLK
connect_bd_net [get_bd_pins axis_dmux_wrapper_0/clk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
# MUX -> CLK
connect_bd_net [get_bd_pins axis_mux_wrapper_0/clk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
# DEMUX -> RST
connect_bd_net [get_bd_pins axis_dmux_wrapper_0/rst] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
# MUX -> RST
connect_bd_net [get_bd_pins axis_mux_wrapper_0/rst] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

# COMMENT THIS /\

# # ICAP
import_files -norecurse "$ROOT_PATH/ip/zycap/src/icap_ctrl.v"
update_compile_order -fileset sources_1
create_bd_cell -type module -reference icap_ctrl icap_ctrl_0
set_property location {3 836 533} [get_bd_cells icap_ctrl_0]
# ICAP -> MUX
connect_bd_intf_net [get_bd_intf_pins icap_ctrl_0/M_AXIS] [get_bd_intf_pins axis_mux_wrapper_0/s00_axis]
# connect_bd_intf_net [get_bd_intf_pins icap_ctrl_0/M_AXIS] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
# DEMUX -> ICAP
connect_bd_intf_net [get_bd_intf_pins axis_dmux_wrapper_0/m00_axis] [get_bd_intf_pins icap_ctrl_0/S_AXIS]
# connect_bd_intf_net [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins icap_ctrl_0/S_AXIS]
connect_bd_net [get_bd_pins icap_ctrl_0/ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
connect_bd_net [get_bd_pins icap_ctrl_0/ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Master {/axi_dma_0/M_AXI_SG} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_dma_0/M_AXI_SG]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Master {/axi_dma_0/M_AXI_S2MM} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]

set_property -dict [list CONFIG.NUM_SI ${axi_ports}] [get_bd_cells axi_smc]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
connect_bd_net [get_bd_pins xlconcat_0/In0] [get_bd_pins axi_dma_0/mm2s_introut]
connect_bd_net [get_bd_pins xlconcat_0/In1] [get_bd_pins axi_dma_0/s2mm_introut]
connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
set_property -dict [list CONFIG.C_GPIO_WIDTH {3} CONFIG.C_ALL_OUTPUTS {1}] [get_bd_cells axi_gpio_0]
set_property CONFIG.C_GPIO_WIDTH [expr $axi_stream_ports*3] [get_bd_cells axi_gpio_0]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_slave {Auto} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_gpio_0/S_AXI} intc_ip {/ps8_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_gpio_0/S_AXI]

# connect_bd_net [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins axis_dmux_wrapper_0/sel]
# connect_bd_net [get_bd_pins axis_mux_wrapper_0/sel] [get_bd_pins axi_gpio_0/gpio_io_o]

# Add split module

create_bd_cell -type module -reference split split_${axi_stream_ports}_0

connect_bd_net [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins split_${axi_stream_ports}_0/gpio]

connect_bd_net [get_bd_pins split_${axi_stream_ports}_0/enable] [get_bd_pins axis_dmux_wrapper_0/enable]
connect_bd_net [get_bd_pins split_${axi_stream_ports}_0/sel] [get_bd_pins axis_mux_wrapper_0/sel]
connect_bd_net [get_bd_pins split_${axi_stream_ports}_0/drop] [get_bd_pins axis_dmux_wrapper_0/drop]
connect_bd_net [get_bd_pins axis_mux_wrapper_0/enable] [get_bd_pins split_${axi_stream_ports}_0/enable]
connect_bd_net [get_bd_pins axis_dmux_wrapper_0/sel] [get_bd_pins split_${axi_stream_ports}_0/sel]


# for { set a 0 }  { $a < [expr ${axi_stream_ports} - 1] } {incr a} {
#     # set num [format %02d $a]
#     # set s "s"
#     # set s_prefix $s$num
#     # set m "m"
#     # set m_prefix $m$num


# }
