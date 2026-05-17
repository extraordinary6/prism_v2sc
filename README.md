# prism_v2sc

`prism_v2sc` is a lightweight prototype that converts a hierarchical Verilog RTL subset into approximate SystemC models.

The project currently supports:

- Pyverilog-based parsing and lowering into a structured JSON IR (with a tree-form expression sub-IR for expression-aware codegen)
- Hierarchical module emission as single-header SystemC (`prism_v2sc.hpp`)
- Verilog constructs handled by the codegen:
  - module ports / signals / parameters / localparams
  - continuous `assign`
  - `always @(*)` combinational processes (per-output style with proper staging)
  - `always @(posedge/negedge ...)` sequential processes with async reset
  - `if`/`else` and ordinary `case` statements
  - bit-select reads (`sig[i]`) and part-select reads (`sig[msb:lsb]`)
  - bit-select / part-select on the LHS of sequential assignments (via staged `__next_*`)
  - concatenation `{a, b, ...}` and replication `{N{x}}` in expressions
  - reduction operators `&x`, `|x`, `^x` and the inverted variants
  - ternary expressions and full binary/unary operator coverage
  - module instantiation with parameter override
  - `generate for` instance arrays and `generate if` (statically resolvable conditions)
- Phase 5/7 conversion metrics (time + memory + traversal counts + optional Verilator lint comparison)
- RTL vs SystemC functional equivalence CI (`.github/workflows/equivalence.yml`)

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
- `examples/alu_demo/`: single-file walkthrough (RTL + generated SystemC + reproduction command)
- `examples/filelist_demo/`: multi-file walkthrough driven by a `.f` filelist (covers `+incdir+`, `-D`, multi-source)

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
- `-I <dir>` and `-I<dir>` include directories
- `+incdir+<dir>` include directories
- `-D <macro[=value]>` and `-D<macro[=value]>` preprocessor defines
- nested `-f <filelist>` and `-f<filelist>` entries
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

The same report also includes Phase 7 flow counters:

- source-index and top-driven traversal timing
- source files parsed during reachable traversal
- modules parsed/lowered once after repeated-instantiation de-dup
- visited, missing, and ambiguous module lists
- truncation flags for captured external-tool stdout/stderr

## 5. Top-Down Reachability

Lowering/codegen is now driven by `--top` reachability using a lightweight module-to-source index:

- only modules reachable from the top instance graph are parsed/lowered/emitted
- repeated instantiations lower each module definition once
- unrelated modules present in input sources are ignored
- unknown instance target modules are reported via diagnostics (`unresolved_instance_module`)
- duplicate module definitions are reported via diagnostics (`ambiguous_module_definition`)

## 6. Diagnostics and Unsupported Constructs

Lowering collects unsupported/risky constructs into IR diagnostics:

- design-level: `design.diagnostics`
- module-level: `module.diagnostics`

Examples currently reported:

- `initial` blocks (parsed but not emitted as executable SystemC behavior)
- unsupported statements nested inside processes
- procedural `for` loops in `always/initial`
- unsupported generate items/patterns
- X/Z/? literals that are approximated as zero in generated C++ expressions
- modules with multiple procedural blocks where full Verilog event scheduling is approximated

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

### 7.1 RTL vs SystemC equivalence (CI)

The `equivalence` GitHub Actions workflow (`.github/workflows/equivalence.yml`)
runs on every push and pull request to `main`. For each fixture under
`tests/equivalence/fixtures/`, it converts the RTL with `prism-v2sc`, then
co-simulates the original Verilog (Icarus Verilog) and the generated
SystemC (libsystemc-dev) with a shared deterministic stimulus file, and
diffs the per-cycle output traces. The comparison is near-cycle-accurate
(inputs driven on negedge, outputs sampled after posedge); the harness
accepts a `--shift-tolerance` knob for designs whose SystemC model
legitimately lags the RTL by a fixed number of cycles.

See `tests/equivalence/README.md` for details on adding fixtures and
running the harness locally.

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

The current development priority is Verilog functional correctness before broad SystemVerilog expansion. The project does not yet have a full golden functional differential harness; Verilator integration currently provides lint/tool comparison, not output-equivalence proof.

See `docs/correctness_strategy.md`, `docs/known_differences.md`, and `docs/hardening_checks.md` for correctness priorities, known differences, and reproducible hardening commands.
