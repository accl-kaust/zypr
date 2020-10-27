//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
//Date        : Thu Oct 22 14:38:40 2020
//Host        : DESKTOP-8GUJJ5H running 64-bit Debian GNU/Linux 10 (buster)
//Command     : generate_target test_wrapper.bd
//Design      : test_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module test_wrapper
   (BT_ctsn,
    BT_rtsn);
  input BT_ctsn;
  output BT_rtsn;

  wire BT_ctsn;
  wire BT_rtsn;

  test test_i
       (.BT_ctsn(BT_ctsn),
        .BT_rtsn(BT_rtsn));
endmodule
