# Documentation Guide

This directory contains the current project documentation. Start with the
table below instead of reading every file in order.

## Input Boundary

`prism_v2sc` converts Verilog/SystemVerilog RTL (`.v`, `.sv`, and related
preprocessed sources). It does **not** compile or convert Chisel, FIRRTL,
Scala, or other RTL generators. For a generator-based project such as
XiangShan, the generated Verilog/SystemVerilog snapshot is an external
prerequisite and only that snapshot is in scope here.

| Document | Purpose | Read when |
| --- | --- | --- |
| `rtl_conversion_roadmap.md` | Current four-phase capability status, completed work, evidence rules, and benchmark workflow. This is the single progress tracker. | Checking project status or planning the next capability increment. |
| `syntax_coverage.md` | Detailed supported, approximated, rejected, and untested Verilog/SystemVerilog language surface. | Deciding whether an RTL construct is currently supported. |
| `known_differences.md` | Semantic differences between RTL simulation and generated approximate SystemC, including scheduling and two-state limitations. | Assessing correctness risk or interpreting warnings. |
| `correctness_strategy.md` | Verification layers: diagnostics, unit tests, differential traces, and real-design gates. | Understanding what a passing test proves. |
| `hardening_checks.md` | Reproducible local commands for unit tests, diagnostics, metrics, and generated-code checks. | Developing or validating a converter change. |
| `model_providers.md` | Manifest schema and provider framework for memory models, blackboxes, and non-convertible simulation modules. | Adapting a project containing vendor or simulation models. |
| `signed_mixed_semantics.md` | Width and signedness behavior for mixed signed/unsigned expressions. | Debugging arithmetic, comparison, shift, or cast differences. |
| `power_diagnostics.md` | Methodology, metrics, limitations, and interpretation of RTL power hotspot diagnostics. | Using or extending the power analysis features. |

Machine-readable companions:

| File | Purpose |
| --- | --- |
| `rtl_coverage_registry.json` | Evidence-linked feature status used by automated validation. |
| `diagnostic_policy.example.json` | Example project policy for allowed and fatal diagnostic codes. |

Real-design commands and detailed evaluation records live under
`verification/`. See `verification/README.md` for that workspace.
