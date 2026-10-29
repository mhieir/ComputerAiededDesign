module Mul2inp #(
    parameter WIDTH = 7
)(
    input [WIDTH-1:0] inp0,
    input [WIDTH-1:0] inp1,
    output [WIDTH-1:0] out
);
    assign out = inp0 * inp1;
endmodule