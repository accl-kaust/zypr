module testic
#(
	localparam get = 999,
	localparam tester = 111

    )
(
output [get:0] led,
input [7:0] sw
);
assign led[3] = sw[1];
endmodule