// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
// Version: 2019.2
// Copyright (C) 1986-2019 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

module xFapplygaussian3x3 (
        ap_clk,
        ap_rst,
        D1_V,
        D2_V,
        D3_V,
        D4_V,
        D5_V,
        D6_V,
        D7_V,
        D8_V,
        D9_V,
        weights_0_read,
        weights_1_read,
        ap_return,
        ap_ce
);


input   ap_clk;
input   ap_rst;
input  [7:0] D1_V;
input  [7:0] D2_V;
input  [7:0] D3_V;
input  [7:0] D4_V;
input  [7:0] D5_V;
input  [7:0] D6_V;
input  [7:0] D7_V;
input  [7:0] D8_V;
input  [7:0] D9_V;
input  [7:0] weights_0_read;
input  [7:0] weights_1_read;
output  [7:0] ap_return;
input   ap_ce;

reg[7:0] ap_return;

reg   [7:0] weights_1_read11_reg_249;
wire    ap_block_state1_pp0_stage0_iter0;
wire    ap_block_state2_pp0_stage0_iter1;
wire    ap_block_pp0_stage0_11001;
reg   [7:0] D5_V_read_reg_255;
wire   [16:0] grp_fu_203_p3;
reg   [16:0] ret_V_1_reg_260;
wire   [23:0] grp_fu_229_p4;
reg   [23:0] add_ln161_1_reg_265;
wire    ap_block_pp0_stage0;
wire   [8:0] rhs_V_4_fu_114_p1;
wire   [8:0] lhs_V_4_fu_110_p1;
wire   [8:0] ret_V_4_fu_118_p2;
wire   [8:0] zext_ln215_fu_128_p1;
wire   [8:0] zext_ln1353_1_fu_132_p1;
wire   [8:0] add_ln1353_fu_136_p2;
wire   [17:0] grp_fu_211_p3;
wire   [16:0] grp_fu_220_p3;
wire   [7:0] ret_V_2_fu_178_p0;
wire   [7:0] ret_V_2_fu_178_p1;
wire   [15:0] ret_V_2_fu_178_p2;
wire   [23:0] grp_fu_239_p4;
wire   [7:0] grp_fu_203_p0;
wire   [7:0] grp_fu_203_p1;
wire   [7:0] grp_fu_203_p2;
wire   [8:0] grp_fu_211_p0;
wire   [8:0] grp_fu_211_p1;
wire   [7:0] grp_fu_211_p2;
wire   [7:0] grp_fu_220_p0;
wire   [7:0] grp_fu_220_p1;
wire   [7:0] grp_fu_220_p2;
wire   [17:0] grp_fu_229_p0;
wire   [16:0] grp_fu_229_p1;
wire   [7:0] grp_fu_229_p2;
wire   [16:0] grp_fu_229_p3;
wire   [16:0] grp_fu_239_p0;
wire   [15:0] grp_fu_239_p1;
wire   [7:0] grp_fu_239_p2;
reg    ap_ce_reg;
reg   [7:0] ap_return_int_reg;
wire   [8:0] grp_fu_203_p00;
wire   [8:0] grp_fu_203_p10;
wire   [16:0] grp_fu_203_p20;
wire   [9:0] grp_fu_211_p00;
wire   [9:0] grp_fu_211_p10;
wire   [17:0] grp_fu_211_p20;
wire   [8:0] grp_fu_220_p00;
wire   [8:0] grp_fu_220_p10;
wire   [16:0] grp_fu_220_p20;
wire   [18:0] grp_fu_229_p00;
wire   [18:0] grp_fu_229_p10;
wire   [23:0] grp_fu_229_p20;
wire   [17:0] grp_fu_239_p00;
wire   [17:0] grp_fu_239_p10;
wire   [23:0] grp_fu_239_p20;
wire   [15:0] ret_V_2_fu_178_p00;
wire   [15:0] ret_V_2_fu_178_p10;

gaussian_am_addmubkb #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 8 ),
    .din1_WIDTH( 8 ),
    .din2_WIDTH( 8 ),
    .dout_WIDTH( 17 ))
gaussian_am_addmubkb_U17(
    .din0(grp_fu_203_p0),
    .din1(grp_fu_203_p1),
    .din2(grp_fu_203_p2),
    .dout(grp_fu_203_p3)
);

gaussian_am_addmucud #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 9 ),
    .din1_WIDTH( 9 ),
    .din2_WIDTH( 8 ),
    .dout_WIDTH( 18 ))
gaussian_am_addmucud_U18(
    .din0(grp_fu_211_p0),
    .din1(grp_fu_211_p1),
    .din2(grp_fu_211_p2),
    .dout(grp_fu_211_p3)
);

gaussian_am_addmubkb #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 8 ),
    .din1_WIDTH( 8 ),
    .din2_WIDTH( 8 ),
    .dout_WIDTH( 17 ))
gaussian_am_addmubkb_U19(
    .din0(grp_fu_220_p0),
    .din1(grp_fu_220_p1),
    .din2(grp_fu_220_p2),
    .dout(grp_fu_220_p3)
);

gaussian_ama_addmdEe #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 18 ),
    .din1_WIDTH( 17 ),
    .din2_WIDTH( 8 ),
    .din3_WIDTH( 17 ),
    .dout_WIDTH( 24 ))
gaussian_ama_addmdEe_U20(
    .din0(grp_fu_229_p0),
    .din1(grp_fu_229_p1),
    .din2(grp_fu_229_p2),
    .din3(grp_fu_229_p3),
    .dout(grp_fu_229_p4)
);

gaussian_ama_addmeOg #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 17 ),
    .din1_WIDTH( 16 ),
    .din2_WIDTH( 8 ),
    .din3_WIDTH( 24 ),
    .dout_WIDTH( 24 ))
gaussian_ama_addmeOg_U21(
    .din0(grp_fu_239_p0),
    .din1(grp_fu_239_p1),
    .din2(grp_fu_239_p2),
    .din3(add_ln161_1_reg_265),
    .dout(grp_fu_239_p4)
);

always @ (posedge ap_clk) begin
    ap_ce_reg <= ap_ce;
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == 1'b1))) begin
        D5_V_read_reg_255 <= D5_V;
        add_ln161_1_reg_265 <= grp_fu_229_p4;
        ret_V_1_reg_260 <= grp_fu_203_p3;
        weights_1_read11_reg_249 <= weights_1_read;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_ce_reg)) begin
        ap_return_int_reg <= {{grp_fu_239_p4[23:16]}};
    end
end

always @ (*) begin
    if ((1'b0 == ap_ce_reg)) begin
        ap_return = ap_return_int_reg;
    end else if ((1'b1 == ap_ce_reg)) begin
        ap_return = {{grp_fu_239_p4[23:16]}};
    end
end

assign add_ln1353_fu_136_p2 = (zext_ln215_fu_128_p1 + zext_ln1353_1_fu_132_p1);

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_block_state1_pp0_stage0_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state2_pp0_stage0_iter1 = ~(1'b1 == 1'b1);

assign grp_fu_203_p0 = grp_fu_203_p00;

assign grp_fu_203_p00 = D6_V;

assign grp_fu_203_p1 = grp_fu_203_p10;

assign grp_fu_203_p10 = D4_V;

assign grp_fu_203_p2 = grp_fu_203_p20;

assign grp_fu_203_p20 = weights_0_read;

assign grp_fu_211_p0 = grp_fu_211_p00;

assign grp_fu_211_p00 = add_ln1353_fu_136_p2;

assign grp_fu_211_p1 = grp_fu_211_p10;

assign grp_fu_211_p10 = ret_V_4_fu_118_p2;

assign grp_fu_211_p2 = grp_fu_211_p20;

assign grp_fu_211_p20 = weights_0_read;

assign grp_fu_220_p0 = grp_fu_220_p00;

assign grp_fu_220_p00 = D8_V;

assign grp_fu_220_p1 = grp_fu_220_p10;

assign grp_fu_220_p10 = D2_V;

assign grp_fu_220_p2 = grp_fu_220_p20;

assign grp_fu_220_p20 = weights_1_read;

assign grp_fu_229_p0 = grp_fu_229_p00;

assign grp_fu_229_p00 = grp_fu_211_p3;

assign grp_fu_229_p1 = grp_fu_229_p10;

assign grp_fu_229_p10 = grp_fu_220_p3;

assign grp_fu_229_p2 = grp_fu_229_p20;

assign grp_fu_229_p20 = weights_0_read;

assign grp_fu_229_p3 = 24'd32768;

assign grp_fu_239_p0 = grp_fu_239_p00;

assign grp_fu_239_p00 = ret_V_1_reg_260;

assign grp_fu_239_p1 = grp_fu_239_p10;

assign grp_fu_239_p10 = ret_V_2_fu_178_p2;

assign grp_fu_239_p2 = grp_fu_239_p20;

assign grp_fu_239_p20 = weights_1_read11_reg_249;

assign lhs_V_4_fu_110_p1 = D1_V;

assign ret_V_2_fu_178_p0 = ret_V_2_fu_178_p00;

assign ret_V_2_fu_178_p00 = D5_V_read_reg_255;

assign ret_V_2_fu_178_p1 = ret_V_2_fu_178_p10;

assign ret_V_2_fu_178_p10 = weights_1_read11_reg_249;

assign ret_V_2_fu_178_p2 = (ret_V_2_fu_178_p0 * ret_V_2_fu_178_p1);

assign ret_V_4_fu_118_p2 = (rhs_V_4_fu_114_p1 + lhs_V_4_fu_110_p1);

assign rhs_V_4_fu_114_p1 = D3_V;

assign zext_ln1353_1_fu_132_p1 = D9_V;

assign zext_ln215_fu_128_p1 = D7_V;

endmodule //xFapplygaussian3x3





































































