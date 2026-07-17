# E603 CPU conversion example

This example is a self-contained, read-only snapshot of the E603 RISC-V CPU
RTL. It demonstrates converting a large flattened CPU hierarchy together with
its synthesizable SRAM wrappers through a local filelist and model manifest.

## Layout

```text
examples/e603_cpu/
├── rtl/e603/        # copied RTL snapshot: core, SoC wrappers, and technology cells
├── sources.f        # verified e603_core_rams design view (9 RTL sources)
├── models.json      # e603_sim_ram memory-provider configuration
├── generated/       # generated model report and SystemC headers
├── project.json     # staged-project conversion manifest
├── project_build/   # checked-in staged-project output
└── README.md
```

The external RTL is copied without modification. `sources.f` defines
`SYNTHESIS`, so assertion and other verification-only content is outside the
functional conversion view.

## Convert

Run from the repository root. The checked-in `generated/` directory contains
the output of this command:

```bash
.venv/bin/python -m prism_v2sc \
  --top e603_core_rams \
  --filelist examples/e603_cpu/sources.f \
  --model-manifest examples/e603_cpu/models.json \
  --fail-on-diagnostics \
  --no-ir \
  --out examples/e603_cpu/generated
```

The conversion produces `model_report.json` and one SystemC header per
reachable or parameter-specialized module. A complete E603 `ir.json` is about
137 MiB, so this checked-in example uses `--no-ir` to remain compatible with
normal Git hosting limits. The model manifest replaces
`e603_sim_ram` with the configured synchronous memory provider; the copied RTL
source remains unchanged.

For compile-oriented output on larger servers:

```bash
.venv/bin/python -m prism_v2sc \
  --top e603_core_rams \
  --filelist examples/e603_cpu/sources.f \
  --model-manifest examples/e603_cpu/models.json \
  --compile-friendly --incremental-codegen --no-ir \
  --out /tmp/e603_systemc_optimized
```

The compile-friendly form uses a shared runtime header, out-of-line methods,
and implementation chunks suitable for the cached `prism_v2sc.systemc_build`
builder. It is intentionally not duplicated under this example because its
implementation chunks are much larger than the normal inspectable output.

The same design is available as a staged project conversion:

```bash
.venv/bin/python -m prism_v2sc.project examples/e603_cpu/project.json
```

This writes the stage output, `conversion_audit.json`, and project summary to
`examples/e603_cpu/project_build/`. The stage sets `"no_ir": true` for the same
repository-size reason; smaller stages retain the default IR output.

For a quick C++14/SystemC syntax check:

```bash
g++ -std=c++14 -fsyntax-only \
  -I/usr/local/systemc-2.3.4/include \
  -Iexamples/e603_cpu/generated/core \
  -Iexamples/e603_cpu/generated/soc \
  -Iexamples/e603_cpu/generated/tech \
  -include examples/e603_cpu/generated/core/e603_core_rams.hpp \
  -x c++ /dev/null
```

## Verification scope

The maintained evaluation uses approximate cycle consistency at the first
architectural fetch event. For the exercised reset configuration, RTL and
SystemC both issue the first request at cycle 18 with address `0x80000000` and
matching AXI ID and burst length. This is a real-design conversion and key-event
gate, not full per-cycle or formal equivalence of every CPU state.

Run the maintained E603 gate directly:

```bash
.venv/bin/python verification/cases/consistency/e603_cpu_consistency.py
```

Run it together with every registered real-design gate:

```bash
.venv/bin/python verification/run_benchmark_suite.py \
  --output /tmp/full_benchmark_report.json
```

See `verification/notes/e603_cpu_real_design_eval.md` for build measurements,
fixed converter defects, and the current proof boundary.
