module MultiplicationProcessing #(
    parameter WORD_WIDTH = 34,
    parameter DEPTH = 128,
    parameter ADDR_WIDTH = 7,
    parameter MP = 16,
    parameter W = 16
)(
    input clk,
    input rst,
    input start,
    input [WORD_WIDTH-1:0] r_data,
    output [ADDR_WIDTH-1:0] address,
    output [WORD_WIDTH-1:0] w_data,
    output write,
    output done
);

    wire en_A, en_B, en_P, en_ans, en_decoder_a, en_decoder_b;
    wire iz_A, iz_B, iz_P, iz_ans;
    wire co_A, co_B, co_P, co_ans;
    wire [2:0] out_counter_A, out_counter_B, out_counter_P, out_counter_ans;
    wire shift_B, i_is_msb, i_is_lsb, i_valid;

    DataPathMultiProc #(.WORD_WIDTH(WORD_WIDTH), .MP(MP), .ADDR_WIDTH(ADDR_WIDTH), .W(W)) my_data_path_multi
                    (clk, rst, en_decoder_a, en_decoder_b, en_ans, iz_ans, co_ans, en_A, iz_A, co_A,
                    en_B, iz_B, co_B, en_P, iz_P, co_P, r_data, shift_B,
                    address, write, i_is_lsb, i_is_msb, i_valid, w_data);

    Controller my_controller(clk, rst, start, co_A, co_B, co_P, co_ans,
                            en_A, en_B, en_P, en_ans, iz_A, iz_B, iz_P,
                            iz_ans, i_is_msb, i_is_lsb, i_valid, shift_B,
                            write, en_decoder_a, en_decoder_b, done);

endmodule