// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
// Version: 2019.2
// Copyright (C) 1986-2019 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

module addWeighted (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_continue,
        ap_idle,
        ap_ready,
        src1_rows_dout,
        src1_rows_empty_n,
        src1_rows_read,
        src1_cols_dout,
        src1_cols_empty_n,
        src1_cols_read,
        src1_data_V_dout,
        src1_data_V_empty_n,
        src1_data_V_read,
        src2_data_V_dout,
        src2_data_V_empty_n,
        src2_data_V_read,
        dst_data_V_din,
        dst_data_V_full_n,
        dst_data_V_write
);

parameter    ap_ST_fsm_state1 = 4'd1;
parameter    ap_ST_fsm_state2 = 4'd2;
parameter    ap_ST_fsm_pp0_stage0 = 4'd4;
parameter    ap_ST_fsm_state5 = 4'd8;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
input   ap_continue;
output   ap_idle;
output   ap_ready;
input  [15:0] src1_rows_dout;
input   src1_rows_empty_n;
output   src1_rows_read;
input  [15:0] src1_cols_dout;
input   src1_cols_empty_n;
output   src1_cols_read;
input  [7:0] src1_data_V_dout;
input   src1_data_V_empty_n;
output   src1_data_V_read;
input  [7:0] src2_data_V_dout;
input   src2_data_V_empty_n;
output   src2_data_V_read;
output  [7:0] dst_data_V_din;
input   dst_data_V_full_n;
output   dst_data_V_write;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg src1_rows_read;
reg src1_cols_read;
reg src1_data_V_read;
reg src2_data_V_read;
reg dst_data_V_write;

reg    ap_done_reg;
(* fsm_encoding = "none" *) reg   [3:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg    src1_rows_blk_n;
reg    src1_cols_blk_n;
reg    src1_data_V_blk_n;
wire    ap_CS_fsm_pp0_stage0;
reg    ap_enable_reg_pp0_iter1;
wire    ap_block_pp0_stage0;
reg   [0:0] icmp_ln68_reg_253;
reg    src2_data_V_blk_n;
reg    dst_data_V_blk_n;
reg   [15:0] t_V_reg_162;
reg   [15:0] width_reg_234;
reg    ap_block_state1;
reg   [15:0] src1_rows_read_reg_239;
wire   [0:0] icmp_ln887_fu_177_p2;
wire    ap_CS_fsm_state2;
wire   [12:0] i_V_fu_182_p2;
reg   [12:0] i_V_reg_248;
wire   [0:0] icmp_ln68_fu_188_p2;
wire    ap_block_state3_pp0_stage0_iter0;
reg    ap_block_state4_pp0_stage0_iter1;
reg    ap_block_pp0_stage0_11001;
wire   [15:0] add_ln1597_fu_193_p2;
reg    ap_enable_reg_pp0_iter0;
reg    ap_block_pp0_stage0_subdone;
reg    ap_condition_pp0_exit_iter0_state3;
reg   [12:0] t_V_4_reg_151;
wire    ap_CS_fsm_state5;
reg    ap_block_pp0_stage0_01001;
wire   [15:0] zext_ln887_fu_173_p1;
wire   [6:0] tmp_6_i_i_fu_199_p4;
wire   [6:0] tmp_7_i_i_fu_209_p4;
wire   [7:0] rhs_V_11_0_i_i_fu_223_p1;
wire   [7:0] lhs_V_19_0_i_i_fu_219_p1;
reg   [3:0] ap_NS_fsm;
reg    ap_idle_pp0;
wire    ap_enable_pp0;

// power-on initialization
initial begin
#0 ap_done_reg = 1'b0;
#0 ap_CS_fsm = 4'd1;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter0 = 1'b0;
end

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
        end else if (((icmp_ln887_fu_177_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter0 <= 1'b0;
    end else begin
        if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b1 == ap_condition_pp0_exit_iter0_state3) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
            ap_enable_reg_pp0_iter0 <= 1'b0;
        end else if (((icmp_ln887_fu_177_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state2))) begin
            ap_enable_reg_pp0_iter0 <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if (((1'b1 == ap_condition_pp0_exit_iter0_state3) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
            ap_enable_reg_pp0_iter1 <= (1'b1 ^ ap_condition_pp0_exit_iter0_state3);
        end else if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
        end else if (((icmp_ln887_fu_177_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state2))) begin
            ap_enable_reg_pp0_iter1 <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state5)) begin
        t_V_4_reg_151 <= i_V_reg_248;
    end else if ((~((ap_start == 1'b0) | (src1_cols_empty_n == 1'b0) | (src1_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        t_V_4_reg_151 <= 13'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln68_fu_188_p2 == 1'd0) & (1'b1 == ap_CS_fsm_pp0_stage0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        t_V_reg_162 <= add_ln1597_fu_193_p2;
    end else if (((icmp_ln887_fu_177_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state2))) begin
        t_V_reg_162 <= 16'd0;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state2)) begin
        i_V_reg_248 <= i_V_fu_182_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        icmp_ln68_reg_253 <= icmp_ln68_fu_188_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((~((ap_start == 1'b0) | (src1_cols_empty_n == 1'b0) | (src1_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        src1_rows_read_reg_239 <= src1_rows_dout;
        width_reg_234 <= src1_cols_dout;
    end
end

always @ (*) begin
    if ((icmp_ln68_fu_188_p2 == 1'd1)) begin
        ap_condition_pp0_exit_iter0_state3 = 1'b1;
    end else begin
        ap_condition_pp0_exit_iter0_state3 = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln887_fu_177_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
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
    if (((ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln887_fu_177_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln68_reg_253 == 1'd0) & (1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        dst_data_V_blk_n = dst_data_V_full_n;
    end else begin
        dst_data_V_blk_n = 1'b1;
    end
end

always @ (*) begin
    if (((icmp_ln68_reg_253 == 1'd0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        dst_data_V_write = 1'b1;
    end else begin
        dst_data_V_write = 1'b0;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        src1_cols_blk_n = src1_cols_empty_n;
    end else begin
        src1_cols_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (src1_cols_empty_n == 1'b0) | (src1_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        src1_cols_read = 1'b1;
    end else begin
        src1_cols_read = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln68_reg_253 == 1'd0) & (1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        src1_data_V_blk_n = src1_data_V_empty_n;
    end else begin
        src1_data_V_blk_n = 1'b1;
    end
end

always @ (*) begin
    if (((icmp_ln68_reg_253 == 1'd0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        src1_data_V_read = 1'b1;
    end else begin
        src1_data_V_read = 1'b0;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        src1_rows_blk_n = src1_rows_empty_n;
    end else begin
        src1_rows_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (src1_cols_empty_n == 1'b0) | (src1_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        src1_rows_read = 1'b1;
    end else begin
        src1_rows_read = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln68_reg_253 == 1'd0) & (1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        src2_data_V_blk_n = src2_data_V_empty_n;
    end else begin
        src2_data_V_blk_n = 1'b1;
    end
end

always @ (*) begin
    if (((icmp_ln68_reg_253 == 1'd0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        src2_data_V_read = 1'b1;
    end else begin
        src2_data_V_read = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if ((~((ap_start == 1'b0) | (src1_cols_empty_n == 1'b0) | (src1_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_state2 : begin
            if (((icmp_ln887_fu_177_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_pp0_stage0 : begin
            if (~((icmp_ln68_fu_188_p2 == 1'd1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else if (((icmp_ln68_fu_188_p2 == 1'd1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_state5;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_state5 : begin
            ap_NS_fsm = ap_ST_fsm_state2;
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln1597_fu_193_p2 = (t_V_reg_162 + 16'd1);

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd2];

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state2 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_state5 = ap_CS_fsm[32'd3];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_pp0_stage0_01001 = ((ap_enable_reg_pp0_iter1 == 1'b1) & (((icmp_ln68_reg_253 == 1'd0) & (src2_data_V_empty_n == 1'b0)) | ((icmp_ln68_reg_253 == 1'd0) & (src1_data_V_empty_n == 1'b0)) | ((icmp_ln68_reg_253 == 1'd0) & (dst_data_V_full_n == 1'b0))));
end

always @ (*) begin
    ap_block_pp0_stage0_11001 = ((ap_enable_reg_pp0_iter1 == 1'b1) & (((icmp_ln68_reg_253 == 1'd0) & (src2_data_V_empty_n == 1'b0)) | ((icmp_ln68_reg_253 == 1'd0) & (src1_data_V_empty_n == 1'b0)) | ((icmp_ln68_reg_253 == 1'd0) & (dst_data_V_full_n == 1'b0))));
end

always @ (*) begin
    ap_block_pp0_stage0_subdone = ((ap_enable_reg_pp0_iter1 == 1'b1) & (((icmp_ln68_reg_253 == 1'd0) & (src2_data_V_empty_n == 1'b0)) | ((icmp_ln68_reg_253 == 1'd0) & (src1_data_V_empty_n == 1'b0)) | ((icmp_ln68_reg_253 == 1'd0) & (dst_data_V_full_n == 1'b0))));
end

always @ (*) begin
    ap_block_state1 = ((ap_start == 1'b0) | (src1_cols_empty_n == 1'b0) | (src1_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1));
end

assign ap_block_state3_pp0_stage0_iter0 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_state4_pp0_stage0_iter1 = (((icmp_ln68_reg_253 == 1'd0) & (src2_data_V_empty_n == 1'b0)) | ((icmp_ln68_reg_253 == 1'd0) & (src1_data_V_empty_n == 1'b0)) | ((icmp_ln68_reg_253 == 1'd0) & (dst_data_V_full_n == 1'b0)));
end

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign dst_data_V_din = (rhs_V_11_0_i_i_fu_223_p1 + lhs_V_19_0_i_i_fu_219_p1);

assign i_V_fu_182_p2 = (t_V_4_reg_151 + 13'd1);

assign icmp_ln68_fu_188_p2 = ((t_V_reg_162 == width_reg_234) ? 1'b1 : 1'b0);

assign icmp_ln887_fu_177_p2 = ((zext_ln887_fu_173_p1 < src1_rows_read_reg_239) ? 1'b1 : 1'b0);

assign lhs_V_19_0_i_i_fu_219_p1 = tmp_6_i_i_fu_199_p4;

assign rhs_V_11_0_i_i_fu_223_p1 = tmp_7_i_i_fu_209_p4;

assign tmp_6_i_i_fu_199_p4 = {{src1_data_V_dout[7:1]}};

assign tmp_7_i_i_fu_209_p4 = {{src2_data_V_dout[7:1]}};

assign zext_ln887_fu_173_p1 = t_V_4_reg_151;

endmodule //addWeighted







































































































































































































