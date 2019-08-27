module led_sw
#(
	localparam test = 12
)
(
output [test:0] led,
input [7:0] sw
);
assign led[3] = sw[1];
endmodule