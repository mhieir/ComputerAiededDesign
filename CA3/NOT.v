module NOT_1bit (a, out);

    input a;
    output out;

    c1 my_not(.A0(1'b1), .A1(1'b1), .SA(1'b0), .B0(1'b0), .B1(1'b0), .SB(1'b1), .S0(a), .S1(a), .f(out));  
endmodule

module NOT
#(parameter WIDTH = 8)
(
    input  [WIDTH-1:0] a,
    output [WIDTH-1:0] out
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_not
            NOT_1bit u_not_1bit (
                .a   (a[i]),
                .out (out[i])
            );
        end
    endgenerate

endmodule
