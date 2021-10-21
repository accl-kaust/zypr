module axis_fifo_top_b (
  input wire clk,
  input wire rst,
  input wire [31:0] s_axis_tdata,
  input wire s_axis_tkeep,
  input wire s_axis_tvalid,
  output wire s_axis_tready,
  input wire s_axis_tlast,
  input wire [7:0] s_axis_tid,
  input wire [7:0] s_axis_tdest,
  input wire s_axis_tuser,
  output wire [31:0] m_axis_tdata,
  output wire m_axis_tkeep,
  output wire m_axis_tvalid,
  input wire m_axis_tready,
  output wire m_axis_tlast,
  output wire [7:0] m_axis_tid,
  output wire [7:0] m_axis_tdest,
  output wire m_axis_tuser
);

  axis_fifo
  inst
  (
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tid(s_axis_tid),
    .s_axis_tdest(s_axis_tdest),
    .s_axis_tuser(s_axis_tuser),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tid(m_axis_tid),
    .m_axis_tdest(m_axis_tdest),
    .m_axis_tuser(m_axis_tuser)
  );
    
endmodule












































































































































