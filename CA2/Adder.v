module Adder4Inp #(
    parameter WIDTH = 16
)
(
    input signed [WIDTH - 1:0] inp0,
    input signed [WIDTH - 1:0] inp1,
    input signed [WIDTH - 1:0] inp2,
    input signed [WIDTH - 1:0] inp3,
    output signed[WIDTH +1:0] out
);
    assign out = inp0 + inp1 + inp2 + inp3;
endmodule


module Adder3Inp #(
    parameter WIDTH = 34
)
(
    input signed [WIDTH - 1:0] inp0,
    input signed[WIDTH - 1:0] inp1,
    input signed[WIDTH - 1:0] inp2,
    output signed [WIDTH - 1:0] out
);
    assign out = inp0 + inp1 + inp2;
endmodule


module Adder2Inp #(
    parameter WIDTH = 7
)
(
    input signed [WIDTH - 1:0] inp0,
    input signed [WIDTH - 1:0] inp1,
    output signed [WIDTH - 1:0] out
);
    assign out = inp0 + inp1;
endmodule