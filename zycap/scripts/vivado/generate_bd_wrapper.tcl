logger "Generating ZyCAP infrastructure" INFO

set work_directory [get_property DIRECTORY [current_project]]
set_property source_mgmt_mode All [current_project]

update_compile_order -fileset sources_1

# Set AXI interfaces on Interconnect
set i 2
set_property -dict [list CONFIG.NUM_MI $i] [get_bd_cells ps8_0_axi_periph]
connect_bd_net [get_bd_pins ps8_0_axi_periph/M01_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
connect_bd_net [get_bd_pins ps8_0_axi_periph/M01_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]

# Add PR Wrapper
create_bd_cell -type module -reference pr_wrapper pr_wrapper_0
set wrapper_intf [get_bd_intf_pins -of [get_bd_cells pr_wrapper_0]]

# Add AXIS mux/demux
create_bd_cell -type module -reference axis_stream_master axis_stream_master_0
create_bd_cell -type module -reference axis_stream_slave axis_stream_slave_0
connect_bd_intf_net [get_bd_intf_pins axis_stream_master_0/DMA] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins axis_stream_slave_0/DMA] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
connect_bd_net [get_bd_pins axis_stream_master_0/clk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
connect_bd_net [get_bd_pins axis_stream_master_0/rst] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axis_stream_slave_0/clk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
connect_bd_net [get_bd_pins axis_stream_slave_0/rst] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]

# Get number of AXIS_M and AXIS_S pins
set mux_pins [expr [llength [get_bd_intf_pins -of [get_bd_cells axis_stream_master_0]]] - 2]
set demux_pins [expr [llength [get_bd_intf_pins -of [get_bd_cells axis_stream_slave_0]]] - 2]

# Connect ICAP IP block
create_bd_cell -type module -reference icap icap_0
connect_bd_intf_net [get_bd_intf_pins icap_0/m_axis] [get_bd_intf_pins axis_stream_master_0/ICAP]
connect_bd_intf_net [get_bd_intf_pins icap_0/s_axis] [get_bd_intf_pins axis_stream_slave_0/ICAP]
connect_bd_net [get_bd_pins icap_0/clk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
connect_bd_net [get_bd_pins icap_0/rst] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]

# Connect ZyCAP IP block
create_bd_cell -type module -reference zycap zycap_ctrl_0
# AXIS Mux
connect_bd_net [get_bd_pins zycap_ctrl_0/zycap_axis_mux_en] [get_bd_pins axis_stream_slave_0/enable]
connect_bd_net [get_bd_pins zycap_ctrl_0/zycap_axis_mux_en] [get_bd_pins axis_stream_master_0/enable]
connect_bd_net [get_bd_pins zycap_ctrl_0/zycap_axis_mux_drop] [get_bd_pins axis_stream_slave_0/drop]
connect_bd_net [get_bd_pins zycap_ctrl_0/zycap_axis_mux_sel] [get_bd_pins axis_stream_slave_0/sel]
connect_bd_net [get_bd_pins zycap_ctrl_0/zycap_axis_mux_sel] [get_bd_pins axis_stream_master_0/sel]
# ICAP
connect_bd_net [get_bd_pins zycap_ctrl_0/zycap_icap_rw] [get_bd_pins icap_0/rw]
connect_bd_net [get_bd_pins zycap_ctrl_0/zycap_icap_err_status] [get_bd_pins icap_0/err]
# AXI Lite
connect_bd_net [get_bd_pins zycap_ctrl_0/s_axi_lite_aresetn] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
connect_bd_intf_net [get_bd_intf_pins zycap_ctrl_0/s_axi_lite] -boundary_type upper [get_bd_intf_pins ps8_0_axi_periph/M01_AXI]
connect_bd_net [get_bd_pins zycap_ctrl_0/s_axi_lite_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]

# Connect AXI_STREAM_MASTER IP to PS
set axis_master [get_bd_intf_pins -of [get_bd_cells pr_wrapper_0] -filter {NAME =~ "AXI_STREAM_MASTER*"}]
set ctr [expr {[llength ${axis_master}] - 1}]
foreach i $axis_master {
    connect_bd_intf_net [get_bd_intf_pins $i] [get_bd_intf_pins axis_stream_master_0/s_0${ctr}_axis]
    [incr ctr -1]
}

# Connect AXI_STREAM_SLAVE IP to PS
set axis_slave [get_bd_intf_pins -of [get_bd_cells pr_wrapper_0] -filter {NAME =~ "AXI_STREAM_SLAVE*"}]
set ctr [expr {[llength ${axis_slave}] - 1}]
foreach i $axis_slave {
    connect_bd_intf_net [get_bd_intf_pins $i] [get_bd_intf_pins axis_stream_slave_0/m_0${ctr}_axis]
    [incr ctr -1]
}

# Connect all the IRQs
set irq_names { *irq* *interrupt* }
set irq_pins {}
foreach name $irq_names {
    set list [get_bd_pins -hierarchical $name ]
    foreach pin $list {
        if {[get_property DIR [get_bd_pins -hierarchical $pin]] == "O"} {
            lappend irq_pins [get_bd_pins -hierarchical $pin] 
        }
    }
}
puts $irq_pins
set config_irqs [expr {[llength ${irq_pins}] + 2}]
set_property -dict [list CONFIG.NUM_PORTS $config_irqs] [get_bd_cells xlconcat_0]

set ctr [expr {$config_irqs - 1}]
foreach i $irq_pins {
    connect_bd_net [get_bd_pins $i] [get_bd_pins xlconcat_0/In${ctr}]
    [incr ctr -1]
}

# Connect all the CLKs
set clk_pins [get_bd_pins -hierarchical *clk_*]
foreach i $clk_pins {
    connect_bd_net [get_bd_pins $i] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
}

# Connect all the RSTs
set rst_pins [get_bd_pins -hierarchical *rst_*]
foreach i $rst_pins {
    connect_bd_net [get_bd_pins $i] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
}

# Connect ZyCAP Controller
connect_bd_intf_net [get_bd_intf_pins zycap_ctrl_0/s_axi_lite] -boundary_type upper [get_bd_intf_pins ps8_0_axi_periph/M01_AXI]
# connect_bd_net [get_bd_pins ps8_0_axi_periph/M01_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
# connect_bd_net [get_bd_pins ps8_0_axi_periph/M01_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]

# Expand AXI Interconnect for PR Modules
set axil_slave [get_bd_intf_pins -of [get_bd_cells pr_wrapper_0] -filter {NAME =~ "AXI_LITE_SLAVE*"}]
set ctr [expr {[llength ${axil_slave}]}]
set config_axil [expr {[llength ${axil_slave}] + 2}]

set_property -dict [list CONFIG.NUM_MI $config_axil ] [get_bd_cells ps8_0_axi_periph]

foreach i $axil_slave {
    set ps_int [expr {$ctr + 1}]
    connect_bd_intf_net [get_bd_intf_pins $i] -boundary_type upper [get_bd_intf_pins ps8_0_axi_periph/M0${ps_int}_AXI]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M0${ps_int}_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M0${ps_int}_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
    [incr ctr -1]
}

# Update DMA config
set_property -dict [list CONFIG.c_s_axis_s2mm_tdata_width.VALUE_SRC USER CONFIG.c_m_axi_s2mm_data_width.VALUE_SRC USER] [get_bd_cells axi_dma_0]
set_property -dict [list CONFIG.c_m_axi_mm2s_data_width {64} CONFIG.c_m_axis_mm2s_tdata_width {64} CONFIG.c_mm2s_burst_size {8} CONFIG.c_m_axi_s2mm_data_width {64} CONFIG.c_s_axis_s2mm_tdata_width {64} CONFIG.c_s2mm_burst_size {8} CONFIG.c_addr_width {64}] [get_bd_cells axi_dma_0]

# Assign AXI Addresses
assign_bd_address [get_bd_addr_segs {zycap_ctrl_0/s_axi_lite/reg0 }]
set_property offset 0x00B0010000 [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_zycap_ctrl_0_reg0}]
assign_bd_address -export_to_file $work_directory/$design_name.sdk/mmio.csv

generate_target all [get_files $work_directory/$design_name.srcs/sources_1/bd/$design_name/$design_name.bd]

make_wrapper -files [get_files $work_directory/$design_name.srcs/sources_1/bd/$design_name/$design_name.bd] -top
add_files -norecurse $work_directory/$design_name.srcs/sources_1/bd/$design_name/hdl/${design_name}_wrapper.v

write_bd_layout -format pdf -orientation landscape $work_directory/$design_name.pdf

# Generate PDF for block diagram
#write_bd_layout -format pdf -orientation landscape /home/alex/GitHub/zycap2/zycap/test/demo/build/example.pdf
