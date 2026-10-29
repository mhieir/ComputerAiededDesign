module Counter #(
    parameter WIDTH = 3
)(
    input   clk,
    input                   rst,
    input                   en,
    input                   iz,
    input   [WIDTH-1:0]     pl,
    output reg [WIDTH-1:0]     out,
    output                  co,
    output                  co2
);
    reg [WIDTH:0] cnt;
    assign out = cnt[WIDTH-1:0];
    assign co  = &out;
    assign co2 = cnt[WIDTH];

    always @(posedge clk , posedge rst) begin
        if (rst) begin
            cnt <= {(WIDTH+1){1'b0}};
        end else if (iz) begin
            cnt <= {1'b0, pl};
        end else if (en) begin
            cnt <= cnt + 1'b1;
        end
    end
endmodule
