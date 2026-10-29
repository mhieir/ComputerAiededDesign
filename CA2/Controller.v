module Controller (
    input clk,
    input rst,
    input start,
    input co_A,
    input co_B,
    input co_P,
    input co_ans,
    output reg en_A,
    output reg en_B,
    output reg en_P,
    output reg en_ans,
    output reg iz_A,
    output reg iz_B,
    output reg iz_P,
    output reg iz_ans,
    output reg i_is_msb,
    output reg i_is_lsb,
    output reg i_valid,
    output reg shift_B,
    output reg write,
    output reg en_decoder_a,
    output reg en_decoder_b,
    output reg done
);

    parameter IDLE = 4'd0,
              INIT = 4'd1,
              LOAD_A = 4'd2,
              LOAD_B = 4'd3,
              START_MUL = 4'd4,
              MUL = 4'd5,
              END_MUL = 4'd6,
              WRITING_IN_MEM = 4'd7,
              DONE_STATE = 4'd8;

    reg [3:0] ps, ns;

    always @(posedge clk, posedge rst) begin
        if (rst) ps <= IDLE;
        else ps <= ns;
    end

    always @(ps, start, co_A, co_P, co_ans, co_B) begin
        case (ps)
            IDLE: ns = start ? INIT : IDLE;
            INIT: ns = ~start ? LOAD_A : INIT;
            LOAD_A: ns = co_A ? LOAD_B : LOAD_A;
            LOAD_B: begin ns =
                co_ans ? DONE_STATE :
                co_B ? START_MUL : LOAD_B;
            end
            START_MUL: ns = MUL;
            MUL: ns = co_P ? END_MUL : MUL;
            END_MUL: ns = WRITING_IN_MEM;
            WRITING_IN_MEM : ns = LOAD_B;
            DONE_STATE: ns = IDLE;
            default: ns = IDLE;
        endcase
    end

    always @(ps) begin
        {en_A, en_B, en_P, en_ans, iz_A, iz_B, iz_P, iz_ans, i_is_msb, i_is_lsb, i_valid, shift_B, write, en_decoder_a,en_decoder_b, done} = 16'b0;

        case (ps)
            INIT: begin iz_A = 1'b1; iz_B = 1'b1; iz_P = 1'b1; iz_ans = 1'b1; end
            LOAD_A: begin en_A = 1'b1; en_decoder_a = 1'b1; end
            LOAD_B: begin en_B = 1'b1; iz_P = 1'b1; en_decoder_b = 1'b1; end
            START_MUL: begin i_is_msb = 1'b1; i_valid = 1'b1; shift_B = 1'b1; en_P = 1'b1; end
            MUL: begin shift_B  = 1'b1; en_P = 1'b1; i_valid = 1'b1; end
            END_MUL: begin i_is_lsb = 1'b1; end
            WRITING_IN_MEM: begin write = 1'b1; en_ans  = 1'b1; end
            DONE_STATE: begin done = 1'b1; end
        endcase
    end

endmodule
