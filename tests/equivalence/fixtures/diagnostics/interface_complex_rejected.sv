// Diagnostic fixture: an interface/modport with only a task import cannot be
// flattened to ordinary packed signal ports.
interface task_only_if;
  task automatic drive(input logic v);
  endtask
  modport master(import drive);
endinterface

module interface_complex_rejected (
  task_only_if.master bus,
  output logic        y
);
  assign y = 1'b0;
endmodule
