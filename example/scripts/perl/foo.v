module regexample (q, d, clk, rst_n);
	parameter Trst = 1,
	Tckq = 1,
	N = 4,
	NOT_USED =1;
	
	output [N-1:0] q;
	input [N-1:0] d;
	input clk, rst_n;
	reg [N-1:0] q;
	always @(posedge clk or negedge rst_n)
	if (!rst_n) q <= #Trst 0;
	else        q <= #Tckq d;
endmodule