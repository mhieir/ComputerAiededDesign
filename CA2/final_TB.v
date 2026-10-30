`timescale 1ns/1ns

module tb_Top_StripesSystem;

    parameter MP = 16;
    parameter W = 16;
    parameter WORD_WIDTH = 34;
    parameter DEPTH = 128;
    parameter ADDR_WIDTH = 7;
    parameter MEM_FILE = "memory_init.txt";

    reg clk, rst, start;
    wire done;

    Multiplier #(.MP(MP), .W(W), .WORD_WIDTH(WORD_WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(ADDR_WIDTH), .MEM_FILE(MEM_FILE)) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        rst = 1;
        start = 0;
        #20 rst = 0;
        #20 start = 1;
        #10 start = 0;
        wait(done == 1);
        #20;
        #50 $finish;
    end
endmodule