`timescale 1ns/1ps

module top ( 
    input wire s_axi_AXILiteS_AWVALID,
    output wire s_axi_AXILiteS_AWREADY,
    input wire [5:0] s_axi_AXILiteS_AWADDR,
    input wire s_axi_AXILiteS_WVALID,
    output wire s_axi_AXILiteS_WREADY,
    input wire [31:0] s_axi_AXILiteS_WDATA,
    input wire [3:0] s_axi_AXILiteS_WSTRB,
    input wire s_axi_AXILiteS_ARVALID,
    output wire s_axi_AXILiteS_ARREADY,
    input wire [5:0] s_axi_AXILiteS_ARADDR,
    output wire s_axi_AXILiteS_RVALID,
    input wire s_axi_AXILiteS_RREADY,
    output wire [31:0] s_axi_AXILiteS_RDATA,
    output wire [1:0] s_axi_AXILiteS_RRESP,
    output wire s_axi_AXILiteS_BVALID,
    input wire s_axi_AXILiteS_BREADY,
    output wire [1:0] s_axi_AXILiteS_BRESP,
    input wire ap_clk,
    input wire ap_rst_n,
    output wire interrupt,
    input wire [23:0] stream_in_TDATA,
    input wire stream_in_TLAST,
    output wire [7:0] stream_out_TDATA,
    output wire stream_out_TLAST,
    input wire stream_in_TVALID,
    output wire stream_in_TREADY,
    output wire stream_out_TVALID,
    input wire stream_out_TREADY
);

wire [7:0] width_data;
wire width_ready;
wire width_valid;
wire width_last;

// HLS Core
gaussian gaussian_hls (
    .s_axi_AXILiteS_AWVALID(s_axi_AXILiteS_AWVALID),
    .s_axi_AXILiteS_AWREADY(s_axi_AXILiteS_AWREADY),
    .s_axi_AXILiteS_AWADDR(s_axi_AXILiteS_AWADDR),
    .s_axi_AXILiteS_WVALID(s_axi_AXILiteS_WVALID),
    .s_axi_AXILiteS_WREADY(s_axi_AXILiteS_WREADY),
    .s_axi_AXILiteS_WDATA(s_axi_AXILiteS_WDATA),
    .s_axi_AXILiteS_WSTRB(s_axi_AXILiteS_WSTRB),
    .s_axi_AXILiteS_ARVALID(s_axi_AXILiteS_ARVALID),
    .s_axi_AXILiteS_ARREADY(s_axi_AXILiteS_ARREADY),
    .s_axi_AXILiteS_ARADDR(s_axi_AXILiteS_ARADDR),
    .s_axi_AXILiteS_RVALID(s_axi_AXILiteS_RVALID),
    .s_axi_AXILiteS_RREADY(s_axi_AXILiteS_RREADY),
    .s_axi_AXILiteS_RDATA(s_axi_AXILiteS_RDATA),
    .s_axi_AXILiteS_RRESP(s_axi_AXILiteS_RRESP),
    .s_axi_AXILiteS_BVALID(s_axi_AXILiteS_BVALID),
    .s_axi_AXILiteS_BREADY(s_axi_AXILiteS_BREADY),
    .s_axi_AXILiteS_BRESP(s_axi_AXILiteS_BRESP),

    .ap_clk(ap_clk),
    .ap_rst_n(ap_rst_n),
    .interrupt(interrupt),

    .stream_in_TDATA(width_data),
    .stream_in_TLAST(width_last),
    .stream_out_TDATA(stream_out_TDATA),
    .stream_out_TLAST(stream_out_TLAST),
    .stream_in_TVALID(width_valid),
    .stream_in_TREADY(width_ready),
    .stream_out_TVALID(stream_out_TVALID),
    .stream_out_TREADY(stream_out_TREADY)
);

// 24bit to 8bit
axis_dwidth_converter_1 stream_input (
  .aclk(ap_clk),                    // input wire aclk
  .aresetn(ap_rst_n),              // input wire aresetn
  .s_axis_tvalid(stream_in_TVALID),  // input wire s_axis_tvalid
  .s_axis_tready(stream_in_TREADY),  // output wire s_axis_tready
  .s_axis_tdata(stream_in_TDATA),    // input wire [7 : 0] s_axis_tdata
  .s_axis_tlast(stream_in_TLAST),    // input wire s_axis_tlast
  .m_axis_tvalid(width_valid),  // output wire m_axis_tvalid
  .m_axis_tready(width_ready),  // input wire m_axis_tready
  .m_axis_tdata(width_data),    // output wire [31 : 0] m_axis_tdata
  .m_axis_tlast(width_last)    // output wire m_axis_tlast
);

endmodule













































