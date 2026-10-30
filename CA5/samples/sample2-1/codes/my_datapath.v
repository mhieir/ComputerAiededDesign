module datapath(
  input clk, rst,
  input [31:0] i1,
  input [31:0] i2,
  input [31:0] i3,
  input [31:0] i4,
  input [31:0] i5,
  input [31:0] i6,
  input [31:0] i7,
  input [31:0] i8,
  input [3:0] alu1_sel1,
  input [3:0] alu1_sel2,
  input [3:0] mul1_sel1,
  input [3:0] mul1_sel2,
  input alu1_op,
  input [1:0] mul1_op,
  input done_next,
  input result_en,
  input reg_node2_en,
  input reg_node4_en,
  input reg_node6_en,
  input reg_node9_en,
  input reg_node11_en,
  input reg_node13_en,
  input reg_node14_en,
  output reg [31:0] result,
  output reg done
);

reg [31:0] reg_node2;
reg [31:0] reg_node4;
reg [31:0] reg_node6;
reg [31:0] reg_node9;
reg [31:0] reg_node11;
reg [31:0] reg_node13;
reg [31:0] reg_node14;

reg [31:0] alu1_op1_reg;
reg [31:0] alu1_op2_reg;

always @(*) begin
  case (alu1_sel1)
    4'd0: alu1_op1_reg = i1;
    4'd1: alu1_op1_reg = i2;
    4'd2: alu1_op1_reg = i3;
    4'd3: alu1_op1_reg = i4;
    4'd4: alu1_op1_reg = i5;
    4'd5: alu1_op1_reg = i6;
    4'd6: alu1_op1_reg = i7;
    4'd7: alu1_op1_reg = i8;
    4'd8: alu1_op1_reg = reg_node2;
    4'd9: alu1_op1_reg = reg_node4;
    4'd10: alu1_op1_reg = reg_node6;
    4'd11: alu1_op1_reg = reg_node9;
    4'd12: alu1_op1_reg = reg_node11;
    4'd13: alu1_op1_reg = reg_node13;
    4'd14: alu1_op1_reg = reg_node14;
    default: alu1_op1_reg = 32'd0;
  endcase
end

always @(*) begin
  case (alu1_sel2)
    4'd0: alu1_op2_reg = i1;
    4'd1: alu1_op2_reg = i2;
    4'd2: alu1_op2_reg = i3;
    4'd3: alu1_op2_reg = i4;
    4'd4: alu1_op2_reg = i5;
    4'd5: alu1_op2_reg = i6;
    4'd6: alu1_op2_reg = i7;
    4'd7: alu1_op2_reg = i8;
    4'd8: alu1_op2_reg = reg_node2;
    4'd9: alu1_op2_reg = reg_node4;
    4'd10: alu1_op2_reg = reg_node6;
    4'd11: alu1_op2_reg = reg_node9;
    4'd12: alu1_op2_reg = reg_node11;
    4'd13: alu1_op2_reg = reg_node13;
    4'd14: alu1_op2_reg = reg_node14;
    default: alu1_op2_reg = 32'd0;
  endcase
end

wire [31:0] alu1_op1 = alu1_op1_reg;
wire [31:0] alu1_op2 = alu1_op2_reg;
wire [31:0] alu1_out = (alu1_op == 1'b0) ? (alu1_op1 + alu1_op2) : (alu1_op1 - alu1_op2);

reg [31:0] mul1_op1_reg;
reg [31:0] mul1_op2_reg;

always @(*) begin
  case (mul1_sel1)
    4'd0: mul1_op1_reg = i1;
    4'd1: mul1_op1_reg = i2;
    4'd2: mul1_op1_reg = i3;
    4'd3: mul1_op1_reg = i4;
    4'd4: mul1_op1_reg = i5;
    4'd5: mul1_op1_reg = i6;
    4'd6: mul1_op1_reg = i7;
    4'd7: mul1_op1_reg = i8;
    4'd8: mul1_op1_reg = reg_node2;
    4'd9: mul1_op1_reg = reg_node4;
    4'd10: mul1_op1_reg = reg_node6;
    4'd11: mul1_op1_reg = reg_node9;
    4'd12: mul1_op1_reg = reg_node11;
    4'd13: mul1_op1_reg = reg_node13;
    4'd14: mul1_op1_reg = reg_node14;
    default: mul1_op1_reg = 32'd0;
  endcase
end

always @(*) begin
  case (mul1_sel2)
    4'd0: mul1_op2_reg = i1;
    4'd1: mul1_op2_reg = i2;
    4'd2: mul1_op2_reg = i3;
    4'd3: mul1_op2_reg = i4;
    4'd4: mul1_op2_reg = i5;
    4'd5: mul1_op2_reg = i6;
    4'd6: mul1_op2_reg = i7;
    4'd7: mul1_op2_reg = i8;
    4'd8: mul1_op2_reg = reg_node2;
    4'd9: mul1_op2_reg = reg_node4;
    4'd10: mul1_op2_reg = reg_node6;
    4'd11: mul1_op2_reg = reg_node9;
    4'd12: mul1_op2_reg = reg_node11;
    4'd13: mul1_op2_reg = reg_node13;
    4'd14: mul1_op2_reg = reg_node14;
    default: mul1_op2_reg = 32'd0;
  endcase
end

wire [31:0] mul1_op1 = mul1_op1_reg;
wire [31:0] mul1_op2 = mul1_op2_reg;
wire [31:0] mul1_out = (mul1_op == 2'b00) ? (mul1_op1 * mul1_op2) : (mul1_op == 2'b01) ? (mul1_op1 / mul1_op2) : (mul1_op == 2'b10) ? (mul1_op1 % mul1_op2) : 32'd0;

always @(posedge clk or posedge rst) begin
  if (rst) begin
    reg_node2 <= 32'd0;
    reg_node4 <= 32'd0;
    reg_node6 <= 32'd0;
    reg_node9 <= 32'd0;
    reg_node11 <= 32'd0;
    reg_node13 <= 32'd0;
    reg_node14 <= 32'd0;
    result <= 32'd0;
    done <= 1'b0;
  end else begin
    done <= done_next;
    if (reg_node2_en) reg_node2 <= mul1_out;
    if (reg_node4_en) reg_node4 <= mul1_out;
    if (reg_node6_en) reg_node6 <= mul1_out;
    if (reg_node9_en) reg_node9 <= mul1_out;
    if (reg_node11_en) reg_node11 <= mul1_out;
    if (reg_node13_en) reg_node13 <= mul1_out;
    if (reg_node14_en) reg_node14 <= alu1_out;
    if (result_en) result <= alu1_out;
  end
end
endmodule