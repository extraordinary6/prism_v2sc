# RTL vs SystemC equivalence harness

This directory contains a small functional-equivalence harness used by the
`equivalence` GitHub Actions workflow. For each fixture it:

1. Runs `prism-v2sc` to lower the RTL into per-module SystemC headers.
2. Generates a deterministic stimulus file (per-fixture seed).
3. Generates a matching **Verilog testbench** and a **SystemC testbench**
   that both consume the same stimulus file and emit one trace line per
   stimulus cycle.
4. Builds and runs the RTL TB with `iverilog` + `vvp`.
5. Builds and runs the SystemC TB with `$CXX` + `-lsystemc`.
6. Diffs the per-cycle output traces.

Equivalence is checked at near-cycle-accurate granularity: inputs are
driven at the negedge of the clock and outputs are sampled after the
posedge so combinational propagation has time to settle through delta
cycles in SystemC. Strict line-by-line matching is the default; pass
`--shift-tolerance N` to drop the first `N` SystemC trace entries before
diffing if a fixture's SystemC implementation legitimately lags the RTL
by a fixed amount.

The SystemC testbench `#include`s the *top module's* per-module hpp at
its mirrored relative path under `build/equivalence/<fixture>/systemc/`.
Children are pulled in transitively via the top hpp's `#include` chain.

## Fixtures

Currently the following fixtures live under `fixtures/`:

| name           | kind          | notes                                                       |
| -------------- | ------------- | ----------------------------------------------------------- |
| mux2           | combinational | 4-bit 2:1 mux                                               |
| adder          | combinational | 8-bit adder with carry-in, exercises concat / bit-select    |
| byteswap       | combinational | 32-bit byte swap via concat                                 |
| alu            | combinational | 8-bit ALU with `case`, concat, bit-select                   |
| counter        | sequential    | 8-bit up counter with async reset                           |
| shift_register | sequential    | 8-bit load/shift register, async reset                      |
| fsm_handshake  | sequential    | Moore-style FSM handshake (start/data_valid/ready/done)     |
| pipeline8      | sequential    | two-stage 8-bit valid/data pipeline, replicate constructions |
| multi_file     | sequential    | filelist-driven build (`+incdir+`, `-D`, three sources)     |

Each fixture is described by a `Fixture` dataclass in `run_equivalence.py`
(top module name, port directions/widths, clock/reset names, simulation
cycle count, seed). To add a fixture: drop a `.v` under `fixtures/` and
add a new `Fixture(...)` entry to `FIXTURES`.

## Local usage

The harness expects `iverilog`, `vvp`, and `g++` on `PATH` together with a
working SystemC installation (Ubuntu: `apt install iverilog libsystemc-dev`).
On Windows the easiest path is to run inside WSL with the same packages.

Run all fixtures:

```bash
python tests/equivalence/run_equivalence.py
```

Run a subset:

```bash
python tests/equivalence/run_equivalence.py --fixtures mux2 counter
```

Generate artifacts only (no build/run/diff), useful on hosts without
iverilog/SystemC installed:

```bash
python tests/equivalence/run_equivalence.py --dry-run
```

Allow a uniform pipeline-lag tolerance:

```bash
python tests/equivalence/run_equivalence.py --shift-tolerance 1
```

All build artifacts and trace files land under `build/equivalence/<fixture>/`.

## Environment overrides

The harness reads a few environment variables to accommodate non-standard
SystemC installs:

- `CXX` — C++ compiler (default `g++`).
- `SC_CXXFLAGS` — extra compile flags (e.g. `-I/opt/systemc/include`).
- `SC_LDFLAGS` — extra link flags (e.g. `-L/opt/systemc/lib`).
- `SC_LIBS` — link libraries (default `-lsystemc -lpthread`).

## CI

The `.github/workflows/equivalence.yml` workflow runs this harness on
`ubuntu-22.04` for every push and pull request to `main`. On failure, the
workflow uploads `build/equivalence/` as an artifact for offline triage.
