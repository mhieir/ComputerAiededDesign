// module Counter #(
//     parameter WIDTH = 3
// )(
//     input clk,
//     input rst,
//     input en,
//     input iz,
//     input [WIDTH-1:0]  pl,
//     output reg  [WIDTH-1:0]  out,
//     output co
// );
//     assign co = &out;

//     always @(posedge clk,posedge rst) begin
//         if (rst) begin
//             out <= {WIDTH{1'b0}};
//         end else if (iz) begin
//             out <= pl;
//         end else if (en) begin
//             out <= out + 1'b1;
//         end
//     end

// endmodule
module Counter #(
    parameter WIDTH = 3
)(
    input   clk,
    input                   rst,
    input                   en,
    input                   iz,
    input   [WIDTH-1:0]     pl,
    output reg [WIDTH-1:0]     out,
    output                  co,   // all-ones on out
    output                  co2   // the next-stage bit (MSB of internal counter)
);
    // (WIDTH+1)-bit internal counter
    reg [WIDTH:0] cnt;

    // Outputs
    assign out = cnt[WIDTH-1:0];
    assign co  = &out;
    assign co2 = cnt[WIDTH];

    always @(posedge clk , posedge rst) begin
        if (rst) begin
            cnt <= {(WIDTH+1){1'b0}};
        end else if (iz) begin
            cnt <= {1'b0, pl};              // load low bits; clear next-stage bit
        end else if (en) begin
            cnt <= cnt + 1'b1;              // increments naturally, MSB flips on wrap
        end
    end
endmodule
