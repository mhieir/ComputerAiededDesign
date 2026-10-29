
module Controller_rnd_gen(input clk, rst, start_rnd, co,
                        output reg iz_shift, load_shift, iz_c, en_c, en_shift, done_rnd,load_rnd);

    parameter idle = 2'b00, init = 2'b01, shifting = 2'b10, done = 2'b11;
    reg [1:0] ps, ns;

    always@(posedge clk, posedge rst) begin
        if(rst) ps <= idle;
        else ps <= ns;
    end

    always@(ps, start_rnd, co) begin
        case(ps)
            idle: ns = start_rnd ? init : idle;
            init: ns = shifting;
            shifting: ns = co ? done : shifting;
            done: ns = idle;
            default: ns = idle;
        endcase
    end

    always@(ps) begin
        {iz_shift, load_shift, iz_c, en_c, en_shift, done_rnd,load_rnd} = 7'b0000000;
        case(ps)
            idle: iz_shift = 1'b1;
            init: begin load_shift = 1'b1; iz_c = 1'b1; end
            shifting: begin en_c = 1'b1; en_shift = 1'b1;  end
            done:begin done_rnd = 1'b1;load_rnd = 1'b1;end
        endcase
    end

endmodule


module Controller_hash(input clk, rst, start, co_i, done_rnd,
                    output reg iz_i, sel_A, sel_B, sel_C, sel_D, load_A, load_B, load_C, load_D, load_M,
                    sel_F, load_F, start_rnd, load_sum, en_i, done,
                    output reg[1:0] sel_sum0, sel_sum1);

    parameter idle = 4'd0, init = 4'd1, start_for = 4'd2, start_rnd_gen = 4'd3,
              wait_rnd = 4'd4, sum0 = 4'd5, sum1 = 4'd6, sum2 = 4'd7,
              sum3 = 4'd8, sum4 = 4'd9, end_for = 4'd10, done_state = 4'd11;
    reg [3:0] ps, ns;

    always@(posedge clk, posedge rst) begin
        if(rst) ps <= idle;
        else ps <= ns;
    end


    always@(ps, start, co_i, done_rnd) begin
        case(ps)
            idle: ns = start ? init : idle;
            init: ns = start_for;
            start_for: ns = co_i ? done_state : start_rnd_gen;
            start_rnd_gen: ns = wait_rnd;
            wait_rnd: ns = done_rnd ? sum0 : wait_rnd;
            sum0: ns = sum1;
            sum1: ns = sum2;
            sum2: ns = sum3;
            sum3: ns = sum4;
            sum4: ns = end_for;
            end_for: ns = start_for;
            done_state: ns = idle;
            default: ns = idle;
        endcase
    end

    always@(ps) begin
        {iz_i, sel_A, sel_B, sel_C, sel_D, load_A, load_B, load_C, load_D, load_M,
         sel_F, load_F, start_rnd, load_sum, en_i, done} = 16'b0;
        {sel_sum0, sel_sum1} = 4'b0;
        case(ps)
            init: begin iz_i = 1'b1; load_A = 1'b1; load_B = 1'b1; load_C = 1'b1; load_D = 1'b1; load_M = 1'b1; end
            start_rnd_gen: begin start_rnd = 1'b1; load_F = 1'b1; end
            sum0: begin sel_sum0 = 2'b11; sel_sum1 = 2'b01; load_sum = 1'b1; end
            sum1: begin sel_sum0 = 2'b00; sel_sum1 = 2'b10; load_sum = 1'b1; end
            sum2: begin sel_sum0 = 2'b01; sel_sum1 = 2'b10; load_sum = 1'b1; end
            sum3: begin sel_F = 1'b1; load_F = 1'b1; end
            sum4: begin sel_sum0 = 2'b10; sel_sum1 = 2'b00; load_sum = 1'b1; end
            end_for: begin
                load_A = 1'b1; load_B = 1'b1; load_C = 1'b1; load_D = 1'b1;
                sel_A = 1'b1; sel_B = 1'b1; sel_C = 1'b1; sel_D = 1'b1; en_i = 1'b1;
            end
            done_state: done = 1'b1;
        endcase
    end

endmodule