module weird (
    input clk,
    input [31:0] a_TDATA_in ,
    input a_TVALID,
    output a_TREADY,
    output [31:0] b_TDATA_out,
    output b_TVALID,
    input b_TREADY,
//      input [31:0] c_TDATA_in,
//   input [0:0] c_TVALID,
//   output [0:0] c_TREADY,
    output irq,
    input [9:0] gpio 
);
    
endmodule
