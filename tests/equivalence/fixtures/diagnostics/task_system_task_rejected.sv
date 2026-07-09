// Diagnostic fixture: user tasks and system-task expression statements are
// not lowered.
module task_system_task_rejected (
  input  logic clk,
  input  logic d,
  output logic q
);
  task automatic set_q(input logic v);
    q = v;
  endtask

  always_ff @(posedge clk) begin
    set_q(d);
    $display("d=%0d", d);
  end
endmodule
