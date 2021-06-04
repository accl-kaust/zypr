// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
// Version: 2019.2
// Copyright (C) 1986-2019 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

module bgr2hsv (
        p_src_mat_rows_dout,
        p_src_mat_rows_empty_n,
        p_src_mat_rows_read,
        p_src_mat_cols_dout,
        p_src_mat_cols_empty_n,
        p_src_mat_cols_read,
        p_src_mat_data_V_dout,
        p_src_mat_data_V_empty_n,
        p_src_mat_data_V_read,
        p_dst_mat_data_V_din,
        p_dst_mat_data_V_full_n,
        p_dst_mat_data_V_write,
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_ready,
        ap_idle,
        ap_continue
);


input  [31:0] p_src_mat_rows_dout;
input   p_src_mat_rows_empty_n;
output   p_src_mat_rows_read;
input  [31:0] p_src_mat_cols_dout;
input   p_src_mat_cols_empty_n;
output   p_src_mat_cols_read;
input  [23:0] p_src_mat_data_V_dout;
input   p_src_mat_data_V_empty_n;
output   p_src_mat_data_V_read;
output  [23:0] p_dst_mat_data_V_din;
input   p_dst_mat_data_V_full_n;
output   p_dst_mat_data_V_write;
input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_ready;
output   ap_idle;
input   ap_continue;

wire    bgr2hsv_Block_codeRe_U0_ap_start;
wire    bgr2hsv_Block_codeRe_U0_ap_done;
wire    bgr2hsv_Block_codeRe_U0_ap_continue;
wire    bgr2hsv_Block_codeRe_U0_ap_idle;
wire    bgr2hsv_Block_codeRe_U0_ap_ready;
wire    bgr2hsv_Block_codeRe_U0_p_src_mat_cols_read;
wire    bgr2hsv_Block_codeRe_U0_p_src_mat_rows_read;
wire   [31:0] bgr2hsv_Block_codeRe_U0_p_src_mat_rows_out_din;
wire    bgr2hsv_Block_codeRe_U0_p_src_mat_rows_out_write;
wire   [31:0] bgr2hsv_Block_codeRe_U0_ap_return;
wire    ap_channel_done_p_src_mat_cols_load_l;
wire    p_src_mat_cols_load_l_full_n;
wire    bgr2hsv_Loop_1_proc_U0_ap_start;
wire    bgr2hsv_Loop_1_proc_U0_ap_done;
wire    bgr2hsv_Loop_1_proc_U0_ap_continue;
wire    bgr2hsv_Loop_1_proc_U0_ap_idle;
wire    bgr2hsv_Loop_1_proc_U0_ap_ready;
wire    bgr2hsv_Loop_1_proc_U0_p_src_mat_rows_read;
wire    bgr2hsv_Loop_1_proc_U0_p_src_mat_data_V_read;
wire   [23:0] bgr2hsv_Loop_1_proc_U0_p_dst_mat_data_V_din;
wire    bgr2hsv_Loop_1_proc_U0_p_dst_mat_data_V_write;
wire    ap_sync_continue;
wire    p_src_mat_rows_c_i_full_n;
wire   [31:0] p_src_mat_rows_c_i_dout;
wire    p_src_mat_rows_c_i_empty_n;
wire   [31:0] p_src_mat_cols_load_l_dout;
wire    p_src_mat_cols_load_l_empty_n;
wire    ap_sync_done;
wire    ap_sync_ready;
reg    ap_sync_reg_bgr2hsv_Block_codeRe_U0_ap_ready;
wire    ap_sync_bgr2hsv_Block_codeRe_U0_ap_ready;
reg   [1:0] bgr2hsv_Block_codeRe_U0_ap_ready_count;
reg    ap_sync_reg_bgr2hsv_Loop_1_proc_U0_ap_ready;
wire    ap_sync_bgr2hsv_Loop_1_proc_U0_ap_ready;
reg   [1:0] bgr2hsv_Loop_1_proc_U0_ap_ready_count;
wire    bgr2hsv_Block_codeRe_U0_start_full_n;
wire    bgr2hsv_Block_codeRe_U0_start_write;
wire    bgr2hsv_Loop_1_proc_U0_start_full_n;
wire    bgr2hsv_Loop_1_proc_U0_start_write;

// power-on initialization
initial begin
#0 ap_sync_reg_bgr2hsv_Block_codeRe_U0_ap_ready = 1'b0;
#0 bgr2hsv_Block_codeRe_U0_ap_ready_count = 2'd0;
#0 ap_sync_reg_bgr2hsv_Loop_1_proc_U0_ap_ready = 1'b0;
#0 bgr2hsv_Loop_1_proc_U0_ap_ready_count = 2'd0;
end

bgr2hsv_Block_codeRe bgr2hsv_Block_codeRe_U0(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(bgr2hsv_Block_codeRe_U0_ap_start),
    .ap_done(bgr2hsv_Block_codeRe_U0_ap_done),
    .ap_continue(bgr2hsv_Block_codeRe_U0_ap_continue),
    .ap_idle(bgr2hsv_Block_codeRe_U0_ap_idle),
    .ap_ready(bgr2hsv_Block_codeRe_U0_ap_ready),
    .p_src_mat_cols_dout(p_src_mat_cols_dout),
    .p_src_mat_cols_empty_n(p_src_mat_cols_empty_n),
    .p_src_mat_cols_read(bgr2hsv_Block_codeRe_U0_p_src_mat_cols_read),
    .p_src_mat_rows_dout(p_src_mat_rows_dout),
    .p_src_mat_rows_empty_n(p_src_mat_rows_empty_n),
    .p_src_mat_rows_read(bgr2hsv_Block_codeRe_U0_p_src_mat_rows_read),
    .p_src_mat_rows_out_din(bgr2hsv_Block_codeRe_U0_p_src_mat_rows_out_din),
    .p_src_mat_rows_out_full_n(p_src_mat_rows_c_i_full_n),
    .p_src_mat_rows_out_write(bgr2hsv_Block_codeRe_U0_p_src_mat_rows_out_write),
    .ap_return(bgr2hsv_Block_codeRe_U0_ap_return)
);

bgr2hsv_Loop_1_proc bgr2hsv_Loop_1_proc_U0(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(bgr2hsv_Loop_1_proc_U0_ap_start),
    .ap_done(bgr2hsv_Loop_1_proc_U0_ap_done),
    .ap_continue(bgr2hsv_Loop_1_proc_U0_ap_continue),
    .ap_idle(bgr2hsv_Loop_1_proc_U0_ap_idle),
    .ap_ready(bgr2hsv_Loop_1_proc_U0_ap_ready),
    .p_src_mat_rows_dout(p_src_mat_rows_c_i_dout),
    .p_src_mat_rows_empty_n(p_src_mat_rows_c_i_empty_n),
    .p_src_mat_rows_read(bgr2hsv_Loop_1_proc_U0_p_src_mat_rows_read),
    .p_read(p_src_mat_cols_load_l_dout),
    .p_src_mat_data_V_dout(p_src_mat_data_V_dout),
    .p_src_mat_data_V_empty_n(p_src_mat_data_V_empty_n),
    .p_src_mat_data_V_read(bgr2hsv_Loop_1_proc_U0_p_src_mat_data_V_read),
    .p_dst_mat_data_V_din(bgr2hsv_Loop_1_proc_U0_p_dst_mat_data_V_din),
    .p_dst_mat_data_V_full_n(p_dst_mat_data_V_full_n),
    .p_dst_mat_data_V_write(bgr2hsv_Loop_1_proc_U0_p_dst_mat_data_V_write)
);

fifo_w32_d2_A p_src_mat_rows_c_i_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(bgr2hsv_Block_codeRe_U0_p_src_mat_rows_out_din),
    .if_full_n(p_src_mat_rows_c_i_full_n),
    .if_write(bgr2hsv_Block_codeRe_U0_p_src_mat_rows_out_write),
    .if_dout(p_src_mat_rows_c_i_dout),
    .if_empty_n(p_src_mat_rows_c_i_empty_n),
    .if_read(bgr2hsv_Loop_1_proc_U0_p_src_mat_rows_read)
);

fifo_w32_d2_A p_src_mat_cols_load_l_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(bgr2hsv_Block_codeRe_U0_ap_return),
    .if_full_n(p_src_mat_cols_load_l_full_n),
    .if_write(bgr2hsv_Block_codeRe_U0_ap_done),
    .if_dout(p_src_mat_cols_load_l_dout),
    .if_empty_n(p_src_mat_cols_load_l_empty_n),
    .if_read(bgr2hsv_Loop_1_proc_U0_ap_ready)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_sync_reg_bgr2hsv_Block_codeRe_U0_ap_ready <= 1'b0;
    end else begin
        if (((ap_sync_ready & ap_start) == 1'b1)) begin
            ap_sync_reg_bgr2hsv_Block_codeRe_U0_ap_ready <= 1'b0;
        end else begin
            ap_sync_reg_bgr2hsv_Block_codeRe_U0_ap_ready <= ap_sync_bgr2hsv_Block_codeRe_U0_ap_ready;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_sync_reg_bgr2hsv_Loop_1_proc_U0_ap_ready <= 1'b0;
    end else begin
        if (((ap_sync_ready & ap_start) == 1'b1)) begin
            ap_sync_reg_bgr2hsv_Loop_1_proc_U0_ap_ready <= 1'b0;
        end else begin
            ap_sync_reg_bgr2hsv_Loop_1_proc_U0_ap_ready <= ap_sync_bgr2hsv_Loop_1_proc_U0_ap_ready;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((bgr2hsv_Block_codeRe_U0_ap_ready == 1'b0) & (ap_sync_ready == 1'b1))) begin
        bgr2hsv_Block_codeRe_U0_ap_ready_count <= (bgr2hsv_Block_codeRe_U0_ap_ready_count - 2'd1);
    end else if (((ap_sync_ready == 1'b0) & (bgr2hsv_Block_codeRe_U0_ap_ready == 1'b1))) begin
        bgr2hsv_Block_codeRe_U0_ap_ready_count <= (bgr2hsv_Block_codeRe_U0_ap_ready_count + 2'd1);
    end
end

always @ (posedge ap_clk) begin
    if (((bgr2hsv_Loop_1_proc_U0_ap_ready == 1'b0) & (ap_sync_ready == 1'b1))) begin
        bgr2hsv_Loop_1_proc_U0_ap_ready_count <= (bgr2hsv_Loop_1_proc_U0_ap_ready_count - 2'd1);
    end else if (((ap_sync_ready == 1'b0) & (bgr2hsv_Loop_1_proc_U0_ap_ready == 1'b1))) begin
        bgr2hsv_Loop_1_proc_U0_ap_ready_count <= (bgr2hsv_Loop_1_proc_U0_ap_ready_count + 2'd1);
    end
end

assign ap_channel_done_p_src_mat_cols_load_l = bgr2hsv_Block_codeRe_U0_ap_done;

assign ap_done = bgr2hsv_Loop_1_proc_U0_ap_done;

assign ap_idle = ((p_src_mat_cols_load_l_empty_n ^ 1'b1) & bgr2hsv_Loop_1_proc_U0_ap_idle & bgr2hsv_Block_codeRe_U0_ap_idle);

assign ap_ready = ap_sync_ready;

assign ap_sync_bgr2hsv_Block_codeRe_U0_ap_ready = (bgr2hsv_Block_codeRe_U0_ap_ready | ap_sync_reg_bgr2hsv_Block_codeRe_U0_ap_ready);

assign ap_sync_bgr2hsv_Loop_1_proc_U0_ap_ready = (bgr2hsv_Loop_1_proc_U0_ap_ready | ap_sync_reg_bgr2hsv_Loop_1_proc_U0_ap_ready);

assign ap_sync_continue = ap_continue;

assign ap_sync_done = bgr2hsv_Loop_1_proc_U0_ap_done;

assign ap_sync_ready = (ap_sync_bgr2hsv_Loop_1_proc_U0_ap_ready & ap_sync_bgr2hsv_Block_codeRe_U0_ap_ready);

assign bgr2hsv_Block_codeRe_U0_ap_continue = p_src_mat_cols_load_l_full_n;

assign bgr2hsv_Block_codeRe_U0_ap_start = ((ap_sync_reg_bgr2hsv_Block_codeRe_U0_ap_ready ^ 1'b1) & ap_start);

assign bgr2hsv_Block_codeRe_U0_start_full_n = 1'b1;

assign bgr2hsv_Block_codeRe_U0_start_write = 1'b0;

assign bgr2hsv_Loop_1_proc_U0_ap_continue = ap_continue;

assign bgr2hsv_Loop_1_proc_U0_ap_start = (p_src_mat_cols_load_l_empty_n & (ap_sync_reg_bgr2hsv_Loop_1_proc_U0_ap_ready ^ 1'b1) & ap_start);

assign bgr2hsv_Loop_1_proc_U0_start_full_n = 1'b1;

assign bgr2hsv_Loop_1_proc_U0_start_write = 1'b0;

assign p_dst_mat_data_V_din = bgr2hsv_Loop_1_proc_U0_p_dst_mat_data_V_din;

assign p_dst_mat_data_V_write = bgr2hsv_Loop_1_proc_U0_p_dst_mat_data_V_write;

assign p_src_mat_cols_read = bgr2hsv_Block_codeRe_U0_p_src_mat_cols_read;

assign p_src_mat_data_V_read = bgr2hsv_Loop_1_proc_U0_p_src_mat_data_V_read;

assign p_src_mat_rows_read = bgr2hsv_Block_codeRe_U0_p_src_mat_rows_read;

endmodule //bgr2hsv















































































































