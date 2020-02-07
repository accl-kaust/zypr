
################################################################
# Connect and attach ZyCAP
################################################################

# create_bd_cell -type ip -vlnv user.shs:user:zycap:1.0 zycap_0
# create_bd_cell -type ip -vlnv user.shs.arb:user:zycap:2.2 zycap_0

# apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_xbar {Auto} Master {/zycap_0/M_AXI_MM2S} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]

# apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/zycap_0/S_AXI_LITE} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins zycap_0/S_AXI_LITE]

# connect_bd_net [get_bd_pins zycap_0/mm2s_introut] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0
set_property -dict [list CONFIG.c_include_sg {1} CONFIG.c_sg_length_width {23} CONFIG.c_sg_include_stscntrl_strm {0} CONFIG.c_include_mm2s_dre {1} CONFIG.c_include_s2mm {1} CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_dma_0]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/axi_dma_0/M_AXI_MM2S} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC0_FPD} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HPC0_FPD]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_slave {Auto} Clk_xbar {Auto} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_dma_0/S_AXI_LITE} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_dma_0/S_AXI_LITE]

connect_bd_net [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]


# Connect S2MM
import_files -norecurse /home/alex/GitHub/zycap2/example/ip/zycap/src/icap_ctrl.v
update_compile_order -fileset sources_1
create_bd_cell -type module -reference icap_ctrl icap_ctrl_0
set_property location {3 836 533} [get_bd_cells icap_ctrl_0]
connect_bd_intf_net [get_bd_intf_pins icap_ctrl_0/S_AXIS] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
connect_bd_intf_net [get_bd_intf_pins icap_ctrl_0/M_AXIS] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
connect_bd_net [get_bd_pins icap_ctrl_0/ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
connect_bd_net [get_bd_pins icap_ctrl_0/ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

# apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Master {/axi_dma_0/M_AXI_S2MM} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]

# Connect SG
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Master {/axi_dma_0/M_AXI_SG} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_dma_0/M_AXI_SG]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Master {/axi_dma_0/M_AXI_S2MM} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]

# apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_slave {Auto} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_dma_0/S_AXI_LITE} intc_ip {/ps8_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_dma_0/S_AXI_LITE]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
connect_bd_net [get_bd_pins xlconcat_0/In0] [get_bd_pins axi_dma_0/mm2s_introut]
connect_bd_net [get_bd_pins xlconcat_0/In1] [get_bd_pins axi_dma_0/s2mm_introut]
connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]

# connect_bd_intf_net [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]

# import_files -norecurse /home/alex/GitHub/zycap2/example/ip/zycap/src/icap_ctrl.v
# update_compile_order -fileset sources_1
# create_bd_cell -type module -reference icap_ctrl icap_ctrl_0
# set_property location {3 836 533} [get_bd_cells icap_ctrl_0]
# connect_bd_intf_net [get_bd_intf_pins icap_ctrl_0/S_AXIS] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
# connect_bd_net [get_bd_pins icap_ctrl_0/ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
# connect_bd_net [get_bd_pins icap_ctrl_0/ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
