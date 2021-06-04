// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
// Version: 2019.2
// Copyright (C) 1986-2019 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

module GaussianBlur (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_continue,
        ap_idle,
        ap_ready,
        p_src_rows_dout,
        p_src_rows_empty_n,
        p_src_rows_read,
        p_src_cols_dout,
        p_src_cols_empty_n,
        p_src_cols_read,
        p_src_data_V_dout,
        p_src_data_V_empty_n,
        p_src_data_V_read,
        p_dst_data_V_din,
        p_dst_data_V_full_n,
        p_dst_data_V_write,
        sigma_dout,
        sigma_empty_n,
        sigma_read
);

parameter    ap_ST_fsm_state1 = 64'd1;
parameter    ap_ST_fsm_state2 = 64'd2;
parameter    ap_ST_fsm_state3 = 64'd4;
parameter    ap_ST_fsm_state4 = 64'd8;
parameter    ap_ST_fsm_state5 = 64'd16;
parameter    ap_ST_fsm_state6 = 64'd32;
parameter    ap_ST_fsm_state7 = 64'd64;
parameter    ap_ST_fsm_state8 = 64'd128;
parameter    ap_ST_fsm_state9 = 64'd256;
parameter    ap_ST_fsm_state10 = 64'd512;
parameter    ap_ST_fsm_state11 = 64'd1024;
parameter    ap_ST_fsm_state12 = 64'd2048;
parameter    ap_ST_fsm_state13 = 64'd4096;
parameter    ap_ST_fsm_state14 = 64'd8192;
parameter    ap_ST_fsm_state15 = 64'd16384;
parameter    ap_ST_fsm_state16 = 64'd32768;
parameter    ap_ST_fsm_state17 = 64'd65536;
parameter    ap_ST_fsm_state18 = 64'd131072;
parameter    ap_ST_fsm_state19 = 64'd262144;
parameter    ap_ST_fsm_state20 = 64'd524288;
parameter    ap_ST_fsm_state21 = 64'd1048576;
parameter    ap_ST_fsm_state22 = 64'd2097152;
parameter    ap_ST_fsm_state23 = 64'd4194304;
parameter    ap_ST_fsm_state24 = 64'd8388608;
parameter    ap_ST_fsm_state25 = 64'd16777216;
parameter    ap_ST_fsm_state26 = 64'd33554432;
parameter    ap_ST_fsm_state27 = 64'd67108864;
parameter    ap_ST_fsm_state28 = 64'd134217728;
parameter    ap_ST_fsm_state29 = 64'd268435456;
parameter    ap_ST_fsm_state30 = 64'd536870912;
parameter    ap_ST_fsm_state31 = 64'd1073741824;
parameter    ap_ST_fsm_state32 = 64'd2147483648;
parameter    ap_ST_fsm_state33 = 64'd4294967296;
parameter    ap_ST_fsm_state34 = 64'd8589934592;
parameter    ap_ST_fsm_state35 = 64'd17179869184;
parameter    ap_ST_fsm_state36 = 64'd34359738368;
parameter    ap_ST_fsm_state37 = 64'd68719476736;
parameter    ap_ST_fsm_state38 = 64'd137438953472;
parameter    ap_ST_fsm_state39 = 64'd274877906944;
parameter    ap_ST_fsm_state40 = 64'd549755813888;
parameter    ap_ST_fsm_state41 = 64'd1099511627776;
parameter    ap_ST_fsm_state42 = 64'd2199023255552;
parameter    ap_ST_fsm_state43 = 64'd4398046511104;
parameter    ap_ST_fsm_state44 = 64'd8796093022208;
parameter    ap_ST_fsm_state45 = 64'd17592186044416;
parameter    ap_ST_fsm_state46 = 64'd35184372088832;
parameter    ap_ST_fsm_state47 = 64'd70368744177664;
parameter    ap_ST_fsm_state48 = 64'd140737488355328;
parameter    ap_ST_fsm_state49 = 64'd281474976710656;
parameter    ap_ST_fsm_state50 = 64'd562949953421312;
parameter    ap_ST_fsm_state51 = 64'd1125899906842624;
parameter    ap_ST_fsm_state52 = 64'd2251799813685248;
parameter    ap_ST_fsm_state53 = 64'd4503599627370496;
parameter    ap_ST_fsm_state54 = 64'd9007199254740992;
parameter    ap_ST_fsm_state55 = 64'd18014398509481984;
parameter    ap_ST_fsm_state56 = 64'd36028797018963968;
parameter    ap_ST_fsm_state57 = 64'd72057594037927936;
parameter    ap_ST_fsm_state58 = 64'd144115188075855872;
parameter    ap_ST_fsm_state59 = 64'd288230376151711744;
parameter    ap_ST_fsm_state60 = 64'd576460752303423488;
parameter    ap_ST_fsm_state61 = 64'd1152921504606846976;
parameter    ap_ST_fsm_state62 = 64'd2305843009213693952;
parameter    ap_ST_fsm_state63 = 64'd4611686018427387904;
parameter    ap_ST_fsm_state64 = 64'd9223372036854775808;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
input   ap_continue;
output   ap_idle;
output   ap_ready;
input  [31:0] p_src_rows_dout;
input   p_src_rows_empty_n;
output   p_src_rows_read;
input  [31:0] p_src_cols_dout;
input   p_src_cols_empty_n;
output   p_src_cols_read;
input  [7:0] p_src_data_V_dout;
input   p_src_data_V_empty_n;
output   p_src_data_V_read;
output  [7:0] p_dst_data_V_din;
input   p_dst_data_V_full_n;
output   p_dst_data_V_write;
input  [31:0] sigma_dout;
input   sigma_empty_n;
output   sigma_read;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg p_src_rows_read;
reg p_src_cols_read;
reg p_src_data_V_read;
reg p_dst_data_V_write;
reg sigma_read;

reg    ap_done_reg;
(* fsm_encoding = "none" *) reg   [63:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg    p_src_rows_blk_n;
reg    p_src_cols_blk_n;
reg    sigma_blk_n;
wire   [31:0] grp_fu_260_p2;
reg   [31:0] reg_295;
wire    ap_CS_fsm_state5;
wire    ap_CS_fsm_state8;
wire    ap_CS_fsm_state24;
wire    ap_CS_fsm_state27;
wire    ap_CS_fsm_state52;
wire    ap_CS_fsm_state55;
reg   [31:0] p_src_rows_read_reg_556;
reg    ap_block_state1;
reg   [31:0] sigma_read_reg_561;
reg   [31:0] imgwidth_reg_568;
wire   [31:0] select_ln40_fu_345_p3;
reg   [31:0] select_ln40_reg_573;
wire    ap_CS_fsm_state2;
wire   [31:0] scale2X_fu_362_p1;
reg   [31:0] scale2X_reg_579;
wire    ap_CS_fsm_state17;
wire   [1:0] i_fu_372_p2;
reg   [1:0] i_reg_587;
wire    ap_CS_fsm_state18;
wire   [0:0] icmp_ln48_fu_366_p2;
wire   [31:0] grp_fu_272_p1;
reg   [31:0] x_reg_609;
wire    ap_CS_fsm_state21;
wire   [31:0] grp_fu_284_p2;
reg   [31:0] t_reg_615;
wire    ap_CS_fsm_state35;
wire   [31:0] grp_fu_255_p2;
wire    ap_CS_fsm_state39;
wire   [31:0] grp_fu_266_p2;
reg   [31:0] sum_reg_625;
wire    ap_CS_fsm_state47;
wire   [1:0] i_1_fu_400_p2;
reg   [1:0] i_1_reg_633;
wire    ap_CS_fsm_state48;
reg   [1:0] cf_addr_1_reg_638;
wire   [0:0] icmp_ln57_fu_394_p2;
wire   [15:0] trunc_ln1252_fu_419_p1;
reg   [15:0] trunc_ln1252_reg_653;
wire   [15:0] trunc_ln1252_1_fu_423_p1;
reg   [15:0] trunc_ln1252_1_reg_658;
wire   [31:0] cf_q0;
reg   [31:0] cf_load_reg_663;
wire    ap_CS_fsm_state49;
wire   [63:0] grp_fu_275_p1;
reg   [63:0] tmp_i_reg_668;
wire    ap_CS_fsm_state57;
reg   [10:0] tmp_V_reg_673;
wire    ap_CS_fsm_state62;
wire   [51:0] tmp_V_1_fu_441_p1;
reg   [51:0] tmp_V_1_reg_679;
reg   [1:0] cf_address0;
reg    cf_ce0;
reg    cf_we0;
reg   [31:0] cf_d0;
wire    grp_xfGaussianFilter3x3_fu_243_ap_start;
wire    grp_xfGaussianFilter3x3_fu_243_ap_done;
wire    grp_xfGaussianFilter3x3_fu_243_ap_idle;
wire    grp_xfGaussianFilter3x3_fu_243_ap_ready;
wire    grp_xfGaussianFilter3x3_fu_243_p_src_mat_data_V_read;
wire   [7:0] grp_xfGaussianFilter3x3_fu_243_p_out_mat_data_V_din;
wire    grp_xfGaussianFilter3x3_fu_243_p_out_mat_data_V_write;
reg   [1:0] i_0_i_i_reg_207;
reg   [31:0] phi_ln56_reg_219;
reg   [1:0] i1_0_i_i_reg_231;
wire    ap_CS_fsm_state63;
reg    grp_xfGaussianFilter3x3_fu_243_ap_start_reg;
wire    ap_CS_fsm_state64;
wire   [63:0] zext_ln52_fu_389_p1;
wire   [63:0] zext_ln58_fu_406_p1;
reg   [7:0] weights_2_fu_162;
wire   [7:0] weights_2_3_fu_538_p3;
reg   [7:0] weights_2_1_fu_166;
wire    ap_CS_fsm_state53;
wire    ap_CS_fsm_state36;
reg   [31:0] grp_fu_260_p0;
reg   [31:0] grp_fu_260_p1;
wire    ap_CS_fsm_state3;
wire    ap_CS_fsm_state6;
wire    ap_CS_fsm_state22;
wire    ap_CS_fsm_state25;
wire    ap_CS_fsm_state50;
reg   [31:0] grp_fu_266_p1;
wire    ap_CS_fsm_state9;
wire  signed [31:0] grp_fu_272_p0;
wire    ap_CS_fsm_state56;
wire    ap_CS_fsm_state28;
wire    ap_CS_fsm_state58;
wire   [31:0] bitcast_ln40_fu_304_p1;
wire   [7:0] tmp_fu_307_p4;
wire   [22:0] trunc_ln40_fu_317_p1;
wire   [0:0] icmp_ln40_1_fu_327_p2;
wire   [0:0] icmp_ln40_fu_321_p2;
wire   [0:0] or_ln40_fu_333_p2;
wire   [0:0] grp_fu_278_p2;
wire   [0:0] and_ln40_fu_339_p2;
wire   [31:0] bitcast_ln46_fu_352_p1;
wire   [31:0] xor_ln46_fu_356_p2;
wire   [1:0] add_ln49_fu_378_p2;
wire   [63:0] grp_fu_290_p2;
wire   [63:0] p_Val2_s_fu_427_p1;
wire   [53:0] mantissa_V_fu_445_p4;
wire   [11:0] zext_ln502_fu_458_p1;
wire   [11:0] add_ln502_fu_461_p2;
wire   [10:0] sub_ln1311_fu_475_p2;
wire   [0:0] isNeg_fu_467_p3;
wire  signed [11:0] sext_ln1311_fu_480_p1;
wire   [11:0] ush_fu_484_p3;
wire  signed [31:0] sext_ln1311_1_fu_492_p1;
wire   [53:0] zext_ln1285_fu_500_p1;
wire   [112:0] zext_ln682_fu_454_p1;
wire   [112:0] zext_ln1287_fu_496_p1;
wire   [53:0] r_V_fu_504_p2;
wire   [0:0] tmp_3_fu_516_p3;
wire   [112:0] r_V_1_fu_510_p2;
wire   [7:0] zext_ln662_fu_524_p1;
wire   [7:0] tmp_2_fu_528_p4;
reg    grp_fu_278_ce;
reg   [63:0] ap_NS_fsm;

// power-on initialization
initial begin
#0 ap_done_reg = 1'b0;
#0 ap_CS_fsm = 64'd1;
#0 grp_xfGaussianFilter3x3_fu_243_ap_start_reg = 1'b0;
end

GaussianBlur_cf #(
    .DataWidth( 32 ),
    .AddressRange( 3 ),
    .AddressWidth( 2 ))
cf_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(cf_address0),
    .ce0(cf_ce0),
    .we0(cf_we0),
    .d0(cf_d0),
    .q0(cf_q0)
);

xfGaussianFilter3x3 grp_xfGaussianFilter3x3_fu_243(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_xfGaussianFilter3x3_fu_243_ap_start),
    .ap_done(grp_xfGaussianFilter3x3_fu_243_ap_done),
    .ap_idle(grp_xfGaussianFilter3x3_fu_243_ap_idle),
    .ap_ready(grp_xfGaussianFilter3x3_fu_243_ap_ready),
    .p_src_mat_data_V_dout(p_src_data_V_dout),
    .p_src_mat_data_V_empty_n(p_src_data_V_empty_n),
    .p_src_mat_data_V_read(grp_xfGaussianFilter3x3_fu_243_p_src_mat_data_V_read),
    .p_out_mat_data_V_din(grp_xfGaussianFilter3x3_fu_243_p_out_mat_data_V_din),
    .p_out_mat_data_V_full_n(p_dst_data_V_full_n),
    .p_out_mat_data_V_write(grp_xfGaussianFilter3x3_fu_243_p_out_mat_data_V_write),
    .img_height(trunc_ln1252_reg_653),
    .img_width(trunc_ln1252_1_reg_658),
    .weights_0_read(weights_2_fu_162),
    .weights_1_read(weights_2_1_fu_166)
);

gaussian_fadd_32njbC #(
    .ID( 1 ),
    .NUM_STAGE( 4 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
gaussian_fadd_32njbC_U48(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(phi_ln56_reg_219),
    .din1(t_reg_615),
    .ce(1'b1),
    .dout(grp_fu_255_p2)
);

gaussian_fmul_32nkbM #(
    .ID( 1 ),
    .NUM_STAGE( 3 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
gaussian_fmul_32nkbM_U49(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(grp_fu_260_p0),
    .din1(grp_fu_260_p1),
    .ce(1'b1),
    .dout(grp_fu_260_p2)
);

gaussian_fdiv_32nlbW #(
    .ID( 1 ),
    .NUM_STAGE( 9 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
gaussian_fdiv_32nlbW_U50(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(32'd1065353216),
    .din1(grp_fu_266_p1),
    .ce(1'b1),
    .dout(grp_fu_266_p2)
);

gaussian_sitofp_3mb6 #(
    .ID( 1 ),
    .NUM_STAGE( 4 ),
    .din0_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
gaussian_sitofp_3mb6_U51(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(grp_fu_272_p0),
    .ce(1'b1),
    .dout(grp_fu_272_p1)
);

gaussian_fpext_32ncg #(
    .ID( 1 ),
    .NUM_STAGE( 2 ),
    .din0_WIDTH( 32 ),
    .dout_WIDTH( 64 ))
gaussian_fpext_32ncg_U52(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(reg_295),
    .ce(1'b1),
    .dout(grp_fu_275_p1)
);

gaussian_fcmp_32nocq #(
    .ID( 1 ),
    .NUM_STAGE( 2 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 1 ))
gaussian_fcmp_32nocq_U53(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(sigma_dout),
    .din1(32'd0),
    .ce(grp_fu_278_ce),
    .opcode(5'd5),
    .dout(grp_fu_278_p2)
);

gaussian_fexp_32npcA #(
    .ID( 1 ),
    .NUM_STAGE( 8 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
gaussian_fexp_32npcA_U54(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(32'd0),
    .din1(reg_295),
    .ce(1'b1),
    .dout(grp_fu_284_p2)
);

gaussian_dadd_64nqcK #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 64 ),
    .din1_WIDTH( 64 ),
    .dout_WIDTH( 64 ))
gaussian_dadd_64nqcK_U55(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(tmp_i_reg_668),
    .din1(64'd4602678819172646912),
    .ce(1'b1),
    .dout(grp_fu_290_p2)
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
        end else if (((grp_xfGaussianFilter3x3_fu_243_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state64))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_xfGaussianFilter3x3_fu_243_ap_start_reg <= 1'b0;
    end else begin
        if (((icmp_ln57_fu_394_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state48))) begin
            grp_xfGaussianFilter3x3_fu_243_ap_start_reg <= 1'b1;
        end else if ((grp_xfGaussianFilter3x3_fu_243_ap_ready == 1'b1)) begin
            grp_xfGaussianFilter3x3_fu_243_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state63)) begin
        i1_0_i_i_reg_231 <= i_1_reg_633;
    end else if ((1'b1 == ap_CS_fsm_state47)) begin
        i1_0_i_i_reg_231 <= 2'd0;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state39)) begin
        i_0_i_i_reg_207 <= i_reg_587;
    end else if ((1'b1 == ap_CS_fsm_state17)) begin
        i_0_i_i_reg_207 <= 2'd0;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state39)) begin
        phi_ln56_reg_219 <= grp_fu_255_p2;
    end else if ((1'b1 == ap_CS_fsm_state17)) begin
        phi_ln56_reg_219 <= 32'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_state48) & (icmp_ln57_fu_394_p2 == 1'd0))) begin
        cf_addr_1_reg_638 <= zext_ln58_fu_406_p1;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        cf_load_reg_663 <= cf_q0;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state48)) begin
        i_1_reg_633 <= i_1_fu_400_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state18)) begin
        i_reg_587 <= i_fu_372_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((~((ap_done_reg == 1'b1) | (p_src_cols_empty_n == 1'b0) | (p_src_rows_empty_n == 1'b0) | (ap_start == 1'b0) | (sigma_empty_n == 1'b0)) & (1'b1 == ap_CS_fsm_state1))) begin
        imgwidth_reg_568 <= p_src_cols_dout;
        p_src_rows_read_reg_556 <= p_src_rows_dout;
        sigma_read_reg_561 <= sigma_dout;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_state55) | (1'b1 == ap_CS_fsm_state52) | (1'b1 == ap_CS_fsm_state27) | (1'b1 == ap_CS_fsm_state24) | (1'b1 == ap_CS_fsm_state8) | (1'b1 == ap_CS_fsm_state5))) begin
        reg_295 <= grp_fu_260_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state17)) begin
        scale2X_reg_579 <= scale2X_fu_362_p1;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state2)) begin
        select_ln40_reg_573 <= select_ln40_fu_345_p3;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state47)) begin
        sum_reg_625 <= grp_fu_266_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state35)) begin
        t_reg_615 <= grp_fu_284_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state62)) begin
        tmp_V_1_reg_679 <= tmp_V_1_fu_441_p1;
        tmp_V_reg_673 <= {{p_Val2_s_fu_427_p1[62:52]}};
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state57)) begin
        tmp_i_reg_668 <= grp_fu_275_p1;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln57_fu_394_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state48))) begin
        trunc_ln1252_1_reg_658 <= trunc_ln1252_1_fu_423_p1;
        trunc_ln1252_reg_653 <= trunc_ln1252_fu_419_p1;
    end
end

always @ (posedge ap_clk) begin
    if (((i1_0_i_i_reg_231 == 2'd1) & (1'b1 == ap_CS_fsm_state63))) begin
        weights_2_1_fu_166 <= weights_2_3_fu_538_p3;
    end
end

always @ (posedge ap_clk) begin
    if (((i1_0_i_i_reg_231 == 2'd0) & (1'b1 == ap_CS_fsm_state63))) begin
        weights_2_fu_162 <= weights_2_3_fu_538_p3;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state21)) begin
        x_reg_609 <= grp_fu_272_p1;
    end
end

always @ (*) begin
    if (((grp_xfGaussianFilter3x3_fu_243_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state64))) begin
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
    if (((grp_xfGaussianFilter3x3_fu_243_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state64))) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state53)) begin
        cf_address0 = cf_addr_1_reg_638;
    end else if ((1'b1 == ap_CS_fsm_state48)) begin
        cf_address0 = zext_ln58_fu_406_p1;
    end else if ((1'b1 == ap_CS_fsm_state35)) begin
        cf_address0 = zext_ln52_fu_389_p1;
    end else begin
        cf_address0 = 'bx;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state53) | (1'b1 == ap_CS_fsm_state48) | (1'b1 == ap_CS_fsm_state35))) begin
        cf_ce0 = 1'b1;
    end else begin
        cf_ce0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state53)) begin
        cf_d0 = reg_295;
    end else if ((1'b1 == ap_CS_fsm_state35)) begin
        cf_d0 = grp_fu_284_p2;
    end else begin
        cf_d0 = 'bx;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state53) | (1'b1 == ap_CS_fsm_state35))) begin
        cf_we0 = 1'b1;
    end else begin
        cf_we0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state50)) begin
        grp_fu_260_p0 = cf_load_reg_663;
    end else if ((1'b1 == ap_CS_fsm_state22)) begin
        grp_fu_260_p0 = x_reg_609;
    end else if (((1'b1 == ap_CS_fsm_state25) | (1'b1 == ap_CS_fsm_state6) | (1'b1 == ap_CS_fsm_state53))) begin
        grp_fu_260_p0 = reg_295;
    end else if ((1'b1 == ap_CS_fsm_state3)) begin
        grp_fu_260_p0 = select_ln40_reg_573;
    end else begin
        grp_fu_260_p0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state53)) begin
        grp_fu_260_p1 = 32'd1132462080;
    end else if ((1'b1 == ap_CS_fsm_state50)) begin
        grp_fu_260_p1 = sum_reg_625;
    end else if ((1'b1 == ap_CS_fsm_state25)) begin
        grp_fu_260_p1 = x_reg_609;
    end else if ((1'b1 == ap_CS_fsm_state22)) begin
        grp_fu_260_p1 = scale2X_reg_579;
    end else if ((1'b1 == ap_CS_fsm_state6)) begin
        grp_fu_260_p1 = 32'd1073741824;
    end else if ((1'b1 == ap_CS_fsm_state3)) begin
        grp_fu_260_p1 = select_ln40_reg_573;
    end else begin
        grp_fu_260_p1 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state18)) begin
        grp_fu_266_p1 = phi_ln56_reg_219;
    end else if ((1'b1 == ap_CS_fsm_state9)) begin
        grp_fu_266_p1 = reg_295;
    end else begin
        grp_fu_266_p1 = 'bx;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state2) | (~((ap_done_reg == 1'b1) | (p_src_cols_empty_n == 1'b0) | (p_src_rows_empty_n == 1'b0) | (ap_start == 1'b0) | (sigma_empty_n == 1'b0)) & (1'b1 == ap_CS_fsm_state1)))) begin
        grp_fu_278_ce = 1'b1;
    end else begin
        grp_fu_278_ce = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state64)) begin
        p_dst_data_V_write = grp_xfGaussianFilter3x3_fu_243_p_out_mat_data_V_write;
    end else begin
        p_dst_data_V_write = 1'b0;
    end
end

always @ (*) begin
    if ((~((ap_done_reg == 1'b1) | (ap_start == 1'b0)) & (1'b1 == ap_CS_fsm_state1))) begin
        p_src_cols_blk_n = p_src_cols_empty_n;
    end else begin
        p_src_cols_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((ap_done_reg == 1'b1) | (p_src_cols_empty_n == 1'b0) | (p_src_rows_empty_n == 1'b0) | (ap_start == 1'b0) | (sigma_empty_n == 1'b0)) & (1'b1 == ap_CS_fsm_state1))) begin
        p_src_cols_read = 1'b1;
    end else begin
        p_src_cols_read = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state64)) begin
        p_src_data_V_read = grp_xfGaussianFilter3x3_fu_243_p_src_mat_data_V_read;
    end else begin
        p_src_data_V_read = 1'b0;
    end
end

always @ (*) begin
    if ((~((ap_done_reg == 1'b1) | (ap_start == 1'b0)) & (1'b1 == ap_CS_fsm_state1))) begin
        p_src_rows_blk_n = p_src_rows_empty_n;
    end else begin
        p_src_rows_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((ap_done_reg == 1'b1) | (p_src_cols_empty_n == 1'b0) | (p_src_rows_empty_n == 1'b0) | (ap_start == 1'b0) | (sigma_empty_n == 1'b0)) & (1'b1 == ap_CS_fsm_state1))) begin
        p_src_rows_read = 1'b1;
    end else begin
        p_src_rows_read = 1'b0;
    end
end

always @ (*) begin
    if ((~((ap_done_reg == 1'b1) | (ap_start == 1'b0)) & (1'b1 == ap_CS_fsm_state1))) begin
        sigma_blk_n = sigma_empty_n;
    end else begin
        sigma_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((ap_done_reg == 1'b1) | (p_src_cols_empty_n == 1'b0) | (p_src_rows_empty_n == 1'b0) | (ap_start == 1'b0) | (sigma_empty_n == 1'b0)) & (1'b1 == ap_CS_fsm_state1))) begin
        sigma_read = 1'b1;
    end else begin
        sigma_read = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if ((~((ap_done_reg == 1'b1) | (p_src_cols_empty_n == 1'b0) | (p_src_rows_empty_n == 1'b0) | (ap_start == 1'b0) | (sigma_empty_n == 1'b0)) & (1'b1 == ap_CS_fsm_state1))) begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_state2 : begin
            ap_NS_fsm = ap_ST_fsm_state3;
        end
        ap_ST_fsm_state3 : begin
            ap_NS_fsm = ap_ST_fsm_state4;
        end
        ap_ST_fsm_state4 : begin
            ap_NS_fsm = ap_ST_fsm_state5;
        end
        ap_ST_fsm_state5 : begin
            ap_NS_fsm = ap_ST_fsm_state6;
        end
        ap_ST_fsm_state6 : begin
            ap_NS_fsm = ap_ST_fsm_state7;
        end
        ap_ST_fsm_state7 : begin
            ap_NS_fsm = ap_ST_fsm_state8;
        end
        ap_ST_fsm_state8 : begin
            ap_NS_fsm = ap_ST_fsm_state9;
        end
        ap_ST_fsm_state9 : begin
            ap_NS_fsm = ap_ST_fsm_state10;
        end
        ap_ST_fsm_state10 : begin
            ap_NS_fsm = ap_ST_fsm_state11;
        end
        ap_ST_fsm_state11 : begin
            ap_NS_fsm = ap_ST_fsm_state12;
        end
        ap_ST_fsm_state12 : begin
            ap_NS_fsm = ap_ST_fsm_state13;
        end
        ap_ST_fsm_state13 : begin
            ap_NS_fsm = ap_ST_fsm_state14;
        end
        ap_ST_fsm_state14 : begin
            ap_NS_fsm = ap_ST_fsm_state15;
        end
        ap_ST_fsm_state15 : begin
            ap_NS_fsm = ap_ST_fsm_state16;
        end
        ap_ST_fsm_state16 : begin
            ap_NS_fsm = ap_ST_fsm_state17;
        end
        ap_ST_fsm_state17 : begin
            ap_NS_fsm = ap_ST_fsm_state18;
        end
        ap_ST_fsm_state18 : begin
            if (((1'b1 == ap_CS_fsm_state18) & (icmp_ln48_fu_366_p2 == 1'd1))) begin
                ap_NS_fsm = ap_ST_fsm_state40;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state19;
            end
        end
        ap_ST_fsm_state19 : begin
            ap_NS_fsm = ap_ST_fsm_state20;
        end
        ap_ST_fsm_state20 : begin
            ap_NS_fsm = ap_ST_fsm_state21;
        end
        ap_ST_fsm_state21 : begin
            ap_NS_fsm = ap_ST_fsm_state22;
        end
        ap_ST_fsm_state22 : begin
            ap_NS_fsm = ap_ST_fsm_state23;
        end
        ap_ST_fsm_state23 : begin
            ap_NS_fsm = ap_ST_fsm_state24;
        end
        ap_ST_fsm_state24 : begin
            ap_NS_fsm = ap_ST_fsm_state25;
        end
        ap_ST_fsm_state25 : begin
            ap_NS_fsm = ap_ST_fsm_state26;
        end
        ap_ST_fsm_state26 : begin
            ap_NS_fsm = ap_ST_fsm_state27;
        end
        ap_ST_fsm_state27 : begin
            ap_NS_fsm = ap_ST_fsm_state28;
        end
        ap_ST_fsm_state28 : begin
            ap_NS_fsm = ap_ST_fsm_state29;
        end
        ap_ST_fsm_state29 : begin
            ap_NS_fsm = ap_ST_fsm_state30;
        end
        ap_ST_fsm_state30 : begin
            ap_NS_fsm = ap_ST_fsm_state31;
        end
        ap_ST_fsm_state31 : begin
            ap_NS_fsm = ap_ST_fsm_state32;
        end
        ap_ST_fsm_state32 : begin
            ap_NS_fsm = ap_ST_fsm_state33;
        end
        ap_ST_fsm_state33 : begin
            ap_NS_fsm = ap_ST_fsm_state34;
        end
        ap_ST_fsm_state34 : begin
            ap_NS_fsm = ap_ST_fsm_state35;
        end
        ap_ST_fsm_state35 : begin
            ap_NS_fsm = ap_ST_fsm_state36;
        end
        ap_ST_fsm_state36 : begin
            ap_NS_fsm = ap_ST_fsm_state37;
        end
        ap_ST_fsm_state37 : begin
            ap_NS_fsm = ap_ST_fsm_state38;
        end
        ap_ST_fsm_state38 : begin
            ap_NS_fsm = ap_ST_fsm_state39;
        end
        ap_ST_fsm_state39 : begin
            ap_NS_fsm = ap_ST_fsm_state18;
        end
        ap_ST_fsm_state40 : begin
            ap_NS_fsm = ap_ST_fsm_state41;
        end
        ap_ST_fsm_state41 : begin
            ap_NS_fsm = ap_ST_fsm_state42;
        end
        ap_ST_fsm_state42 : begin
            ap_NS_fsm = ap_ST_fsm_state43;
        end
        ap_ST_fsm_state43 : begin
            ap_NS_fsm = ap_ST_fsm_state44;
        end
        ap_ST_fsm_state44 : begin
            ap_NS_fsm = ap_ST_fsm_state45;
        end
        ap_ST_fsm_state45 : begin
            ap_NS_fsm = ap_ST_fsm_state46;
        end
        ap_ST_fsm_state46 : begin
            ap_NS_fsm = ap_ST_fsm_state47;
        end
        ap_ST_fsm_state47 : begin
            ap_NS_fsm = ap_ST_fsm_state48;
        end
        ap_ST_fsm_state48 : begin
            if (((icmp_ln57_fu_394_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state48))) begin
                ap_NS_fsm = ap_ST_fsm_state64;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state49;
            end
        end
        ap_ST_fsm_state49 : begin
            ap_NS_fsm = ap_ST_fsm_state50;
        end
        ap_ST_fsm_state50 : begin
            ap_NS_fsm = ap_ST_fsm_state51;
        end
        ap_ST_fsm_state51 : begin
            ap_NS_fsm = ap_ST_fsm_state52;
        end
        ap_ST_fsm_state52 : begin
            ap_NS_fsm = ap_ST_fsm_state53;
        end
        ap_ST_fsm_state53 : begin
            ap_NS_fsm = ap_ST_fsm_state54;
        end
        ap_ST_fsm_state54 : begin
            ap_NS_fsm = ap_ST_fsm_state55;
        end
        ap_ST_fsm_state55 : begin
            ap_NS_fsm = ap_ST_fsm_state56;
        end
        ap_ST_fsm_state56 : begin
            ap_NS_fsm = ap_ST_fsm_state57;
        end
        ap_ST_fsm_state57 : begin
            ap_NS_fsm = ap_ST_fsm_state58;
        end
        ap_ST_fsm_state58 : begin
            ap_NS_fsm = ap_ST_fsm_state59;
        end
        ap_ST_fsm_state59 : begin
            ap_NS_fsm = ap_ST_fsm_state60;
        end
        ap_ST_fsm_state60 : begin
            ap_NS_fsm = ap_ST_fsm_state61;
        end
        ap_ST_fsm_state61 : begin
            ap_NS_fsm = ap_ST_fsm_state62;
        end
        ap_ST_fsm_state62 : begin
            ap_NS_fsm = ap_ST_fsm_state63;
        end
        ap_ST_fsm_state63 : begin
            ap_NS_fsm = ap_ST_fsm_state48;
        end
        ap_ST_fsm_state64 : begin
            if (((grp_xfGaussianFilter3x3_fu_243_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state64))) begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state64;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln49_fu_378_p2 = ($signed(i_0_i_i_reg_207) + $signed(2'd3));

assign add_ln502_fu_461_p2 = ($signed(12'd3073) + $signed(zext_ln502_fu_458_p1));

assign and_ln40_fu_339_p2 = (or_ln40_fu_333_p2 & grp_fu_278_p2);

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state17 = ap_CS_fsm[32'd16];

assign ap_CS_fsm_state18 = ap_CS_fsm[32'd17];

assign ap_CS_fsm_state2 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_state21 = ap_CS_fsm[32'd20];

assign ap_CS_fsm_state22 = ap_CS_fsm[32'd21];

assign ap_CS_fsm_state24 = ap_CS_fsm[32'd23];

assign ap_CS_fsm_state25 = ap_CS_fsm[32'd24];

assign ap_CS_fsm_state27 = ap_CS_fsm[32'd26];

assign ap_CS_fsm_state28 = ap_CS_fsm[32'd27];

assign ap_CS_fsm_state3 = ap_CS_fsm[32'd2];

assign ap_CS_fsm_state35 = ap_CS_fsm[32'd34];

assign ap_CS_fsm_state36 = ap_CS_fsm[32'd35];

assign ap_CS_fsm_state39 = ap_CS_fsm[32'd38];

assign ap_CS_fsm_state47 = ap_CS_fsm[32'd46];

assign ap_CS_fsm_state48 = ap_CS_fsm[32'd47];

assign ap_CS_fsm_state49 = ap_CS_fsm[32'd48];

assign ap_CS_fsm_state5 = ap_CS_fsm[32'd4];

assign ap_CS_fsm_state50 = ap_CS_fsm[32'd49];

assign ap_CS_fsm_state52 = ap_CS_fsm[32'd51];

assign ap_CS_fsm_state53 = ap_CS_fsm[32'd52];

assign ap_CS_fsm_state55 = ap_CS_fsm[32'd54];

assign ap_CS_fsm_state56 = ap_CS_fsm[32'd55];

assign ap_CS_fsm_state57 = ap_CS_fsm[32'd56];

assign ap_CS_fsm_state58 = ap_CS_fsm[32'd57];

assign ap_CS_fsm_state6 = ap_CS_fsm[32'd5];

assign ap_CS_fsm_state62 = ap_CS_fsm[32'd61];

assign ap_CS_fsm_state63 = ap_CS_fsm[32'd62];

assign ap_CS_fsm_state64 = ap_CS_fsm[32'd63];

assign ap_CS_fsm_state8 = ap_CS_fsm[32'd7];

assign ap_CS_fsm_state9 = ap_CS_fsm[32'd8];

always @ (*) begin
    ap_block_state1 = ((ap_done_reg == 1'b1) | (p_src_cols_empty_n == 1'b0) | (p_src_rows_empty_n == 1'b0) | (ap_start == 1'b0) | (sigma_empty_n == 1'b0));
end

assign bitcast_ln40_fu_304_p1 = sigma_read_reg_561;

assign bitcast_ln46_fu_352_p1 = grp_fu_266_p2;

assign grp_fu_272_p0 = $signed(add_ln49_fu_378_p2);

assign grp_xfGaussianFilter3x3_fu_243_ap_start = grp_xfGaussianFilter3x3_fu_243_ap_start_reg;

assign i_1_fu_400_p2 = (i1_0_i_i_reg_231 + 2'd1);

assign i_fu_372_p2 = (i_0_i_i_reg_207 + 2'd1);

assign icmp_ln40_1_fu_327_p2 = ((trunc_ln40_fu_317_p1 == 23'd0) ? 1'b1 : 1'b0);

assign icmp_ln40_fu_321_p2 = ((tmp_fu_307_p4 != 8'd255) ? 1'b1 : 1'b0);

assign icmp_ln48_fu_366_p2 = ((i_0_i_i_reg_207 == 2'd3) ? 1'b1 : 1'b0);

assign icmp_ln57_fu_394_p2 = ((i1_0_i_i_reg_231 == 2'd3) ? 1'b1 : 1'b0);

assign isNeg_fu_467_p3 = add_ln502_fu_461_p2[32'd11];

assign mantissa_V_fu_445_p4 = {{{{1'd1}, {tmp_V_1_reg_679}}}, {1'd0}};

assign or_ln40_fu_333_p2 = (icmp_ln40_fu_321_p2 | icmp_ln40_1_fu_327_p2);

assign p_Val2_s_fu_427_p1 = grp_fu_290_p2;

assign p_dst_data_V_din = grp_xfGaussianFilter3x3_fu_243_p_out_mat_data_V_din;

assign r_V_1_fu_510_p2 = zext_ln682_fu_454_p1 << zext_ln1287_fu_496_p1;

assign r_V_fu_504_p2 = mantissa_V_fu_445_p4 >> zext_ln1285_fu_500_p1;

assign scale2X_fu_362_p1 = xor_ln46_fu_356_p2;

assign select_ln40_fu_345_p3 = ((and_ln40_fu_339_p2[0:0] === 1'b1) ? 32'd1061997773 : sigma_read_reg_561);

assign sext_ln1311_1_fu_492_p1 = $signed(ush_fu_484_p3);

assign sext_ln1311_fu_480_p1 = $signed(sub_ln1311_fu_475_p2);

assign sub_ln1311_fu_475_p2 = (11'd1023 - tmp_V_reg_673);

assign tmp_2_fu_528_p4 = {{r_V_1_fu_510_p2[60:53]}};

assign tmp_3_fu_516_p3 = r_V_fu_504_p2[32'd53];

assign tmp_V_1_fu_441_p1 = p_Val2_s_fu_427_p1[51:0];

assign tmp_fu_307_p4 = {{bitcast_ln40_fu_304_p1[30:23]}};

assign trunc_ln1252_1_fu_423_p1 = imgwidth_reg_568[15:0];

assign trunc_ln1252_fu_419_p1 = p_src_rows_read_reg_556[15:0];

assign trunc_ln40_fu_317_p1 = bitcast_ln40_fu_304_p1[22:0];

assign ush_fu_484_p3 = ((isNeg_fu_467_p3[0:0] === 1'b1) ? sext_ln1311_fu_480_p1 : add_ln502_fu_461_p2);

assign weights_2_3_fu_538_p3 = ((isNeg_fu_467_p3[0:0] === 1'b1) ? zext_ln662_fu_524_p1 : tmp_2_fu_528_p4);

assign xor_ln46_fu_356_p2 = (bitcast_ln46_fu_352_p1 ^ 32'd2147483648);

assign zext_ln1285_fu_500_p1 = $unsigned(sext_ln1311_1_fu_492_p1);

assign zext_ln1287_fu_496_p1 = $unsigned(sext_ln1311_1_fu_492_p1);

assign zext_ln502_fu_458_p1 = tmp_V_reg_673;

assign zext_ln52_fu_389_p1 = i_0_i_i_reg_207;

assign zext_ln58_fu_406_p1 = i1_0_i_i_reg_231;

assign zext_ln662_fu_524_p1 = tmp_3_fu_516_p3;

assign zext_ln682_fu_454_p1 = mantissa_V_fu_445_p4;

endmodule //GaussianBlur





































































