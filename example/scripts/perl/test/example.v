module led_sw
#(
	localparam example = 12,
	localparam tester = 23,
    parameter toot = 123
    )
(
output [example:0] led,
input [7:0] sw
);
assign led[3] = sw[1];


tesx dut1();

test dut(
    .x(sw)
);

endmodule

module test #(
    parameter thing = 12
)(
    input x, output y);
tesx dut2();

tesx what_a_dut();

tesx why_this_a_dut();


assign x = y;
endmodule