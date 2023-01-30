################################################################
# Block diagram build script
################################################################

set_property board_part avnet.com:ultra96v2:part0:1.2 [current_project]

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}

set work_directory [get_property DIRECTORY [current_project]]
set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

create_bd_design $design_name

current_bd_design $design_name

set parentCell [get_bd_cells /]

# Get object for parentCell
set parentObj [get_bd_cells $parentCell]
if { $parentObj == "" } {
   puts "ERROR: Unable to find parent cell <$parentCell>!"
   return
}

# Make sure parentObj is hier blk
set parentType [get_property TYPE $parentObj]
if { $parentType ne "hier" } {
   puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
   return
}

# Save current instance; Restore later
set oldCurInst [current_bd_instance .]

# Set parent object as current
current_bd_instance $parentObj

# Add the Processor System and apply board preset
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e zynq_ultra_ps_e_0
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]

# Enable the GP ports, enable GEM0, GEM1
set_property -dict [list CONFIG.PSU__USE__M_AXI_GP0 {1} \
CONFIG.PSU__MAXIGP0__DATA_WIDTH {64} \
CONFIG.PSU__USE__M_AXI_GP1 {0} \
CONFIG.PSU__USE__S_AXI_GP0 {1} \
CONFIG.PSU__SAXIGP0__DATA_WIDTH {64} \
CONFIG.PSU__GPIO_EMIO__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__GPIO_EMIO__PERIPHERAL__IO {12} \
CONFIG.PSU__NUM_FABRIC_RESETS {1} \
CONFIG.PSU__UART0__MODEM__ENABLE {1}] [get_bd_cells zynq_ultra_ps_e_0]

# Add the Direct Memory Access
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_dma_0
set_property -dict [list CONFIG.c_include_sg {1} \
CONFIG.c_sg_length_width {23} \
CONFIG.c_addr_width {64} \
CONFIG.c_sg_include_stscntrl_strm {0} \
CONFIG.c_include_mm2s_dre {1} \
CONFIG.c_include_s2mm {1} \
CONFIG.c_mm2s_burst_size {256} \
CONFIG.c_s2mm_burst_size {256} \
CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_dma_0]

# Disable Scatter Gather
# create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_dma_0
# set_property -dict [list CONFIG.c_include_sg {0} \
# CONFIG.c_addr_width {64} \
# CONFIG.c_include_mm2s_dre {1} \
# CONFIG.c_include_s2mm {1} \
# CONFIG.c_mm2s_burst_size {256} \
# CONFIG.c_s2mm_burst_size {256} \
# CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_dma_0]

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_dma_0/S_AXI_LITE} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/axi_dma_0/M_AXI_SG} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC0_FPD} ddr_seg {Auto} intc_ip {New AXI SmartConnect} master_apm {0}}  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HPC0_FPD]
endgroup

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Master {/axi_dma_0/M_AXI_MM2S} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC0_FPD} ddr_seg {Auto} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_dma_0/M_AXI_MM2S]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Master {/axi_dma_0/M_AXI_S2MM} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC0_FPD} ddr_seg {Auto} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]
endgroup

# connect_bd_intf_net [get_bd_intf_pins axi_dma_0/M_AXI_SG] -boundary_type upper [get_bd_intf_pins ps8_0_axi_periph/S02_AXI]
# connect_bd_intf_net [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] -boundary_type upper [get_bd_intf_pins ps8_0_axi_periph/S03_AXI]


# connect_bd_net [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
# connect_bd_net [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]

# Concat DMA interupts
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_0
connect_bd_net [get_bd_pins axi_dma_0/mm2s_introut] [get_bd_pins xlconcat_0/In0]
connect_bd_net [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins xlconcat_0/In1]
connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]

# Automate connections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_slave {Auto} Clk_xbar {Auto} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_dma_0/S_AXI_LITE} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_dma_0/S_AXI_LITE]

# Create ports for Bluetooth UART0
create_bd_port -dir I BT_HCI_CTS
connect_bd_net [get_bd_ports BT_HCI_CTS] [get_bd_pins zynq_ultra_ps_e_0/emio_uart0_ctsn]
create_bd_port -dir O BT_HCI_RTS
connect_bd_net [get_bd_ports BT_HCI_RTS] [get_bd_pins zynq_ultra_ps_e_0/emio_uart0_rtsn]

# Connect FPD to PL CLK
#connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/maxihpm1_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]

# Restore current instance
current_bd_instance $oldCurInst

validate_bd_design
save_bd_design

#make_wrapper -files [get_files $work_directory/$design_name.srcs/sources_1/bd/$design_name/$design_name.bd] -top
#add_files -norecurse $work_directory/$design_name.srcs/sources_1/bd/$design_name/hdl/${design_name}_wrapper.v
