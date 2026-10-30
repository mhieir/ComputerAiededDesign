module Register #(
    parameter WIDTH = 32 
)(
    input clk,  
    input rst,
    input en,
    input [WIDTH-1:0]inp,
    output reg  [WIDTH-1:0]out    
);

    always @(posedge clk, posedge rst) begin
        if (rst)
            out <= {WIDTH{1'b0}};
        else if (en)
            out <= inp;
    end

endmodule

