module Multiplier
#(
    parameter WIDTH = 4
)
(   input[WIDTH-1:0] inp,
    output[WIDTH-1:0] out
);
    assign out = inp[WIDTH-1:WIDTH/2] * inp[WIDTH/2-1:0];
endmodule