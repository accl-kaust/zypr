// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
// Version: 2019.2
// Copyright (C) 1986-2019 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

module xfMat2AXIstream (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_continue,
        ap_idle,
        ap_ready,
        img_rows_dout,
        img_rows_empty_n,
        img_rows_read,
        img_cols_dout,
        img_cols_empty_n,
        img_cols_read,
        img_data_V_dout,
        img_data_V_empty_n,
        img_data_V_read,
        stream_out_TDATA,
        stream_out_TVALID,
        stream_out_TREADY,
        stream_out_TLAST
);

parameter    ap_ST_fsm_state1 = 4'd1;
parameter    ap_ST_fsm_state2 = 4'd2;
parameter    ap_ST_fsm_pp0_stage0 = 4'd4;
parameter    ap_ST_fsm_state6 = 4'd8;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
input   ap_continue;
output   ap_idle;
output   ap_ready;
input  [31:0] img_rows_dout;
input   img_rows_empty_n;
output   img_rows_read;
input  [31:0] img_cols_dout;
input   img_cols_empty_n;
output   img_cols_read;
input  [0:0] img_data_V_dout;
input   img_data_V_empty_n;
output   img_data_V_read;
output  [7:0] stream_out_TDATA;
output   stream_out_TVALID;
input   stream_out_TREADY;
output  [0:0] stream_out_TLAST;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg img_rows_read;
reg img_cols_read;
reg img_data_V_read;

reg    ap_done_reg;
(* fsm_encoding = "none" *) reg   [3:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg    img_rows_blk_n;
reg    img_cols_blk_n;
reg    img_data_V_blk_n;
wire    ap_CS_fsm_pp0_stage0;
reg    ap_enable_reg_pp0_iter1;
wire    ap_block_pp0_stage0;
reg   [0:0] icmp_ln63_reg_248;
reg    stream_out_TDATA_blk_n;
reg    ap_enable_reg_pp0_iter2;
reg   [0:0] icmp_ln63_reg_248_pp0_iter1_reg;
reg   [10:0] j_0_i_reg_137;
reg   [31:0] rows_reg_214;
reg    ap_block_state1;
reg   [31:0] cols_reg_219;
wire   [31:0] add_ln71_fu_148_p2;
reg   [31:0] add_ln71_reg_224;
wire   [31:0] add_ln71_1_fu_154_p2;
reg   [31:0] add_ln71_1_reg_229;
wire   [0:0] icmp_ln60_fu_164_p2;
wire    ap_CS_fsm_state2;
wire    regslice_both_AXI_video_strm_V_data_V_U_apdone_blk;
wire   [10:0] i_fu_169_p2;
reg   [10:0] i_reg_238;
wire   [0:0] icmp_ln71_fu_175_p2;
reg   [0:0] icmp_ln71_reg_243;
wire   [0:0] icmp_ln63_fu_184_p2;
wire    ap_block_state3_pp0_stage0_iter0;
reg    ap_block_state4_pp0_stage0_iter1;
reg    ap_block_state4_io;
wire    ap_block_state5_pp0_stage0_iter2;
reg    ap_block_state5_io;
reg    ap_block_pp0_stage0_11001;
wire   [10:0] j_fu_189_p2;
reg    ap_enable_reg_pp0_iter0;
wire   [0:0] pixelpacket_last_V_fu_200_p2;
reg   [0:0] pixelpacket_last_V_reg_257;
reg    ap_block_pp0_stage0_subdone;
reg    ap_condition_pp0_exit_iter0_state3;
reg   [10:0] i_0_i_reg_126;
wire    ap_CS_fsm_state6;
reg    ap_block_pp0_stage0_01001;
wire   [31:0] zext_ln60_fu_160_p1;
wire   [31:0] zext_ln63_fu_180_p1;
wire   [0:0] icmp_ln71_1_fu_195_p2;
reg   [3:0] ap_NS_fsm;
reg    ap_idle_pp0;
wire    ap_enable_pp0;
wire   [7:0] stream_out_TDATA_int;
reg    stream_out_TVALID_int;
wire    stream_out_TREADY_int;
wire    regslice_both_AXI_video_strm_V_data_V_U_vld_out;
wire    regslice_both_AXI_video_strm_V_last_V_U_apdone_blk;
wire    regslice_both_AXI_video_strm_V_last_V_U_ack_in_dummy;
wire    regslice_both_AXI_video_strm_V_last_V_U_vld_out;

// power-on initialization
initial begin
#0 ap_done_reg = 1'b0;
#0 ap_CS_fsm = 4'd1;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter2 = 1'b0;
#0 ap_enable_reg_pp0_iter0 = 1'b0;
end

regslice_both #(
    .DataWidth( 8 ))
regslice_both_AXI_video_strm_V_data_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .data_in(stream_out_TDATA_int),
    .vld_in(stream_out_TVALID_int),
    .ack_in(stream_out_TREADY_int),
    .data_out(stream_out_TDATA),
    .vld_out(regslice_both_AXI_video_strm_V_data_V_U_vld_out),
    .ack_out(stream_out_TREADY),
    .apdone_blk(regslice_both_AXI_video_strm_V_data_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 1 ))
regslice_both_AXI_video_strm_V_last_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .data_in(pixelpacket_last_V_reg_257),
    .vld_in(stream_out_TVALID_int),
    .ack_in(regslice_both_AXI_video_strm_V_last_V_U_ack_in_dummy),
    .data_out(stream_out_TLAST),
    .vld_out(regslice_both_AXI_video_strm_V_last_V_U_vld_out),
    .ack_out(stream_out_TREADY),
    .apdone_blk(regslice_both_AXI_video_strm_V_last_V_U_apdone_blk)
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
        end else if (((regslice_both_AXI_video_strm_V_data_V_U_apdone_blk == 1'b0) & (icmp_ln60_fu_164_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
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
        end else if (((regslice_both_AXI_video_strm_V_data_V_U_apdone_blk == 1'b0) & (icmp_ln60_fu_164_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state2))) begin
            ap_enable_reg_pp0_iter0 <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            if ((1'b1 == ap_condition_pp0_exit_iter0_state3)) begin
                ap_enable_reg_pp0_iter1 <= (1'b1 ^ ap_condition_pp0_exit_iter0_state3);
            end else if ((1'b1 == 1'b1)) begin
                ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
            end
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter2 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter2 <= ap_enable_reg_pp0_iter1;
        end else if (((regslice_both_AXI_video_strm_V_data_V_U_apdone_blk == 1'b0) & (icmp_ln60_fu_164_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state2))) begin
            ap_enable_reg_pp0_iter2 <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state6)) begin
        i_0_i_reg_126 <= i_reg_238;
    end else if ((~((ap_start == 1'b0) | (img_cols_empty_n == 1'b0) | (img_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        i_0_i_reg_126 <= 11'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln63_fu_184_p2 == 1'd1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        j_0_i_reg_137 <= j_fu_189_p2;
    end else if (((regslice_both_AXI_video_strm_V_data_V_U_apdone_blk == 1'b0) & (icmp_ln60_fu_164_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state2))) begin
        j_0_i_reg_137 <= 11'd0;
    end
end

always @ (posedge ap_clk) begin
    if ((~((ap_start == 1'b0) | (img_cols_empty_n == 1'b0) | (img_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        add_ln71_1_reg_229 <= add_ln71_1_fu_154_p2;
        add_ln71_reg_224 <= add_ln71_fu_148_p2;
        cols_reg_219 <= img_cols_dout;
        rows_reg_214 <= img_rows_dout;
    end
end

always @ (posedge ap_clk) begin
    if (((regslice_both_AXI_video_strm_V_data_V_U_apdone_blk == 1'b0) & (1'b1 == ap_CS_fsm_state2))) begin
        i_reg_238 <= i_fu_169_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        icmp_ln63_reg_248 <= icmp_ln63_fu_184_p2;
        icmp_ln63_reg_248_pp0_iter1_reg <= icmp_ln63_reg_248;
    end
end

always @ (posedge ap_clk) begin
    if (((regslice_both_AXI_video_strm_V_data_V_U_apdone_blk == 1'b0) & (icmp_ln60_fu_164_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state2))) begin
        icmp_ln71_reg_243 <= icmp_ln71_fu_175_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln63_fu_184_p2 == 1'd1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        pixelpacket_last_V_reg_257 <= pixelpacket_last_V_fu_200_p2;
    end
end

always @ (*) begin
    if ((icmp_ln63_fu_184_p2 == 1'd0)) begin
        ap_condition_pp0_exit_iter0_state3 = 1'b1;
    end else begin
        ap_condition_pp0_exit_iter0_state3 = 1'b0;
    end
end

always @ (*) begin
    if (((regslice_both_AXI_video_strm_V_data_V_U_apdone_blk == 1'b0) & (icmp_ln60_fu_164_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
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
    if (((ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if (((regslice_both_AXI_video_strm_V_data_V_U_apdone_blk == 1'b0) & (icmp_ln60_fu_164_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        img_cols_blk_n = img_cols_empty_n;
    end else begin
        img_cols_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (img_cols_empty_n == 1'b0) | (img_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        img_cols_read = 1'b1;
    end else begin
        img_cols_read = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln63_reg_248 == 1'd1) & (1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        img_data_V_blk_n = img_data_V_empty_n;
    end else begin
        img_data_V_blk_n = 1'b1;
    end
end

always @ (*) begin
    if (((icmp_ln63_reg_248 == 1'd1) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        img_data_V_read = 1'b1;
    end else begin
        img_data_V_read = 1'b0;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        img_rows_blk_n = img_rows_empty_n;
    end else begin
        img_rows_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (img_cols_empty_n == 1'b0) | (img_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        img_rows_read = 1'b1;
    end else begin
        img_rows_read = 1'b0;
    end
end

always @ (*) begin
    if ((((icmp_ln63_reg_248_pp0_iter1_reg == 1'd1) & (1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((icmp_ln63_reg_248 == 1'd1) & (1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0)))) begin
        stream_out_TDATA_blk_n = stream_out_TREADY_int;
    end else begin
        stream_out_TDATA_blk_n = 1'b1;
    end
end

always @ (*) begin
    if (((icmp_ln63_reg_248 == 1'd1) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        stream_out_TVALID_int = 1'b1;
    end else begin
        stream_out_TVALID_int = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if ((~((ap_start == 1'b0) | (img_cols_empty_n == 1'b0) | (img_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_state2 : begin
            if (((regslice_both_AXI_video_strm_V_data_V_U_apdone_blk == 1'b0) & (icmp_ln60_fu_164_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end else if (((regslice_both_AXI_video_strm_V_data_V_U_apdone_blk == 1'b0) & (icmp_ln60_fu_164_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state2))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end
        end
        ap_ST_fsm_pp0_stage0 : begin
            if ((~((ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_subdone) & (icmp_ln63_fu_184_p2 == 1'd0)) & ~((ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter2 == 1'b1) & (1'b0 == ap_block_pp0_stage0_subdone)))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else if ((((ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter2 == 1'b1) & (1'b0 == ap_block_pp0_stage0_subdone)) | ((ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_subdone) & (icmp_ln63_fu_184_p2 == 1'd0)))) begin
                ap_NS_fsm = ap_ST_fsm_state6;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_state6 : begin
            ap_NS_fsm = ap_ST_fsm_state2;
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln71_1_fu_154_p2 = ($signed(img_cols_dout) + $signed(32'd4294967295));

assign add_ln71_fu_148_p2 = ($signed(img_rows_dout) + $signed(32'd4294967295));

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd2];

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state2 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_state6 = ap_CS_fsm[32'd3];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_pp0_stage0_01001 = ((icmp_ln63_reg_248 == 1'd1) & (img_data_V_empty_n == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b1));
end

always @ (*) begin
    ap_block_pp0_stage0_11001 = (((1'b1 == ap_block_state5_io) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((ap_enable_reg_pp0_iter1 == 1'b1) & ((1'b1 == ap_block_state4_io) | ((icmp_ln63_reg_248 == 1'd1) & (img_data_V_empty_n == 1'b0)))));
end

always @ (*) begin
    ap_block_pp0_stage0_subdone = (((1'b1 == ap_block_state5_io) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((ap_enable_reg_pp0_iter1 == 1'b1) & ((1'b1 == ap_block_state4_io) | ((icmp_ln63_reg_248 == 1'd1) & (img_data_V_empty_n == 1'b0)))));
end

always @ (*) begin
    ap_block_state1 = ((ap_start == 1'b0) | (img_cols_empty_n == 1'b0) | (img_rows_empty_n == 1'b0) | (ap_done_reg == 1'b1));
end

assign ap_block_state3_pp0_stage0_iter0 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_state4_io = ((icmp_ln63_reg_248 == 1'd1) & (stream_out_TREADY_int == 1'b0));
end

always @ (*) begin
    ap_block_state4_pp0_stage0_iter1 = ((icmp_ln63_reg_248 == 1'd1) & (img_data_V_empty_n == 1'b0));
end

always @ (*) begin
    ap_block_state5_io = ((icmp_ln63_reg_248_pp0_iter1_reg == 1'd1) & (stream_out_TREADY_int == 1'b0));
end

assign ap_block_state5_pp0_stage0_iter2 = ~(1'b1 == 1'b1);

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign i_fu_169_p2 = (i_0_i_reg_126 + 11'd1);

assign icmp_ln60_fu_164_p2 = (($signed(zext_ln60_fu_160_p1) < $signed(rows_reg_214)) ? 1'b1 : 1'b0);

assign icmp_ln63_fu_184_p2 = (($signed(zext_ln63_fu_180_p1) < $signed(cols_reg_219)) ? 1'b1 : 1'b0);

assign icmp_ln71_1_fu_195_p2 = ((zext_ln63_fu_180_p1 == add_ln71_1_reg_229) ? 1'b1 : 1'b0);

assign icmp_ln71_fu_175_p2 = ((zext_ln60_fu_160_p1 == add_ln71_reg_224) ? 1'b1 : 1'b0);

assign j_fu_189_p2 = (j_0_i_reg_137 + 11'd1);

assign pixelpacket_last_V_fu_200_p2 = (icmp_ln71_reg_243 & icmp_ln71_1_fu_195_p2);

assign stream_out_TDATA_int = ((img_data_V_dout[0:0] === 1'b1) ? 8'd255 : 8'd0);

assign stream_out_TVALID = regslice_both_AXI_video_strm_V_data_V_U_vld_out;

assign zext_ln60_fu_160_p1 = i_0_i_reg_126;

assign zext_ln63_fu_180_p1 = j_0_i_reg_137;

endmodule //xfMat2AXIstream





































































































