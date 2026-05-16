# prism_v2sc

`prism_v2sc` is a lightweight prototype that converts a hierarchical Verilog RTL subset into approximate SystemC models.

The project currently supports:

- Pyverilog-based parsing and lowering into a structured JSON IR
- Hierarchical module emission as single-header SystemC (`prism_v2sc.hpp`)
- Basic handling for:
  - module ports/signals/parameters
  - continuous `assign`
  - simple `always @(*)` combinational processes
  - simple edge-triggered `always @(posedge/negedge ...)`
  - module instantiation with parameter override
  - simple `generate for` instance arrays
- Phase 5 conversion metrics (time + memory + optional Verilator lint comparison)

It intentionally does **not** guarantee full Verilog/SystemVerilog semantic equivalence.

## 1. Requirements

- Python 3.10+
- `pyverilog>=1.3.0`

Install dependencies in your environment:

```powershell
python -m pip install -e .
```

or:

```powershell
python -m pip install pyverilog
```

## 2. Project Layout

Key paths:

- `src/prism_v2sc/cli.py`: CLI entrypoint
- `src/prism_v2sc/frontend/`: parse/lower pipeline
- `src/prism_v2sc/codegen/`: SystemC emission
- `src/prism_v2sc/verify/harness.py`: phase5 metrics + optional Verilator comparison
- `tests/`: unit/integration tests and RTL fixtures

## 3. CLI Usage

Run via module:

```powershell
python -m prism_v2sc --top <top_module> [options] [<verilog_sources...>]
```

### Core options

- `--top <name>`: top module name (required)
- `--filelist <path>`: `.f` style source list (can be provided multiple times)
- `--out <dir>`: output directory (default: `build/systemc`)
- `--dump-ir`: print JSON IR to stdout instead of writing output files

### Phase 5 options

- `--metrics`: write `metrics.json`
- `--compare-verilator`: run best-effort `verilator --lint-only` timing/memory measurement
- `--fail-on-diagnostics`: return non-zero if error-level diagnostics are found

## 4. Typical Workflows

### 4.1 Dump IR only

```powershell
python -m prism_v2sc --top top --dump-ir rtl/top.v
```

### 4.2 Generate IR + SystemC header

```powershell
python -m prism_v2sc --top top --out build/systemc rtl/top.v
```

Outputs:

- `build/systemc/ir.json`
- `build/systemc/prism_v2sc.hpp`

### 4.3 Generate with phase5 metrics

```powershell
python -m prism_v2sc --top top --metrics --out build/systemc rtl/top.v
```

Additional output:

- `build/systemc/metrics.json`

### 4.4 Use filelist input

```powershell
python -m prism_v2sc --top top --filelist rtl/sources.f --out build/systemc
```

`sources.f` currently supports:

- one file path per line
- blank lines
- comment lines starting with `#` or `//`

You can combine positional sources and filelist sources. The tool resolves absolute paths and de-duplicates repeated entries deterministically.

### 4.5 Include Verilator comparison

```powershell
python -m prism_v2sc --top top --metrics --compare-verilator --out build/systemc rtl/top.v
```

If Verilator is discoverable, `metrics.json` includes:

- availability + executable path
- lint elapsed time
- peak observed Verilator process memory
- captured stdout/stderr

## 5. Top-Down Reachability

Lowering/codegen is now driven by `--top` reachability:

- only modules reachable from the top instance graph are lowered/emitted
- unrelated modules present in input sources are ignored
- unknown instance target modules are reported via diagnostics (`unresolved_instance_module`)

## 6. Diagnostics and Unsupported Constructs

Lowering collects unsupported/risky constructs into IR diagnostics:

- design-level: `design.diagnostics`
- module-level: `module.diagnostics`

Examples currently reported:

- `initial` blocks (parsed but not emitted as executable SystemC behavior)
- `case` statements in processes
- procedural `for` loops in `always/initial`
- unsupported generate items/patterns

Use `--fail-on-diagnostics` in CI to hard-fail when error diagnostics are present.

## 7. Testing

Run all tests:

```powershell
python -m pytest -q
```

Current test coverage includes:

- CLI behavior and output generation
- frontend lowering checks
- SystemC header generation for hierarchy/parameters/generate-for
- phase5 metrics and diagnostics behavior

## 8. Notes on Verilator Detection (Windows/MSYS2/MinGW)

The harness supports multiple discovery patterns, including common wrapper/binary layouts used by MSYS2/MinGW installs.

If your environment still reports Verilator unavailable, confirm:

1. the Verilator command is reachable from the same shell running Python
2. required helper binaries/interpreter are in `PATH`
3. `verilator --version` succeeds in that shell

## 9. Scope and Limitations

This tool is currently a pragmatic RTL-subset translator. It prioritizes:

- hierarchy preservation
- practical conversion and iteration speed
- explicit diagnostics over silent mis-compilation

It does not yet implement full scheduling-accurate equivalence for all language features.
