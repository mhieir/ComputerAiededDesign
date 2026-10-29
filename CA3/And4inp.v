module AND4_1bit (a, b, c, d, out);

    input a, b, c, d;
    output out;

    c2 my_4inp_and(.D00(1'b0), .D01(1'b0), .D10(1'b0), .D11(d), .A1(c), .B1(1'b0), .A0(a), .B0(b), .out(out));

endmodule

module AND4_Nbit
#(parameter N = 8)
(
    input  [N-1:0] a,
    input  [N-1:0] b,
    input  [N-1:0] c,
    input  [N-1:0] d,
    output [N-1:0] out
);

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_and4
            AND4_1bit u_and4_1bit (
                .a   (a[i]),
                .b   (b[i]),
                .c   (c[i]),
                .d   (d[i]),
                .out (out[i])
            );
        end
    endgenerate

endmodule
