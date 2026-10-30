module Adder #(parameter WIDTH = 4)
    (input [WIDTH-1:0] inp0, inp1, output[WIDTH-1:0] out);
    assign out = inp0 + inp1;
endmodule

module And #(parameter WIDTH = 4)
    (input [WIDTH-1:0] inp0,inp1, output[WIDTH-1:0] out);
    assign out = inp0 & inp1;
endmodule

module Or #(parameter WIDTH = 4)
    (input [WIDTH-1:0] inp0,inp1, output[WIDTH-1:0] out);
    assign out = inp0 | inp1;
endmodule

module Xor #(parameter WIDTH = 4)
    (input [WIDTH-1:0] inp0,inp1, output[WIDTH-1:0] out);
    assign out = inp0 ^ inp1;
endmodule

module Not #(parameter WIDTH = 4)
    (input [WIDTH-1:0] inp, output[WIDTH-1:0] out);
    assign out = ~inp;
endmodule