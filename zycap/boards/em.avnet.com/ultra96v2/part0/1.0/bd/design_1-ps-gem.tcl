################################################################
# Block diagram build script
################################################################

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}

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

# Disable all of the GP ports
set_property -dict [list CONFIG.PSU__USE__M_AXI_GP0 {0} \
CONFIG.PSU__GPIO_EMIO__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__GPIO_EMIO__PERIPHERAL__IO {12} \
CONFIG.PSU__NUM_FABRIC_RESETS {1} \
CONFIG.PSU__UART0__MODEM__ENABLE {1}] [get_bd_cells zynq_ultra_ps_e_0]

# Add the Direct Memory Access
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_dma_0
set_property -dict [list CONFIG.c_include_sg {0} \
CONFIG.c_sg_length_width {26} \
CONFIG.c_sg_include_stscntrl_strm {0}] [get_bd_cells axi_dma_0]

# Automate connections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} \ 
Clk_slave {Auto} \
Clk_xbar {Auto} \
Master {/zynq_ultra_ps_e_0/M_AXI_HPM1_FPD} \
Slave {/axi_dma_0/S_AXI_LITE} \
ddr_seg {Auto} \
intc_ip {New AXI Interconnect} \
master_apm {0}}  [get_bd_intf_pins axi_dma_0/S_AXI_LITE]

# Create ports for Bluetooth UART0
create_bd_port -dir I BT_HCI_CTS
connect_bd_net [get_bd_ports BT_HCI_CTS] [get_bd_pins zynq_ultra_ps_e_0/emio_uart0_ctsn]
create_bd_port -dir O BT_HCI_RTS
connect_bd_net [get_bd_ports BT_HCI_RTS] [get_bd_pins zynq_ultra_ps_e_0/emio_uart0_rtsn]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
