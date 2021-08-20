module tesx
#(
	localparam get = 43,
	localparam testerthing = 94,
	parameter woah = 34
    )
(
output [get:0] led,
input [7:0] sw
);
assign led[3] = sw[1];

testic dut_testic(
);
endmodule