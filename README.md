# prism_v2sc

`prism_v2sc` converts a synthesizable Verilog / SystemVerilog RTL subset into hierarchical, approximate SystemC models. One ``.hpp`` per module, mirroring the source directory layout.

It uses [slang](https://sv-lang.com/) (via the [pyslang](https://pypi.org/project/pyslang/) Python bindings) for parsing and elaboration. slang resolves parameter overrides, folds `generate if`, unrolls `generate for`, and turns port widths into concrete integers before the lowerer ever sees the design.

The tool is intentionally a **practical RTL subset translator**, not a full SystemVerilog semantic equivalent. Unsupported constructs are surfaced as diagnostics rather than silently miscompiled.

## Install

```powershell
python -m pip install -e .
```

Requirements: Python 3.10+; `pyslang>=11.0,<12.0` (pulled in transitively, ships as a prebuilt wheel on Windows and Linux).

## CLI

```powershell
python -m prism_v2sc --top <module> [options] [<sources...>]
```

| flag | purpose |
| --- | --- |
| `--top <name>` | top-level module (required) |
| `--filelist <path>` | `.f`-style filelist (can be repeated) |
| `--out <dir>` | output directory (default `build/systemc`) |
| `--dump-ir` | print the JSON IR to stdout instead of writing it |
| `--metrics` | also write `metrics.json` (timing + memory + traversal counters) |
| `--compare-verilator` | run `verilator --lint-only` alongside and capture its timing |
| `--fail-on-diagnostics` | exit non-zero when error-level diagnostics are reported |

A `.f` filelist accepts one file per line plus `-I`/`+incdir+` includes, `-D` defines, `-f` nested filelists, and `#`/`//` comments.

## Output Layout

```
build/systemc/
├── ir.json                       # Phase 1 JSON IR (every reachable module)
├── <module>.hpp                  # per-module SystemC header
└── <nested>/<module>.hpp         # nested paths mirror the source tree
```

Each module's header `#include`s the headers of every child it instantiates, so users only include the top header — the rest is pulled in transitively. There is no umbrella header.

## How It Works

1. slang ingests every source file at once and produces an elaborated `Compilation` (parameter overrides applied, generate constructs resolved, widths concrete).
2. The flow walks the elaborated instance tree rooted at `--top` and lowers each reachable module into `ModuleIR`. Unreachable definitions are ignored; repeated instantiations lower exactly once.
3. Codegen emits one `.hpp` per module in **post-order DFS** (children first), so a parent's `#include` paths always point at files that already exist on disk.
4. Diagnostics from slang's elaboration and from the lowerer itself surface on the `DesignIR` and are summarized at the end of the run.

## Examples

| location | scope |
| --- | --- |
| `examples/alu_demo/` | single-file 8-bit ALU showing `case`, concat, bit-select |
| `examples/filelist_demo/` | multi-file build driven by a `.f` filelist with `+incdir+` and `-D` |

## Tests

```powershell
python -m pytest -q
```

Currently 85 tests covering IR lowering, codegen output shape, CLI behavior, multi-file output layout, expression coverage, diagnostics, hardening, and subroutines.

## Equivalence CI

`.github/workflows/equivalence.yml` runs on Linux. For each fixture under `tests/equivalence/fixtures/` it co-simulates the original RTL (Icarus Verilog) and the generated SystemC (libsystemc-dev) against a shared deterministic stimulus and diffs the per-cycle output traces. See `tests/equivalence/README.md` for fixture list, local usage, and environment overrides.

Local trace-equivalence runs require SystemC headers and libraries. On machines without `<systemc>` available, use the unit suite plus `tests/equivalence/run_equivalence.py --dry-run --keep-going` for conversion coverage, and rely on CI for the final RTL/SystemC trace diff.

## Further Reading

- `docs/correctness_strategy.md` — how correctness is established and what the golden loop looks like.
- `docs/syntax_coverage.md` — what RTL surface is verified by the equivalence CI, what is explicitly rejected, and what is queued for Phase 11.
- `docs/known_differences.md` — explicit list of where generated SystemC diverges from full Verilog/SV semantics.
- `docs/signed_mixed_semantics.md` — notes on signed / unsigned mixed-expression semantics and remaining context-sizing limits.
- `docs/hardening_checks.md` — reproducible local checks (unit suite, metrics smoke, static checks).
- `docs/power_diagnostics.md` — methodology for the planned RTL power hotspot diagnostics layer.
- `docs/pyslang_migration.md` — historical record of the pyverilog → pyslang migration (Phases A/B/C, completed).
- `plan.md` — current converter phase status and completed SV feature rollout list.
- `plan2.md` — phased implementation checklist for the planned power diagnostics feature.
