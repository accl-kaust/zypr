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

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * AXI4-Stream 2 port mux (wrapper)
 */
module axis_mux_wrapper #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 32,
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
    input  wire                  clk,
    input  wire                  rst,

    /*
     * AXI Stream inputs
     */
    input  wire [DATA_WIDTH-1:0] s00_axis_tdata,
    input  wire [KEEP_WIDTH-1:0] s00_axis_tkeep,
    input  wire                  s00_axis_tvalid,
    output wire                  s00_axis_tready,
    input  wire                  s00_axis_tlast,
    input  wire [ID_WIDTH-1:0]   s00_axis_tid,
    input  wire [DEST_WIDTH-1:0] s00_axis_tdest,
    input  wire [USER_WIDTH-1:0] s00_axis_tuser,

    input  wire [DATA_WIDTH-1:0] s01_axis_tdata,
    input  wire [KEEP_WIDTH-1:0] s01_axis_tkeep,
    input  wire                  s01_axis_tvalid,
    output wire                  s01_axis_tready,
    input  wire                  s01_axis_tlast,
    input  wire [ID_WIDTH-1:0]   s01_axis_tid,
    input  wire [DEST_WIDTH-1:0] s01_axis_tdest,
    input  wire [USER_WIDTH-1:0] s01_axis_tuser,

    /*
     * AXI Stream output
     */
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire [KEEP_WIDTH-1:0] m_axis_tkeep,
    output wire                  m_axis_tvalid,
    input  wire                  m_axis_tready,
    output wire                  m_axis_tlast,
    output wire [ID_WIDTH-1:0]   m_axis_tid,
    output wire [DEST_WIDTH-1:0] m_axis_tdest,
    output wire [USER_WIDTH-1:0] m_axis_tuser,

    /*
     * Control
     */
    input  wire                  enable,
    input  wire [0:0]            select
);

axis_mux #(
    .S_COUNT(2),
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
    .s_axis_tdata({ s01_axis_tdata, s00_axis_tdata }),
    .s_axis_tkeep({ s01_axis_tkeep, s00_axis_tkeep }),
    .s_axis_tvalid({ s01_axis_tvalid, s00_axis_tvalid }),
    .s_axis_tready({ s01_axis_tready, s00_axis_tready }),
    .s_axis_tlast({ s01_axis_tlast, s00_axis_tlast }),
    .s_axis_tid({ s01_axis_tid, s00_axis_tid }),
    .s_axis_tdest({ s01_axis_tdest, s00_axis_tdest }),
    .s_axis_tuser({ s01_axis_tuser, s00_axis_tuser }),
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
    .select(select)
);

endmodule
