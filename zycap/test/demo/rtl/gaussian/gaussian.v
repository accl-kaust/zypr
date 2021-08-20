// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
// Version: 2019.2
// Copyright (C) 1986-2019 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

(* CORE_GENERATION_INFO="gaussian,hls_ip_2019_2,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=1,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xczu3eg-sbva484-1-e,HLS_INPUT_CLOCK=10.000000,HLS_INPUT_ARCH=dataflow,HLS_SYN_CLOCK=9.770400,HLS_SYN_LAT=-1,HLS_SYN_TPT=-1,HLS_SYN_MEM=3,HLS_SYN_DSP=20,HLS_SYN_FF=3497,HLS_SYN_LUT=6785,HLS_VERSION=2019_2}" *)

module gaussian (
        s_axi_AXILiteS_AWVALID,
        s_axi_AXILiteS_AWREADY,
        s_axi_AXILiteS_AWADDR,
        s_axi_AXILiteS_WVALID,
        s_axi_AXILiteS_WREADY,
        s_axi_AXILiteS_WDATA,
        s_axi_AXILiteS_WSTRB,
        s_axi_AXILiteS_ARVALID,
        s_axi_AXILiteS_ARREADY,
        s_axi_AXILiteS_ARADDR,
        s_axi_AXILiteS_RVALID,
        s_axi_AXILiteS_RREADY,
        s_axi_AXILiteS_RDATA,
        s_axi_AXILiteS_RRESP,
        s_axi_AXILiteS_BVALID,
        s_axi_AXILiteS_BREADY,
        s_axi_AXILiteS_BRESP,
        ap_clk,
        ap_rst_n,
        interrupt,
        stream_in_TDATA,
        stream_in_TLAST,
        stream_out_TDATA,
        stream_out_TLAST,
        stream_in_TVALID,
        stream_in_TREADY,
        stream_out_TVALID,
        stream_out_TREADY
);

parameter    C_S_AXI_AXILITES_DATA_WIDTH = 32;
parameter    C_S_AXI_AXILITES_ADDR_WIDTH = 6;
parameter    C_S_AXI_DATA_WIDTH = 32;
parameter    C_S_AXI_ADDR_WIDTH = 32;

parameter C_S_AXI_AXILITES_WSTRB_WIDTH = (32 / 8);
parameter C_S_AXI_WSTRB_WIDTH = (32 / 8);

input   s_axi_AXILiteS_AWVALID;
output   s_axi_AXILiteS_AWREADY;
input  [C_S_AXI_AXILITES_ADDR_WIDTH - 1:0] s_axi_AXILiteS_AWADDR;
input   s_axi_AXILiteS_WVALID;
output   s_axi_AXILiteS_WREADY;
input  [C_S_AXI_AXILITES_DATA_WIDTH - 1:0] s_axi_AXILiteS_WDATA;
input  [C_S_AXI_AXILITES_WSTRB_WIDTH - 1:0] s_axi_AXILiteS_WSTRB;
input   s_axi_AXILiteS_ARVALID;
output   s_axi_AXILiteS_ARREADY;
input  [C_S_AXI_AXILITES_ADDR_WIDTH - 1:0] s_axi_AXILiteS_ARADDR;
output   s_axi_AXILiteS_RVALID;
input   s_axi_AXILiteS_RREADY;
output  [C_S_AXI_AXILITES_DATA_WIDTH - 1:0] s_axi_AXILiteS_RDATA;
output  [1:0] s_axi_AXILiteS_RRESP;
output   s_axi_AXILiteS_BVALID;
input   s_axi_AXILiteS_BREADY;
output  [1:0] s_axi_AXILiteS_BRESP;
input   ap_clk;
input   ap_rst_n;
output   interrupt;
input  [7:0] stream_in_TDATA;
input  [0:0] stream_in_TLAST;
output  [7:0] stream_out_TDATA;
output  [0:0] stream_out_TLAST;
input   stream_in_TVALID;
output   stream_in_TREADY;
output   stream_out_TVALID;
input   stream_out_TREADY;

 reg    ap_rst_n_inv;
wire    ap_start;
wire    ap_ready;
wire    ap_done;
wire    ap_idle;
wire   [31:0] rows_in;
wire   [31:0] cols_in;
wire   [31:0] sigma;
wire    Block_Mat_exit71_pro_U0_ap_start;
wire    Block_Mat_exit71_pro_U0_start_full_n;
wire    Block_Mat_exit71_pro_U0_ap_done;
wire    Block_Mat_exit71_pro_U0_ap_continue;
wire    Block_Mat_exit71_pro_U0_ap_idle;
wire    Block_Mat_exit71_pro_U0_ap_ready;
wire    Block_Mat_exit71_pro_U0_start_out;
wire    Block_Mat_exit71_pro_U0_start_write;
wire   [31:0] Block_Mat_exit71_pro_U0_in_mat_rows_out_din;
wire    Block_Mat_exit71_pro_U0_in_mat_rows_out_write;
wire   [31:0] Block_Mat_exit71_pro_U0_in_mat_cols_out_din;
wire    Block_Mat_exit71_pro_U0_in_mat_cols_out_write;
wire   [31:0] Block_Mat_exit71_pro_U0_out_mat_rows_out_din;
wire    Block_Mat_exit71_pro_U0_out_mat_rows_out_write;
wire   [31:0] Block_Mat_exit71_pro_U0_out_mat_cols_out_din;
wire    Block_Mat_exit71_pro_U0_out_mat_cols_out_write;
wire   [31:0] Block_Mat_exit71_pro_U0_sigma_out_din;
wire    Block_Mat_exit71_pro_U0_sigma_out_write;
wire    AXIstream2xfMat_U0_ap_start;
wire    AXIstream2xfMat_U0_ap_done;
wire    AXIstream2xfMat_U0_ap_continue;
wire    AXIstream2xfMat_U0_ap_idle;
wire    AXIstream2xfMat_U0_ap_ready;
wire    AXIstream2xfMat_U0_stream_in_TREADY;
wire    AXIstream2xfMat_U0_img_rows_read;
wire    AXIstream2xfMat_U0_img_cols_read;
wire   [7:0] AXIstream2xfMat_U0_img_data_V_din;
wire    AXIstream2xfMat_U0_img_data_V_write;
wire   [31:0] AXIstream2xfMat_U0_img_rows_out_din;
wire    AXIstream2xfMat_U0_img_rows_out_write;
wire   [31:0] AXIstream2xfMat_U0_img_cols_out_din;
wire    AXIstream2xfMat_U0_img_cols_out_write;
wire    GaussianBlur_U0_ap_start;
wire    GaussianBlur_U0_ap_done;
wire    GaussianBlur_U0_ap_continue;
wire    GaussianBlur_U0_ap_idle;
wire    GaussianBlur_U0_ap_ready;
wire    GaussianBlur_U0_p_src_rows_read;
wire    GaussianBlur_U0_p_src_cols_read;
wire    GaussianBlur_U0_p_src_data_V_read;
wire   [7:0] GaussianBlur_U0_p_dst_data_V_din;
wire    GaussianBlur_U0_p_dst_data_V_write;
wire    GaussianBlur_U0_sigma_read;
wire    xfMat2AXIstream_U0_ap_start;
wire    xfMat2AXIstream_U0_ap_done;
wire    xfMat2AXIstream_U0_ap_continue;
wire    xfMat2AXIstream_U0_ap_idle;
wire    xfMat2AXIstream_U0_ap_ready;
wire    xfMat2AXIstream_U0_img_rows_read;
wire    xfMat2AXIstream_U0_img_cols_read;
wire    xfMat2AXIstream_U0_img_data_V_read;
wire   [7:0] xfMat2AXIstream_U0_stream_out_TDATA;
wire    xfMat2AXIstream_U0_stream_out_TVALID;
wire   [0:0] xfMat2AXIstream_U0_stream_out_TLAST;
wire    ap_sync_continue;
wire    in_mat_rows_c_full_n;
wire   [31:0] in_mat_rows_c_dout;
wire    in_mat_rows_c_empty_n;
wire    in_mat_cols_c_full_n;
wire   [31:0] in_mat_cols_c_dout;
wire    in_mat_cols_c_empty_n;
wire    out_mat_rows_c_full_n;
wire   [31:0] out_mat_rows_c_dout;
wire    out_mat_rows_c_empty_n;
wire    out_mat_cols_c_full_n;
wire   [31:0] out_mat_cols_c_dout;
wire    out_mat_cols_c_empty_n;
wire    sigma_c_full_n;
wire   [31:0] sigma_c_dout;
wire    sigma_c_empty_n;
wire    in_mat_data_V_full_n;
wire   [7:0] in_mat_data_V_dout;
wire    in_mat_data_V_empty_n;
wire    in_mat_rows_c9_full_n;
wire   [31:0] in_mat_rows_c9_dout;
wire    in_mat_rows_c9_empty_n;
wire    in_mat_cols_c10_full_n;
wire   [31:0] in_mat_cols_c10_dout;
wire    in_mat_cols_c10_empty_n;
wire    out_mat_data_V_full_n;
wire   [7:0] out_mat_data_V_dout;
wire    out_mat_data_V_empty_n;
wire    ap_sync_done;
wire    ap_sync_ready;
reg    ap_sync_reg_Block_Mat_exit71_pro_U0_ap_ready;
wire    ap_sync_Block_Mat_exit71_pro_U0_ap_ready;
reg   [1:0] Block_Mat_exit71_pro_U0_ap_ready_count;
reg    ap_sync_reg_AXIstream2xfMat_U0_ap_ready;
wire    ap_sync_AXIstream2xfMat_U0_ap_ready;
reg   [1:0] AXIstream2xfMat_U0_ap_ready_count;
wire   [0:0] start_for_GaussianBlur_U0_din;
wire    start_for_GaussianBlur_U0_full_n;
wire   [0:0] start_for_GaussianBlur_U0_dout;
wire    start_for_GaussianBlur_U0_empty_n;
wire   [0:0] start_for_xfMat2AXIstream_U0_din;
wire    start_for_xfMat2AXIstream_U0_full_n;
wire   [0:0] start_for_xfMat2AXIstream_U0_dout;
wire    start_for_xfMat2AXIstream_U0_empty_n;
wire    AXIstream2xfMat_U0_start_full_n;
wire    AXIstream2xfMat_U0_start_write;
wire    GaussianBlur_U0_start_full_n;
wire    GaussianBlur_U0_start_write;
wire    xfMat2AXIstream_U0_start_full_n;
wire    xfMat2AXIstream_U0_start_write;

// power-on initialization
initial begin
#0 ap_sync_reg_Block_Mat_exit71_pro_U0_ap_ready = 1'b0;
#0 Block_Mat_exit71_pro_U0_ap_ready_count = 2'd0;
#0 ap_sync_reg_AXIstream2xfMat_U0_ap_ready = 1'b0;
#0 AXIstream2xfMat_U0_ap_ready_count = 2'd0;
end

gaussian_AXILiteS_s_axi #(
    .C_S_AXI_ADDR_WIDTH( C_S_AXI_AXILITES_ADDR_WIDTH ),
    .C_S_AXI_DATA_WIDTH( C_S_AXI_AXILITES_DATA_WIDTH ))
gaussian_AXILiteS_s_axi_U(
    .AWVALID(s_axi_AXILiteS_AWVALID),
    .AWREADY(s_axi_AXILiteS_AWREADY),
    .AWADDR(s_axi_AXILiteS_AWADDR),
    .WVALID(s_axi_AXILiteS_WVALID),
    .WREADY(s_axi_AXILiteS_WREADY),
    .WDATA(s_axi_AXILiteS_WDATA),
    .WSTRB(s_axi_AXILiteS_WSTRB),
    .ARVALID(s_axi_AXILiteS_ARVALID),
    .ARREADY(s_axi_AXILiteS_ARREADY),
    .ARADDR(s_axi_AXILiteS_ARADDR),
    .RVALID(s_axi_AXILiteS_RVALID),
    .RREADY(s_axi_AXILiteS_RREADY),
    .RDATA(s_axi_AXILiteS_RDATA),
    .RRESP(s_axi_AXILiteS_RRESP),
    .BVALID(s_axi_AXILiteS_BVALID),
    .BREADY(s_axi_AXILiteS_BREADY),
    .BRESP(s_axi_AXILiteS_BRESP),
    .ACLK(ap_clk),
    .ARESET(ap_rst_n_inv),
    .ACLK_EN(1'b1),
    .ap_start(ap_start),
    .interrupt(interrupt),
    .ap_ready(ap_ready),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .rows_in(rows_in),
    .cols_in(cols_in),
    .sigma(sigma)
);

Block_Mat_exit71_pro Block_Mat_exit71_pro_U0(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .ap_start(Block_Mat_exit71_pro_U0_ap_start),
    .start_full_n(Block_Mat_exit71_pro_U0_start_full_n),
    .ap_done(Block_Mat_exit71_pro_U0_ap_done),
    .ap_continue(Block_Mat_exit71_pro_U0_ap_continue),
    .ap_idle(Block_Mat_exit71_pro_U0_ap_idle),
    .ap_ready(Block_Mat_exit71_pro_U0_ap_ready),
    .start_out(Block_Mat_exit71_pro_U0_start_out),
    .start_write(Block_Mat_exit71_pro_U0_start_write),
    .rows_in(rows_in),
    .cols_in(cols_in),
    .sigma(sigma),
    .in_mat_rows_out_din(Block_Mat_exit71_pro_U0_in_mat_rows_out_din),
    .in_mat_rows_out_full_n(in_mat_rows_c_full_n),
    .in_mat_rows_out_write(Block_Mat_exit71_pro_U0_in_mat_rows_out_write),
    .in_mat_cols_out_din(Block_Mat_exit71_pro_U0_in_mat_cols_out_din),
    .in_mat_cols_out_full_n(in_mat_cols_c_full_n),
    .in_mat_cols_out_write(Block_Mat_exit71_pro_U0_in_mat_cols_out_write),
    .out_mat_rows_out_din(Block_Mat_exit71_pro_U0_out_mat_rows_out_din),
    .out_mat_rows_out_full_n(out_mat_rows_c_full_n),
    .out_mat_rows_out_write(Block_Mat_exit71_pro_U0_out_mat_rows_out_write),
    .out_mat_cols_out_din(Block_Mat_exit71_pro_U0_out_mat_cols_out_din),
    .out_mat_cols_out_full_n(out_mat_cols_c_full_n),
    .out_mat_cols_out_write(Block_Mat_exit71_pro_U0_out_mat_cols_out_write),
    .sigma_out_din(Block_Mat_exit71_pro_U0_sigma_out_din),
    .sigma_out_full_n(sigma_c_full_n),
    .sigma_out_write(Block_Mat_exit71_pro_U0_sigma_out_write)
);

AXIstream2xfMat AXIstream2xfMat_U0(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .ap_start(AXIstream2xfMat_U0_ap_start),
    .ap_done(AXIstream2xfMat_U0_ap_done),
    .ap_continue(AXIstream2xfMat_U0_ap_continue),
    .ap_idle(AXIstream2xfMat_U0_ap_idle),
    .ap_ready(AXIstream2xfMat_U0_ap_ready),
    .stream_in_TDATA(stream_in_TDATA),
    .stream_in_TVALID(stream_in_TVALID),
    .stream_in_TREADY(AXIstream2xfMat_U0_stream_in_TREADY),
    .stream_in_TLAST(stream_in_TLAST),
    .img_rows_dout(in_mat_rows_c_dout),
    .img_rows_empty_n(in_mat_rows_c_empty_n),
    .img_rows_read(AXIstream2xfMat_U0_img_rows_read),
    .img_cols_dout(in_mat_cols_c_dout),
    .img_cols_empty_n(in_mat_cols_c_empty_n),
    .img_cols_read(AXIstream2xfMat_U0_img_cols_read),
    .img_data_V_din(AXIstream2xfMat_U0_img_data_V_din),
    .img_data_V_full_n(in_mat_data_V_full_n),
    .img_data_V_write(AXIstream2xfMat_U0_img_data_V_write),
    .img_rows_out_din(AXIstream2xfMat_U0_img_rows_out_din),
    .img_rows_out_full_n(in_mat_rows_c9_full_n),
    .img_rows_out_write(AXIstream2xfMat_U0_img_rows_out_write),
    .img_cols_out_din(AXIstream2xfMat_U0_img_cols_out_din),
    .img_cols_out_full_n(in_mat_cols_c10_full_n),
    .img_cols_out_write(AXIstream2xfMat_U0_img_cols_out_write)
);

GaussianBlur GaussianBlur_U0(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .ap_start(GaussianBlur_U0_ap_start),
    .ap_done(GaussianBlur_U0_ap_done),
    .ap_continue(GaussianBlur_U0_ap_continue),
    .ap_idle(GaussianBlur_U0_ap_idle),
    .ap_ready(GaussianBlur_U0_ap_ready),
    .p_src_rows_dout(in_mat_rows_c9_dout),
    .p_src_rows_empty_n(in_mat_rows_c9_empty_n),
    .p_src_rows_read(GaussianBlur_U0_p_src_rows_read),
    .p_src_cols_dout(in_mat_cols_c10_dout),
    .p_src_cols_empty_n(in_mat_cols_c10_empty_n),
    .p_src_cols_read(GaussianBlur_U0_p_src_cols_read),
    .p_src_data_V_dout(in_mat_data_V_dout),
    .p_src_data_V_empty_n(in_mat_data_V_empty_n),
    .p_src_data_V_read(GaussianBlur_U0_p_src_data_V_read),
    .p_dst_data_V_din(GaussianBlur_U0_p_dst_data_V_din),
    .p_dst_data_V_full_n(out_mat_data_V_full_n),
    .p_dst_data_V_write(GaussianBlur_U0_p_dst_data_V_write),
    .sigma_dout(sigma_c_dout),
    .sigma_empty_n(sigma_c_empty_n),
    .sigma_read(GaussianBlur_U0_sigma_read)
);

xfMat2AXIstream xfMat2AXIstream_U0(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .ap_start(xfMat2AXIstream_U0_ap_start),
    .ap_done(xfMat2AXIstream_U0_ap_done),
    .ap_continue(xfMat2AXIstream_U0_ap_continue),
    .ap_idle(xfMat2AXIstream_U0_ap_idle),
    .ap_ready(xfMat2AXIstream_U0_ap_ready),
    .img_rows_dout(out_mat_rows_c_dout),
    .img_rows_empty_n(out_mat_rows_c_empty_n),
    .img_rows_read(xfMat2AXIstream_U0_img_rows_read),
    .img_cols_dout(out_mat_cols_c_dout),
    .img_cols_empty_n(out_mat_cols_c_empty_n),
    .img_cols_read(xfMat2AXIstream_U0_img_cols_read),
    .img_data_V_dout(out_mat_data_V_dout),
    .img_data_V_empty_n(out_mat_data_V_empty_n),
    .img_data_V_read(xfMat2AXIstream_U0_img_data_V_read),
    .stream_out_TDATA(xfMat2AXIstream_U0_stream_out_TDATA),
    .stream_out_TVALID(xfMat2AXIstream_U0_stream_out_TVALID),
    .stream_out_TREADY(stream_out_TREADY),
    .stream_out_TLAST(xfMat2AXIstream_U0_stream_out_TLAST)
);

fifo_w32_d2_A in_mat_rows_c_U(
    .clk(ap_clk),
    .reset(ap_rst_n_inv),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(Block_Mat_exit71_pro_U0_in_mat_rows_out_din),
    .if_full_n(in_mat_rows_c_full_n),
    .if_write(Block_Mat_exit71_pro_U0_in_mat_rows_out_write),
    .if_dout(in_mat_rows_c_dout),
    .if_empty_n(in_mat_rows_c_empty_n),
    .if_read(AXIstream2xfMat_U0_img_rows_read)
);

fifo_w32_d2_A in_mat_cols_c_U(
    .clk(ap_clk),
    .reset(ap_rst_n_inv),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(Block_Mat_exit71_pro_U0_in_mat_cols_out_din),
    .if_full_n(in_mat_cols_c_full_n),
    .if_write(Block_Mat_exit71_pro_U0_in_mat_cols_out_write),
    .if_dout(in_mat_cols_c_dout),
    .if_empty_n(in_mat_cols_c_empty_n),
    .if_read(AXIstream2xfMat_U0_img_cols_read)
);

fifo_w32_d4_A out_mat_rows_c_U(
    .clk(ap_clk),
    .reset(ap_rst_n_inv),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(Block_Mat_exit71_pro_U0_out_mat_rows_out_din),
    .if_full_n(out_mat_rows_c_full_n),
    .if_write(Block_Mat_exit71_pro_U0_out_mat_rows_out_write),
    .if_dout(out_mat_rows_c_dout),
    .if_empty_n(out_mat_rows_c_empty_n),
    .if_read(xfMat2AXIstream_U0_img_rows_read)
);

fifo_w32_d4_A out_mat_cols_c_U(
    .clk(ap_clk),
    .reset(ap_rst_n_inv),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(Block_Mat_exit71_pro_U0_out_mat_cols_out_din),
    .if_full_n(out_mat_cols_c_full_n),
    .if_write(Block_Mat_exit71_pro_U0_out_mat_cols_out_write),
    .if_dout(out_mat_cols_c_dout),
    .if_empty_n(out_mat_cols_c_empty_n),
    .if_read(xfMat2AXIstream_U0_img_cols_read)
);

fifo_w32_d3_A sigma_c_U(
    .clk(ap_clk),
    .reset(ap_rst_n_inv),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(Block_Mat_exit71_pro_U0_sigma_out_din),
    .if_full_n(sigma_c_full_n),
    .if_write(Block_Mat_exit71_pro_U0_sigma_out_write),
    .if_dout(sigma_c_dout),
    .if_empty_n(sigma_c_empty_n),
    .if_read(GaussianBlur_U0_sigma_read)
);

fifo_w8_d2_A in_mat_data_V_U(
    .clk(ap_clk),
    .reset(ap_rst_n_inv),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(AXIstream2xfMat_U0_img_data_V_din),
    .if_full_n(in_mat_data_V_full_n),
    .if_write(AXIstream2xfMat_U0_img_data_V_write),
    .if_dout(in_mat_data_V_dout),
    .if_empty_n(in_mat_data_V_empty_n),
    .if_read(GaussianBlur_U0_p_src_data_V_read)
);

fifo_w32_d2_A in_mat_rows_c9_U(
    .clk(ap_clk),
    .reset(ap_rst_n_inv),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(AXIstream2xfMat_U0_img_rows_out_din),
    .if_full_n(in_mat_rows_c9_full_n),
    .if_write(AXIstream2xfMat_U0_img_rows_out_write),
    .if_dout(in_mat_rows_c9_dout),
    .if_empty_n(in_mat_rows_c9_empty_n),
    .if_read(GaussianBlur_U0_p_src_rows_read)
);

fifo_w32_d2_A in_mat_cols_c10_U(
    .clk(ap_clk),
    .reset(ap_rst_n_inv),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(AXIstream2xfMat_U0_img_cols_out_din),
    .if_full_n(in_mat_cols_c10_full_n),
    .if_write(AXIstream2xfMat_U0_img_cols_out_write),
    .if_dout(in_mat_cols_c10_dout),
    .if_empty_n(in_mat_cols_c10_empty_n),
    .if_read(GaussianBlur_U0_p_src_cols_read)
);

fifo_w8_d2_A out_mat_data_V_U(
    .clk(ap_clk),
    .reset(ap_rst_n_inv),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(GaussianBlur_U0_p_dst_data_V_din),
    .if_full_n(out_mat_data_V_full_n),
    .if_write(GaussianBlur_U0_p_dst_data_V_write),
    .if_dout(out_mat_data_V_dout),
    .if_empty_n(out_mat_data_V_empty_n),
    .if_read(xfMat2AXIstream_U0_img_data_V_read)
);

start_for_GaussiarcU start_for_GaussiarcU_U(
    .clk(ap_clk),
    .reset(ap_rst_n_inv),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(start_for_GaussianBlur_U0_din),
    .if_full_n(start_for_GaussianBlur_U0_full_n),
    .if_write(Block_Mat_exit71_pro_U0_start_write),
    .if_dout(start_for_GaussianBlur_U0_dout),
    .if_empty_n(start_for_GaussianBlur_U0_empty_n),
    .if_read(GaussianBlur_U0_ap_ready)
);

start_for_xfMat2Asc4 start_for_xfMat2Asc4_U(
    .clk(ap_clk),
    .reset(ap_rst_n_inv),
    .if_read_ce(1'b1),
    .if_write_ce(1'b1),
    .if_din(start_for_xfMat2AXIstream_U0_din),
    .if_full_n(start_for_xfMat2AXIstream_U0_full_n),
    .if_write(Block_Mat_exit71_pro_U0_start_write),
    .if_dout(start_for_xfMat2AXIstream_U0_dout),
    .if_empty_n(start_for_xfMat2AXIstream_U0_empty_n),
    .if_read(xfMat2AXIstream_U0_ap_ready)
);

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        ap_sync_reg_AXIstream2xfMat_U0_ap_ready <= 1'b0;
    end else begin
        if (((ap_sync_ready & ap_start) == 1'b1)) begin
            ap_sync_reg_AXIstream2xfMat_U0_ap_ready <= 1'b0;
        end else begin
            ap_sync_reg_AXIstream2xfMat_U0_ap_ready <= ap_sync_AXIstream2xfMat_U0_ap_ready;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        ap_sync_reg_Block_Mat_exit71_pro_U0_ap_ready <= 1'b0;
    end else begin
        if (((ap_sync_ready & ap_start) == 1'b1)) begin
            ap_sync_reg_Block_Mat_exit71_pro_U0_ap_ready <= 1'b0;
        end else begin
            ap_sync_reg_Block_Mat_exit71_pro_U0_ap_ready <= ap_sync_Block_Mat_exit71_pro_U0_ap_ready;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == AXIstream2xfMat_U0_ap_ready) & (ap_sync_ready == 1'b1))) begin
        AXIstream2xfMat_U0_ap_ready_count <= (AXIstream2xfMat_U0_ap_ready_count - 2'd1);
    end else if (((1'b1 == AXIstream2xfMat_U0_ap_ready) & (ap_sync_ready == 1'b0))) begin
        AXIstream2xfMat_U0_ap_ready_count <= (AXIstream2xfMat_U0_ap_ready_count + 2'd1);
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == Block_Mat_exit71_pro_U0_ap_ready) & (ap_sync_ready == 1'b1))) begin
        Block_Mat_exit71_pro_U0_ap_ready_count <= (Block_Mat_exit71_pro_U0_ap_ready_count - 2'd1);
    end else if (((1'b1 == Block_Mat_exit71_pro_U0_ap_ready) & (ap_sync_ready == 1'b0))) begin
        Block_Mat_exit71_pro_U0_ap_ready_count <= (Block_Mat_exit71_pro_U0_ap_ready_count + 2'd1);
    end
end

assign AXIstream2xfMat_U0_ap_continue = 1'b1;

assign AXIstream2xfMat_U0_ap_start = ((ap_sync_reg_AXIstream2xfMat_U0_ap_ready ^ 1'b1) & ap_start);

assign AXIstream2xfMat_U0_start_full_n = 1'b1;

assign AXIstream2xfMat_U0_start_write = 1'b0;

assign Block_Mat_exit71_pro_U0_ap_continue = 1'b1;

assign Block_Mat_exit71_pro_U0_ap_start = ((ap_sync_reg_Block_Mat_exit71_pro_U0_ap_ready ^ 1'b1) & ap_start);

assign Block_Mat_exit71_pro_U0_start_full_n = (start_for_xfMat2AXIstream_U0_full_n & start_for_GaussianBlur_U0_full_n);

assign GaussianBlur_U0_ap_continue = 1'b1;

assign GaussianBlur_U0_ap_start = start_for_GaussianBlur_U0_empty_n;

assign GaussianBlur_U0_start_full_n = 1'b1;

assign GaussianBlur_U0_start_write = 1'b0;

assign ap_done = xfMat2AXIstream_U0_ap_done;

assign ap_idle = (xfMat2AXIstream_U0_ap_idle & GaussianBlur_U0_ap_idle & Block_Mat_exit71_pro_U0_ap_idle & AXIstream2xfMat_U0_ap_idle);

assign ap_ready = ap_sync_ready;

always @ (*) begin
    ap_rst_n_inv = ~ap_rst_n;
end

assign ap_sync_AXIstream2xfMat_U0_ap_ready = (ap_sync_reg_AXIstream2xfMat_U0_ap_ready | AXIstream2xfMat_U0_ap_ready);

assign ap_sync_Block_Mat_exit71_pro_U0_ap_ready = (ap_sync_reg_Block_Mat_exit71_pro_U0_ap_ready | Block_Mat_exit71_pro_U0_ap_ready);

assign ap_sync_continue = 1'b1;

assign ap_sync_done = xfMat2AXIstream_U0_ap_done;

assign ap_sync_ready = (ap_sync_Block_Mat_exit71_pro_U0_ap_ready & ap_sync_AXIstream2xfMat_U0_ap_ready);

assign start_for_GaussianBlur_U0_din = 1'b1;

assign start_for_xfMat2AXIstream_U0_din = 1'b1;

assign stream_in_TREADY = AXIstream2xfMat_U0_stream_in_TREADY;

assign stream_out_TDATA = xfMat2AXIstream_U0_stream_out_TDATA;

assign stream_out_TLAST = xfMat2AXIstream_U0_stream_out_TLAST;

assign stream_out_TVALID = xfMat2AXIstream_U0_stream_out_TVALID;

assign xfMat2AXIstream_U0_ap_continue = 1'b1;

assign xfMat2AXIstream_U0_ap_start = start_for_xfMat2AXIstream_U0_empty_n;

assign xfMat2AXIstream_U0_start_full_n = 1'b1;

assign xfMat2AXIstream_U0_start_write = 1'b0;

endmodule //gaussian
















































































