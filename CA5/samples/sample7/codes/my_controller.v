module controller(
  input clk, rst, start,
  output reg op_ready,
  output reg [3:0] log1_sel1, log1_sel2,
  output reg [3:0] log2_sel1, log2_sel2,
  output reg [3:0] mul1_sel1, mul1_sel2,
  output reg [1:0] log1_op,
  output reg [1:0] log2_op,
  output reg [1:0] mul1_op,
  output reg done_next, result_en,
  output reg reg_node2_en,
  output reg reg_node4_en,
  output reg reg_node6_en,
  output reg reg_node9_en,
  output reg reg_node10_en,
  output reg reg_node13_en,
  output reg reg_node14_en
);

reg [2:0] state, next_state;
localparam S_IDLE = 0;
localparam S_CYCLE_1 = 1;
localparam S_CYCLE_2 = 2;
localparam S_CYCLE_3 = 3;
localparam S_CYCLE_4 = 4;
localparam S_CYCLE_5 = 5;
localparam S_DONE = 6;

always @(posedge clk or posedge rst) begin
  if (rst) state <= S_IDLE;
  else state <= next_state;
end

always @(*) begin
  op_ready = 1'b0;
  next_state = state;
  log1_sel1 = 4'd0;
  log1_sel2 = 4'd0;
  log2_sel1 = 4'd0;
  log2_sel2 = 4'd0;
  mul1_sel1 = 4'd0;
  mul1_sel2 = 4'd0;
  log1_op = 2'b00;
  log2_op = 2'b00;
  mul1_op = 2'b00;
  result_en = 1'b0;
  done_next = 1'b0;
  reg_node2_en = 1'b0;
  reg_node4_en = 1'b0;
  reg_node6_en = 1'b0;
  reg_node9_en = 1'b0;
  reg_node10_en = 1'b0;
  reg_node13_en = 1'b0;
  reg_node14_en = 1'b0;

  case (state)
    S_IDLE: begin
      op_ready = 1'b1;
      if (start) next_state = S_CYCLE_1;
    end
    S_CYCLE_1: begin
      mul1_op = 2'b00;
      mul1_sel1 = 4'd0;
      mul1_sel2 = 4'd1;
      reg_node2_en = 1'b1;
      next_state = S_CYCLE_2;
    end
    S_CYCLE_2: begin
      mul1_op = 2'b00;
      mul1_sel1 = 4'd8;
      mul1_sel2 = 4'd2;
      reg_node4_en = 1'b1;
      next_state = S_CYCLE_3;
    end
    S_CYCLE_3: begin
      mul1_op = 2'b00;
      mul1_sel1 = 4'd9;
      mul1_sel2 = 4'd3;
      reg_node6_en = 1'b1;
      log1_op = 2'b00;
      log1_sel1 = 4'd4;
      log1_sel2 = 4'd5;
      reg_node9_en = 1'b1;
      next_state = S_CYCLE_4;
    end
    S_CYCLE_4: begin
      log2_op = 2'b01;
      log2_sel1 = 4'd10;
      log2_sel2 = 4'd11;
      reg_node10_en = 1'b1;
      log1_op = 2'b00;
      log1_sel1 = 4'd6;
      log1_sel2 = 4'd7;
      reg_node13_en = 1'b1;
      next_state = S_CYCLE_5;
    end
    S_CYCLE_5: begin
      log1_op = 2'b01;
      log1_sel1 = 4'd12;
      log1_sel2 = 4'd13;
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