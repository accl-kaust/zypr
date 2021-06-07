// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
// Version: 2019.2
// Copyright (C) 1986-2019 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

module inRange (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_continue,
        ap_idle,
        ap_ready,
        src_rows_dout,
        src_rows_empty_n,
        src_rows_read,
        src_cols_dout,
        src_cols_empty_n,
        src_cols_read,
        src_data_V_dout,
        src_data_V_empty_n,
        src_data_V_read,
        dst_data_V_din,
        dst_data_V_full_n,
        dst_data_V_write
);

parameter    ap_ST_fsm_state1 = 2'd1;
parameter    ap_ST_fsm_state2 = 2'd2;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
input   ap_continue;
output   ap_idle;
output   ap_ready;
input  [31:0] src_rows_dout;
input   src_rows_empty_n;
output   src_rows_read;
input  [31:0] src_cols_dout;
input   src_cols_empty_n;
output   src_cols_read;
input  [23:0] src_data_V_dout;
input   src_data_V_empty_n;
output   src_data_V_read;
output  [0:0] dst_data_V_din;
input   dst_data_V_full_n;
output   dst_data_V_write;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg src_rows_read;
reg src_cols_read;
reg src_data_V_read;
reg dst_data_V_write;

reg    ap_done_reg;
(* fsm_encoding = "none" *) reg   [1:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg    src_rows_blk_n;
reg    src_cols_blk_n;
wire   [15:0] width_fu_90_p1;
reg   [15:0] width_reg_100;
reg    ap_block_state1;
wire   [15:0] height_fu_95_p1;
reg   [15:0] height_reg_105;
wire    grp_xFinRangeKernel_fu_80_ap_start;
wire    grp_xFinRangeKernel_fu_80_ap_done;
wire    grp_xFinRangeKernel_fu_80_ap_idle;
wire    grp_xFinRangeKernel_fu_80_ap_ready;
wire    grp_xFinRangeKernel_fu_80_p_src_mat_data_V_read;
wire   [0:0] grp_xFinRangeKernel_fu_80_p_dst_mat_data_V_din;
wire    grp_xFinRangeKernel_fu_80_p_dst_mat_data_V_write;
reg    grp_xFinRangeKernel_fu_80_ap_start_reg;
reg    ap_block_state1_ignore_call8;
wire    ap_CS_fsm_state2;
reg   [1:0] ap_NS_fsm;

// power-on initialization
initial begin
#0 ap_done_reg = 1'b0;
#0 ap_CS_fsm = 2'd1;
#0 grp_xFinRangeKernel_fu_80_ap_start_reg = 1'b0;
end

xFinRangeKernel grp_xFinRangeKernel_fu_80(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_xFinRangeKernel_fu_80_ap_start),
    .ap_done(grp_xFinRangeKernel_fu_80_ap_done),
    .ap_idle(grp_xFinRangeKernel_fu_80_ap_idle),
    .ap_ready(grp_xFinRangeKernel_fu_80_ap_ready),
    .p_src_mat_data_V_dout(src_data_V_dout),
    .p_src_mat_data_V_empty_n(src_data_V_empty_n),
    .p_src_mat_data_V_read(grp_xFinRangeKernel_fu_80_p_src_mat_data_V_read),
    .p_dst_mat_data_V_din(grp_xFinRangeKernel_fu_80_p_dst_mat_data_V_din),
    .p_dst_mat_data_V_full_n(dst_data_V_full_n),
    .p_dst_mat_data_V_write(grp_xFinRangeKernel_fu_80_p_dst_mat_data_V_write),
    .height(height_reg_105),
    .width(width_reg_100)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((grp_xFinRangeKernel_fu_80_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state2))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_xFinRangeKernel_fu_80_ap_start_reg <= 1'b0;
    end else begin
        if ((~((ap_start == 1'b0) | (src_cols_empty_n == 1'b0) | (src_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
            grp_xFinRangeKernel_fu_80_ap_start_reg <= 1'b1;
        end else if ((grp_xFinRangeKernel_fu_80_ap_ready == 1'b1)) begin
            grp_xFinRangeKernel_fu_80_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if ((~((ap_start == 1'b0) | (src_cols_empty_n == 1'b0) | (src_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        height_reg_105 <= height_fu_95_p1;
        width_reg_100 <= width_fu_90_p1;
    end
end

always @ (*) begin
    if (((grp_xFinRangeKernel_fu_80_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state2))) begin
        ap_done = 1'b1;
    end else begin
        ap_done = ap_done_reg;
    end
end

always @ (*) begin
    if (((ap_start == 1'b0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((grp_xFinRangeKernel_fu_80_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state2))) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state2)) begin
        dst_data_V_write = grp_xFinRangeKernel_fu_80_p_dst_mat_data_V_write;
    end else begin
        dst_data_V_write = 1'b0;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        src_cols_blk_n = src_cols_empty_n;
    end else begin
        src_cols_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (src_cols_empty_n == 1'b0) | (src_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        src_cols_read = 1'b1;
    end else begin
        src_cols_read = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state2)) begin
        src_data_V_read = grp_xFinRangeKernel_fu_80_p_src_mat_data_V_read;
    end else begin
        src_data_V_read = 1'b0;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        src_rows_blk_n = src_rows_empty_n;
    end else begin
        src_rows_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (src_cols_empty_n == 1'b0) | (src_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        src_rows_read = 1'b1;
    end else begin
        src_rows_read = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if ((~((ap_start == 1'b0) | (src_cols_empty_n == 1'b0) | (src_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_state2 : begin
            if (((grp_xFinRangeKernel_fu_80_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state2))) begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state2 = ap_CS_fsm[32'd1];

always @ (*) begin
    ap_block_state1 = ((ap_start == 1'b0) | (src_cols_empty_n == 1'b0) | (src_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1));
end

always @ (*) begin
    ap_block_state1_ignore_call8 = ((ap_start == 1'b0) | (src_cols_empty_n == 1'b0) | (src_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1));
end

assign dst_data_V_din = grp_xFinRangeKernel_fu_80_p_dst_mat_data_V_din;

assign grp_xFinRangeKernel_fu_80_ap_start = grp_xFinRangeKernel_fu_80_ap_start_reg;

assign height_fu_95_p1 = src_rows_dout[15:0];

assign width_fu_90_p1 = src_cols_dout[15:0];

endmodule //inRange























































































































