logger "Generating ZyCAP infrastructure" INFO

set work_directory [get_property DIRECTORY [current_project]]
set_property source_mgmt_mode All [current_project]

update_compile_order -fileset sources_1

# Set AXI interfaces on Interconnect
set i 2

# Add PR Wrapper
create_bd_cell -type module -reference pr_wrapper pr_wrapper_0
set wrapper_intf [get_bd_intf_pins -of [get_bd_cells pr_wrapper_0]]

# Connect ICAP IP block
create_bd_cell -type module -reference icap icap_0
connect_bd_net [get_bd_pins icap_0/clk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]

# Connect ZyCAP IP block
create_bd_cell -type module -reference zycap zycap_ctrl_0

# ICAP
# connect_bd_net [get_bd_pins zycap_ctrl_0/zycap_icap_rw] [get_bd_pins icap_0/rw]
# connect_bd_net [get_bd_pins zycap_ctrl_0/zycap_icap_err_status] [get_bd_pins icap_0/err]
# AXI Lite
connect_bd_net [get_bd_pins zycap_ctrl_0/s_axi_lite_aresetn] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
connect_bd_intf_net [get_bd_intf_pins zycap_ctrl_0/s_axi_lite] -boundary_type upper [get_bd_intf_pins ps8_0_axi_periph/M01_AXI]
connect_bd_net [get_bd_pins zycap_ctrl_0/s_axi_lite_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]

# Connect AXI_STREAM MUX
set axis_mux [expr {${axis_mux_mi} + 1}]
set axis_demux [expr {${axis_demux_si} + 1}]
create_bd_cell -type ip -vlnv xilinx.com:ip:axis_interconnect:2.1 axis_mux
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI $axis_mux CONFIG.ROUTING_MODE {1}] [get_bd_cells axis_mux]
connect_bd_intf_net [get_bd_intf_pins axis_mux/S00_AXIS] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]

# Connect AXI_STREAM DEMUX
create_bd_cell -type ip -vlnv xilinx.com:ip:axis_interconnect:2.1 axis_demux
set_property -dict [list CONFIG.NUM_SI $axis_demux CONFIG.NUM_MI {1} CONFIG.ROUTING_MODE {1}] [get_bd_cells axis_demux]
connect_bd_intf_net [get_bd_intf_pins axis_demux/M00_AXIS] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]

connect_bd_net [get_bd_pins icap_0/rst] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
# Resize AXIS for ICAP if required
if {$axis_mux_mi != 0} {
    if {$ip_axis_data_width != 32} { 
        set ip_axis_data_width_bytes [expr {$ip_axis_data_width / 8}]

        # TO ICAP
        create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_0
        connect_bd_net [get_bd_pins axis_dwidth_converter_0/aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
        connect_bd_net [get_bd_pins axis_dwidth_converter_0/aresetn] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
        set_property -dict [list CONFIG.S_TDATA_NUM_BYTES $ip_axis_data_width_bytes ] [get_bd_cells axis_dwidth_converter_0]
        set_property -dict [list CONFIG.M_TDATA_NUM_BYTES {4}] [get_bd_cells axis_dwidth_converter_0]
        connect_bd_intf_net [get_bd_intf_pins axis_dwidth_converter_0/M_AXIS] [get_bd_intf_pins icap_0/s_axis]
        connect_bd_intf_net [get_bd_intf_pins axis_mux/M0${axis_mux_mi}_AXIS] [get_bd_intf_pins axis_dwidth_converter_0/S_AXIS]

        # FROM ICAP
        create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_1
        connect_bd_net [get_bd_pins axis_dwidth_converter_1/aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
        connect_bd_net [get_bd_pins axis_dwidth_converter_1/aresetn] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
        set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {4}] [get_bd_cells axis_dwidth_converter_1]
        set_property -dict [list CONFIG.M_TDATA_NUM_BYTES $ip_axis_data_width_bytes ] [get_bd_cells axis_dwidth_converter_1]
        connect_bd_intf_net [get_bd_intf_pins icap_0/m_axis] [get_bd_intf_pins axis_dwidth_converter_1/S_AXIS]
        connect_bd_intf_net [get_bd_intf_pins axis_dwidth_converter_1/M_AXIS] [get_bd_intf_pins axis_demux/S0${axis_demux_si}_AXIS]

    } else {
        connect_bd_intf_net [get_bd_intf_pins icap_0/m_axis] [get_bd_intf_pins axis_demux/S0${axis_demux_si}_AXIS]
        connect_bd_intf_net [get_bd_intf_pins icap_0/s_axis] [get_bd_intf_pins axis_mux/M0${axis_mux_mi}_AXIS]
    }
    # Connect AXI_STREAM_MASTER IP to PS
    set axis_master [get_bd_intf_pins -of [get_bd_cells pr_wrapper_0] -filter {NAME =~ "AXI_STREAM_MASTER*"}]
    set ctr [expr {[llength ${axis_master}] - 1}]
    foreach i $axis_master {
        connect_bd_intf_net [get_bd_intf_pins $i] [get_bd_intf_pins axis_demux/S0${ctr}_AXIS]
        [incr ctr -1]
    }

    # Connect AXI_STREAM_SLAVE IP to PS
    set axis_slave [get_bd_intf_pins -of [get_bd_cells pr_wrapper_0] -filter {NAME =~ "AXI_STREAM_SLAVE*"}]
    set ctr [expr {[llength ${axis_slave}] - 1}]
    foreach i $axis_slave {
        connect_bd_intf_net [get_bd_intf_pins $i] [get_bd_intf_pins axis_mux/M0${ctr}_AXIS]
        [incr ctr -1]
    }
} else {
    connect_bd_intf_net [get_bd_intf_pins icap_0/m_axis] [get_bd_intf_pins axis_demux/S0${axis_demux_si}_AXIS]
    connect_bd_intf_net [get_bd_intf_pins icap_0/s_axis] [get_bd_intf_pins axis_mux/M0${axis_mux_mi}_AXIS]
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

# Connect all the AXIS Interconnect CLKs
set clk_pins [get_bd_pins -hierarchical *0*_AXIS_ACLK]
connect_bd_net [get_bd_pins axis_demux/ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
connect_bd_net [get_bd_pins axis_mux/ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
if {$axis_mux_mi != 0} {
    connect_bd_net [get_bd_pins axis_demux/S_AXI_CTRL_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
    connect_bd_net [get_bd_pins axis_mux/S_AXI_CTRL_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
}
foreach i $clk_pins {
    connect_bd_net [get_bd_pins $i] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
}

# Connect all the AXIS Interconnect RSTs
set rst_pins [get_bd_pins -hierarchical *0*_AXIS_ARESETN]

connect_bd_net [get_bd_pins axis_demux/ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axis_mux/ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
if {$axis_mux_mi != 0} {
    connect_bd_net [get_bd_pins axis_demux/S_AXI_CTRL_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
    connect_bd_net [get_bd_pins axis_mux/S_AXI_CTRL_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
    lappend $rst_pins [get_bd_pins -hierarchical S_AXI_CTRL_ARESETN]

} 
foreach i $rst_pins {
    puts $i
    connect_bd_net [get_bd_pins $i] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
}

# Connect all the RSTs
set rst_pins [get_bd_pins -hierarchical *rst_*]
foreach i $rst_pins {
    puts $i
    connect_bd_net [get_bd_pins $i] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
}

# Connect ZyCAP Controller
connect_bd_intf_net [get_bd_intf_pins zycap_ctrl_0/s_axi_lite] -boundary_type upper [get_bd_intf_pins ps8_0_axi_periph/M01_AXI]
# connect_bd_net [get_bd_pins ps8_0_axi_periph/M01_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
# connect_bd_net [get_bd_pins ps8_0_axi_periph/M01_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]

# Expand AXI Interconnect for PR Modules
set axil_slave [get_bd_intf_pins -of [get_bd_cells pr_wrapper_0] -filter {NAME =~ "AXI_LITE_SLAVE*"}]
set ctr [expr {[llength ${axil_slave}]}]
if {$axis_mux_mi != 0} {
    set number_axi 4
} else {
    set number_axi 2
}
set config_axil [expr {[llength ${axil_slave}] + ${number_axi}}]

# NEEDS TO BE MADE DYNAMIC
set_property -dict [list CONFIG.NUM_MI $config_axil ] [get_bd_cells ps8_0_axi_periph]
if {$axis_mux_mi != 0} {
    connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axis_demux/S_AXI_CTRL] [get_bd_intf_pins ps8_0_axi_periph/M02_AXI]
    connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axis_mux/S_AXI_CTRL] [get_bd_intf_pins ps8_0_axi_periph/M03_AXI]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M02_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M03_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M02_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M03_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
} else {

}

set n 0
foreach i $axil_slave {
    set ps_int [expr {$ctr + [expr {$number_axi - 1}]}]
    connect_bd_intf_net [get_bd_intf_pins $i] -boundary_type upper [get_bd_intf_pins ps8_0_axi_periph/M0${ps_int}_AXI]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M0${ps_int}_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins pr_wrapper_0/S_AXI_ACLK_${n}]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M0${ps_int}_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn] [get_bd_pins pr_wrapper_0/S_AXI_ARESETN_${n}]
    [incr ctr -1]
    [incr n 1]
}

# Create 200MHz Clock
if {$hs_icap == 1} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_200_mhz
    set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} CONFIG.USE_LOCKED {false} CONFIG.USE_RESET {false} CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.000} CONFIG.CLKOUT1_JITTER {102.086}] [get_bd_cells clk_200_mhz]
    # Disconnect clocks to be reconnected to 200MHz
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins icap_0/clk]
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axis_mux/ACLK]
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axis_mux/S00_AXIS_ACLK]
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axis_mux/M00_AXIS_ACLK]
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axi_dma_0/m_axi_mm2s_aclk]
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axi_dma_0/m_axi_s2mm_aclk]
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axis_demux/ACLK]
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axis_demux/S00_AXIS_ACLK]
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axis_demux/M00_AXIS_ACLK]
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins zynq_ultra_ps_e_0/saxihpc0_fpd_aclk]
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axi_smc/aclk]
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axi_dma_0/s_axi_lite_aclk]
    disconnect_bd_net /zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins ps8_0_axi_periph/M00_ACLK]
    connect_bd_net [get_bd_pins clk_200_mhz/clk_in1] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
    connect_bd_net [get_bd_pins axis_mux/ACLK] \
    [get_bd_pins axis_mux/S00_AXIS_ACLK] \
    [get_bd_pins axis_mux/M00_AXIS_ACLK] \
    [get_bd_pins axis_demux/ACLK] \
    [get_bd_pins axis_demux/S00_AXIS_ACLK] \
    [get_bd_pins axis_demux/M00_AXIS_ACLK] \
    [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] \
    [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] \
    [get_bd_pins icap_0/clk] \
    [get_bd_pins axi_smc/aclk] \
    [get_bd_pins axi_dma_0/s_axi_lite_aclk] \
    [get_bd_pins ps8_0_axi_periph/M00_ACLK] \
    [get_bd_pins zynq_ultra_ps_e_0/saxihpc0_fpd_aclk] \
    [get_bd_pins clk_200_mhz/clk_out1] -boundary_type upper 
}

if {$debug_icap == 1} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0
    set_property -dict [list CONFIG.C_BRAM_CNT {6} CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0}] [get_bd_cells system_ila_0]
    connect_bd_net [get_bd_pins system_ila_0/clk] [get_bd_pins clk_200_mhz/clk_out1]
    connect_bd_net [get_bd_pins system_ila_0/resetn] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
    connect_bd_intf_net [get_bd_intf_pins system_ila_0/SLOT_0_AXIS] -boundary_type upper [get_bd_intf_pins axis_mux/M00_AXIS]
}

if {$loopback_check == 1 && $hs_icap == 1} {
    startgroup
    set_property -dict [list CONFIG.NUM_MI {2} CONFIG.ROUTING_MODE {1}] [get_bd_cells axis_mux]
    endgroup
    startgroup
    set_property -dict [list CONFIG.NUM_SI {2} CONFIG.ROUTING_MODE {1}] [get_bd_cells axis_demux]
    endgroup
    connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axis_mux/M01_AXIS] [get_bd_intf_pins axis_demux/S01_AXIS]
    connect_bd_net [get_bd_pins axis_demux/S01_AXIS_ACLK] [get_bd_pins clk_200_mhz/clk_out1]
    connect_bd_net [get_bd_pins axis_demux/S_AXI_CTRL_ACLK] [get_bd_pins clk_200_mhz/clk_out1]
    connect_bd_net [get_bd_pins axis_demux/S01_AXIS_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
    connect_bd_net [get_bd_pins axis_demux/S_AXI_CTRL_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
    connect_bd_net [get_bd_pins axis_mux/M01_AXIS_ACLK] [get_bd_pins clk_200_mhz/clk_out1]
    connect_bd_net [get_bd_pins axis_mux/S_AXI_CTRL_ACLK] [get_bd_pins clk_200_mhz/clk_out1]
    connect_bd_net [get_bd_pins axis_mux/S_AXI_CTRL_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
    connect_bd_net [get_bd_pins axis_mux/M01_AXIS_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
    startgroup
    set_property -dict [list CONFIG.NUM_MI {5}] [get_bd_cells ps8_0_axi_periph]
    endgroup
    connect_bd_intf_net -boundary_type upper [get_bd_intf_pins ps8_0_axi_periph/M03_AXI] [get_bd_intf_pins axis_mux/S_AXI_CTRL]
    connect_bd_intf_net -boundary_type upper [get_bd_intf_pins ps8_0_axi_periph/M04_AXI] [get_bd_intf_pins axis_demux/S_AXI_CTRL]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M03_ACLK] [get_bd_pins clk_200_mhz/clk_out1]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M04_ACLK] [get_bd_pins clk_200_mhz/clk_out1]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M04_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M03_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
}

if {$gpio_debug == 1} {

    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
    set_property -dict [list CONFIG.C_GPIO_WIDTH {4} CONFIG.C_ALL_INPUTS {1}] [get_bd_cells axi_gpio_0]

    create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1
    set_property -dict [list CONFIG.NUM_PORTS {4}] [get_bd_cells xlconcat_1]

    connect_bd_net [get_bd_pins icap_0/err] [get_bd_pins xlconcat_1/In0]
    connect_bd_net [get_bd_pins icap_0/avail] [get_bd_pins xlconcat_1/In1]
    connect_bd_net [get_bd_pins icap_0/done] [get_bd_pins xlconcat_1/In2]
    connect_bd_net [get_bd_pins xlconcat_1/dout] [get_bd_pins axi_gpio_0/gpio_io_i]
    connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
    connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]

    set_property -dict [list CONFIG.NUM_MI {6}] [get_bd_cells ps8_0_axi_periph]
    connect_bd_intf_net -boundary_type upper [get_bd_intf_pins ps8_0_axi_periph/M05_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M05_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
    connect_bd_net [get_bd_pins ps8_0_axi_periph/M05_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]

}


# Disable SG
set_property -dict [list CONFIG.c_include_sg {0}] [get_bd_cells axi_dma_0]
delete_bd_objs [get_bd_intf_nets axi_dma_0_M_AXI_SG]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Master {/axi_dma_0/M_AXI_S2MM} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC0_FPD} ddr_seg {Auto} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]

# Update DMA config
# set_property -dict [list CONFIG.c_s_axis_s2mm_tdata_width.VALUE_SRC USER CONFIG.c_m_axi_s2mm_data_width.VALUE_SRC USER] [get_bd_cells axi_dma_0]
# set_property -dict [list CONFIG.c_m_axi_mm2s_data_width {64} CONFIG.c_m_axis_mm2s_tdata_width {64} CONFIG.c_mm2s_burst_size {8} CONFIG.c_m_axi_s2mm_data_width {64} CONFIG.c_s_axis_s2mm_tdata_width {64} CONFIG.c_s2mm_burst_size {8} CONFIG.c_addr_width {64}] [get_bd_cells axi_dma_0]

# Assign AXI Addresses
assign_bd_address [get_bd_addr_segs {zycap_ctrl_0/s_axi_lite/reg0 }]
set_property offset 0x00A0010000 [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_zycap_ctrl_0_reg0}]
assign_bd_address [get_bd_addr_segs {axis_mux/xbar/S_AXI_CTRL}]
if {$axis_mux_mi != 0} {
    # AXIS Demux
    set_property offset 0x00A0030000 [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_xbar_Reg1}]
    # AXIS Mux
    set_property offset 0x00A0020000 [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_xbar_Reg}]
}

assign_bd_address
assign_bd_address -export_to_file $work_directory/$design_name.sdk/mmio.csv

generate_target all [get_files $work_directory/$design_name.srcs/sources_1/bd/$design_name/$design_name.bd]
export_ip_user_files -of_objects [get_files $work_directory/$design_name.srcs/sources_1/bd/$design_name/$design_name.bd] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $work_directory/$design_name.srcs/sources_1/bd/$design_name/$design_name.bd]

make_wrapper -files [get_files $work_directory/$design_name.srcs/sources_1/bd/$design_name/$design_name.bd] -top
add_files -norecurse $work_directory/$design_name.srcs/sources_1/bd/$design_name/hdl/${design_name}_wrapper.v

# write_bd_layout -format pdf -orientation landscape $work_directory/$design_name.pdf

# Generate PDF for block diagram
#write_bd_layout -format pdf -orientation landscape /home/alex/GitHub/zycap2/zycap/test/demo/build/example.pdf
