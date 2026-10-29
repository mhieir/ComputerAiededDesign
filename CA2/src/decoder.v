module Decoder #(
	parameter N = 3,
	parameter OUT_WIDTH = 1 << N
)(
	input [N-1:0] sel,
	output [OUT_WIDTH-1:0] out
);
	assign out = (1 << sel);
endmodule
