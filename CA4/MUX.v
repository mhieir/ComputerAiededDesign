module MUX2to1
#(
    parameter WIDTH = 4
)
    (input[WIDTH - 1:0] inp0, inp1, input sel,output [WIDTH - 1:0] out);
    assign out = sel ? inp1 : inp0;
endmodule



module MUX3to1
#(
    parameter WIDTH = 4
)
    (input[WIDTH-1:0] inp0, inp1,inp2, input[1:0] sel,output [WIDTH-1:0] out);
    assign out = (sel == 2'b00 )? inp0 :
          (sel == 2'b01) ? inp1 :
          (sel == 2'b10) ? inp2 : {WIDTH{1'bz}};
endmodule



module MUX4to1
#(
    parameter WIDTH = 4
)
(input[WIDTH-1:0] inp0, inp1,inp2,inp3, input[1:0] sel,output [WIDTH-1:0] out);
    assign out = (sel == 2'b00) ? inp0 :
          (sel == 2'b01) ? inp1 :
          (sel == 2'b10) ? inp2 :
          (sel == 2'b11) ? inp3 : {WIDTH{1'bz}};
endmodule
