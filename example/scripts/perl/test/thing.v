module tesx
#(
	localparam get = 12,
	localparam tester = 23

    )
(
output [get:0] led,
input [7:0] sw
);
assign led[3] = sw[1];
endmodule