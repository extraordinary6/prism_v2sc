# Correctness Strategy

`prism_v2sc` targets **functional correctness for the supported synthesizable RTL subset**. Full Verilog/SystemVerilog semantic equivalence (including X/Z fidelity and full event scheduling) is explicitly out of scope.

## Layered Checks

| Layer | What it catches | Where |
| --- | --- | --- |
| Frontend diagnostics | Unknown modules, duplicate definitions, unsupported elaborated constructs. Sourced from slang itself plus the lowerer. | `DesignIR.diagnostics`; surfaced through the CLI summary; gate with `--fail-on-diagnostics`. |
| Unit tests | IR lowering shape, codegen text, per-module file layout (mirror directory structure, post-order emission, positional binding resolution), expression coverage, hardening edges. | `tests/`, run with `python -m pytest -q`. 59 tests at time of writing. |
| Static generated-code checks | Obvious miscompile markers in the emitted SystemC (TODO comments, missing `<systemc>`, missing `SC_MODULE`). | `prism_v2sc.verify.static_checks.check_generated_systemc()`. |
| Verilator lint integration | Cross-check against a second tool's frontend, capture its timing/memory. | Enable with `--compare-verilator`; output lands in `metrics.json`. |
| **Differential RTL ↔ SystemC equivalence** | Per-cycle output trace divergence between the original RTL (Icarus Verilog) and the generated SystemC (libsystemc-dev). | `.github/workflows/equivalence.yml` and `tests/equivalence/run_equivalence.py`. |

The equivalence layer is the **actual functional correctness signal**. Everything above it is supportive.

## Golden Loop

For each fixture under `tests/equivalence/fixtures/`:

1. Convert the RTL to per-module SystemC headers with `prism-v2sc`.
2. Generate a deterministic stimulus file (per-fixture seed).
3. Generate matching Verilog and SystemC testbenches that both consume that stimulus.
4. Build and run the RTL TB with `iverilog` + `vvp`.
5. Build and run the SystemC TB with `$CXX` + `-lsystemc`.
6. Diff the per-cycle output traces.

Comparison is **near-cycle-accurate**: inputs are driven on the negedge of the clock, outputs are sampled after the posedge so combinational logic settles through delta cycles in SystemC. A `--shift-tolerance N` knob exists for designs whose SystemC model legitimately lags the RTL by a fixed number of cycles.

On failure, the harness persists stimulus, both traces, build logs, and a per-cycle diff log under `build/equivalence/<fixture>/` for offline triage. CI uploads that directory as a workflow artifact.

## Adding a New Feature

The expected motion when adding a new RTL construct or SV feature:

1. Add a minimal RTL fixture under `tests/equivalence/fixtures/` that exercises the construct in isolation.
2. Register it in `FIXTURES` in `tests/equivalence/run_equivalence.py`.
3. Run the harness locally on Linux (or push and let CI run it).
4. Land the lowering/codegen changes that make the fixture's trace match the RTL.
5. Add a focused unit test in `tests/` if the change has an IR-shape or codegen-text invariant worth pinning.

If a construct cannot be matched cycle-accurately, the lowerer must emit a `DiagnosticIR` rather than silently degrade. See `docs/known_differences.md` for the current list.

## Out of Scope

- Four-state exact X/Z semantics.
- Full Verilog event scheduler equivalence (we approximate with `SC_METHOD`).
- Dynamic SystemVerilog (classes, randomization, programs, runtime assertions/properties) — surfaced as diagnostics, not partially lowered.
