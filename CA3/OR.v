module OR_1bit (a, b, out);

    input a, b;
    output out;

    c1 my_or(.A0(1'b0), .A1(1'b0), .B0(1'b1), .B1(1'b1), .SA(1'b0), .SB(1'b0), .S0(a), .S1(b), .f(out));

endmodule

module OR
#(parameter WIDTH = 8)
(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output [WIDTH-1:0] out
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_or
            OR_1bit u_or_1bit (
                .a   (a[i]),
                .b   (b[i]),
                .out (out[i])
            );
        end
    endgenerate

endmodule

