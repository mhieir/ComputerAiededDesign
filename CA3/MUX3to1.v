module MUX3to1
#(parameter N = 8)
(
    input  [N-1:0] a,
    input  [N-1:0] b,
    input  [N-1:0] c,
    input sel0,
    input sel1,
    output [N-1:0] out
);

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_mux3to1
            MUX3to1_1bit u_mux3to1_1bit (
                .a    (a[i]),
                .b    (b[i]),
                .c    (c[i]),
                .sel0 (sel0),
                .sel1 (sel1),
                .out  (out[i])
            );
        end
    endgenerate

endmodule

