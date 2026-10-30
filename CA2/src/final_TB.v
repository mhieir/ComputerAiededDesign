`timescale 1ns/1ps

module tb_Top_StripesSystem;

    parameter WORD_WIDTH = 34;

    reg clk, rst, start;
    wire done;
    wire [WORD_WIDTH-1:0] out_multiple;
    Top_StripesSystem uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .out_multiple(out_multiple),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer i;

    initial begin
        $dumpfile("tb_Top_StripesSystem.vcd");
        $dumpvars(0, tb_Top_StripesSystem);

        $display("====================================================");
        $display("     MATRIX-VECTOR MULTIPLICATION TEST (8x8 * 8x1)  ");
        $display("====================================================");
        rst = 1;
        start = 0;
        #20 rst = 0;
        #20 start = 1;
        #10 start = 0;
        wait(done == 1);
        #20;
        $display("✅ Computation Done at time %0t", $time);
        $display("Reading 8 output results from memory (addr 72–79):");
        for (i = 72; i < 80; i = i + 1) begin
            $display("mem[%0d] = %0d", i, $signed(uut.datapath_inst.mem_inst.mem[i]));
        end
        $display("====================================================");
        $display("                TEST COMPLETE                       ");
        $display("====================================================");
        #50 $finish;
    end
endmodule