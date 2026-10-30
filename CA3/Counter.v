module Counter
#(parameter WIDTH = 6)
(
    input clk,
    input rst,
    input en,
    input iz,
    input [WIDTH-1:0] pl,
    output [WIDTH-1:0] out,
    output co,
    output co2
);

    wire [WIDTH-1:0] carry;
    wire [WIDTH-1:0] not_out;
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_cnt
            NOT_1bit inv_inst (.a(out[i]), .out(not_out[i]));
            if (i == 0) begin
                assign carry[i] = out[i];
            end else begin
                AND_1bit and_inst (.a(out[i]), .b(carry[i-1]), .out(carry[i]));
            end

            s2 my_s2 (
                .D00 (out[i]),
                .D01 (not_out[i]),
                .D10 (pl[i]),
                .D11 (pl[i]),          
                .A1  (iz),            
                .B1  (1'b0),
                .A0  (en),
                .B0  (i == 0 ? 1'b1 : carry[i-1]),
                .clr (rst),
                .clk (clk),
                .out (out[i])
            );
        end
    endgenerate

    assign co = carry[WIDTH-1];

    wire not_co2;
    NOT_1bit inv_co2 (.a(co2), .out(not_co2));

    s2 msb_cell (
        .D00 (co2),    
        .D01 (not_co2), 
        .D10 (1'b0),    
        .D11 (1'b0),     
        .A1  (iz),
        .B1  (1'b0),
        .A0  (en),
        .B0  (co),
        .clr (rst),
        .clk (clk),
        .out (co2)
    );

endmodule