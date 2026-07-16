# RTL ↔ SystemC Equivalence Harness

This directory holds the functional-equivalence harness invoked by `.github/workflows/equivalence.yml`. For each trace-equivalence fixture it:

1. Runs `prism-v2sc` to lower the RTL into per-module SystemC headers.
2. Generates a deterministic per-fixture stimulus file.
3. Generates a matching **Verilog testbench** and a **SystemC testbench** that both consume that stimulus and emit one trace line per stimulus cycle.
4. Builds and runs the RTL TB with `iverilog` + `vvp`, or VCS via `--rtl-sim vcs`.
5. Builds and runs the SystemC TB with `$CXX` + `-lsystemc`.
6. Diffs the per-cycle output traces.

Comparison is **near-cycle-accurate**: inputs are driven at the negedge of the clock and outputs are sampled after the posedge so combinational propagation has time to settle through delta cycles in SystemC. Default behavior is strict line-by-line matching; pass `--shift-tolerance N` to drop the first `N` SystemC trace entries before diffing if a fixture's SystemC model legitimately lags the RTL by a fixed number of cycles.

The SystemC testbench `#include`s the **top module's** per-module hpp at its mirrored relative path under `build/equivalence/<fixture>/systemc/`. Children are pulled in transitively via the top hpp's `#include` chain.

Conversion-only fixtures use the same harness for SV constructs that `prism-v2sc` can lower but Icarus Verilog cannot compile. They run `prism-v2sc`, validate `ir.json`, check the top header exists, and assert no error diagnostics.

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
| `filelist_edges` | sequential | nested `-f` filelists, relative source paths, `+incdir+`, and macro-controlled source behavior |
| `gen_demo` | combinational | `generate` constructs that slang unrolls during elaboration |
| `slice_writers` | sequential | two `always_ff` blocks each writing one bit of the same 2-bit register; verifies the multi-writer aggregation pass produces a single-writer SystemC build |
| `sv_always_comb` | combinational | SystemVerilog `always_comb` keyword |
| `sv_always_ff` | sequential | SystemVerilog `always_ff` keyword with async reset |
| `sv_always_latch` | combinational | SystemVerilog `always_latch` (enable-gated transparent latch) |
| `casez_priority` | combinational | priority encoder using `casez` wildcards (mask/match lowering) |
| `casex_priority` | combinational | priority encoder using `casex` wildcards |
| `signed_shift_cast` | combinational | `$signed(x) >>> n` — verifies arithmetic right shift via the `sc_int` cast |
| `signed_declared_arith` | combinational | signed-declared ports/signals, signed comparison, arithmetic right shift, and signed based literals |
| `signed_mixed_context` | combinational | signed/unsigned boundary expressions with explicit extension/casts: add/sub, signed math compare, unsigned bit-pattern compare, part-select arithmetic shift, and signed ternary |
| `width_boundaries` | combinational | 1/2/31/32/33/63/64/65-bit packed expressions, concat, shifts, compare, and the wide-port hex trace path |
| `nested_selects` | combinational | nested ternary expressions plus `case` defaults and uncovered branches |
| `staged_read_after_write` | combinational | blocking read-after-write within one combinational process, including a later part-select write |
| `blocking_comb_chain` | combinational | longer blocking-assignment chains in one combinational process |
| `part_select_assembly` | combinational | out-of-order non-overlapping bit/part-select writes that assemble full vectors |
| `regfile_mem` | sequential | 8-entry register file backed by an unpacked array `reg [7:0] mem [0:7]`; verifies the per-cell `sc_signal` array lowering |
| `memory_edges` | sequential | unpacked memory reset initialization, write enable, independent read/write addresses, and same-cycle old-value reads |
| `nba_chain` | sequential | nonblocking assignment chains preserve pre-edge RHS values |
| `async_reset_edges` | sequential | active-high async reset polarity and reset/clock boundary behavior |
| `procedural_for` | combinational | constant-bound procedural `for` loop unrolling |
| `procedural_for_edges` | combinational | decrementing loops, non-zero starts, nested procedural loops, and sensitivity through unrolled blocks |
| `latch_edges` | combinational | `always_latch` hold behavior plus partial assignment in one process |
| `sensitivity_edges` | combinational | inferred sensitivity through function call arguments, selects, concat, and replication |
| `param_hierarchy_edges` | combinational | multi-level parameter/localparam propagation, derived widths, and instance overrides |
| `typedef_enum_fsm` | sequential | typedef aliases plus enum member values |
| `packed_aggregate_demo` | combinational | packed struct/union flattening and field access |
| `package_import` | sequential | package wildcard/explicit imports, package functions, typedefs, and parameters |
| `inout_bus` | combinational | whole-vector `inout` lowering through resolved SystemC vectors |
| `inout_edges` | combinational | whole-vector high-Z branches, mutually exclusive DUT/external drive, and resolved-value sampling through top and child modules |

Each fixture is described by a `Fixture` dataclass in `run_equivalence.py` (top module name, port directions/widths/signedness, clock/reset names, simulation cycle count, seed). To add a fixture: drop a `.v` under `fixtures/` and add a new `Fixture(...)` entry to `FIXTURES`.

## Conversion Fixtures

Trace equivalence also depends on the RTL simulator accepting the source. When Icarus cannot compile a supported SV construct, the harness keeps CI coverage through a conversion fixture instead.

| Fixture | What it checks |
| --- | --- |
| `interface_modport` | simple packed-signal interfaces plus simple modport input/output directions flatten to ordinary `iface__field` signals/ports and generated top-header bindings |
| `interface_modport_variants` | multiple simple interface instances and modport directions flatten to stable top-level signals and child bindings |
| `package_multifile` | package typedefs, parameters, and functions resolve across multiple source files |
| `generate_named_blocks` | named generate hierarchy elaborates to stable generated header instance names and bridge bindings |
| `typedef_package_enum` | package enum typedefs lower to integer constants and stable local storage/header snippets |

Conversion fixtures are described by a `ConversionFixture` dataclass in `run_equivalence.py`. They do not need `iverilog`, `vvp`, or SystemC.

## Diagnostic Fixtures

Trace equivalence can't reach rejection cases (driver conflicts, unknown modules, duplicate definitions) or intentional approximations (X/Z literals collapsed to 0). These get a second kind of fixture: `prism-v2sc` runs on the RTL and the harness asserts every expected diagnostic code appears in the resulting `ir.json`. It also reruns the same conversion with `--fail-on-diagnostics` and checks that warning-only cases exit 0 while error-level cases exit 2.

Diagnostic fixtures live under `fixtures/diagnostics/` and are described by a `DiagnosticFixture` dataclass in `run_equivalence.py`. Current set:

| Fixture | Asserts diagnostic code(s) |
| --- | --- |
| `driver_conflict_procedural` | `multiple_procedural_drivers`, `multiple_always_ff_drivers` |
| `mixed_assignment_styles` | `mixed_assignment_styles` |
| `blocking_in_always_ff` | `blocking_in_always_ff` |
| `comb_process_order` | `event_scheduler_approximated` |
| `xz_literal_approximated` | `x_z_literal_approximated` |
| `xz_logic_rejected` | `x_z_literal_approximated` |
| `overlap_slice_writers` | `overlapping_procedural_writes` |
| `mixed_assignment_deeper` | `mixed_assignment_styles` |
| `while_repeat_rejected` | `unsupported_whileloop`, `unsupported_repeatloop` |
| `interface_complex_rejected` | `unsupported_interface_port` |
| `task_system_task_rejected` | `unsupported_task_first_round`, `unsupported_expression_statement_call` |
| `dynamic_sv_rejected` | `unsupported_classtype` |
| `slang_unknown_module` | `slang_UnknownModule` |
| `slang_duplicate_definition` | `slang_DuplicateDefinition` |

Diagnostic fixtures don't need `iverilog` / SystemC — only `prism-v2sc`. They share the same `--fixtures` selection mechanism and `--keep-going` flag as the trace fixtures.

## Local Usage

Trace fixtures expect `iverilog`, `vvp`, and `g++` on `PATH` together with a working SystemC installation (Ubuntu: `apt install iverilog libsystemc-dev`). On Windows the easiest path is to run inside WSL with the same packages. If `<systemc>` is not available locally, use `--dry-run --keep-going` to check conversion and generated testbench artifacts; CI remains the authority for full RTL/SystemC trace diffs.

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
| `SC_CXX_STANDARD` | C++ language mode matching the installed SystemC ABI | `c++17` |
| `SC_LDFLAGS` | extra link flags (e.g. `-L/opt/systemc/lib`) | empty |
| `SC_LIBS` | link libraries | `-lsystemc -lpthread` |
| `VCS` | VCS executable used by `--rtl-sim vcs` | `vcs` |
| `VCS_FLAGS` | VCS compile/elaboration flags | `-full64 -sverilog -timescale=1ns/1ps` |
| `VCS_RUN_FLAGS` | runtime flags passed to the generated VCS executable | empty |
| `VCS_TARGET_ARCH` | VCS target architecture; useful for older VCS installs | `linux64` |

## CI

`.github/workflows/equivalence.yml` runs the harness on `ubuntu-22.04` for pushes to `main` and `feat/**`, pull requests targeting `main`, and manual dispatch. On failure, the workflow uploads `build/equivalence/` as an artifact (`equivalence-artifacts`) for offline triage.
