module led_sw
#(
	localparam example = 12,
	localparam tester = 23

    )
(
output [example:0] led,
input [7:0] sw
);
assign led[3] = sw[1];
endmodule