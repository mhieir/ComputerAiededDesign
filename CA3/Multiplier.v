
module HalfAdder(a, b, sum, co);
    input a, b;
    output sum, co;
    XOR_1bit my_xor(.a(a), .b(b), .out(sum));
    AND_1bit my_and(.a(a), .b(b), .out(co));
endmodule


module Multiplier_4bit (
    input [3:0] a,
    input [3:0] b,
    output [7:0] out
);

    wire [3:0] pp0, pp1, pp2, pp3;

    AND_1bit p00 (.a(a[0]), .b(b[0]), .out(pp0[0]));
    AND_1bit p01 (.a(a[1]), .b(b[0]), .out(pp0[1]));
    AND_1bit p02 (.a(a[2]), .b(b[0]), .out(pp0[2]));
    AND_1bit p03 (.a(a[3]), .b(b[0]), .out(pp0[3]));
    AND_1bit p10 (.a(a[0]), .b(b[1]), .out(pp1[0]));
    AND_1bit p11 (.a(a[1]), .b(b[1]), .out(pp1[1]));
    AND_1bit p12 (.a(a[2]), .b(b[1]), .out(pp1[2]));
    AND_1bit p13 (.a(a[3]), .b(b[1]), .out(pp1[3]));
    AND_1bit p20 (.a(a[0]), .b(b[2]), .out(pp2[0]));
    AND_1bit p21 (.a(a[1]), .b(b[2]), .out(pp2[1]));
    AND_1bit p22 (.a(a[2]), .b(b[2]), .out(pp2[2]));
    AND_1bit p23 (.a(a[3]), .b(b[2]), .out(pp2[3]));
    AND_1bit p30 (.a(a[0]), .b(b[3]), .out(pp3[0]));
    AND_1bit p31 (.a(a[1]), .b(b[3]), .out(pp3[1]));
    AND_1bit p32 (.a(a[2]), .b(b[3]), .out(pp3[2]));
    AND_1bit p33 (.a(a[3]), .b(b[3]), .out(pp3[3]));


    wire [3:0] s1, c1;
    assign out[0] = pp0[0];
    HalfAdder ha1_0 (.a(pp0[1]), .b(pp1[0]), .sum(s1[0]), .co(c1[0]));
    Fulladder fa1_1 (.a(pp0[2]), .b(pp1[1]), .cin(c1[0]), .sum(s1[1]), .co(c1[1]));
    Fulladder fa1_2 (.a(pp0[3]), .b(pp1[2]), .cin(c1[1]), .sum(s1[2]), .co(c1[2]));
    HalfAdder ha1_3 (.a(pp1[3]), .b(c1[2]), .sum(s1[3]), .co(c1[3]));
    wire [3:0] s2, c2;
    assign out[1] = s1[0];
    HalfAdder ha2_0 (.a(s1[1]), .b(pp2[0]), .sum(s2[0]), .co(c2[0]));
    Fulladder fa2_1 (.a(s1[2]), .b(pp2[1]), .cin(c2[0]), .sum(s2[1]), .co(c2[1]));
    Fulladder fa2_2 (.a(s1[3]), .b(pp2[2]), .cin(c2[1]), .sum(s2[2]), .co(c2[2]));
    Fulladder fa2_3 (.a(c1[3]), .b(pp2[3]), .cin(c2[2]), .sum(s2[3]), .co(c2[3]));
    wire [3:0] s3, c3;
    assign out[2] = s2[0];
    HalfAdder ha3_0 (.a(s2[1]), .b(pp3[0]), .sum(out[3]), .co(c3[0]));
    Fulladder fa3_1 (.a(s2[2]), .b(pp3[1]), .cin(c3[0]), .sum(out[4]), .co(c3[1]));
    Fulladder fa3_2 (.a(s2[3]), .b(pp3[2]), .cin(c3[1]), .sum(out[5]), .co(c3[2]));
    Fulladder fa3_3 (.a(c2[3]), .b(pp3[3]), .cin(c3[2]), .sum(out[6]), .co(out[7]));

endmodule