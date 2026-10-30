module Datapath_hash
#(
    parameter WIDTH = 4,
    parameter NUM_WORDS = 4,
    parameter ITER = 64
)(
	input clk, rst,
    input iz_i, en_i,
    input sel_A, sel_B, sel_C, sel_D,
    input load_A, load_B, load_C, load_D,
    input sel_F, load_F,
    input load_M,
    input start_rnd,
	input[1:0] sel_sum0,sel_sum1,
	input load_sum,
	input[1:0] rnd,
	input [(NUM_WORDS * WIDTH) - 1 : 0] message,
	output co_i,
	output [(NUM_WORDS * WIDTH) - 1 : 0] digest,
	output [($clog2(ITER)-1):0] i
);
	wire [WIDTH-1:0] inp_A, inp_B, inp_C, inp_D;
	wire [WIDTH-1:0] A, B, C, D;
	wire [WIDTH-1:0] out_sum;
	wire [WIDTH-1:0] inp_f0, inp_f1, inp_f2, inp_f3;
	wire [WIDTH-1:0] out_or_1, out_not_1, out_not_2, out_xor_3, out_and_1, out_and_2, out_and_3, out_and_4;
	wire[1:0] sel_i;
	wire [WIDTH-1:0] out_i;
	wire [WIDTH-1:0] constant_i;
	wire [WIDTH-1:0] left_rotate;
	wire [WIDTH-1:0] F;
	wire [WIDTH-1:0] inp_F;
	wire [(NUM_WORDS * WIDTH) - 1 : 0] M;
	wire [WIDTH-1:0] M_rnd;
	wire [WIDTH-1:0] inp_sum_0, inp_sum_1, inp_sum;

	localparam I_WIDTH = $clog2(ITER);
    localparam [WIDTH-1:0] a0 = 8'b00000001;
    localparam [WIDTH-1:0] b0 = 8'b10001001;
    localparam [WIDTH-1:0] c0 = 8'b11111110;
    localparam [WIDTH-1:0] d0 = 8'b01110110;

	Register #(.WIDTH(WIDTH)) my_reg_A(clk, rst, load_A, inp_A, A);
	Register #(.WIDTH(WIDTH)) my_reg_B(clk, rst, load_B, inp_B, B);
	Register #(.WIDTH(WIDTH)) my_reg_C(clk, rst, load_C, inp_C, C);
	Register #(.WIDTH(WIDTH)) my_reg_D(clk, rst, load_D, inp_D, D);

	MUX2to1 #(.WIDTH(WIDTH)) my_mux_A(a0, D, sel_A, inp_A);
	MUX2to1 #(.WIDTH(WIDTH)) my_mux_B(b0, out_sum, sel_B, inp_B);
	MUX2to1 #(.WIDTH(WIDTH)) my_mux_C(c0, B, sel_C, inp_C);
	MUX2to1 #(.WIDTH(WIDTH)) my_mux_D(d0, C, sel_D, inp_D);

	Xor #(.WIDTH(WIDTH)) my_xor_1(C, out_or_1, inp_f3);
	Not #(.WIDTH(WIDTH)) my_not_1(D, out_not_1);
	Or #(.WIDTH(WIDTH)) my_or_1(B, out_not_1, out_or_1);
	Xor #(.WIDTH(WIDTH)) my_xor_2(B, out_xor_3, inp_f2);
	Xor #(.WIDTH(WIDTH)) my_xor_3(C, D, out_xor_3);
	Or #(.WIDTH(WIDTH)) my_or_2(out_and_1, out_and_2, inp_f1);
	And #(.WIDTH(WIDTH)) my_and_1(out_not_1, C, out_and_1);
	And #(.WIDTH(WIDTH)) my_and_2(B, D, out_and_2);
	Not #(.WIDTH(WIDTH)) my_not_2(B, out_not_2);
	And #(.WIDTH(WIDTH)) my_and_3(C, B, out_and_3);
	And #(.WIDTH(WIDTH)) my_and_4(D, out_not_2, out_and_4);
	Or #(.WIDTH(WIDTH)) my_or_3(out_and_3, out_and_4, inp_f0);


	MUX4to1 #(.WIDTH(WIDTH)) my_mux_i(inp_f0, inp_f1, inp_f2, inp_f3, sel_i, out_i);
	wire co_i_s;
	Counter#(.WIDTH(I_WIDTH)) my_counter_i(clk, rst, en_i, iz_i, {I_WIDTH{1'b0}}, i, co_i_s,co_i);
	assign sel_i = i[I_WIDTH-1 : I_WIDTH-2];
	Rom_file #(.ADDR_WIDTH(6), .DATA_WIDTH(WIDTH)) my_constant_rom(i, constant_i);

	Multiplier#(.WIDTH(WIDTH)) my_multiplier(F, left_rotate);

	MUX2to1 #(.WIDTH(WIDTH)) my_mux_F(out_i, out_sum, sel_F, inp_F);

	Register#(.WIDTH(WIDTH)) my_reg_F(clk, rst, load_F, inp_F, F);
	Register#(.WIDTH(NUM_WORDS * WIDTH)) my_reg_M(clk, rst, load_M, message, M);

	MUX4to1 #(.WIDTH(WIDTH)) my_mux_M(M[(4*WIDTH)-1 : 3*WIDTH], M[(3*WIDTH)-1 : 2*WIDTH], M[(2*WIDTH)-1 : 1*WIDTH ], M[(1*WIDTH)-1 : 0 ], rnd, M_rnd);
	MUX4to1 #(.WIDTH(WIDTH)) my_mux_sum0(constant_i, M_rnd, B, A, sel_sum0, inp_sum_0);
	MUX3to1 #(.WIDTH(WIDTH)) my_mux_sum1(left_rotate, F, out_sum, sel_sum1, inp_sum_1);

	Adder #(.WIDTH(WIDTH)) my_adder(inp_sum_0, inp_sum_1, inp_sum);

	Register#(.WIDTH(WIDTH)) my_reg_Sum(clk, rst, load_sum, inp_sum, out_sum);

	assign digest = {A, B, C, D};


endmodule

module Datapath_rnd_gen
#(
    parameter NUM_REP = 6
)
(
    input clk, rst,
    input iz_c, en_c,
    input load_shift, en_shift, iz_shift, load_rnd,
    input [5:0] inp_shift,
    output co,
    output [($clog2(NUM_REP+1)-1):0] out_counter,
    output [5:0] out_shift,
    output [1:0] out_rnd
);

	localparam CNT_WIDTH = $clog2(NUM_REP + 1);
    localparam [CNT_WIDTH-1:0] PL_VAL = (1 << CNT_WIDTH) - NUM_REP;

	wire shift_input,out_xor_1bit_0;
	wire carry;
	Xor #(.WIDTH(1)) my_1bit_xor0(out_shift[5],out_shift[3],out_xor_1bit_0);
	Xor #(.WIDTH(1)) my_1bit_xor1(out_shift[1],out_xor_1bit_0,shift_input);

	Left_shift_register my_sh_reg(clk,rst,iz_shift,load_shift, en_shift, shift_input,inp_shift,out_shift);
	Register#(.WIDTH(2)) my_reg_rnd(clk, rst, load_rnd,out_shift[5:4] , out_rnd);
	Counter#(.WIDTH(CNT_WIDTH)) my_counter(clk,rst,en_c,iz_c,PL_VAL,out_counter,co,carry);
endmodule