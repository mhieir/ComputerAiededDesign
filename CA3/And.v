module AND_1bit(a, b, out);
    input a, b;
    output out;

    c1 my_and(.A0(1'b0), .A1(1'b0), .SA(1'b0), .B0(1'b0), .B1(a), .SB(1'b1), .S0(b), .S1(b), .f(out));

endmodule

module AND
#(parameter WIDTH = 8)
(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output [WIDTH-1:0] out
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_and
            AND_1bit u_and_1bit (
                .a   (a[i]),
                .b   (b[i]),
                .out (out[i])
            );
        end
    endgenerate
    
endmodule

