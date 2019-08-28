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

test dut(
    .x(sw)
);

endmodule

module test (input x, output y);

assign x = y;
endmodule