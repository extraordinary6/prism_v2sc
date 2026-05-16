# prism_v2sc Plan (Status-Based)

Last updated: 2026-05-17

This document reflects the **actual repository state** and defines the next phases.

## 1. Project Goal

`prism_v2sc` aims to translate a synthesizable Verilog RTL subset into hierarchical, readable, approximate SystemC models with explicit diagnostics and measurable conversion behavior.

Primary priorities:

- keep module hierarchy
- avoid unnecessary global flatten/unroll
- provide practical conversion for real RTL subsets
- report unsupported/risky constructs instead of silently miscompiling

## 2. Current Status Summary

Overall status: **Phase 0-9 completed; SystemVerilog expansion still deferred** as planned.

What is implemented now:

- multi-source Verilog input via positional CLI args and `--filelist`
- Pyverilog parse + module index + structured IR with a tree-form expression sub-IR
- top-down reachable-module lowering based on `--top`
- SystemC single-header generation (`SC_MODULE`, instances, generate-for vectors, generate-if branch selection)
- Verilog expression coverage:
  - bit-select reads (`sig[i]`) and part-select reads (`sig[msb:lsb]`)
  - bit-select / part-select LHS in sequential blocks via staged `__next_*`
  - concatenation `{a, b, ...}` and replication `{N{x}}`
  - reduction operators `&x`, `|x`, `^x` and inverted forms
  - ternary, full binary/unary operator set, sized/unsized literals
- diagnostics in IR for unsupported constructs (now including unfoldable generate-if conditions)
- phase5 metrics harness:
  - elapsed time
  - Python allocation peak (`tracemalloc`)
  - observed process memory
  - source indexing and top-driven traversal timing
  - reachable source/module parse counts
  - captured external-tool stdout/stderr truncation flags
  - optional Verilator lint timing/memory capture
- **RTL vs SystemC functional differential CI on Linux** (`.github/workflows/equivalence.yml`):
  - 8 hardware-style fixtures (mux2, adder with concat/bit-select, byteswap, alu with case, counter, shift register, FSM, pipeline with replicate)
  - Icarus Verilog runs the RTL TB; libsystemc-dev runs the generated SystemC TB
  - per-cycle output trace diff with optional shift tolerance
- tests passing (50+ unit/integration tests covering frontend, codegen, expression coverage, CLI, phase5/7/8, hardening)

What is not implemented yet:

- per-instance generate-if expansion (currently uses the default parameter value)
- full semantic equivalence (event scheduling corner cases / X/Z fidelity)
- broad SystemVerilog coverage (deferred)

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
- structured expression sub-IR (`prism_v2sc.ir.expressions.lower_expr`) used by codegen

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
- bit-select / part-select LHS staging in always_ff
- procedural driver/conflict diagnostics:
  - multiple procedural writers on same target
  - multiple always_ff writers on same target
  - mixed blocking/nonblocking assignment style on same target
  - blocking assignment usage warning inside always_ff

### Phase 4: Hierarchy and Parameters

Status: **Done (subset)**

- module instantiation
- parameter override template emission
- simple generate-for handling
- generate-if branch selection for statically resolvable conditions

### Phase 5: Robustness and Scale Metrics

Status: **Done (baseline)**

- realistic RTL subset test added
- diagnostics integrated and test-covered
- conversion metrics persisted to `metrics.json`
- Verilator comparison path added (including Windows/MSYS2/MinGW detection variants)

### Phase 6: Filelist and Top-Down Reachability

Status: **Done**

### Phase 7: Flow and Memory Refinement

Status: **Done (baseline)**

### Phase 8: Semantic Coverage Expansion

Status: **Done**

### Phase 9: Verilog Expression Coverage + Differential CI

Status: **Done**

Done:

1. Added structured expression sub-IR (`lower_expr`/`render_rvalue`).
2. Tree-based SystemC codegen replacing the regex-substitution rvalue renderer.
3. Bit-select / part-select reads and writes.
4. Concatenation and replication with width inference.
5. Reduction operators via `and_reduce()`, `or_reduce()`, `xor_reduce()`.
6. `generate if` lowering with const-fold over local parameter values.
7. Phantom-sensitivity fix (sized literals no longer leak base prefixes into the sensitivity list).
8. Added 4 new hardware-style fixtures (alu, byteswap, shift_register, fsm_handshake) and restored the replicate-based pipeline / concat-based adder.
9. Added a GitHub Actions Linux workflow that iverilog/SystemC-co-simulates each fixture and diffs per-cycle traces.

## 6. Risks and Mitigations

1. Pyverilog front-end limits for modern SV:
   - mitigation: constrain supported subset and keep diagnostics explicit
2. Semantic mismatch risk in complex scheduling:
   - mitigation: progressive coverage with the new differential CI, not silent fallback
3. Multi-file path and include complexity:
   - mitigation: strict normalization, deterministic file ordering, clear errors
4. Windows/MSYS2 toolchain variability:
   - mitigation: explicit executable discovery + environment inference + tests

## 7. Direction Update

Current priority is **Verilog functional correctness before SystemVerilog expansion**.

Remaining Verilog-side hardening:

1. expand the equivalence CI fixture catalog (more FSM patterns, RAM-style memories, wider arithmetic, `casex`/`casez`)
2. tighten width inference for nested concat/repeat constructions
3. teach `generate if` to specialize per-instance rather than only on default parameter values
4. extend driver-conflict analysis to recognize concat-LHS targets

SystemVerilog expansion remains deferred until the Verilog subset has a green CI on a broader fixture set.
