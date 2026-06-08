```text
 ____  ____  ___ ____  __  __     __     ______ ____   ____ 
|  _ \|  _ \|_ _/ ___||  \/  |    \ \   / /___ \ ___| / ___|
| |_) | |_) || |\___ \| |\/| |     \ \ / /  __) \___ \| |    
|  __/|  _ < | | ___) | |  | |      \ V /  / __/ ___) | |___ 
|_|   |_| \_\___|____/|_|  |_|       \_/  |_____|____/ \____|
```

<p align="center">
  <a href="README.md">English</a> |
  <a href="README_zh.md">中文</a>
</p>

<p align="center">
  <img alt="Python 3.10+" src="https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white">
  <img alt="pyslang 11.x" src="https://img.shields.io/badge/pyslang-11.x-4B5563">
  <img alt="SystemC CI verified" src="https://img.shields.io/badge/SystemC-CI%20verified-16A34A">
  <img alt="154 tests" src="https://img.shields.io/badge/tests-154%20collected-0EA5E9">
  <img alt="Power diagnostics" src="https://img.shields.io/badge/power-diagnostics-F59E0B">
</p>

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
| `--power-static` | run IR-only power suspect analysis and write `power_static.json` |
| `--power-instrument <manifest>` | emit instrumented SystemC and write a probe manifest |
| `--power-report <profile.json>` | score a collected profile and write `power_report.json` |

A `.f` filelist accepts one file per line plus `-I`/`+incdir+` includes, `-D` defines, `-f` nested filelists, and `#`/`//` comments.

Power options also include `--power-report-static <json>`, `--power-all-signals`, `--power-probe-ports`, `--power-memory-cells`, and `--power-deep-profile`.

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
| `examples/power_demo/` | small RTL examples for static power suspects |

## Power Diagnostics

The power diagnostics path is implemented as an advisory RTL-stage hotspot tool. It reports relative, workload-scoped activity and structural risks; it does not produce absolute watts, signoff power, or measured glitch power.

Static analysis is pure Python and does not require SystemC:

```powershell
python -m prism_v2sc --top wide_reg_no_enable --power-static `
  --power-static-output build/power_static.json `
  examples/power_demo/wide_reg_no_enable.v
```

Dynamic profiling is opt-in. First generate instrumented SystemC plus a probe manifest:

```powershell
python -m prism_v2sc --top wide_reg_no_enable --out build/power_systemc `
  --power-instrument build/probe_manifest.json `
  examples/power_demo/wide_reg_no_enable.v
```

Then link the generated top header into a SystemC workload/testbench, run that workload, and call `dut.prism_power_dump(std::ostream&)` to dump counters. Convert that dump into a `power_profile.json` with `prism_v2sc.power.runner.create_power_profile_json(...)`, or provide an equivalent JSON profile with `workload` metadata and `probes` counters.

Finally score the profile:

```powershell
python -m prism_v2sc --power-report build/power_profile.json `
  --power-report-static build/power_static.json `
  --power-report-output build/power_report.json
```

Generated reports include ranked hotspots, per-probe metrics (`total_bit_toggles`, `toggle_rate`, `change_rate`, `idle_ratio`, `width_weighted_activity`), static reason codes, recommendations, confidence labels, and explicit limitations. Deep profiling can be enabled with `--power-deep-profile`; it adds per-bit and T1-style counters for top-K follow-up analysis. Memory-cell probes are opt-in and capped via the probe planner guardrails.

## Tests

```powershell
python -m pytest -q
```

The suite currently collects 154 tests covering IR lowering, codegen output shape, CLI behavior, multi-file output layout, expression coverage, diagnostics, hardening, subroutines, static power analysis, probe planning, instrumentation shape, profile parsing, scoring, deep profiling, workload comparison, and power report stability.

## Equivalence CI

`.github/workflows/equivalence.yml` runs on Linux. For each fixture under `tests/equivalence/fixtures/` it co-simulates the original RTL (Icarus Verilog) and the generated SystemC (libsystemc-dev) against a shared deterministic stimulus and diffs the per-cycle output traces. See `tests/equivalence/README.md` for fixture list, local usage, and environment overrides.

Local trace-equivalence and dynamic power smoke runs require SystemC headers and libraries. On machines without `<systemc>` available, use the Python unit suite plus `tests/equivalence/run_equivalence.py --dry-run --keep-going` for conversion coverage, and rely on CI for the final SystemC compile/run checks.

The Linux CI installs `libsystemc-dev`, runs the full pytest suite, and then runs `tests/equivalence/run_equivalence.py --keep-going`. That full pytest run includes Linux-only power checks that compile/run an instrumented SystemC design, parse `prism_power_dump` output, and compare instrumented vs uninstrumented SystemC traces. This is the intended coverage path when local SystemC is not installed.

## Further Reading

- `docs/correctness_strategy.md` — how correctness is established and what the golden loop looks like.
- `docs/syntax_coverage.md` — what RTL surface is verified by the equivalence CI, what is explicitly rejected, and what is queued for Phase 11.
- `docs/known_differences.md` — explicit list of where generated SystemC diverges from full Verilog/SV semantics.
- `docs/signed_mixed_semantics.md` — notes on signed / unsigned mixed-expression semantics and remaining context-sizing limits.
- `docs/hardening_checks.md` — reproducible local checks (unit suite, metrics smoke, static checks).
- `docs/power_diagnostics.md` — methodology for the RTL power hotspot diagnostics layer.
- `docs/pyslang_migration.md` — historical record of the pyverilog → pyslang migration (Phases A/B/C, completed).
- `docs/plan.md` — current converter phase status and completed SV feature rollout list.
- `docs/plan2.md` — completed phased implementation checklist for the power diagnostics feature.
