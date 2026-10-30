module MUX2to1 #(
    parameter WIDTH = 34
)(
    input [WIDTH-1 : 0] inp0,
    input [WIDTH-1 : 0] inp1,
    input sel,
    output [WIDTH-1 : 0] out
);
    assign out = (sel == 1'b0) ? inp0 :
                (sel == 1'b1) ? inp1 : {WIDTH{1'bz}};
endmodule



module MUX3to1 #(
    parameter WIDTH = 16

)(
    input [WIDTH-1:0] inp0,
    input [WIDTH-1:0] inp1,
    input [WIDTH-1:0] inp2,
    input[1:0] sel,
    output [WIDTH-1:0] out
);
    assign out = (sel == 2'b00 )? inp0 :
          (sel == 2'b01) ? inp1 :
          (sel == 2'b10) ? inp2 : {WIDTH{1'bz}};
endmodule

module MUX_2sel_3to1 #(
    parameter WIDTH = 16
)(
    input [WIDTH-1:0] inp0, inp1, inp2,
    input sel0, sel1,
    output [WIDTH-1:0] out
);
    assign out = (sel1 & sel0) ? inp0 :
                 (sel0) ? inp1 :
                 (~sel0) ? inp2 : {WIDTH{1'bz}};

endmodule

module MUX_3sel_3to1 #(
    parameter WIDTH = 7
)(
    input [WIDTH-1:0] inp0, inp1, inp2,
    input sel0, sel1, sel2,
    output [WIDTH-1:0] out
);
    assign out = (sel0) ? inp0 :
                 (sel1) ? inp1 :
                 (sel2) ? inp2 :{{WIDTH}0'bz};
endmodule