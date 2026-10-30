`timescale 1ns / 1ns


module verifyTestBench();
  parameter WIDTH = 8;
  parameter NUM_WORDS = 4; 
  parameter ITER = 64;
  parameter NUM_REP = 6;


  parameter [31:0] MAX_TESTS = 32'd64;
  parameter [31:0] START = 0;

  reg clk, rst, start;
  reg [NUM_WORDS*WIDTH-1:0] message;
  wire [NUM_WORDS*WIDTH-1:0] digest;
  wire done;

  integer outfile, logfile, reffile;
  integer infile;
  integer i;
  reg [31:0] msg_val;
  reg [NUM_WORDS*WIDTH-1:0] expected;
  reg [NUM_WORDS*WIDTH-1:0] ref_msg;
  integer scan_ret;
  integer ref_scan;
  reg ref_exists;
  reg [1023:0] ref_line;
  integer ref_len;

  integer pass_count;
  integer fail_count;

  
  Top #(
      .WIDTH(WIDTH),
      .NUM_WORDS(NUM_WORDS),
      .ITER(ITER),
      .NUM_REP(NUM_REP)
  ) uut (
      .clk(clk),
      .rst(rst),
      .start(start),
      .message(message),
      .digest(digest),
      .done(done)
  );

  always #1 clk = ~clk;

  initial begin
    clk = 0; rst = 1; start = 0;
    pass_count = 0; fail_count = 0;

    #10 rst = 0;

    outfile = $fopen("verify_out_hw.txt","w");
    logfile = $fopen("verify_log_hw.txt","w");
    infile = $fopen("testcase.txt","r");
    reffile = $fopen("golden_out_hw.txt","r");
    ref_exists = (reffile != 32'd0);

    if (infile == 0) begin
      $display("Error: testcase.txt not found or could not be opened.");
      $finish;
    end

    if (outfile == 0 || logfile == 0) begin
      $display("Error opening output or log files.");
      $finish;
    end

    if (ref_exists) $fdisplay(logfile, "Reference file opened: golden_ref.txt");
    else $fdisplay(logfile, "No reference file found: comparison disabled");

    $fdisplay(logfile, "Verify run: START=%0d MAX_TESTS=%0d", START, MAX_TESTS);

    for (i = 0; i < MAX_TESTS; i = i + 1) begin : test_loop
      
      scan_ret = $fscanf(infile, "%h\n", message);
      if (scan_ret != 1) begin
        $display("End of input file or read error at message index %0d", i);
        $fdisplay(logfile, "End of input file or read error at message index %0d", i);
        disable test_loop;
      end

      if (ref_exists) begin
        ref_len = $fgets(ref_line, reffile);
        if (ref_len == 0) begin
          ref_exists = 0;
          $fdisplay(logfile, "Reference file ended unexpectedly at index %0d", i);
        end else begin
          
          ref_scan = $sscanf(ref_line, "%h %h", ref_msg, expected);
          if (ref_scan == 2) begin
            if (ref_msg !== message) begin
              $fdisplay(logfile, "Warning: reference message mismatch at index %0d: ref=%08h input=%08h", i, ref_msg, message);
            end
          end else begin
            ref_scan = $sscanf(ref_line, "%h", expected);
            if (ref_scan != 1) begin
              ref_exists = 0;
              $fdisplay(logfile, "Reference file parse error at index %0d", i);
            end
          end
        end
      end

      #10 rst = 1;
      #10 rst = 0;

      msg_val = message;

      #4 start = 1; #2 start = 0;

      wait (done);
      @(posedge clk);
      #1;

      
      $fdisplay(outfile, "%08h %08h", msg_val, digest);

      
      if (ref_exists) begin
        if (digest == expected) begin
          pass_count = pass_count + 1;
        end else begin
          fail_count = fail_count + 1;
          $fdisplay(logfile, "Mismatch for %08h : expected=%08h got=%08h", msg_val, expected, digest);
        end
      end

      if ((i % 1000) == 0) begin
        $display("Processed %0d/%0d messages (passes=%0d fails=%0d)", i, MAX_TESTS, pass_count, fail_count);
        $fdisplay(logfile, "Processed %0d/%0d messages (passes=%0d fails=%0d)", i, MAX_TESTS, pass_count, fail_count);
      end
    end

    if (ref_exists) begin
      $display("Verification complete: passed %0d / %0d", pass_count, pass_count + fail_count);
      $fdisplay(logfile, "Verification complete: passed %0d / %0d", pass_count, pass_count + fail_count);
    end else begin
      $display("Run complete. No reference was provided; outputs saved to verify_out_hw.txt");
    end

    $fclose(outfile);
    $fclose(logfile);
    if (reffile != 0) $fclose(reffile);
    if (infile != 0) $fclose(infile);

    $stop;
  end

endmodule

