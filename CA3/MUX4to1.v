module MUX4to1
#(parameter WIDTH = 8)
(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  [WIDTH-1:0] c,
    input  [WIDTH-1:0] d,
    input  sel0,
    input  sel1,
    output [WIDTH-1:0] out
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_mux4to1
            MUX4to1_1bit u_mux4to1_1bit (
                .a    (a[i]),
                .b    (b[i]),
                .c    (c[i]),
                .d    (d[i]),
                .sel0 (sel0),
                .sel1 (sel1),
                .out  (out[i])
            );
        end
    endgenerate

endmodule

