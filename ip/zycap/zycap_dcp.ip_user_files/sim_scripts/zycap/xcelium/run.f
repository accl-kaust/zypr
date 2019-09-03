-makelib xcelium_lib/xil_defaultlib -sv \
  "/tools/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/tools/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "/tools/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "/tools/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/lib_pkg_v1_0_2 \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_2 \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/7aff/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_2 \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/7aff/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_2 \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/7aff/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib xcelium_lib/lib_fifo_v1_0_11 \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/6078/hdl/lib_fifo_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/lib_srl_fifo_v1_0_2 \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/lib_cdc_v1_0_2 \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/axi_datamover_v5_1_19 \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/ec8a/hdl/axi_datamover_v5_1_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/axi_sg_v4_1_10 \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/6e5f/hdl/axi_sg_v4_1_rfs.vhd" \
-endlib
-makelib xcelium_lib/axi_dma_v7_1_18 \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/ipshared/6bfe/hdl/axi_dma_v7_1_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/ip/zycap_axi_dma_0_0/sim/zycap_axi_dma_0_0.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../zycap_dcp.srcs/sources_1/ipshared/cf83/verilog/icap_ctrl.v" \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/ip/zycap_icap_ctrl_0_1/sim/zycap_icap_ctrl_0_1.v" \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/hdl/zycap.v" \
  "../../../../zycap_dcp.srcs/sources_1/bd/zycap/sim/zycap.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

