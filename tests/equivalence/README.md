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

Each fixture is described by a `Fixture` dataclass in `run_equivalence.py` (top module name, port directions/widths, clock/reset names, simulation cycle count, seed). To add a fixture: drop a `.v` under `fixtures/` and add a new `Fixture(...)` entry to `FIXTURES`.

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
