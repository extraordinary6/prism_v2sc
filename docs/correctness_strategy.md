# Correctness Strategy

The project priority is Verilog-to-SystemC functional correctness for the supported Verilog subset. SystemVerilog expansion is deferred until the Verilog path has a stronger correctness loop.

## Current State

Current checks are necessary but not sufficient:

- Unit tests validate IR lowering and generated text for selected fixtures.
- Static checks catch generated fallback markers such as TODO comments.
- Verilator integration currently provides lint and tool metrics.

Current checks do not yet prove functional equivalence between RTL and generated SystemC.

## Required Golden Loop

The next hardening milestone should add a differential harness:

1. Use Verilator as the RTL golden reference for supported Verilog fixtures.
2. Compile and run the generated SystemC model for the same stimulus when a SystemC toolchain is available.
3. Compare observable outputs cycle-by-cycle for the supported approximate-cycle semantics.
4. Persist the stimulus, expected outputs, generated outputs, tool versions, and mismatch summary.
5. Keep unsupported or known-approximate behavior explicit through diagnostics.

## Priority Scope

Priority features for the Verilog subset:

- generate-for instance arrays
- bit-select and part-select reads/writes
- width slicing/truncation such as `vector[7:0]`
- ordinary `case`, `if`, continuous assignments, and simple sequential blocks
- deterministic diagnostics for unsupported constructs

Deferred:

- broad SystemVerilog syntax
- four-state exact X/Z semantics
- full Verilog event scheduler equivalence
