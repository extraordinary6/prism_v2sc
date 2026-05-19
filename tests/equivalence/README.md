# RTL ↔ SystemC Equivalence Harness

This directory holds the functional-equivalence harness invoked by `.github/workflows/equivalence.yml`. For each fixture it:

1. Runs `prism-v2sc` to lower the RTL into per-module SystemC headers.
2. Generates a deterministic per-fixture stimulus file.
3. Generates a matching **Verilog testbench** and a **SystemC testbench** that both consume that stimulus and emit one trace line per stimulus cycle.
4. Builds and runs the RTL TB with `iverilog` + `vvp`.
5. Builds and runs the SystemC TB with `$CXX` + `-lsystemc`.
6. Diffs the per-cycle output traces.

Comparison is **near-cycle-accurate**: inputs are driven at the negedge of the clock and outputs are sampled after the posedge so combinational propagation has time to settle through delta cycles in SystemC. Default behavior is strict line-by-line matching; pass `--shift-tolerance N` to drop the first `N` SystemC trace entries before diffing if a fixture's SystemC model legitimately lags the RTL by a fixed number of cycles.

The SystemC testbench `#include`s the **top module's** per-module hpp at its mirrored relative path under `build/equivalence/<fixture>/systemc/`. Children are pulled in transitively via the top hpp's `#include` chain.

## Fixtures

| name | kind | what it exercises |
| --- | --- | --- |
| `mux2` | combinational | 4-bit 2:1 mux |
| `adder` | combinational | 8-bit adder with carry-in (concat + bit-select) |
| `byteswap` | combinational | 32-bit byte swap via concat |
| `alu` | combinational | 8-bit ALU with `case`, concat, bit-select |
| `function_alu` | combinational | 8-bit ALU implemented via a synthesizable SV `function` |
| `counter` | sequential | 8-bit up counter, async reset |
| `shift_register` | sequential | 8-bit load/shift register, async reset |
| `fsm_handshake` | sequential | Moore-style FSM handshake (start/data_valid/ready/done) |
| `pipeline8` | sequential | two-stage 8-bit valid/data pipeline (replicate constructions) |
| `multi_file` | sequential | filelist-driven build with `+incdir+`, `-D`, three sources |
| `gen_demo` | combinational | `generate` constructs that slang unrolls during elaboration |
| `slice_writers` | sequential | two `always_ff` blocks each writing one bit of the same 2-bit register; verifies the multi-writer aggregation pass produces a single-writer SystemC build |
| `sv_always_comb` | combinational | SystemVerilog `always_comb` keyword |
| `sv_always_ff` | sequential | SystemVerilog `always_ff` keyword with async reset |
| `sv_always_latch` | combinational | SystemVerilog `always_latch` (enable-gated transparent latch) |
| `casez_priority` | combinational | priority encoder using `casez` wildcards (mask/match lowering) |
| `casex_priority` | combinational | priority encoder using `casex` wildcards |
| `signed_shift_cast` | combinational | `$signed(x) >>> n` — verifies arithmetic right shift via the `sc_int` cast |
| `regfile_mem` | sequential | 8-entry register file backed by an unpacked array `reg [7:0] mem [0:7]`; verifies the per-cell `sc_signal` array lowering |

Each fixture is described by a `Fixture` dataclass in `run_equivalence.py` (top module name, port directions/widths, clock/reset names, simulation cycle count, seed). To add a fixture: drop a `.v` under `fixtures/` and add a new `Fixture(...)` entry to `FIXTURES`.

## Diagnostic Fixtures

Trace equivalence can't reach rejection cases (driver conflicts, unknown modules, duplicate definitions) or intentional approximations (X/Z literals collapsed to 0). These get a second kind of fixture: `prism-v2sc` runs on the RTL and the harness asserts every expected diagnostic code appears in the resulting `ir.json`.

Diagnostic fixtures live under `fixtures/diagnostics/` and are described by a `DiagnosticFixture` dataclass in `run_equivalence.py`. Current set:

| Fixture | Asserts diagnostic code(s) |
| --- | --- |
| `driver_conflict_procedural` | `multiple_procedural_drivers`, `multiple_always_ff_drivers` |
| `mixed_assignment_styles` | `mixed_assignment_styles` |
| `blocking_in_always_ff` | `blocking_in_always_ff` |
| `xz_literal_approximated` | `x_z_literal_approximated` |
| `slang_unknown_module` | `slang_UnknownModule` |
| `slang_duplicate_definition` | `slang_DuplicateDefinition` |

Diagnostic fixtures don't need `iverilog` / SystemC — only `prism-v2sc`. They share the same `--fixtures` selection mechanism and `--keep-going` flag as the trace fixtures.

## Local Usage

The harness expects `iverilog`, `vvp`, and `g++` on `PATH` together with a working SystemC installation (Ubuntu: `apt install iverilog libsystemc-dev`). On Windows the easiest path is to run inside WSL with the same packages.

Run everything:

```bash
python tests/equivalence/run_equivalence.py
```

Run a subset:

```bash
python tests/equivalence/run_equivalence.py --fixtures mux2 counter
```

Keep running after the first failure (useful in CI):

```bash
python tests/equivalence/run_equivalence.py --keep-going
```

Generate artifacts only — no build, no run, no diff — useful on hosts without iverilog/SystemC:

```bash
python tests/equivalence/run_equivalence.py --dry-run
```

Allow a uniform pipeline-lag tolerance:

```bash
python tests/equivalence/run_equivalence.py --shift-tolerance 1
```

All build artifacts and trace files land under `build/equivalence/<fixture>/`. On failure the diff log is at `build/equivalence/<fixture>/diff.log`.

## Environment Overrides

For non-standard SystemC installs:

| variable | purpose | default |
| --- | --- | --- |
| `CXX` | C++ compiler | `g++` |
| `SC_CXXFLAGS` | extra compile flags (e.g. `-I/opt/systemc/include`) | empty |
| `SC_LDFLAGS` | extra link flags (e.g. `-L/opt/systemc/lib`) | empty |
| `SC_LIBS` | link libraries | `-lsystemc -lpthread` |

## CI

`.github/workflows/equivalence.yml` runs the harness on `ubuntu-22.04` for every push and pull request to `main`, plus pushes to `feat/pyslang-migration`. On failure, the workflow uploads `build/equivalence/` as an artifact (`equivalence-artifacts`) for offline triage.
