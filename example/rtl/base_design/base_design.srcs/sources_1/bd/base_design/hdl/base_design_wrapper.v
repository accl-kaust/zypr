//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.2.1 (lin64) Build 2288692 Thu Jul 26 18:23:50 MDT 2018
//Date        : Thu Oct 10 16:49:13 2019
//Host        : alex-warc running 64-bit Ubuntu 18.04.3 LTS
//Command     : generate_target base_design_wrapper.bd
//Design      : base_design_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module base_design_wrapper
   (BT_ctsn,
    BT_rtsn,
    reset_rtl);
  input BT_ctsn;
  output BT_rtsn;
  input reset_rtl;

  wire BT_ctsn;
  wire BT_rtsn;
  wire reset_rtl;

  base_design base_design_i
       (.BT_ctsn(BT_ctsn),
        .BT_rtsn(BT_rtsn),
        .reset_rtl(reset_rtl));
endmodule
