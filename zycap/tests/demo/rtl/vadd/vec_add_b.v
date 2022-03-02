// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
// Version: 2019.2
// Copyright (C) 1986-2019 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

(* CORE_GENERATION_INFO="vec_add,hls_ip_2019_2,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xczu3eg-sbva484-1-e,HLS_INPUT_CLOCK=10.000000,HLS_INPUT_ARCH=others,HLS_SYN_CLOCK=1.203000,HLS_SYN_LAT=21,HLS_SYN_TPT=none,HLS_SYN_MEM=0,HLS_SYN_DSP=0,HLS_SYN_FF=47,HLS_SYN_LUT=161,HLS_VERSION=2019_2}" *)

module vec_add_b (
        ap_clk,
        ap_rst_n,
        A_TDATA,
        A_TVALID,
        A_TREADY,
        A_TKEEP,
        A_TSTRB,
        A_TUSER,
        A_TLAST,
        A_TID,
        A_TDEST,
        C_TDATA,
        C_TVALID,
        C_TREADY,
        C_TKEEP,
        C_TSTRB,
        C_TUSER,
        C_TLAST,
        C_TID,
        C_TDEST,
        s_axi_control_AWVALID,
        s_axi_control_AWREADY,
        s_axi_control_AWADDR,
        s_axi_control_WVALID,
        s_axi_control_WREADY,
        s_axi_control_WDATA,
        s_axi_control_WSTRB,
        s_axi_control_ARVALID,
        s_axi_control_ARREADY,
        s_axi_control_ARADDR,
        s_axi_control_RVALID,
        s_axi_control_RREADY,
        s_axi_control_RDATA,
        s_axi_control_RRESP,
        s_axi_control_BVALID,
        s_axi_control_BREADY,
        s_axi_control_BRESP,
        interrupt
);

parameter    ap_ST_fsm_state1 = 3'd1;
parameter    ap_ST_fsm_state2 = 3'd2;
parameter    ap_ST_fsm_state3 = 3'd4;
parameter    C_S_AXI_CONTROL_DATA_WIDTH = 32;
parameter    C_S_AXI_CONTROL_ADDR_WIDTH = 4;
parameter    C_S_AXI_DATA_WIDTH = 32;

parameter C_S_AXI_CONTROL_WSTRB_WIDTH = (4);
parameter C_S_AXI_WSTRB_WIDTH = (4);

input   ap_clk;
input   ap_rst_n;
input  [31:0] A_TDATA;
input   A_TVALID;
output   A_TREADY;
input  [3:0] A_TKEEP;
input  [3:0] A_TSTRB;
input  [0:0] A_TUSER;
input  [0:0] A_TLAST;
input  [0:0] A_TID;
input  [0:0] A_TDEST;
output  [31:0] C_TDATA;
output   C_TVALID;
input   C_TREADY;
output  [3:0] C_TKEEP;
output  [3:0] C_TSTRB;
output  [0:0] C_TUSER;
output  [0:0] C_TLAST;
output  [0:0] C_TID;
output  [0:0] C_TDEST;
input   s_axi_control_AWVALID;
output   s_axi_control_AWREADY;
input  [C_S_AXI_CONTROL_ADDR_WIDTH - 1:0] s_axi_control_AWADDR;
input   s_axi_control_WVALID;
output   s_axi_control_WREADY;
input  [C_S_AXI_CONTROL_DATA_WIDTH - 1:0] s_axi_control_WDATA;
input  [C_S_AXI_CONTROL_WSTRB_WIDTH - 1:0] s_axi_control_WSTRB;
input   s_axi_control_ARVALID;
output   s_axi_control_ARREADY;
input  [C_S_AXI_CONTROL_ADDR_WIDTH - 1:0] s_axi_control_ARADDR;
output   s_axi_control_RVALID;
input   s_axi_control_RREADY;
output  [C_S_AXI_CONTROL_DATA_WIDTH - 1:0] s_axi_control_RDATA;
output  [1:0] s_axi_control_RRESP;
output   s_axi_control_BVALID;
input   s_axi_control_BREADY;
output  [1:0] s_axi_control_BRESP;
output   interrupt;

reg A_TREADY;

 reg    ap_rst_n_inv;
wire    ap_start;
reg    ap_done;
reg    ap_idle;
(* fsm_encoding = "none" *) reg   [2:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg    ap_ready;
reg    A_TDATA_blk_n;
wire    ap_CS_fsm_state2;
wire   [0:0] icmp_ln18_fu_131_p2;
reg    C_TDATA_blk_n;
wire    ap_CS_fsm_state3;
wire   [3:0] i_fu_137_p2;
reg   [3:0] i_reg_164;
wire    regslice_both_C_V_data_V_U_apdone_blk;
reg    ap_block_state2;
reg    ap_block_state2_io;
reg   [3:0] i_0_reg_120;
reg   [2:0] ap_NS_fsm;
wire    regslice_both_A_V_data_V_U_apdone_blk;
wire   [31:0] A_TDATA_int;
wire    A_TVALID_int;
reg    A_TREADY_int;
wire    regslice_both_A_V_data_V_U_ack_in;
wire    regslice_both_A_V_keep_V_U_apdone_blk;
wire   [3:0] A_TKEEP_int;
wire    regslice_both_A_V_keep_V_U_vld_out;
wire    regslice_both_A_V_keep_V_U_ack_in;
wire    regslice_both_A_V_strb_V_U_apdone_blk;
wire   [3:0] A_TSTRB_int;
wire    regslice_both_A_V_strb_V_U_vld_out;
wire    regslice_both_A_V_strb_V_U_ack_in;
wire    regslice_both_A_V_user_V_U_apdone_blk;
wire   [0:0] A_TUSER_int;
wire    regslice_both_A_V_user_V_U_vld_out;
wire    regslice_both_A_V_user_V_U_ack_in;
wire    regslice_both_A_V_last_V_U_apdone_blk;
wire   [0:0] A_TLAST_int;
wire    regslice_both_A_V_last_V_U_vld_out;
wire    regslice_both_A_V_last_V_U_ack_in;
wire    regslice_both_A_V_id_V_U_apdone_blk;
wire   [0:0] A_TID_int;
wire    regslice_both_A_V_id_V_U_vld_out;
wire    regslice_both_A_V_id_V_U_ack_in;
wire    regslice_both_A_V_dest_V_U_apdone_blk;
wire   [0:0] A_TDEST_int;
wire    regslice_both_A_V_dest_V_U_vld_out;
wire    regslice_both_A_V_dest_V_U_ack_in;
wire   [31:0] C_TDATA_int;
reg    C_TVALID_int;
wire    C_TREADY_int;
wire    regslice_both_C_V_data_V_U_vld_out;
wire    regslice_both_C_V_keep_V_U_apdone_blk;
wire    regslice_both_C_V_keep_V_U_ack_in_dummy;
wire    regslice_both_C_V_keep_V_U_vld_out;
wire    regslice_both_C_V_strb_V_U_apdone_blk;
wire    regslice_both_C_V_strb_V_U_ack_in_dummy;
wire    regslice_both_C_V_strb_V_U_vld_out;
wire    regslice_both_C_V_user_V_U_apdone_blk;
wire    regslice_both_C_V_user_V_U_ack_in_dummy;
wire    regslice_both_C_V_user_V_U_vld_out;
wire    regslice_both_C_V_last_V_U_apdone_blk;
wire   [0:0] C_TLAST_int;
wire    regslice_both_C_V_last_V_U_ack_in_dummy;
wire    regslice_both_C_V_last_V_U_vld_out;
wire    regslice_both_C_V_id_V_U_apdone_blk;
wire    regslice_both_C_V_id_V_U_ack_in_dummy;
wire    regslice_both_C_V_id_V_U_vld_out;
wire    regslice_both_C_V_dest_V_U_apdone_blk;
wire    regslice_both_C_V_dest_V_U_ack_in_dummy;
wire    regslice_both_C_V_dest_V_U_vld_out;

// power-on initialization
initial begin
#0 ap_CS_fsm = 3'd1;
end

vec_add_control_s_axi #(
    .C_S_AXI_ADDR_WIDTH( C_S_AXI_CONTROL_ADDR_WIDTH ),
    .C_S_AXI_DATA_WIDTH( C_S_AXI_CONTROL_DATA_WIDTH ))
vec_add_control_s_axi_U(
    .AWVALID(s_axi_control_AWVALID),
    .AWREADY(s_axi_control_AWREADY),
    .AWADDR(s_axi_control_AWADDR),
    .WVALID(s_axi_control_WVALID),
    .WREADY(s_axi_control_WREADY),
    .WDATA(s_axi_control_WDATA),
    .WSTRB(s_axi_control_WSTRB),
    .ARVALID(s_axi_control_ARVALID),
    .ARREADY(s_axi_control_ARREADY),
    .ARADDR(s_axi_control_ARADDR),
    .RVALID(s_axi_control_RVALID),
    .RREADY(s_axi_control_RREADY),
    .RDATA(s_axi_control_RDATA),
    .RRESP(s_axi_control_RRESP),
    .BVALID(s_axi_control_BVALID),
    .BREADY(s_axi_control_BREADY),
    .BRESP(s_axi_control_BRESP),
    .ACLK(ap_clk),
    .ARESET(ap_rst_n_inv),
    .ACLK_EN(1'b1),
    .ap_start(ap_start),
    .interrupt(interrupt),
    .ap_ready(ap_ready),
    .ap_done(ap_done),
    .ap_idle(ap_idle)
);

regslice_both #(
    .DataWidth( 32 ))
regslice_both_A_V_data_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(A_TDATA),
    .vld_in(A_TVALID),
    .ack_in(regslice_both_A_V_data_V_U_ack_in),
    .data_out(A_TDATA_int),
    .vld_out(A_TVALID_int),
    .ack_out(A_TREADY_int),
    .apdone_blk(regslice_both_A_V_data_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 4 ))
regslice_both_A_V_keep_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(A_TKEEP),
    .vld_in(A_TVALID),
    .ack_in(regslice_both_A_V_keep_V_U_ack_in),
    .data_out(A_TKEEP_int),
    .vld_out(regslice_both_A_V_keep_V_U_vld_out),
    .ack_out(A_TREADY_int),
    .apdone_blk(regslice_both_A_V_keep_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 4 ))
regslice_both_A_V_strb_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(A_TSTRB),
    .vld_in(A_TVALID),
    .ack_in(regslice_both_A_V_strb_V_U_ack_in),
    .data_out(A_TSTRB_int),
    .vld_out(regslice_both_A_V_strb_V_U_vld_out),
    .ack_out(A_TREADY_int),
    .apdone_blk(regslice_both_A_V_strb_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 1 ))
regslice_both_A_V_user_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(A_TUSER),
    .vld_in(A_TVALID),
    .ack_in(regslice_both_A_V_user_V_U_ack_in),
    .data_out(A_TUSER_int),
    .vld_out(regslice_both_A_V_user_V_U_vld_out),
    .ack_out(A_TREADY_int),
    .apdone_blk(regslice_both_A_V_user_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 1 ))
regslice_both_A_V_last_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(A_TLAST),
    .vld_in(A_TVALID),
    .ack_in(regslice_both_A_V_last_V_U_ack_in),
    .data_out(A_TLAST_int),
    .vld_out(regslice_both_A_V_last_V_U_vld_out),
    .ack_out(A_TREADY_int),
    .apdone_blk(regslice_both_A_V_last_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 1 ))
regslice_both_A_V_id_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(A_TID),
    .vld_in(A_TVALID),
    .ack_in(regslice_both_A_V_id_V_U_ack_in),
    .data_out(A_TID_int),
    .vld_out(regslice_both_A_V_id_V_U_vld_out),
    .ack_out(A_TREADY_int),
    .apdone_blk(regslice_both_A_V_id_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 1 ))
regslice_both_A_V_dest_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(A_TDEST),
    .vld_in(A_TVALID),
    .ack_in(regslice_both_A_V_dest_V_U_ack_in),
    .data_out(A_TDEST_int),
    .vld_out(regslice_both_A_V_dest_V_U_vld_out),
    .ack_out(A_TREADY_int),
    .apdone_blk(regslice_both_A_V_dest_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 32 ))
regslice_both_C_V_data_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(C_TDATA_int),
    .vld_in(C_TVALID_int),
    .ack_in(C_TREADY_int),
    .data_out(C_TDATA),
    .vld_out(regslice_both_C_V_data_V_U_vld_out),
    .ack_out(C_TREADY),
    .apdone_blk(regslice_both_C_V_data_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 4 ))
regslice_both_C_V_keep_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(4'd15),
    .vld_in(C_TVALID_int),
    .ack_in(regslice_both_C_V_keep_V_U_ack_in_dummy),
    .data_out(C_TKEEP),
    .vld_out(regslice_both_C_V_keep_V_U_vld_out),
    .ack_out(C_TREADY),
    .apdone_blk(regslice_both_C_V_keep_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 4 ))
regslice_both_C_V_strb_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(4'd15),
    .vld_in(C_TVALID_int),
    .ack_in(regslice_both_C_V_strb_V_U_ack_in_dummy),
    .data_out(C_TSTRB),
    .vld_out(regslice_both_C_V_strb_V_U_vld_out),
    .ack_out(C_TREADY),
    .apdone_blk(regslice_both_C_V_strb_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 1 ))
regslice_both_C_V_user_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(1'd0),
    .vld_in(C_TVALID_int),
    .ack_in(regslice_both_C_V_user_V_U_ack_in_dummy),
    .data_out(C_TUSER),
    .vld_out(regslice_both_C_V_user_V_U_vld_out),
    .ack_out(C_TREADY),
    .apdone_blk(regslice_both_C_V_user_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 1 ))
regslice_both_C_V_last_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(C_TLAST_int),
    .vld_in(C_TVALID_int),
    .ack_in(regslice_both_C_V_last_V_U_ack_in_dummy),
    .data_out(C_TLAST),
    .vld_out(regslice_both_C_V_last_V_U_vld_out),
    .ack_out(C_TREADY),
    .apdone_blk(regslice_both_C_V_last_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 1 ))
regslice_both_C_V_id_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(1'd0),
    .vld_in(C_TVALID_int),
    .ack_in(regslice_both_C_V_id_V_U_ack_in_dummy),
    .data_out(C_TID),
    .vld_out(regslice_both_C_V_id_V_U_vld_out),
    .ack_out(C_TREADY),
    .apdone_blk(regslice_both_C_V_id_V_U_apdone_blk)
);

regslice_both #(
    .DataWidth( 1 ))
regslice_both_C_V_dest_V_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .data_in(1'd0),
    .vld_in(C_TVALID_int),
    .ack_in(regslice_both_C_V_dest_V_U_ack_in_dummy),
    .data_out(C_TDEST),
    .vld_out(regslice_both_C_V_dest_V_U_vld_out),
    .ack_out(C_TREADY),
    .apdone_blk(regslice_both_C_V_dest_V_U_apdone_blk)
);

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == C_TREADY_int) & (1'b1 == ap_CS_fsm_state3))) begin
        i_0_reg_120 <= i_reg_164;
    end else if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b1))) begin
        i_0_reg_120 <= 4'd0;
    end
end

always @ (posedge ap_clk) begin
    if ((~((1'b1 == ap_block_state2_io) | (regslice_both_C_V_data_V_U_apdone_blk == 1'b1) | ((icmp_ln18_fu_131_p2 == 1'd0) & (1'b0 == A_TVALID_int))) & (1'b1 == ap_CS_fsm_state2))) begin
        i_reg_164 <= i_fu_137_p2;
    end
end

always @ (*) begin
    if (((icmp_ln18_fu_131_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
        A_TDATA_blk_n = A_TVALID_int;
    end else begin
        A_TDATA_blk_n = 1'b1;
    end
end

always @ (*) begin
    if (((1'b1 == A_TVALID) & (regslice_both_A_V_data_V_U_ack_in == 1'b1))) begin
        A_TREADY = 1'b1;
    end else begin
        A_TREADY = 1'b0;
    end
end

always @ (*) begin
    if ((~((1'b1 == ap_block_state2_io) | (regslice_both_C_V_data_V_U_apdone_blk == 1'b1) | ((icmp_ln18_fu_131_p2 == 1'd0) & (1'b0 == A_TVALID_int))) & (icmp_ln18_fu_131_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
        A_TREADY_int = 1'b1;
    end else begin
        A_TREADY_int = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state3) | ((icmp_ln18_fu_131_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2)))) begin
        C_TDATA_blk_n = C_TREADY_int;
    end else begin
        C_TDATA_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((1'b1 == ap_block_state2_io) | (regslice_both_C_V_data_V_U_apdone_blk == 1'b1) | ((icmp_ln18_fu_131_p2 == 1'd0) & (1'b0 == A_TVALID_int))) & (icmp_ln18_fu_131_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
        C_TVALID_int = 1'b1;
    end else begin
        C_TVALID_int = 1'b0;
    end
end

always @ (*) begin
    if ((~((1'b1 == ap_block_state2_io) | (regslice_both_C_V_data_V_U_apdone_blk == 1'b1) | ((icmp_ln18_fu_131_p2 == 1'd0) & (1'b0 == A_TVALID_int))) & (icmp_ln18_fu_131_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state2))) begin
        ap_done = 1'b1;
    end else begin
        ap_done = 1'b0;
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
    if ((~((1'b1 == ap_block_state2_io) | (regslice_both_C_V_data_V_U_apdone_blk == 1'b1) | ((icmp_ln18_fu_131_p2 == 1'd0) & (1'b0 == A_TVALID_int))) & (icmp_ln18_fu_131_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state2))) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_state2 : begin
            if ((~((1'b1 == ap_block_state2_io) | (regslice_both_C_V_data_V_U_apdone_blk == 1'b1) | ((icmp_ln18_fu_131_p2 == 1'd0) & (1'b0 == A_TVALID_int))) & (icmp_ln18_fu_131_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state2))) begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end else if ((~((1'b1 == ap_block_state2_io) | (regslice_both_C_V_data_V_U_apdone_blk == 1'b1) | ((icmp_ln18_fu_131_p2 == 1'd0) & (1'b0 == A_TVALID_int))) & (icmp_ln18_fu_131_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
                ap_NS_fsm = ap_ST_fsm_state3;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end
        end
        ap_ST_fsm_state3 : begin
            if (((1'b1 == C_TREADY_int) & (1'b1 == ap_CS_fsm_state3))) begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state3;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign C_TDATA_int = (A_TDATA_int + 32'd10);

assign C_TLAST_int = ((i_0_reg_120 == 4'd9) ? 1'b1 : 1'b0);

assign C_TVALID = regslice_both_C_V_data_V_U_vld_out;

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state2 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_state3 = ap_CS_fsm[32'd2];

always @ (*) begin
    ap_block_state2 = ((regslice_both_C_V_data_V_U_apdone_blk == 1'b1) | ((icmp_ln18_fu_131_p2 == 1'd0) & (1'b0 == A_TVALID_int)));
end

always @ (*) begin
    ap_block_state2_io = ((icmp_ln18_fu_131_p2 == 1'd0) & (1'b0 == C_TREADY_int));
end

always @ (*) begin
    ap_rst_n_inv = ~ap_rst_n;
end

assign i_fu_137_p2 = (i_0_reg_120 + 4'd1);

assign icmp_ln18_fu_131_p2 = ((i_0_reg_120 == 4'd10) ? 1'b1 : 1'b0);

endmodule //vec_add































