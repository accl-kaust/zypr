/*

Copyright (c) 2013-2018 Alex Forencich

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
 * AXI4-Stream FIFO
 */
module axis_fifo_b #
(
    // FIFO depth in words
    // KEEP_WIDTH words per cycle if KEEP_ENABLE set
    // Rounded up to nearest power of 2 cycles
    parameter DEPTH = 4096,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 32,
    // Propagate tkeep signal
    // If disabled, tkeep assumed to be 1'b1
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (4),
    // Propagate tlast signal
    parameter LAST_ENABLE = 1,
    // Propagate tid signal
    parameter ID_ENABLE = 1,
    // tid signal width
    parameter ID_WIDTH = 8,
    // Propagate tdest signal
    parameter DEST_ENABLE = 1,
    // tdest signal width
    parameter DEST_WIDTH = 8,
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // number of output pipeline registers
    parameter PIPELINE_OUTPUT = 2,
    // Frame FIFO mode - operate on frames instead of cycles
    // When set, output_r_TVALID will not be deasserted within a frame
    // Requires LAST_ENABLE set
    parameter FRAME_FIFO = 0,
    // tuser value for bad frame marker
    parameter USER_BAD_FRAME_VALUE = 1'b1,
    // tuser mask for bad frame marker
    parameter USER_BAD_FRAME_MASK = 1'b1,
    // Drop frames marked bad
    // Requires FRAME_FIFO set
    parameter DROP_BAD_FRAME = 0,
    // Drop incoming frames when full
    // When set, input_r_TREADY is always asserted
    // Requires FRAME_FIFO set
    parameter DROP_WHEN_FULL = 0
)
(
    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]  input_r_TDATA,
    input  wire [KEEP_WIDTH-1:0]  input_r_TKEEP,
    input  wire                   input_r_TVALID,
    output wire                   input_r_TREADY,
    input  wire                   input_r_TLAST,
    input  wire [ID_WIDTH-1:0]    input_r_TID,
    input  wire [DEST_WIDTH-1:0]  input_r_TDEST,
    input  wire [USER_WIDTH-1:0]  input_r_TUSER,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  output_r_TDATA,
    output wire [KEEP_WIDTH-1:0]  output_r_TKEEP,
    output wire                   output_r_TVALID,
    input  wire                   output_r_TREADY,
    output wire                   output_r_TLAST,
    output wire [ID_WIDTH-1:0]    output_r_TID,
    output wire [DEST_WIDTH-1:0]  output_r_TDEST,
    output wire [USER_WIDTH-1:0]  output_r_TUSER,

    input  wire                   ap_clk,
    input  wire                   ap_rst_n

    /*
     * Status
     */

);
    wire ap_rst;
     wire                   status_overflow;
     wire                   status_bad_frame;
     wire                   status_good_frame;

         assign ap_rst = !ap_rst_n;


parameter ADDR_WIDTH = (KEEP_ENABLE && KEEP_WIDTH > 1) ? $clog2(DEPTH/KEEP_WIDTH) : $clog2(DEPTH);

// check configuration
initial begin
    if (PIPELINE_OUTPUT < 1) begin
        $error("Error: PIPELINE_OUTPUT must be at least 1 (instance %m)");
        $finish;
    end

    if (FRAME_FIFO && !LAST_ENABLE) begin
        $error("Error: FRAME_FIFO set requires LAST_ENABLE set (instance %m)");
        $finish;
    end

    if (DROP_BAD_FRAME && !FRAME_FIFO) begin
        $error("Error: DROP_BAD_FRAME set requires FRAME_FIFO set (instance %m)");
        $finish;
    end

    if (DROP_WHEN_FULL && !FRAME_FIFO) begin
        $error("Error: DROP_WHEN_FULL set requires FRAME_FIFO set (instance %m)");
        $finish;
    end

    if (DROP_BAD_FRAME && (USER_BAD_FRAME_MASK & {USER_WIDTH{1'b1}}) == 0) begin
        $error("Error: Invalid USER_BAD_FRAME_MASK value (instance %m)");
        $finish;
    end
end

localparam KEEP_OFFSET = DATA_WIDTH;
localparam LAST_OFFSET = KEEP_OFFSET + (KEEP_ENABLE ? KEEP_WIDTH : 0);
localparam ID_OFFSET   = LAST_OFFSET + (LAST_ENABLE ? 1          : 0);
localparam DEST_OFFSET = ID_OFFSET   + (ID_ENABLE   ? ID_WIDTH   : 0);
localparam USER_OFFSET = DEST_OFFSET + (DEST_ENABLE ? DEST_WIDTH : 0);
localparam WIDTH       = USER_OFFSET + (USER_ENABLE ? USER_WIDTH : 0);

reg [ADDR_WIDTH:0] wr_ptr_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] wr_ptr_cur_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_reg = {ADDR_WIDTH+1{1'b0}};

reg [WIDTH-1:0] mem[(2**ADDR_WIDTH)-1:0];
reg [WIDTH-1:0] mem_read_data_reg;
reg mem_read_data_valid_reg = 1'b0;

wire [WIDTH-1:0] s_axis;

reg [WIDTH-1:0] m_axis_pipe_reg[PIPELINE_OUTPUT-1:0];
reg [PIPELINE_OUTPUT-1:0] m_axis_tvalid_pipe_reg = 1'b0;

// full when first MSB different but rest same
wire full = wr_ptr_reg == (rd_ptr_reg ^ {1'b1, {ADDR_WIDTH{1'b0}}});
wire full_cur = wr_ptr_cur_reg == (rd_ptr_reg ^ {1'b1, {ADDR_WIDTH{1'b0}}});
// empty when pointers match exactly
wire empty = wr_ptr_reg == rd_ptr_reg;
// overflow within packet
wire full_wr = wr_ptr_reg == (wr_ptr_cur_reg ^ {1'b1, {ADDR_WIDTH{1'b0}}});

reg drop_frame_reg = 1'b0;
reg overflow_reg = 1'b0;
reg bad_frame_reg = 1'b0;
reg good_frame_reg = 1'b0;

assign input_r_TREADY = FRAME_FIFO ? (!full_cur || full_wr || DROP_WHEN_FULL) : !full;

generate
    assign s_axis[DATA_WIDTH-1:0] = input_r_TDATA;
    if (KEEP_ENABLE) assign s_axis[KEEP_OFFSET +: KEEP_WIDTH] = input_r_TKEEP;
    if (LAST_ENABLE) assign s_axis[LAST_OFFSET]               = input_r_TLAST;
    if (ID_ENABLE)   assign s_axis[ID_OFFSET   +: ID_WIDTH]   = input_r_TID;
    if (DEST_ENABLE) assign s_axis[DEST_OFFSET +: DEST_WIDTH] = input_r_TDEST;
    if (USER_ENABLE) assign s_axis[USER_OFFSET +: USER_WIDTH] = input_r_TUSER;
endgenerate

assign output_r_TVALID = m_axis_tvalid_pipe_reg[PIPELINE_OUTPUT-1];

assign output_r_TDATA = m_axis_pipe_reg[PIPELINE_OUTPUT-1][DATA_WIDTH-1:0];
assign output_r_TKEEP = KEEP_ENABLE ? m_axis_pipe_reg[PIPELINE_OUTPUT-1][KEEP_OFFSET +: KEEP_WIDTH] : {KEEP_WIDTH{1'b1}};
assign output_r_TLAST = LAST_ENABLE ? m_axis_pipe_reg[PIPELINE_OUTPUT-1][LAST_OFFSET]               : 1'b1;
assign output_r_TID   = ID_ENABLE   ? m_axis_pipe_reg[PIPELINE_OUTPUT-1][ID_OFFSET   +: ID_WIDTH]   : {ID_WIDTH{1'b0}};
assign output_r_TDEST = DEST_ENABLE ? m_axis_pipe_reg[PIPELINE_OUTPUT-1][DEST_OFFSET +: DEST_WIDTH] : {DEST_WIDTH{1'b0}};
assign output_r_TUSER = USER_ENABLE ? m_axis_pipe_reg[PIPELINE_OUTPUT-1][USER_OFFSET +: USER_WIDTH] : {USER_WIDTH{1'b0}};

assign status_overflow = overflow_reg;
assign status_bad_frame = bad_frame_reg;
assign status_good_frame = good_frame_reg;

// Write logic
always @(posedge ap_clk) begin
    overflow_reg <= 1'b0;
    bad_frame_reg <= 1'b0;
    good_frame_reg <= 1'b0;

    if (input_r_TREADY && input_r_TVALID) begin
        // transfer in
        if (!FRAME_FIFO) begin
            // normal FIFO mode
            mem[wr_ptr_reg[ADDR_WIDTH-1:0]] <= s_axis;
            wr_ptr_reg <= wr_ptr_reg + 1;
        end else if (full_cur || full_wr || drop_frame_reg) begin
            // full, packet overflow, or currently dropping frame
            // drop frame
            drop_frame_reg <= 1'b1;
            if (input_r_TLAST) begin
                // end of frame, reset write pointer
                wr_ptr_cur_reg <= wr_ptr_reg;
                drop_frame_reg <= 1'b0;
                overflow_reg <= 1'b1;
            end
        end else begin
            mem[wr_ptr_cur_reg[ADDR_WIDTH-1:0]] <= s_axis;
            wr_ptr_cur_reg <= wr_ptr_cur_reg + 1;
            if (input_r_TLAST) begin
                // end of frame
                if (DROP_BAD_FRAME && USER_BAD_FRAME_MASK & ~(input_r_TUSER ^ USER_BAD_FRAME_VALUE)) begin
                    // bad packet, reset write pointer
                    wr_ptr_cur_reg <= wr_ptr_reg;
                    bad_frame_reg <= 1'b1;
                end else begin
                    // good packet, update write pointer
                    wr_ptr_reg <= wr_ptr_cur_reg + 1;
                    good_frame_reg <= 1'b1;
                end
            end
        end
    end

    if (ap_rst) begin
        wr_ptr_reg <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_cur_reg <= {ADDR_WIDTH+1{1'b0}};

        drop_frame_reg <= 1'b0;
        overflow_reg <= 1'b0;
        bad_frame_reg <= 1'b0;
        good_frame_reg <= 1'b0;
    end
end

// Read logic
integer j;

always @(posedge ap_clk) begin
    if (output_r_TREADY) begin
        // output ready; invalidate stage
        m_axis_tvalid_pipe_reg[PIPELINE_OUTPUT-1] <= 1'b0;
    end

    for (j = PIPELINE_OUTPUT-1; j > 0; j = j - 1) begin
        if (output_r_TREADY || ((~m_axis_tvalid_pipe_reg) >> j)) begin
            // output ready or bubble in pipeline; transfer down pipeline
            m_axis_tvalid_pipe_reg[j] <= m_axis_tvalid_pipe_reg[j-1];
            m_axis_pipe_reg[j] <= m_axis_pipe_reg[j-1];
            m_axis_tvalid_pipe_reg[j-1] <= 1'b0;
        end
    end

    if (output_r_TREADY || ~m_axis_tvalid_pipe_reg) begin
        // output ready or bubble in pipeline; read new data from FIFO
        m_axis_tvalid_pipe_reg[0] <= 1'b0;
        m_axis_pipe_reg[0] <= mem[rd_ptr_reg[ADDR_WIDTH-1:0]];
        if (!empty) begin
            // not empty, increment pointer
            m_axis_tvalid_pipe_reg[0] <= 1'b1;
            rd_ptr_reg <= rd_ptr_reg + 1;
        end
    end

    if (ap_rst) begin
        rd_ptr_reg <= {ADDR_WIDTH+1{1'b0}};
        m_axis_tvalid_pipe_reg <= {PIPELINE_OUTPUT{1'b0}};
    end
end

endmodule





























