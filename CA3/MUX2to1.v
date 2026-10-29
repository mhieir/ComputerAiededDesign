module MUX2to1
#(parameter WIDTH = 8)
(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  sel,
    output [WIDTH-1:0] out
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_mux2to1
            MUX2to1_1bit u_mux2to1_1bit (
                .a   (a[i]),
                .b   (b[i]),
                .sel (sel),
                .out (out[i])
            );
        end
    endgenerate

endmodule

module MUX2to1_Bitwise
#(parameter WIDTH = 8)
(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  [WIDTH-1:0] sel,
    output [WIDTH-1:0] out
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_mux_bitwise
            MUX2to1_1bit u_mux_bit (
                .a   (a[i]),
                .b   (b[i]),
                .sel (sel[i]),
                .out (out[i])
            );
        end
    endgenerate

endmodule
