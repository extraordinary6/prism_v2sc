# prism_v2sc Plan (Status-Based)

Last updated: 2026-05-16

This document reflects the **actual repository state** and defines the next phases.

## 1. Project Goal

`prism_v2sc` aims to translate a synthesizable Verilog RTL subset into hierarchical, readable, approximate SystemC models with explicit diagnostics and measurable conversion behavior.

Primary priorities:

- keep module hierarchy
- avoid unnecessary global flatten/unroll
- provide practical conversion for real RTL subsets
- report unsupported/risky constructs instead of silently miscompiling

## 2. Current Status Summary

Overall status: **Phase 0-6 baseline completed** with known gaps.

What is implemented now:

- multi-source Verilog input via positional CLI args and `--filelist`
- Pyverilog parse + module index + structured IR
- top-down reachable-module lowering based on `--top`
- SystemC single-header generation (`SC_MODULE`, instances, simple generate-for vectors)
- diagnostics in IR for unsupported constructs
- phase5 metrics harness:
  - elapsed time
  - Python allocation peak (`tracemalloc`)
  - observed process memory
  - optional Verilator lint timing/memory capture
- tests passing (`20 passed`)

What is not implemented yet:

- full streaming parse/elaboration
- broad SystemVerilog coverage
- full semantic equivalence (event scheduling/NBA corner cases/X/Z fidelity)

## 3. Milestone Status

### Phase 0: Project Skeleton

Status: **Done**

- package layout in `src/`
- CLI entrypoint
- pytest setup
- baseline docs and license

### Phase 1: AST and IR

Status: **Done**

- parse with Pyverilog
- module index + lowering to JSON IR
- IR model definitions for modules/ports/signals/processes/instances/generate-for

### Phase 2: Base SystemC Codegen

Status: **Done**

- header emission
- ports/signals/assign/always process emission for supported subset
- hierarchical instance members and binding

### Phase 3: Sequential Semantics

Status: **Done (current scope)**

Done:

- edge-sensitive process recognition (`posedge`/`negedge`)
- structured `if` emission in sequential methods
- always_ff staged next-state emission for nonblocking assignments
- procedural driver/conflict diagnostics:
  - multiple procedural writers on same target
  - multiple always_ff writers on same target
  - mixed blocking/nonblocking assignment style on same target
  - blocking assignment usage warning inside always_ff

Known limits:

- no full event-scheduler equivalence guarantee for all Verilog corner cases
- bit/part-select-sensitive conflict granularity is conservative at base-signal level

### Phase 4: Hierarchy and Parameters

Status: **Done (subset)**

- module instantiation
- parameter override template emission
- simple generate-for handling

Known limitation:

- generate bit-select bindings still include TODO fallback paths in some cases

### Phase 5: Robustness and Scale Metrics

Status: **Done (baseline)**

- realistic RTL subset test added
- diagnostics integrated and test-covered
- conversion metrics persisted to `metrics.json`
- Verilator comparison path added (including Windows/MSYS2/MinGW detection variants)

Known limitation:

- metrics currently keep full Verilator stdout/stderr payload; large designs may create large JSON files

## 4. New Requirement Added

User-requested addition: **filelist support must be part of near-term goals**.

This is now promoted into the next phase plan.

### Phase 6: Filelist and Top-Down Reachability

Status: **Done**

Completed:

1. Added `--filelist <path>` support (repeatable option).
2. Implemented `.f` style list parsing:
   - one path per line
   - ignores blank lines
   - ignores `#` and `//` comment lines
3. Merged filelist + positional sources with deterministic dedupe.
4. Added top-down reachable-module filtering from `--top`.
5. Added unresolved instance-module diagnostics for unknown references.
6. Added regression tests for:
   - filelist parsing
   - mixed positional + filelist mode
   - reachable-module pruning behavior
   - unresolved instance diagnostics

Known limits:

- filelist parser currently targets a simple `.f` subset and does not yet parse advanced options (`-I`, `+incdir+`, `-D`, nested `-f`).

## 5. Next Phases

### Phase 7: Flow and Memory Refinement

Status: **Planned**

Goals:

- module-by-module lowering/codegen pipeline to reduce peak residency
- metrics split by stage with clearer RSS semantics
- optional truncation/summarization for captured tool stdout/stderr

Exit criteria:

- measurable reduction or stable bounded peak memory on multi-file fixture set.
- reproducible benchmark command documented.

### Phase 8: Semantic Coverage Expansion

Status: **Planned**

Goals:

- improve process semantics (NBA discipline, conflict checks)
- expand supported statements and expression handling
- add known-differences manifest and stronger fail-fast policies

Exit criteria:

- expanded regression suite for new constructs
- explicit unsupported/difference reporting for remaining gaps

## 6. Risks and Mitigations

1. Pyverilog front-end limits for modern SV:
   - mitigation: constrain supported subset and keep diagnostics explicit
2. Semantic mismatch risk in complex scheduling:
   - mitigation: progressive coverage with differential checks, not silent fallback
3. Multi-file path and include complexity:
   - mitigation: strict normalization, deterministic file ordering, clear errors
4. Windows/MSYS2 toolchain variability:
   - mitigation: explicit executable discovery + environment inference + tests

## 7. Immediate Action Plan

Next implementation target is **Phase 7**:

1. add stage-level and per-module memory/timing breakdown
2. prototype module-by-module lowering/codegen residency control
3. add optional truncation for large external tool stdout/stderr in metrics
4. define reproducible benchmark command and fixture
5. update docs with benchmark and interpretation guidance
