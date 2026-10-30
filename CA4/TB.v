`timescale 1ns/1ns

module tb_Hash_Generator;

    reg clk;
    reg rst;
    reg start;
    reg [31:0] message;

    wire [31:0] digest;
    wire done;

    Top uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .message(message),
        .digest(digest),
        .done(done)
    );
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        message = 32'hdf01f0b7;
        #20;
        rst = 0;
        #10;
        start = 1;
        #10;
        start = 0;
	    #50;
        start = 1;
        #10;
        start = 0;
        wait (done == 1);
        $display("\nMessage Value: %08x", message);
        $display("\nDigest: %08x\n", digest);
        #50;
        $finish;
    end

endmodule
