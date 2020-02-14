`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.02.2020 15:08:18
// Design Name: 
// Module Name: split
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module split(
    input [2:0] gpio,
    output enable,
    output drop,
    output select
    );
    
assign enable = gpio[0];
assign drop = gpio[1];
assign select = gpio[2]; 
    
endmodule
