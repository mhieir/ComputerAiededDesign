module Adder(input [31:0] inp0, inp1, output[31:0] out);
    assign out = inp0 + inp1;
endmodule

module And(input [31:0] inp0,inp1, output[31:0] out);
    assign out = inp0 & inp1;
endmodule

module Or(input [31:0] inp0,inp1, output[31:0] out);
    assign out = inp0 | inp1;
endmodule

module Xor #(parameter WIDTH = 32)
    (input [WIDTH-1:0] inp0,inp1, output[WIDTH-1:0] out);
    assign out = inp0 ^ inp1;
endmodule

module Not #(parameter WIDTH = 32)
    (input [WIDTH-1:0] inp, output[WIDTH-1:0] out);
    assign out = ~inp;
endmodule