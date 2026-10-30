module CarryOut (a, b, cin, cout);
    input a, b, cin;
    output cout;
    c2 my_carry_out(.D00(1'b0), .D01(1'b1), .D10(cin), .D11(1'b1), .A1(a), .B1(b), .A0(a), .B0(b), .out(cout));
endmodule

module Fulladder(a, b, cin, sum, co);
    input a, b, cin;
    output sum, co;
    wire s;
    XOR_1bit my_x1(.a(a), .b(b), .out(s));
    XOR_1bit my_x2(.a(s), .b(cin), .out(sum));
    CarryOut my_carry(.a(a), .b(b), .cin(cin), .cout(co));
endmodule

module Adder
#(parameter N = 8)
(
    input  [N-1:0] a,
    input  [N-1:0] b,
    input  cin,
    output [N-1:0] sum,
    output cout
);
    wire [N:0] c;
    assign c[0] = cin;
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_fa
            Fulladder u_fa (
                .a   (a[i]),
                .b   (b[i]),
                .cin (c[i]),
                .sum (sum[i]),
                .co  (c[i+1])
            );
        end
    endgenerate
    assign cout = c[N];

endmodule
