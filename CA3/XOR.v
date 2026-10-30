module XOR_1bit (a, b, out);

    input a, b;
    output out;

    c2 my_xor(.D00(1'b0), .D01(1'b1), .D10(1'b1), .D11(1'b0), .A1(a), .B1(b), .A0(a), .B0(b), .out(out));
endmodule

module XOR
#(parameter WIDTH = 8)
(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output [WIDTH-1:0] out
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_xor
            XOR_1bit u_xor_1bit (
                .a   (a[i]),
                .b   (b[i]),
                .out (out[i])
            );
        end
    endgenerate

endmodule
