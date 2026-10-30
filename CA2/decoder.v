module Decoder #(
	parameter N = 3,
	parameter OUT_WIDTH = 1 << N
)(
	input [N-1:0] sel,
	input en,
	output [OUT_WIDTH-1:0] out
);
	assign out = en ? (1 << sel) : {OUT_WIDTH{1'bx}};
endmodule
