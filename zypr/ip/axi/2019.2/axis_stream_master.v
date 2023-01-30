/*

Copyright (c) 2018 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Modified 2021 Alex Bucknall

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * AXI4-Stream 3 port mux (wrapper)
 */
module axis_stream_master #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 64,
    // Propagate tkeep signal
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // tid signal width
    parameter ID_WIDTH = 8,
    // Propagate tdest signal
    parameter DEST_ENABLE = 0,
    // tdest signal width
    parameter DEST_WIDTH = 8,
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1
)
(
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
    input  wire                  clk,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst RST" *)
    input  wire                  rst,

    /*
     * ICAP Stream inputs
     */
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TDATA" *)
    input  wire [DATA_WIDTH-1:0] icap_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TKEEP" *)
    input  wire [KEEP_WIDTH-1:0] icap_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TVALID" *)
    input  wire                  icap_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TREADY" *)
    output wire                  icap_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TLAST" *)
    input  wire                  icap_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TID" *)
    input  wire [ID_WIDTH-1:0]   icap_axis_tid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TDEST" *)
    input  wire [DEST_WIDTH-1:0] icap_axis_tdest,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TUSER" *)
    input  wire [USER_WIDTH-1:0] icap_axis_tuser,

    /*
     * AXI Stream inputs
     */
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_00_axis TDATA" *)
    input  wire [DATA_WIDTH-1:0] s_00_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_00_axis TKEEP" *)
    input  wire [KEEP_WIDTH-1:0] s_00_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_00_axis TVALID" *)
    input  wire                  s_00_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_00_axis TREADY" *)
    output wire                  s_00_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_00_axis TLAST" *)
    input  wire                  s_00_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_00_axis TID" *)
    input  wire [ID_WIDTH-1:0]   s_00_axis_tid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_00_axis TDEST" *)
    input  wire [DEST_WIDTH-1:0] s_00_axis_tdest,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_00_axis TUSER" *)
    input  wire [USER_WIDTH-1:0] s_00_axis_tuser,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_01_axis TDATA" *)
    input  wire [DATA_WIDTH-1:0] s_01_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_01_axis TKEEP" *)
    input  wire [KEEP_WIDTH-1:0] s_01_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_01_axis TVALID" *)
    input  wire                  s_01_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_01_axis TREADY" *)
    output wire                  s_01_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_01_axis TLAST" *)
    input  wire                  s_01_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_01_axis TID" *)
    input  wire [ID_WIDTH-1:0]   s_01_axis_tid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_01_axis TDEST" *)
    input  wire [DEST_WIDTH-1:0] s_01_axis_tdest,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_01_axis TUSER" *)
    input  wire [USER_WIDTH-1:0] s_01_axis_tuser,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_02_axis TDATA" *)
    input  wire [DATA_WIDTH-1:0] s_02_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_02_axis TKEEP" *)
    input  wire [KEEP_WIDTH-1:0] s_02_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_02_axis TVALID" *)
    input  wire                  s_02_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_02_axis TREADY" *)
    output wire                  s_02_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_02_axis TLAST" *)
    input  wire                  s_02_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_02_axis TID" *)
    input  wire [ID_WIDTH-1:0]   s_02_axis_tid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_02_axis TDEST" *)
    input  wire [DEST_WIDTH-1:0] s_02_axis_tdest,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_02_axis TUSER" *)
    input  wire [USER_WIDTH-1:0] s_02_axis_tuser,

    /*
     * AXI Stream output
     */
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TDATA" *)
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TKEEP" *)
    output wire [KEEP_WIDTH-1:0] m_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TVALID" *)
    output wire                  m_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TREADY" *)
    input  wire                  m_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TLAST" *)
    output wire                  m_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TID" *)
    output wire [ID_WIDTH-1:0]   m_axis_tid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TDEST" *)
    output wire [DEST_WIDTH-1:0] m_axis_tdest,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TUSER" *)
    output wire [USER_WIDTH-1:0] m_axis_tuser,

    /*
     * Control
     */
    input  wire                  enable,
    input  wire [1:0]            sel
);

axis_mux #(
    .S_COUNT(3),
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .ID_ENABLE(ID_ENABLE),
    .ID_WIDTH(ID_WIDTH),
    .DEST_ENABLE(DEST_ENABLE),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH)
)
axis_mux_inst (
    .clk(clk),
    .rst(rst),
    // AXI inputs
    .s_axis_tdata({ s02_axis_tdata, s01_axis_tdata, s00_axis_tdata, icap_axis_tdata }),
    .s_axis_tkeep({ s02_axis_tkeep, s01_axis_tkeep, s00_axis_tkeep, icap_axis_tkeep }),
    .s_axis_tvalid({ s02_axis_tvalid, s01_axis_tvalid, s00_axis_tvalid, icap_axis_tvalid }),
    .s_axis_tready({ s02_axis_tready, s01_axis_tready, s00_axis_tready, icap_axis_tready }),
    .s_axis_tlast({ s02_axis_tlast, s01_axis_tlast, s00_axis_tlast, icap_axis_tlast }),
    .s_axis_tid({ s02_axis_tid, s01_axis_tid, s00_axis_tid, icap_axis_tid }),
    .s_axis_tdest({ s02_axis_tdest, s01_axis_tdest, s00_axis_tdest, icap_axis_tdest }),
    .s_axis_tuser({ s02_axis_tuser, s01_axis_tuser, s00_axis_tuser, icap_axis_tuser }),
    // AXI output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tid(m_axis_tid),
    .m_axis_tdest(m_axis_tdest),
    .m_axis_tuser(m_axis_tuser),
    // Control
    .enable(enable),
    .sel(sel)
);

endmodule
