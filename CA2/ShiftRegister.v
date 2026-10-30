module ShiftRegister #(
    parameter WIDTH = 8
)(
    input clk,
    input rst,
    input shift,
    input en,
    input [WIDTH-1:0] r_data,
    output out
);
    reg [WIDTH-1:0] reg_data;
    
    always @(posedge clk, posedge rst) begin
        if (rst) reg_data <= {WIDTH{1'b0}};
        else if (en) reg_data <= r_data;
        else if (shift) reg_data <= {reg_data[WIDTH-2:0], reg_data[WIDTH-1]};
        else reg_data <= reg_data;
    end
    assign out = reg_data[WIDTH-1];
endmodule
