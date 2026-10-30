`timescale 1ns/1ns
module tb;
  reg clk, rst, start;
  reg [31:0] i1;
  reg [31:0] i2;
  reg [31:0] i3;
  reg [31:0] i4;
  reg [31:0] i5;
  reg [31:0] i6;
  reg [31:0] i7;
  wire [31:0] result;
  wire done;

  top uut (
    .clk(clk), .rst(rst), .start(start),
    .i1(i1),
    .i2(i2),
    .i3(i3),
    .i4(i4),
    .i5(i5),
    .i6(i6),
    .i7(i7),
    .result(result), .done(done)
  );
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  initial begin
    rst = 1; start = 0;
    i1 = 32'd10;
    i2 = 32'd20;
    i3 = 32'd30;
    i4 = 32'd40;
    i5 = 32'd50;
    i6 = 32'd60;
    i7 = 32'd70;
    #15 rst = 0;
    #10 start = 1;
    #10 start = 0;
    wait(done == 1);
    #20;
    $display("Simulation Finished. Result = %d", result);
    $stop;
  end
endmodule