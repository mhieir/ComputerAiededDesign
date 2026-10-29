module controller(
  input clk, rst, start,
  output reg op_ready,
  output reg [3:0] alu1_sel1, alu1_sel2,
  output reg [3:0] log1_sel1, log1_sel2,
  output reg [3:0] log2_sel1, log2_sel2,
  output reg [3:0] mul1_sel1, mul1_sel2,
  output reg alu1_op,
  output reg [1:0] log1_op,
  output reg [1:0] log2_op,
  output reg [1:0] mul1_op,
  output reg done_next, result_en,
  output reg reg_node2_en,
  output reg reg_node5_en,
  output reg reg_node6_en,
  output reg reg_node9_en,
  output reg reg_node12_en,
  output reg reg_node13_en,
  output reg reg_node14_en
);

reg [2:0] state, next_state;
localparam S_IDLE = 0;
localparam S_CYCLE_1 = 1;
localparam S_CYCLE_2 = 2;
localparam S_CYCLE_3 = 3;
localparam S_CYCLE_4 = 4;
localparam S_DONE = 5;

always @(posedge clk or posedge rst) begin
  if (rst) state <= S_IDLE;
  else state <= next_state;
end

always @(*) begin
  op_ready = 1'b0;
  next_state = state;
  alu1_sel1 = 4'd0;
  alu1_sel2 = 4'd0;
  log1_sel1 = 4'd0;
  log1_sel2 = 4'd0;
  log2_sel1 = 4'd0;
  log2_sel2 = 4'd0;
  mul1_sel1 = 4'd0;
  mul1_sel2 = 4'd0;
  alu1_op = 1'b0;
  log1_op = 2'b00;
  log2_op = 2'b00;
  mul1_op = 2'b00;
  result_en = 1'b0;
  done_next = 1'b0;
  reg_node2_en = 1'b0;
  reg_node5_en = 1'b0;
  reg_node6_en = 1'b0;
  reg_node9_en = 1'b0;
  reg_node12_en = 1'b0;
  reg_node13_en = 1'b0;
  reg_node14_en = 1'b0;

  case (state)
    S_IDLE: begin
      op_ready = 1'b1;
      if (start) next_state = S_CYCLE_1;
    end
    S_CYCLE_1: begin
      log1_op = 2'b00;
      log1_sel1 = 4'd0;
      log1_sel2 = 4'd1;
      reg_node2_en = 1'b1;
      log2_op = 2'b00;
      log2_sel1 = 4'd2;
      log2_sel2 = 4'd3;
      reg_node5_en = 1'b1;
      next_state = S_CYCLE_2;
    end
    S_CYCLE_2: begin
      alu1_op = 1'b0;
      alu1_sel1 = 4'd8;
      alu1_sel2 = 4'd9;
      reg_node6_en = 1'b1;
      log1_op = 2'b00;
      log1_sel1 = 4'd4;
      log1_sel2 = 4'd5;
      reg_node9_en = 1'b1;
      log2_op = 2'b00;
      log2_sel1 = 4'd6;
      log2_sel2 = 4'd7;
      reg_node12_en = 1'b1;
      next_state = S_CYCLE_3;
    end
    S_CYCLE_3: begin
      alu1_op = 1'b0;
      alu1_sel1 = 4'd11;
      alu1_sel2 = 4'd12;
      reg_node13_en = 1'b1;
      next_state = S_CYCLE_4;
    end
    S_CYCLE_4: begin
      mul1_op = 2'b00;
      mul1_sel1 = 4'd10;
      mul1_sel2 = 4'd13;
      reg_node14_en = 1'b1;
      result_en = 1'b1;
      next_state = S_DONE;
    end
    S_DONE: begin
      done_next = 1'b1;
      next_state = S_IDLE;
    end
  endcase
end
endmodule