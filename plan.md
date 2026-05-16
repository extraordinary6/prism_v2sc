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

Overall status: **Phase 0-5 baseline completed** with known gaps.

What is implemented now:

- multi-source Verilog input via positional CLI args
- Pyverilog parse + module index + structured IR
- SystemC single-header generation (`SC_MODULE`, instances, simple generate-for vectors)
- diagnostics in IR for unsupported constructs
- phase5 metrics harness:
  - elapsed time
  - Python allocation peak (`tracemalloc`)
  - observed process memory
  - optional Verilator lint timing/memory capture
- tests passing (`16 passed`)

What is not implemented yet:

- native `--filelist` input support
- true top-down reachable-module lowering/codegen
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

## 5. Next Phases

### Phase 6: Filelist and Top-Down Reachability

Status: **Planned (next)**

Goals:

1. Add `--filelist <path>` support.
2. Support common `.f` style list parsing:
   - one path per line
   - ignore blank lines
   - ignore `#` and `//` comment lines
3. Merge filelist sources with positional sources safely (deterministic ordering, dedupe).
4. Add top-down reachable-module filtering from `--top`:
   - only lower/generate modules reachable from top instance graph
   - keep diagnostics for unresolved/unknown module references
5. Add tests for:
   - filelist parsing
   - mixed positional + filelist mode
   - reachable-module pruning behavior

Exit criteria:

- CLI accepts both direct files and filelist.
- top-down reachable conversion works on multi-file hierarchical fixtures.
- test suite remains green.

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

Next implementation target is **Phase 6**:

1. implement `--filelist`
2. add source aggregation/normalization layer
3. add top-down reachable-module filtering
4. add corresponding CLI/frontend tests
5. update README usage examples for filelist mode
