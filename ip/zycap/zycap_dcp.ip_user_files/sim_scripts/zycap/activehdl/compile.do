vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm
vlib activehdl/lib_pkg_v1_0_2
vlib activehdl/fifo_generator_v13_2_2
vlib activehdl/lib_fifo_v1_0_11
vlib activehdl/lib_srl_fifo_v1_0_2
vlib activehdl/lib_cdc_v1_0_2
vlib activehdl/axi_datamover_v5_1_19
vlib activehdl/axi_sg_v4_1_10
vlib activehdl/axi_dma_v7_1_18

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm
vmap lib_pkg_v1_0_2 activehdl/lib_pkg_v1_0_2
vmap fifo_generator_v13_2_2 activehdl/fifo_generator_v13_2_2
vmap lib_fifo_v1_0_11 activehdl/lib_fifo_v1_0_11
vmap lib_srl_fifo_v1_0_2 activehdl/lib_srl_fifo_v1_0_2
vmap lib_cdc_v1_0_2 activehdl/lib_cdc_v1_0_2
vmap axi_datamover_v5_1_19 activehdl/axi_datamover_v5_1_19
vmap axi_sg_v4_1_10 activehdl/axi_sg_v4_1_10
vmap axi_dma_v7_1_18 activehdl/axi_dma_v7_1_18

vlog -work xil_defaultlib  -sv2k12 \
"/tools/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/tools/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/tools/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/tools/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work lib_pkg_v1_0_2 -93 \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \

vlog -work fifo_generator_v13_2_2  -v2k5 \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/7aff/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_2 -93 \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/7aff/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_2  -v2k5 \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/7aff/hdl/fifo_generator_v13_2_rfs.v" \

vcom -work lib_fifo_v1_0_11 -93 \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/6078/hdl/lib_fifo_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_2 -93 \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work axi_datamover_v5_1_19 -93 \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/ec8a/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vcom -work axi_sg_v4_1_10 -93 \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/6e5f/hdl/axi_sg_v4_1_rfs.vhd" \

vcom -work axi_dma_v7_1_18 -93 \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/6bfe/hdl/axi_dma_v7_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/ip/zycap_axi_dma_0_0/sim/zycap_axi_dma_0_0.vhd" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../zycap_dcp.srcs/sources_1/ipshared/cf83/verilog/icap_ctrl.v" \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/ip/zycap_icap_ctrl_0_1/sim/zycap_icap_ctrl_0_1.v" \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/hdl/zycap.v" \
"../../../../zycap_dcp.srcs/sources_1/bd/zycap/sim/zycap.v" \

vlog -work xil_defaultlib \
"glbl.v"

