module Top
#(
    parameter WIDTH = 8,
    parameter NUM_WORDS = 4,
    parameter ITER = 64,
    parameter NUM_REP = 6
)
(
    input clk, rst, start,
    input [(NUM_WORDS * WIDTH) - 1 : 0] message,
    output [(NUM_WORDS * WIDTH) - 1 : 0] digest,
    output done
);

    wire start_rnd, done_rnd;
    wire [($clog2(ITER)-1):0] i;
    wire [1:0] out_rnd;

    Rnd_gen #(.NUM_REP(NUM_REP)) my_rnd_gen (
        .clk(clk),
        .rst(rst),
        .start_rnd(start_rnd),
        .input_number(i),
        .done_rnd(done_rnd),
        .out_rnd(out_rnd)
    );

    Hash #(
        .WIDTH(WIDTH),
        .NUM_WORDS(NUM_WORDS),
        .ITER(ITER)
    ) my_hash (
        .clk(clk),
        .rst(rst),
        .start(start),
        .message(message),
        .done_rnd(done_rnd),
        .rnd(out_rnd),
        .digest(digest),
        .start_rnd(start_rnd),
        .done(done),
        .i(i)
    );

endmodule


module Rnd_gen
#(
    parameter NUM_REP = 6
)
(
    input clk, rst, start_rnd,
    input [($clog2(64)-1):0] input_number,
    output done_rnd,
    output [1:0] out_rnd
);

    localparam CNT_WIDTH = $clog2(NUM_REP + 1);
    wire iz_c, en_c, load_shift, en_shift, iz_shift, co, load_rnd;
    wire [CNT_WIDTH-1:0] out_counter;
    wire [5:0] out_shift;

    Datapath_rnd_gen #(.NUM_REP(NUM_REP)) my_datapath_rnd_gen (
        .clk(clk),
        .rst(rst),
        .iz_c(iz_c),
        .en_c(en_c),
        .load_shift(load_shift),
        .en_shift(en_shift),
        .iz_shift(iz_shift),
        .load_rnd(load_rnd),
        .inp_shift(input_number[5:0]),
        .co(co),
        .out_counter(out_counter),
        .out_shift(out_shift),
        .out_rnd(out_rnd)
    );

    Controller_rnd_gen my_controller_rnd_gen (
        .clk(clk),
        .rst(rst),
        .start_rnd(start_rnd),
        .co(co),
        .iz_shift(iz_shift),
        .load_shift(load_shift),
        .iz_c(iz_c),
        .en_c(en_c),
        .en_shift(en_shift),
        .done_rnd(done_rnd),
        .load_rnd(load_rnd)
    );

endmodule


module Hash
#(
    parameter WIDTH = 8,
    parameter NUM_WORDS = 4,
    parameter ITER = 64
)
(
    input clk, rst, start, 
    input [(NUM_WORDS * WIDTH) - 1 : 0] message,
    input done_rnd,
    input [1:0] rnd,
    output [(NUM_WORDS * WIDTH) - 1 : 0] digest,
    output start_rnd,
    output done,
    output [($clog2(ITER)-1):0] i
);

    wire iz_i, sel_A, sel_B, sel_C, sel_D, load_A, load_B, load_C, load_D, load_M;
    wire sel_F, load_F, load_sum, en_i;
    wire [1:0] sel_sum0, sel_sum1;
    wire co_i;

    Controller_hash my_controller_hash (
        .clk(clk), .rst(rst), .start(start), .co_i(co_i), .done_rnd(done_rnd), 
        .iz_i(iz_i), .sel_A(sel_A), .sel_B(sel_B), .sel_C(sel_C), .sel_D(sel_D), 
        .load_A(load_A), .load_B(load_B), .load_C(load_C), .load_D(load_D),
        .load_M(load_M), .sel_F(sel_F), .load_F(load_F), .start_rnd(start_rnd), 
        .load_sum(load_sum), .en_i(en_i), .done(done), .sel_sum0(sel_sum0), .sel_sum1(sel_sum1)
    );

    Datapath_hash #(
        .WIDTH(WIDTH), 
        .NUM_WORDS(NUM_WORDS), 
        .ITER(ITER)
    ) my_datapath_hash (
        .clk(clk), .rst(rst), .iz_i(iz_i), .en_i(en_i), 
        .sel_A(sel_A), .sel_B(sel_B), .sel_C(sel_C), .sel_D(sel_D), 
        .load_A(load_A), .load_B(load_B), .load_C(load_C), .load_D(load_D),
        .sel_F(sel_F), .load_F(load_F), .load_M(load_M), .start_rnd(start_rnd), 
        .sel_sum0(sel_sum0), .sel_sum1(sel_sum1), .load_sum(load_sum), 
        .rnd(rnd), .message(message), .co_i(co_i), .digest(digest), .i(i)
    );

endmodule
