module top(
  input clk,
  input rst,
  input start,
  input [31:0] i1,
  input [31:0] i2,
  input [31:0] i3,
  input [31:0] i4,
  input [31:0] i5,
  input [31:0] i6,
  input [31:0] i7,
  input [31:0] i8,
  output [31:0] result,
  output done
);

  wire op_ready;
  wire done_next;
  wire result_en;

  wire [3:0] alu1_sel1;
  wire [3:0] alu1_sel2;
  wire [3:0] log1_sel1;
  wire [3:0] log1_sel2;
  wire [3:0] mul1_sel1;
  wire [3:0] mul1_sel2;

  wire alu1_op;
  wire [1:0] log1_op;
  wire [1:0] mul1_op;

  wire reg_node2_en;
  wire reg_node5_en;
  wire reg_node6_en;
  wire reg_node9_en;
  wire reg_node12_en;
  wire reg_node13_en;
  wire reg_node14_en;

  controller u_controller (
    .clk(clk),
    .rst(rst),
    .start(start),
    .op_ready(op_ready),
    .alu1_sel1(alu1_sel1),
    .alu1_sel2(alu1_sel2),
    .log1_sel1(log1_sel1),
    .log1_sel2(log1_sel2),
    .mul1_sel1(mul1_sel1),
    .mul1_sel2(mul1_sel2),
    .alu1_op(alu1_op),
    .log1_op(log1_op),
    .mul1_op(mul1_op),
    .done_next(done_next),
    .result_en(result_en),
    .reg_node2_en(reg_node2_en),
    .reg_node5_en(reg_node5_en),
    .reg_node6_en(reg_node6_en),
    .reg_node9_en(reg_node9_en),
    .reg_node12_en(reg_node12_en),
    .reg_node13_en(reg_node13_en),
    .reg_node14_en(reg_node14_en)
  );

  datapath u_datapath (
    .clk(clk),
    .rst(rst),
    .i1(i1),
    .i2(i2),
    .i3(i3),
    .i4(i4),
    .i5(i5),
    .i6(i6),
    .i7(i7),
    .i8(i8),
    .alu1_sel1(alu1_sel1),
    .alu1_sel2(alu1_sel2),
    .log1_sel1(log1_sel1),
    .log1_sel2(log1_sel2),
    .mul1_sel1(mul1_sel1),
    .mul1_sel2(mul1_sel2),
    .alu1_op(alu1_op),
    .log1_op(log1_op),
    .mul1_op(mul1_op),
    .done_next(done_next),
    .result_en(result_en),
    .reg_node2_en(reg_node2_en),
    .reg_node5_en(reg_node5_en),
    .reg_node6_en(reg_node6_en),
    .reg_node9_en(reg_node9_en),
    .reg_node12_en(reg_node12_en),
    .reg_node13_en(reg_node13_en),
    .reg_node14_en(reg_node14_en),
    .result(result),
    .done(done)
  );

endmodule