# E203 CPU conversion example

This example is a self-contained, read-only snapshot of the E203 RISC-V CPU
RTL. It demonstrates converting a non-trivial multi-module CPU through a local
filelist and a model manifest.

## Layout

```text
examples/e203_cpu/
├── rtl/e203/        # copied RTL snapshot, including core, SoC, debug and peripherals
├── sources.f        # verified e203_cpu_top design view (51 RTL sources)
├── models.json       # sirv_sim_ram memory-provider configuration
├── generated/        # generated IR, model report, and SystemC headers
└── README.md
```

The complete upstream `rtl/e203` tree is included so the example can be
extended without depending on the external checkout. The default `sources.f`
selects the CPU-core design view used by the current evaluation: 51 sources,
top module `e203_cpu_top`, and the required `core`, `general`, and `subsys`
files. The copied `soc/`, `perips/`, `debug/`, `fab/`, and `mems/` sources are
available, but are not implicitly claimed as converted or verified by this
example.

## Convert

Run from the repository root. The checked-in `generated/` directory contains
the output of this command and can be regenerated when the converter or input
example changes.

```bash
.venv/bin/python -m prism_v2sc \
  --top e203_cpu_top \
  --filelist examples/e203_cpu/sources.f \
  --model-manifest examples/e203_cpu/models.json \
  --fail-on-diagnostics \
  --out examples/e203_cpu/generated
```

The conversion produces `ir.json`, `model_report.json`, and one SystemC header
per reachable module under `generated/`. The model manifest replaces
the parameterized `sirv_sim_ram` simulation model with the configured memory
provider; the RTL source itself is unchanged.

The same design is also available as a project-level staged conversion:

```bash
.venv/bin/python -m prism_v2sc.project examples/e203_cpu/project.json
```

This writes the generated stage, its `conversion_audit.json`, and a project
summary to `examples/e203_cpu/project_build/`. The project manifest format is
intended for larger repositories with multiple ordered subsystem stages.

For a quick compile check with the project's SystemC installation:

```bash
g++ -std=c++14 -fsyntax-only \
  -I/usr/local/systemc-2.3.4/include \
  -Iexamples/e203_cpu/generated \
  -include examples/e203_cpu/generated/core/e203_cpu_top.hpp \
  -x c++ /dev/null
```

## Consistency evaluation

The maintained E203 harness exercises six representative programs:
`baseline`, `alu_branch`, `muldiv_bytes`, `signed_divzero`, `csr`, and
`timer_irq`.

```bash
.venv/bin/python verification/cases/consistency/e203_cpu_consistency.py
```

That harness is the authoritative full regression and currently uses the
external E203 checkout and its verification filelist. The conversion command
above independently proves that the checked-in copy is self-contained. The
current evaluation checks key architectural time points and DTCM results with
approximately cycle-accurate timing; it is not a formal proof or a strict
cycle-by-cycle equivalence claim.

Known simulator-only assertions and similar verification constructs are
excluded by the synthesis define and are not part of the converted functional
model. Warnings should be reviewed, but the documented E203 run completed with
zero error diagnostics and compiled SystemC output.
