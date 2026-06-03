module package_import_tb;
  reg        clk;
  reg        rst_n;
  reg  [7:0] a;
  reg  [7:0] b;
  reg  [1:0] op_sel;
  wire [7:0] result;

  package_import dut (
    .clk(clk),
    .rst_n(rst_n),
    .a(a),
    .b(b),
    .op_sel(op_sel),
    .result(result)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $dumpfile("package_import.vcd");
    $dumpvars(0, package_import_tb);

    rst_n = 0;
    a = 0;
    b = 0;
    op_sel = 0;
    #12;
    rst_n = 1;
    #10;

    // Test ADD with normal values
    a = 8'd10;
    b = 8'd20;
    op_sel = 2'b00;  // OP_ADD
    #10;

    // Test ADD with saturation
    a = 8'd200;
    b = 8'd100;
    op_sel = 2'b00;  // OP_ADD (should saturate to 255)
    #10;

    // Test SUB
    a = 8'd50;
    b = 8'd30;
    op_sel = 2'b01;  // OP_SUB
    #10;

    // Test SUB with underflow protection
    a = 8'd10;
    b = 8'd30;
    op_sel = 2'b01;  // OP_SUB (should be 0)
    #10;

    // Test AND
    a = 8'hAA;
    b = 8'h55;
    op_sel = 2'b10;  // OP_AND
    #10;

    // Test OR
    a = 8'hA0;
    b = 8'h0A;
    op_sel = 2'b11;  // OP_OR
    #10;

    // More ADD tests
    a = 8'd15;
    b = 8'd25;
    op_sel = 2'b00;
    #10;

    // More AND tests
    a = 8'hFF;
    b = 8'h0F;
    op_sel = 2'b10;
    #10;

    #20;
    $finish;
  end
endmodule
