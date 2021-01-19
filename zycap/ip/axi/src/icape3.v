//----------------------------------------------------------------------------
// Filename:          icap_stream
// Version:           1.00.a
// Description:       ICAP hardmacro instantitation
// Author:            Alex Bucknall
// 
//----------------------------------------------------------------------------

module icap 
	(
		input           ACLK,
		input           ARESETN,
        output          AVAILABLE,

		output          S_AXIS_TREADY,
		input [31 : 0]  S_AXIS_TDATA,
		input           S_AXIS_TLAST,
		input           S_AXIS_TVALID,

		input           M_AXIS_TREADY,
		output [31 : 0] M_AXIS_TDATA,
		output          M_AXIS_TLAST,
		output          M_AXIS_TVALID,

        output          DONE_IRQ,
        output          ERR_IRQ
	);

wire [31:0] icap_data;
wire [31:0] icap_data_echo;

assign S_AXIS_TREADY = 1'b1; 
assign icap_data = {
    S_AXIS_TDATA[24],
    S_AXIS_TDATA[25],
    S_AXIS_TDATA[26],
    S_AXIS_TDATA[27],
    S_AXIS_TDATA[28],
    S_AXIS_TDATA[29],
    S_AXIS_TDATA[30],
    S_AXIS_TDATA[31],
    S_AXIS_TDATA[16],
    S_AXIS_TDATA[17],
    S_AXIS_TDATA[18],
    S_AXIS_TDATA[19],
    S_AXIS_TDATA[20],
    S_AXIS_TDATA[21],
    S_AXIS_TDATA[22],
    S_AXIS_TDATA[23],
    S_AXIS_TDATA[8],
    S_AXIS_TDATA[9],
    S_AXIS_TDATA[10],
    S_AXIS_TDATA[11],
    S_AXIS_TDATA[12],
    S_AXIS_TDATA[13],
    S_AXIS_TDATA[14],
    S_AXIS_TDATA[15],
    S_AXIS_TDATA[0],
    S_AXIS_TDATA[1],
    S_AXIS_TDATA[2],
    S_AXIS_TDATA[3],
    S_AXIS_TDATA[4],
    S_AXIS_TDATA[5],
    S_AXIS_TDATA[6],
    S_AXIS_TDATA[7]
    };

assign M_AXIS_TDATA = {
    icap_data_echo[24],
    icap_data_echo[25],
    icap_data_echo[26],
    icap_data_echo[27],
    icap_data_echo[28],
    icap_data_echo[29],
    icap_data_echo[30],
    icap_data_echo[31],
    icap_data_echo[16],
    icap_data_echo[17],
    icap_data_echo[18],
    icap_data_echo[19],
    icap_data_echo[20],
    icap_data_echo[21],
    icap_data_echo[22],
    icap_data_echo[23],
    icap_data_echo[8],
    icap_data_echo[9],
    icap_data_echo[10],
    icap_data_echo[11],
    icap_data_echo[12],
    icap_data_echo[13],
    icap_data_echo[14],
    icap_data_echo[15],
    icap_data_echo[0],
    icap_data_echo[1],
    icap_data_echo[2],
    icap_data_echo[3],
    icap_data_echo[4],
    icap_data_echo[5],
    icap_data_echo[6],
    icap_data_echo[7]
    };


   ICAPE3 #(
      .DEVICE_ID('h3651093),     // Specifies the pre-programmed Device ID value to be used for simulation
                                  // purposes.
      // .ICAP_WIDTH("X32"),         // Specifies the input and output data width.
      .SIM_CFG_FILE_NAME("None")  // Specifies the Raw Bitstream (RBT) file to be parsed by the simulation
                                  // model.
   )
   ICAPE3_inst (
        .AVAIL(AVAILABLE),  
        .O(icap_data_echo),                   // 32-bit output: Configuration data output bus
        .PRDONE(DONE_IRQ),      // 1-bit output: Indicates completion of Partial Reconfiguration
        .PRERROR(ERR_IRQ),             // 1-bit output: Indicates Error during Partial Reconfiguration
        .CLK(ACLK),             // 1-bit input: Clock Input
        .CSIB(~S_AXIS_TVALID),  // 1-bit input: Active-Low ICAP Enable
        .I(icap_data),          // 32-bit input: Configuration data input bus
        .RDWRB(~S_AXIS_TVALID)  // 1-bit input: Read/Write Select input
   );

endmodule
