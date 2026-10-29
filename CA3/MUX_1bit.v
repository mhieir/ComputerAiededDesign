module MUX2to1_1bit(a, b, sel, out);

    input sel;
    input a, b;
    output out;
    c2 my_mux2to1_1bit(.D00(a), .D01(b), .D10(1'b0), .D11(1'b0), .A1(1'b0), .B1(1'b0), .A0(sel), .B0(1'b1), .out(out));

endmodule

module MUX3to1_1bit(a, b, c, sel0, sel1, out);

    input sel0, sel1;
    input a, b, c;
    output out;
    c2 my_mux3to1_1bit(.D00(a), .D01(b), .D10(c), .D11(1'b0), .A1(1'b0), .B1(sel1), .A0(1'b1), .B0(sel0), .out(out));

endmodule

module MUX4to1_1bit(a, b, c, d, sel0, sel1, out);

    input sel0, sel1;
    input a, b, c, d;
    output out;
    c2 my_mux4to1_1bit(.D00(a), .D01(b), .D10(c), .D11(d), .A1(1'b0), .B1(sel1), .A0(1'b1), .B0(sel0), .out(out));

endmodule
