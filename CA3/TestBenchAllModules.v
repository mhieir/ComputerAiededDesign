

module tb_Adder;

    parameter N = 8;

    reg [N-1:0] a;
    reg [N-1:0] b;
    reg cin;
    wire [N-1:0] sum;
    wire cout;

    Adder #(.N(N)) uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        a = 0;
        b = 0;
        cin = 0;
        #10;

        a = 8'd15;
        b = 8'd10;
        cin = 0;
        #10;

        a = 8'd255;
        b = 8'd1;
        cin = 0;
        #10;

        a = 8'd50;
        b = 8'd50;
        cin = 1;
        #10;

        a = 8'hFF;
        b = 8'hFF;
        cin = 1;
        #10;

        $finish;
    end

endmodule

module tb_AND;

    parameter WIDTH = 8;

    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    wire [WIDTH-1:0] out;

    AND #(.WIDTH(WIDTH)) uut (
        .a(a),
        .b(b),
        .out(out)
    );

    initial begin
        a = 0;
        b = 0;
        #10;

        a = 8'hFF;
        b = 8'hFF;
        #10;

        a = 8'hAA; 
        b = 8'h55; 
        #10;

        a = 8'hF0;
        b = 8'hCC;
        #10;

        $finish;
    end

endmodule


module tb_AND4_Nbit;

    parameter N = 8;

    reg [N-1:0] a;
    reg [N-1:0] b;
    reg [N-1:0] c;
    reg [N-1:0] d;
    wire [N-1:0] out;

    AND4_Nbit #(.N(N)) uut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .out(out)
    );

    initial begin
        a = 0; b = 0; c = 0; d = 0;
        #10;

        a = 8'hFF; b = 8'hFF; c = 8'hFF; d = 8'hFF;
        #10;

        a = 8'hFF; b = 8'hFF; c = 8'hFF; d = 8'h00;
        #10;

        a = 8'hF0; b = 8'hF0; c = 8'hFF; d = 8'hFF;
        #10;

        a = 8'hAA; b = 8'h55; c = 8'hFF; d = 8'hFF;
        #10;

        $finish;
    end

endmodule

 

module tb_Multiplier_4bit;

    reg [3:0] a;
    reg [3:0] b;
    wire [7:0] out;

    Multiplier_4bit uut (
        .a(a),
        .b(b),
        .out(out)
    );

    initial begin
        a = 0; b = 0;
        #10;
        
        a = 4'd15; b = 4'd15;
        #10;

        a = 4'd1; b = 4'd1;
        #10;

        a = 4'd10; b = 4'd5;
        #10;

        a = 4'd3; b = 4'd7;
        #10;

        a = 4'd8; b = 4'd2;
        #10;

        $finish;
    end

endmodule

 

module tb_Counter;

    parameter WIDTH = 6;

    reg clk;
    reg rst;
    reg en;
    reg iz;
    reg [WIDTH-1:0] pl;
    wire [WIDTH-1:0] out;
    wire co;
    wire co2;

    Counter #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .iz(iz),
        .pl(pl),
        .out(out),
        .co(co),
        .co2(co2)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        en = 0;
        iz = 0;
        pl = 0;
        #15;
        rst = 0;
        #10;

        pl = 6'd61;
        iz = 1; 
        #10;
        iz = 0;

        en = 1;
        #40;

        en = 0;
        #20;

        en = 1;
        #20;
        rst = 1;
        #10;
        rst = 0;
        iz = 1;
        pl = 0;
        #10;
        iz = 0;
        #50;

        $finish;
    end

endmodule


module tb_MUX2to1;

    parameter WIDTH = 8;

    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    reg sel;
    wire [WIDTH-1:0] out;

    MUX2to1 #(.WIDTH(WIDTH)) uut (
        .a(a),
        .b(b),
        .sel(sel),
        .out(out)
    );

    initial begin
        a = 0;
        b = 0;
        sel = 0;
        #10;

        a = 8'hAA; 
        b = 8'h55; 
        
        sel = 0;
        #10;

        sel = 1;
        #10;

        $finish;
    end

endmodule


module  ;

    parameter WIDTH = 8;

    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    reg [WIDTH-1:0] sel;
    wire [WIDTH-1:0] out;

    MUX2to1_Bitwise #(.WIDTH(WIDTH)) uut (
        .a(a),
        .b(b),
        .sel(sel),
        .out(out)
    );

    initial begin
        a = 0;
        b = 0;
        sel = 0;
        #10;

        a = 8'hAA; 
        b = 8'h55; 
        
        sel = 8'hF0; 
        #10;

        sel = 8'h0F; 
        #10;

        a = 8'h00;
        b = 8'hFF;
        sel = 8'hAA; 
        #10;

        $finish;
    end

endmodule

module tb_MUX3to1;

    parameter N = 8;

    reg [N-1:0] a;
    reg [N-1:0] b;
    reg [N-1:0] c;
    reg sel0;
    reg sel1;
    wire [N-1:0] out;

    MUX3to1 #(.N(N)) uut (
        .a(a),
        .b(b),
        .c(c),
        .sel0(sel0),
        .sel1(sel1),
        .out(out)
    );

    initial begin
        a = 0;
        b = 0;
        c = 0;
        sel0 = 0;
        sel1 = 0;
        #10;

        a = 8'hAA; 
        b = 8'hBB; 
        c = 8'hCC; 

        sel1 = 0; sel0 = 0;
        #10;

        sel1 = 0; sel0 = 1;
        #10;

        sel1 = 1; sel0 = 0;
        #10;

        sel1 = 1; sel0 = 1;
        #10;

        $finish;
    end

endmodule

 

module tb_MUX4to1;

    parameter WIDTH = 8;

    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    reg [WIDTH-1:0] c;
    reg [WIDTH-1:0] d;
    reg sel0;
    reg sel1;
    wire [WIDTH-1:0] out;

    MUX4to1 #(.WIDTH(WIDTH)) uut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .sel0(sel0),
        .sel1(sel1),
        .out(out)
    );

    initial begin
        a = 8'hAA;
        b = 8'hBB;
        c = 8'hCC;
        d = 8'hDD;
        sel0 = 0;
        sel1 = 0;
        #10;

        sel1 = 0;
        sel0 = 1;
        #10;

        sel1 = 1;
        sel0 = 0;
        #10;

        sel1 = 1;
        sel0 = 1;
        #10;

        $finish;
    end

endmodule


module tb_NOT;

    parameter WIDTH = 8;

    reg [WIDTH-1:0] a;
    wire [WIDTH-1:0] out;

    NOT #(.WIDTH(WIDTH)) uut (
        .a(a),
        .out(out)
    );

    initial begin
        a = 0;
        #10;

        a = 8'hFF;
        #10;

        a = 8'hAA; 
        #10;

        a = 8'h55; 
        #10;

        $finish;
    end

endmodule



module tb_OR;

    parameter WIDTH = 8;

    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    wire [WIDTH-1:0] out;

    OR #(.WIDTH(WIDTH)) uut (
        .a(a),
        .b(b),
        .out(out)
    );

    initial begin
        a = 0; b = 0;
        #10;

        a = 8'hFF; b = 8'hFF;
        #10;

        a = 8'hAA; b = 8'h55;
        #10;

        a = 8'hF0; b = 8'h0F;
        #10;

        $finish;
    end

endmodule



module tb_Register;

    parameter WIDTH = 8;

    reg clk;
    reg rst;
    reg Ld;
    reg [WIDTH-1:0] in;
    wire [WIDTH-1:0] out;

    Register #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst(rst),
        .Ld(Ld),
        .in(in),
        .out(out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        Ld = 0;
        in = 0;
        #15;
        rst = 0;

        in = 8'hAA;
        Ld = 1;
        #10;

        Ld = 0;
        in = 8'hFF;
        #10;

        Ld = 1;
        #10;

        rst = 1;
        #10;

        $finish;
    end

endmodule

 

module tb_Register_Merged_MUX;

    parameter WIDTH = 8;

    reg clk;
    reg rst;
    reg load;
    reg sel;
    reg [WIDTH-1:0] val_0;
    reg [WIDTH-1:0] val_1;
    wire [WIDTH-1:0] out;

    Register_Merged_MUX #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .sel(sel),
        .val_0(val_0),
        .val_1(val_1),
        .out(out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        load = 0;
        sel = 0;
        val_0 = 0;
        val_1 = 0;
        #15;
        rst = 0;

        val_0 = 8'hAA; 
        val_1 = 8'h55;

        load = 1;
        sel = 0;
        #10;

        load = 0;
        val_0 = 8'h00;
        #10;

        load = 1;
        sel = 1;
        #10;

        rst = 1;
        #10;

        $finish;
    end

endmodule

 

module tb_Left_shift_register;

    parameter N = 6;

    reg clk;
    reg rst;
    reg iz;
    reg en_shift;
    reg shift_input;
    reg [N-1:0] pl;
    reg load_val;
    wire [N-1:0] out;

    Left_shift_register #(.N(N)) uut (
        .clk(clk),
        .rst(rst),
        .iz(iz),
        .en_shift(en_shift),
        .shift_input(shift_input),
        .pl(pl),
        .load_val(load_val),
        .out(out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        iz = 0;
        en_shift = 0;
        shift_input = 0;
        pl = 0;
        load_val = 0;
        #15;
        rst = 0;
        #10;

        pl = 6'b001100;
        load_val = 1;
        #10;

        load_val = 0;
        en_shift = 1;
        shift_input = 1;
        #10;

        shift_input = 0;
        #10;

        shift_input = 1;
        #10;

        en_shift = 0;
        #20;

        load_val = 1;
        pl = 6'b111111;
        #10;

        $finish;
    end

endmodule


module tb_Hash;

    reg clk;
    reg rst;
    reg start;
    reg [31:0] message;
    
    reg done_rnd;
    reg [1:0] rnd;

    wire [31:0] digest;
    wire start_rnd;
    wire done;
    wire [5:0] i;

    Hash uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .message(message),
        .done_rnd(done_rnd),
        .rnd(rnd),
        .digest(digest),
        .start_rnd(start_rnd),
        .done(done),
        .i(i)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk) begin
        if (start_rnd) begin
            repeat(2) @(posedge clk);
            rnd <= $random % 4;
            done_rnd <= 1;
            @(posedge clk);
            done_rnd <= 0;
        end else begin
            done_rnd <= 0;
        end
    end

    initial begin
        rst = 1;
        start = 0;
        message = 0;
        rnd = 0;
        done_rnd = 0;
        #15;
        rst = 0;
        #10;

        message = 32'hDEADBEEF;
        start = 1;
        #10;
        start = 0;

        wait(done == 1);
        #20;

        rst = 1;
        #10;
        rst = 0;
        message = 32'hA5A5A5A5;
        start = 1;
        #10;
        start = 0;
        wait(done == 1);
        #20;

        $finish;
    end

endmodule



module tb_Rnd_gen;

    reg clk;
    reg rst;
    reg start_rnd;
    reg [5:0] input_number;
    wire done_rnd;
    wire [1:0] out_rnd;

    Rnd_gen uut (
        .clk(clk),
        .rst(rst),
        .start_rnd(start_rnd),
        .input_number(input_number),
        .done_rnd(done_rnd),
        .out_rnd(out_rnd)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        start_rnd = 0;
        input_number = 0;
        #15;
        rst = 0;
        #10;

        input_number = 6'd25; 
        start_rnd = 1;
        #10;
        start_rnd = 0;

        wait(done_rnd == 1);
        #20;

        input_number = 6'd42;
        start_rnd = 1;
        #10;
        start_rnd = 0;

        wait(done_rnd == 1);
        #20;

        $finish;
    end

endmodule

module tb_XOR;

    parameter WIDTH = 8;

    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    wire [WIDTH-1:0] out;

    XOR #(.WIDTH(WIDTH)) uut (
        .a(a),
        .b(b),
        .out(out)
    );

    initial begin
        a = 0; b = 0;
        #10;

        a = 8'hFF; b = 8'h00;
        #10;

        a = 8'hAA; b = 8'h55;
        #10;

        a = 8'hF0; b = 8'h0F;
        #10;

        a = 8'h12; b = 8'h12;
        #10;

        $finish;
    end

endmodule