module Multiplier #(
    parameter MP = 16,
    parameter W = 16,
    parameter WORD_WIDTH = 34,
    parameter DEPTH = 128,
    parameter ADDR_WIDTH = 7,
    parameter MEM_FILE = "memory_init.txt"
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
    Memory #(.WORD_WIDTH(WORD_WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(ADDR_WIDTH), .MEM_FILE(MEM_FILE)) my_memory(clk, rst, write, address, write_data, r_data);
    MultiplicationProcessing #(.WORD_WIDTH(WORD_WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(ADDR_WIDTH), .MP(MP), .W(W)) my_multiplication_processing(clk, rst, start, r_data, address, write_data, write, done);
    
endmodule