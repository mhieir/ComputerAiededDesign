module Rnd_gen(input clk, rst, start_rnd, input[5:0] input_number, output done_rnd,output [1:0] out_rnd);
    wire iz_c, en_c, load_shift,en_shift,iz_shift,co,load_rnd;
    wire[2:0] out_counter;
    wire[5:0] out_shift;
    Datapath_rnd_gen my_datapath_rnd_gen(clk, rst, iz_c, en_c, load_shift, en_shift, iz_shift,load_rnd, input_number, co, out_counter, out_shift,out_rnd);
    Controller_rnd_gen my_controller_rnd_gen(clk, rst, start_rnd, co, iz_shift, load_shift, iz_c, en_c, en_shift, done_rnd,load_rnd);

endmodule

module Hash(input clk, rst, start, input[127:0] message,input done_rnd,input[1:0] rnd,
                      output[127:0] digest,output start_rnd ,output done,output [5:0] i);

    wire iz_i, sel_A, sel_B, sel_C, sel_D, load_A, load_B, load_C, load_D, load_M;
    wire sel_F, load_F, load_sum, en_i;
    wire[1:0] sel_sum0, sel_sum1;
    wire co_i;
    Controller_hash my_controller_hash(clk, rst, start, co_i, done_rnd, iz_i, sel_A, sel_B, sel_C, sel_D, load_A, load_B, load_C, load_D,
                                      load_M, sel_F, load_F, start_rnd, load_sum, en_i, done, sel_sum0, sel_sum1);

    Datapath_hash my_datapath_hash(clk, rst, iz_i, en_i, sel_A, sel_B, sel_C, sel_D, load_A, load_B, load_C, load_D,
                                  sel_F, load_F, load_M, start_rnd, sel_sum0, sel_sum1, load_sum, rnd, message, co_i, digest,i);

endmodule


module Hash_Generator(input clk, rst, start, input[127:0] message,
                    output[127:0] digest, output done);

    wire start_rnd, done_rnd;
    wire [5:0] i;
    wire[1:0] out_rnd;
    Rnd_gen my_rnd_gen(clk, rst, start_rnd, i, done_rnd,out_rnd);
    Hash my_hash(clk, rst, start, message,done_rnd,out_rnd, digest,start_rnd, done,i);
endmodule