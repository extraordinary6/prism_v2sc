```text
 ____  ____  ___ ____  __  __     __     ______ ____   ____
|  _ \|  _ \|_ _/ ___||  \/  |    \ \   / /___ \ ___| / ___|
| |_) | |_) || |\___ \| |\/| |     \ \ / /  __) \___ \| |
|  __/|  _ < | | ___) | |  | |      \ V /  / __/ ___) | |___
|_|   |_| \_\___|____/|_|  |_|       \_/  |_____|____/ \____|
```

<p align="center">
  <a href="README.md">English</a> |
  <a href="README_zh.md">Chinese</a>
</p>

<p align="center">
  <img alt="Python 3.10+" src="https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white">
  <img alt="pyslang 11.x" src="https://img.shields.io/badge/pyslang-11.x-4B5563">
  <img alt="SystemC CI verified" src="https://img.shields.io/badge/SystemC-CI%20verified-16A34A">
  <img alt="156 tests" src="https://img.shields.io/badge/tests-156%20collected-0EA5E9">
  <img alt="Power diagnostics" src="https://img.shields.io/badge/power-diagnostics-F59E0B">
</p>

# prism_v2sc

`prism_v2sc` converts a synthesizable Verilog / SystemVerilog RTL subset into hierarchical, approximate SystemC models. It emits one `.hpp` per reachable module and mirrors the RTL source directory layout.

The frontend uses [slang](https://sv-lang.com/) through [pyslang](https://pypi.org/project/pyslang/). slang parses and elaborates the whole design first, so parameter overrides, `generate if`, `generate for`, and concrete port widths are resolved before lowering.

This is a practical RTL subset translator, not a full SystemVerilog semantic equivalent. Unsupported constructs are reported as diagnostics instead of being silently miscompiled.

## Install

```powershell
python -m pip install -e .
```

Requirements: Python 3.10+ and `pyslang>=11.0,<12.0`. SystemC is only needed when compiling/running generated SystemC locally; Linux CI installs it for full verification.

## CLI

Basic conversion:

```powershell
python -m prism_v2sc --top <module> [options] [<sources...>]
```

Multi-file conversion through a filelist:

```powershell
python -m prism_v2sc --top top_datapath `
  --filelist examples\filelist_demo\rtl\sources.f `
  --out build\systemc_filelist
```

Core options:

| flag | purpose |
| --- | --- |
| `--top <name>` | Top-level RTL module. Required for conversion, static power analysis, and instrumentation. |
| `<sources...>` | Positional Verilog/SystemVerilog source files. Can be combined with `--filelist`; duplicates are removed. |
| `--filelist <path>` | `.f`-style filelist. Can be repeated. Paths inside the filelist are resolved relative to that filelist. |
| `--out <dir>` | Output directory for generated SystemC and `ir.json`. Default: `build/systemc`. |
| `--dump-ir` | Print the JSON IR to stdout instead of writing `ir.json`. |
| `--metrics` | Write `metrics.json` with timing, memory, and traversal counters. |
| `--compare-verilator` | Run best-effort `verilator --lint-only` for the same inputs and record timing. |
| `--fail-on-diagnostics` | Return exit code `2` when error-level diagnostics are present. |
| `--version` | Print the package version. |

Filelists support:

```text
# comments and blank lines are ignored
+incdir+include
-I ../shared/include
-D USE_FAST_PATH
-D WIDTH=32
-f nested_sources.f
rtl/child.v
rtl/top.v
```

Power options:

| flag | purpose |
| --- | --- |
| `--power-static` | Run static RTL power suspect analysis and write `power_static.json`. |
| `--power-static-output <file>` | Output path for static analysis. Default: `power_static.json`. |
| `--power-instrument <manifest>` | Generate instrumented SystemC and write a probe manifest. |
| `--power-all-signals` | Probe all eligible signals instead of only state registers plus combinational suspects. |
| `--power-probe-ports` | Include module ports in probe plans. |
| `--power-memory-cells` | Include capped per-cell probes for unpacked-array memories. |
| `--power-deep-profile` | Add per-bit toggle counters and high-cycle counters for deeper profiling. |
| `--power-profile-dump <csv>` | Convert a `prism_power_dump` CSV from a real SystemC workload into `power_profile.json`. |
| `--power-profile-output <file>` | Output path for `--power-profile-dump`. Default: `power_profile.json`. |
| `--power-workload-name <name>` | Workload name stored in `power_profile.json`. |
| `--power-workload-cycles <n>` | Total workload cycles stored in `power_profile.json`. |
| `--power-profile-top <module>` | Top module metadata for a profile conversion command. |
| `--power-profile-source <path>` | Source/filelist metadata for a profile conversion command. Repeatable. |
| `--power-vector-file <path>` | Optional vector file metadata; the converter records its SHA-256. |
| `--power-seed <n>` | Optional workload random seed metadata. |
| `--power-reset-cycles <n>` | Reset cycle metadata. |
| `--power-report <profile.json>` | Score a collected profile and write `power_report.json`. |
| `--power-report-static <json>` | Static analysis JSON to join with dynamic activity. |
| `--power-report-output <file>` | Output path for the scored report. Default: `power_report.json`. |

## Output Layout

```text
build/systemc/
|-- ir.json
|-- <module>.hpp
`-- <nested>/<module>.hpp
```

Each generated module header includes the headers for the child modules it instantiates. Include the generated top header from your SystemC testbench; child headers are pulled in transitively.

## How It Works

1. slang reads every source at once and creates an elaborated `Compilation`.
2. `prism_v2sc` walks the instance tree rooted at `--top` and lowers only reachable modules into `ModuleIR`.
3. Codegen writes one `.hpp` per module in post-order DFS, so child headers exist before parent headers reference them.
4. Diagnostics from slang and from the lowerer are stored in the IR and summarized at the end of the run.

## Examples

| location | scope |
| --- | --- |
| `examples/alu_demo/` | Single-file 8-bit ALU showing `case`, concat, and bit-select. |
| `examples/filelist_demo/` | Multi-file build driven by a `.f` filelist with `+incdir+` and `-D`. |
| `examples/power_demo/` | Small single-module RTL examples for static power suspects. |
| `examples/power_multimodule_demo/` | Multi-module filelist-driven power demo with generated reports and instrumented SystemC. |

## Power Diagnostics

Power diagnostics are advisory RTL-stage hotspot diagnostics. They report relative, workload-scoped activity and structural risks. They do not produce absolute watts, signoff power, or measured glitch power.

### 1. Static Analysis

Static analysis does not need SystemC:

```powershell
python -m prism_v2sc --top power_soc_top `
  --filelist examples\power_multimodule_demo\rtl\sources.f `
  --power-static `
  --power-static-output build\power_static.json
```

The output `power_static.json` contains static suspects such as:

- `clock_gating_candidate`: wide state that may benefit from enable/clock gating.
- `counter_activity_candidate`: counter-like state update patterns.
- `wide_mux_candidate`: wide mux logic.
- `high_fanout_candidate`: control signals feeding many destinations.
- `glitch_risk_structural`: deep combinational logic that may glitch.

### 2. Generate Instrumented SystemC

```powershell
python -m prism_v2sc --top power_soc_top `
  --filelist examples\power_multimodule_demo\rtl\sources.f `
  --out build\power_systemc `
  --power-instrument build\probe_manifest.json `
  --power-all-signals `
  --power-deep-profile
```

This writes instrumented headers under `build/power_systemc/` and a `probe_manifest.json`. By default, probe planning always includes state registers and adds selected combinational suspects. `--power-all-signals` broadens that to all eligible combinational signals; `--power-deep-profile` adds per-bit and high-cycle counters.

If a generated top module exposes `__power_sample_strobe`, bind it in your SystemC workload and pulse it once per sample point. Generated parent modules automatically pass that strobe into instrumented child modules that need it.

### 3. Run A Real Workload

Your workload/testbench drives the generated top module with real vectors or traffic. After the run, call only the top-level dump API:

```cpp
#include "top/power_soc_top.hpp"
#include <systemc>
#include <fstream>

int sc_main(int argc, char** argv) {
  sc_clock clk("clk", 10, SC_NS);
  sc_signal<bool> rst_n, start, power_sample_strobe;
  sc_signal<sc_uint<4>> command;
  sc_signal<sc_uint<64>> data_a, data_b, data_c, data_d, result;
  sc_signal<sc_uint<16>> packets;

  power_soc_top dut("dut");
  dut.clk(clk);
  dut.rst_n(rst_n);
  dut.start(start);
  dut.command(command);
  dut.data_a(data_a);
  dut.data_b(data_b);
  dut.data_c(data_c);
  dut.data_d(data_d);
  dut.result(result);
  dut.packets(packets);
  dut.__power_sample_strobe(power_sample_strobe);

  // Drive reset and real workload vectors here. Pulse power_sample_strobe
  // at the sample point you want to use for combinational probes.

  std::ofstream csv("build/power_dump.csv");
  dut.prism_power_dump(csv);
  return 0;
}
```

`dut.prism_power_dump(csv)` recursively dumps all instrumented reachable child modules and writes one CSV header. The CSV contains both `module` and `instance_path`, so reports can point to hierarchical locations such as `dut.u_alu`.

### 4. Convert CSV To Profile JSON

```powershell
python -m prism_v2sc --power-profile-dump build\power_dump.csv `
  --power-profile-output build\power_profile.json `
  --power-workload-name real_vectors_smoke `
  --power-workload-cycles 1000 `
  --power-profile-top power_soc_top `
  --power-profile-source examples/power_multimodule_demo/rtl/sources.f `
  --power-vector-file vectors/real_vectors.txt `
  --power-seed 1 `
  --power-reset-cycles 5
```

This command parses the raw CSV from `prism_power_dump`, preserves per-probe counters, records workload metadata, and hashes the vector file when one is provided.

### 5. Generate The Power Report

```powershell
python -m prism_v2sc --power-report build\power_profile.json `
  --power-report-static build\power_static.json `
  --power-report-output build\power_report.json
```

The report contains ranked hotspots, per-probe metrics (`total_bit_toggles`, `toggle_rate`, `change_rate`, `idle_ratio`, `width_weighted_activity`), static reason codes, recommendations, confidence labels, instance paths, and explicit limitations.

## Tests

```powershell
python -m pytest -q
```

The suite currently collects 156 tests covering IR lowering, codegen output shape, CLI behavior, multi-file output layout, expression coverage, diagnostics, hardening, subroutines, static power analysis, probe planning, instrumentation shape, recursive power dump generation, profile parsing, scoring, deep profiling, workload comparison, and power report stability.

## Equivalence CI

`.github/workflows/equivalence.yml` runs on Linux. It co-simulates RTL fixtures with Icarus Verilog and generated SystemC with `libsystemc-dev`, then diffs per-cycle traces. The CI also runs Linux-only power checks that compile and run instrumented SystemC, parse `prism_power_dump` output, and compare instrumented and uninstrumented traces.

Local trace-equivalence and dynamic power smoke runs require SystemC headers and libraries. On machines without `<systemc>`, run the Python unit suite locally and rely on Linux CI for final SystemC compile/run checks.

## Further Reading

- `docs/correctness_strategy.md`: correctness strategy and golden loop.
- `docs/syntax_coverage.md`: verified RTL surface and queued support.
- `docs/known_differences.md`: known semantic differences from full Verilog/SV.
- `docs/signed_mixed_semantics.md`: signed/unsigned mixed-expression notes.
- `docs/hardening_checks.md`: reproducible local checks.
- `docs/power_diagnostics.md`: RTL power hotspot methodology.
- `docs/pyslang_migration.md`: pyverilog to pyslang migration record.
- `docs/plan.md`: converter phase status.
- `docs/plan2.md`: completed power diagnostics implementation checklist.
