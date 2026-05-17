# Correctness Strategy

The project priority is Verilog-to-SystemC functional correctness for the supported Verilog subset. SystemVerilog expansion is deferred until the Verilog path has a stronger correctness loop.

## Current State

Current checks:

- Unit tests validate IR lowering, generated text, and the per-module file
  layout (mirror directory structure, post-order emission, positional
  binding resolution) for selected fixtures.
- Static checks catch generated fallback markers such as TODO comments.
- Verilator integration provides lint and tool metrics.
- The `equivalence` GitHub Actions workflow co-simulates each fixture's
  RTL with `iverilog` and the generated SystemC with `libsystemc-dev`,
  diffing per-cycle output traces. This is the actual functional
  correctness signal for the supported Verilog subset.

## Required Golden Loop

The differential harness in CI implements this loop:

1. Use Icarus Verilog as the RTL golden reference for supported Verilog fixtures.
2. Compile and run the generated SystemC model for the same stimulus.
3. Compare observable outputs cycle-by-cycle (near-cycle-accurate;
   inputs driven on negedge, outputs sampled after posedge).
4. Persist stimulus, RTL/SystemC traces, build logs, and a diff log on
   failure for offline triage.
5. Keep unsupported or known-approximate behavior explicit through diagnostics.

Per-fixture caveats are recorded in `docs/known_differences.md`.

## Priority Scope

Priority features for the Verilog subset:

- module hierarchy preservation across per-module hpp files
- generate-for instance arrays
- bit-select and part-select reads/writes
- width slicing/truncation such as `vector[7:0]`
- ordinary `case`, `if`, continuous assignments, and simple sequential blocks
- positional and named instance port bindings
- deterministic diagnostics for unsupported constructs

Deferred:

- broad SystemVerilog syntax
- four-state exact X/Z semantics
- full Verilog event scheduler equivalence
- per-instance generate-if expansion (currently uses default parameter values)
