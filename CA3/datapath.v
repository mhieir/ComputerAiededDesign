module Datapath_hash
#(
    parameter WIDTH = 8,
    parameter NUM_WORDS = 4,
    parameter ITER = 64
)
(
    input clk, rst,
    input iz_i, en_i,
    input sel_A, sel_B, sel_C, sel_D,
    input load_A, load_B, load_C, load_D,
    input sel_F, load_F,
    input load_M,
    input start_rnd,
    input [1:0] sel_sum0, sel_sum1,
    input load_sum,
    input [1:0] rnd,
    input [(NUM_WORDS * WIDTH) - 1 : 0] message,
    output co_i,
    output [(NUM_WORDS * WIDTH) - 1 : 0] digest,
    output [($clog2(ITER)-1):0] i
);

    localparam I_WIDTH = $clog2(ITER);

    wire [WIDTH-1:0] inp_A, inp_B, inp_C, inp_D;
    wire [WIDTH-1:0] A, B, C, D;
    wire [WIDTH-1:0] out_sum;
    wire [1:0] sel_i;
    wire [WIDTH-1:0] out_i;
    wire [WIDTH-1:0] constant_i;
    wire [WIDTH-1:0] mult_result; 
    wire [7:0] mult_out_raw;      
    wire [WIDTH-1:0] F;
    wire [WIDTH-1:0] inp_F;
    wire [(NUM_WORDS * WIDTH) - 1 : 0] M;
    wire [WIDTH-1:0] M_rnd;
    wire [WIDTH-1:0] inp_sum_0, inp_sum_1, inp_sum;

    localparam [WIDTH-1:0] a0 = {{ (WIDTH-8){1'b0}}, 8'b00000001};
    localparam [WIDTH-1:0] b0 = {{ (WIDTH-8){1'b0}}, 8'b10001001};
    localparam [WIDTH-1:0] c0 = {{ (WIDTH-8){1'b0}}, 8'b11111110};
    localparam [WIDTH-1:0] d0 = {{ (WIDTH-8){1'b0}}, 8'b01110110};

    Register_Merged_MUX #(.WIDTH(WIDTH)) opt_reg_A (.clk(clk), .rst(rst), .load(load_A), .sel(sel_A), .val_0(a0), .val_1(D), .out(A));
    Register_Merged_MUX #(.WIDTH(WIDTH)) opt_reg_B (.clk(clk), .rst(rst), .load(load_B), .sel(sel_B), .val_0(b0), .val_1(out_sum), .out(B));
    Register_Merged_MUX #(.WIDTH(WIDTH)) opt_reg_C (.clk(clk), .rst(rst), .load(load_C), .sel(sel_C), .val_0(c0), .val_1(B), .out(C));
    Register_Merged_MUX #(.WIDTH(WIDTH)) opt_reg_D (.clk(clk), .rst(rst), .load(load_D), .sel(sel_D), .val_0(d0), .val_1(C), .out(D));

    Register_Merged_MUX #(.WIDTH(WIDTH)) opt_reg_F (.clk(clk), .rst(rst), .load(load_F), .sel(sel_F), .val_0(out_i), .val_1(out_sum), .out(F));

    wire [WIDTH-1:0] func_round1, func_round2, func_round3, func_round4;

    MUX2to1_Bitwise #(.WIDTH(WIDTH)) opt_mux_r1 (.a(D), .b(C), .sel(B), .out(func_round1));
    MUX2to1_Bitwise #(.WIDTH(WIDTH)) opt_mux_r2 (.a(C), .b(B), .sel(D), .out(func_round2));
    
    wire [WIDTH-1:0] xor_BC, not_D, or_B_notD;
    XOR #(.WIDTH(WIDTH)) calc_xor1 (B, C, xor_BC);
    XOR #(.WIDTH(WIDTH)) calc_xor2 (xor_BC, D, func_round3);
    
    NOT #(.WIDTH(WIDTH)) calc_notD (D, not_D);
    OR  #(.WIDTH(WIDTH)) calc_or   (B, not_D, or_B_notD);
    XOR #(.WIDTH(WIDTH)) calc_xor3 (C, or_B_notD, func_round4);

    MUX4to1 #(.WIDTH(WIDTH)) final_mux (
        .a(func_round1), .b(func_round2), .c(func_round3), .d(func_round4), 
        .sel0(sel_i[0]), .sel1(sel_i[1]), .out(out_i)
    );

    wire co_i_s;

    Counter #(.WIDTH(I_WIDTH)) my_counter_i (
        .clk(clk), 
        .rst(rst), 
        .en(en_i), 
        .iz(iz_i), 
        .pl({I_WIDTH{1'b0}}), 
        .out(i), 
        .co(co_i_s),
        .co2(co_i)
    );

    assign sel_i = i[I_WIDTH-1 : I_WIDTH-2];
    
    Rom_file #(.ADDR_WIDTH(6), .DATA_WIDTH(WIDTH), .ROM_FILE("k.mem")) my_constant_rom(i[5:0], constant_i);

    Multiplier_4bit my_mult_unit (
        .a(F[(WIDTH/2)-1 : 0]), 
        .b(F[WIDTH-1 : (WIDTH/2)]), 
        .out(mult_out_raw)
    );
    assign mult_result = {{ (WIDTH-8){1'b0}}, mult_out_raw };

    MUX2to1 #(.WIDTH(WIDTH)) my_mux_F(out_i, out_sum, sel_F, inp_F);
    Register #(.WIDTH(WIDTH)) my_reg_F(clk, rst, load_F, inp_F, F);

    Register #(.WIDTH(NUM_WORDS * WIDTH)) my_reg_M(clk, rst, load_M, message, M);

    MUX4to1 #(.WIDTH(WIDTH)) my_mux_M(
        .a(M[ (4*WIDTH)-1 : 3*WIDTH ]), 
        .b(M[ (3*WIDTH)-1 : 2*WIDTH ]), 
        .c(M[ (2*WIDTH)-1 : 1*WIDTH ]), 
        .d(M[ (1*WIDTH)-1 : 0 ]),       
        .sel0(rnd[0]), 
        .sel1(rnd[1]), 
        .out(M_rnd)
    );

    MUX4to1 #(.WIDTH(WIDTH)) my_mux_sum0(constant_i, M_rnd, B, A, sel_sum0[0], sel_sum0[1], inp_sum_0);
    MUX3to1 #(.N(WIDTH)) my_mux_sum1(mult_result, F, out_sum, sel_sum1[0], sel_sum1[1], inp_sum_1);
    
    wire temp_carry;
    Adder #(.N(WIDTH)) my_adder(inp_sum_0, inp_sum_1, 1'b0, inp_sum, temp_carry);
    
    Register #(.WIDTH(WIDTH)) my_reg_Sum(clk, rst, load_sum, inp_sum, out_sum);

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

    wire shift_input, out_xor_1bit_0;
    wire co_unused;

    XOR_1bit my_1bit_xor0(out_shift[5], out_shift[3], out_xor_1bit_0);
    XOR_1bit my_1bit_xor1(out_shift[1], out_xor_1bit_0, shift_input);

    Left_shift_register my_sh_reg (
        .clk(clk),
        .rst(rst),
        .iz(iz_shift),     
        .en_shift(en_shift),
        .shift_input(shift_input),
        .pl(inp_shift),
        .load_val(load_shift), 
        .out(out_shift)
    );

    Register #(.WIDTH(2)) my_reg_rnd(clk, rst, load_rnd, out_shift[5:4], out_rnd);

    Counter #(.WIDTH(CNT_WIDTH)) my_counter (
        .clk(clk),
        .rst(rst),
        .en(en_c),
        .iz(iz_c),
        .pl(PL_VAL),
        .out(out_counter),
        .co(co),
        .co2(co_unused)
    );

endmodule