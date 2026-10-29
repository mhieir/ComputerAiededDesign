module Multiplier #(
    parameter MP = 16,
    parameter WORD_WIDTH = 34,
    parameter DEPTH = 128,
    parameter ADDR_WIDTH = 7
)(
    input clk,
    input rst,
    input start,
    output done
);
    wire write;
    wire [ADDR_WIDTH-1:0] address;
    wire [WORD_WIDTH-1:0] write_data;
    wire [WORD_WIDTH-1:0] r_data;
    Memory #(.WORD_WIDTH(34), .DEPTH(128), .ADDR_WIDTH(7)) my_memory(clk, rst, write, address, write_data, r_data);
    MultiplicationProcessing #(.WORD_WIDTH(34), .DEPTH(128), .ADDR_WIDTH(7)) my_multiplication_processing(clk, rst, start, r_data, address, w_data, write, done);
endmodule