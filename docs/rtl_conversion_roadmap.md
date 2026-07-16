# RTL Conversion Roadmap

This is the implementation and evidence ledger for moving prism-v2sc toward
reliable conversion of mainstream synthesizable RTL. Synthesis and downstream
netlist checks are intentionally out of scope for this roadmap.

The input boundary is explicit: the converter accepts Verilog/SystemVerilog
RTL and associated preprocessor inputs. Chisel, FIRRTL, Scala, and RTL
generator execution are outside the project. Generator-based designs are
benchmarked only from a fixed, externally generated Verilog/SystemVerilog
snapshot.

## Evidence rules

- `supported`: a focused differential or real-design regression exists.
- `supported_with_warning`: conversion is defined, but the semantic limitation
  is explicit and covered by a diagnostic contract.
- `modeled_by_provider`: behavior is supplied by a versioned provider and has
  an independent provider consistency test.
- `rejected`: the converter refuses the construct with an error diagnostic.
- `not_tested`: no support claim is allowed.

## Four phases

| Phase | Scope | Status | Evidence / next gate |
| --- | --- | --- | --- |
| 1 | Coverage registry, diagnostic policy, conversion audit | Complete | registry validator, `--conversion-audit`, `--diagnostic-policy`, unit tests |
| 2 | High-frequency RTL semantics, interfaces, memories, providers, differential fuzzing | Complete | 12 generated cases × 192 trace samples passed with VCS/SystemC C++14; focused and provider regressions also pass |
| 3 | Large-project source classification, staged conversion, provider/blackbox contracts | Complete | source/module audit plus `prism-v2sc-project`; E203 staged project conversion passed |
| 4 | Blind real-RTL benchmark and continuous coverage statistics | Complete | benchmark manifest/runner plus `verification/benchmark_baseline.json` with evidence-linked real-design baseline |

## Current baseline

The baseline includes focused trace fixtures, diagnostic fixtures, and real
design gates for E203, MHSA, OFDM FFT, ICB/APB, tinyNPU, and memory providers.
These are evidence for their listed contracts, not a universal RTL guarantee.

## Stage 1 deliverables

- `docs/rtl_coverage_registry.json` is the machine-readable feature contract.
- `docs/diagnostic_policy.example.json` documents policy syntax.
- `--conversion-audit <path>` records source count, reachable modules,
  generated modules, providers, diagnostics, and policy status.
- `--diagnostic-policy <path>` allows a project to explicitly allow or deny
  diagnostic codes; the default behavior remains unchanged.

The checked-in registry is validated by `tests/test_coverage_registry.py`; a
non-`not_tested` claim must point to an existing evidence artifact.

## Staged project conversion

Large designs can be split into ordered stages with independent tops,
filelists, model manifests, and diagnostic policies:

```bash
.venv/bin/python -m prism_v2sc.project project.json
```

The runner writes one SystemC/audit directory per stage and a final
`project_report.json`. A stage depending on a failed or skipped stage is never
run and is recorded as `skipped_dependency`.

## Benchmark execution

List the maintained real-design gates:

```bash
.venv/bin/python verification/run_benchmark_suite.py --list
```

Run selected gates and write a machine-readable result report:

```bash
.venv/bin/python verification/run_benchmark_suite.py \
  --cases e203_cpu memory_provider \
  --output build/benchmark_report.json
```

An unavailable external checkout is recorded as `unavailable`; a functional
failure is recorded as `failed`; an environment failure such as an unavailable
EDA license is recorded as `infrastructure_failed`. None of these are turned
into a pass.

The checked-in baseline at `verification/benchmark_baseline.json` is separate
from live runner output. It links each pass claim to the corresponding real
design evaluation note and records the contract-specific count (scenarios,
keypoints, trace cases, events, or memory modes).

The roadmap is updated only when an implementation and its evidence both land.
