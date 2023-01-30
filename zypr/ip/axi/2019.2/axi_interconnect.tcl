
open_project [lindex $argv 0]
open_bd_design [lindex $argv 1]

set slaves [lindex $argv 2]
set masters [lindex $argv 3]

# Generate
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0
set_property -dict [list CONFIG.NUM_SI {$slaves} CONFIG.NUM_MI {$masters}] [get_bd_cells axi_interconnect_0]

# Enable PS Slave AXI
set_property -dict [list CONFIG.PSU__USE__S_AXI_GP2 {1}] [get_bd_cells zynq_ultra_ps_e_0]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/saxihp0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
