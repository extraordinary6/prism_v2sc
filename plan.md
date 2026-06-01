# prism_v2sc Plan

Last updated: 2026-05-20.

This document tracks **what is implemented right now** and **what is queued next**. It is not a roadmap of aspirations; entries land here only after they exist in the code.

## Current State

Frontend:

- slang (via pyslang) parses and fully elaborates every source into a single `Compilation`.
- The flow walks the elaborated instance tree rooted at `--top`. Only reachable modules are lowered; repeated instantiations lower exactly once.
- slang's elaboration diagnostics (`slang_UnknownModule`, `slang_DuplicateDefinition`, …) are surfaced as `DiagnosticIR` entries on the `DesignIR`.

IR:

- `ModuleIR` carries ports, signals, parameters, continuous assigns, processes, and instances.
- Expressions are a JSON-serializable dict tree (schema documented in `prism_v2sc.codegen.expr`).
- Sized literals (`3'b101`, `8'hFF`, …) carry both the original `raw` text and the resolved integer `value`.

Codegen:

- One `.hpp` per module, output directory mirrors the RTL source tree.
- **Bottom-up streaming emission** (post-order DFS): a parent's header lands on disk only after every child header is already written.
- Per-output `__next_<signal>` staging pattern keeps bit-select / part-select LHS and case-default branches correct under `SC_METHOD` semantics.
- Concatenation `{a, b}` and replication `{N{x}}` lower to explicit shift-OR chains with `sc_uint<W>` casts.

Supported RTL surface (with equivalence CI):

- module hierarchy, parameter override (slang resolves before lowering)
- continuous `assign`, `always @(*)`, `always @(posedge/negedge ...)` with async reset
- `if`/`else`, ordinary `case`, ternary, full binary/unary operators
- bit-select / part-select reads and writes
- concatenation, replication, reduction operators
- positional and named instance bindings (positional resolved via cached child signature)
- synthesizable SV `function`
- `generate for` (slang unrolls) and `generate if` (slang folds)

Metrics & verification:

- Phase 5 metrics (`metrics.json`): wall time, Python allocation peak, observed process RSS, slang parse & traversal elapsed time, module/source counts, optional `verilator --lint-only` capture.
- Static checks on generated SystemC (TODO markers, missing `<systemc>`, missing `SC_MODULE`).
- 76 unit/integration tests under `tests/` (`python -m pytest -q`).
- Differential CI co-simulates RTL via Icarus Verilog and generated SystemC via libsystemc-dev for **21 trace fixtures**, and asserts diagnostic codes for **6 rejection / approximation fixtures** under `tests/equivalence/fixtures/diagnostics/` (`.github/workflows/equivalence.yml`).
- Dedicated pyslang wheel smoke job (`.github/workflows/pyslang_smoke.yml`) guarding against upstream wheel regressions on Linux + Windows / Python 3.11–3.12.

## Phases Completed

| Phase | Outcome |
| --- | --- |
| 0 – Skeleton | Package layout, CLI entry point, pytest scaffolding. |
| 1 – Parse + IR | Source ingest and JSON IR (now driven by slang). |
| 2 – Base codegen | SystemC header emission for ports/signals/assigns/processes. |
| 3 – Sequential semantics | `always_ff` staged next-state, edge-sensitive recognition, driver-conflict diagnostics. |
| 4 – Hierarchy & parameters | Instantiation, parameter override templates, generate constructs (now via slang). |
| 5 – Metrics | `metrics.json`, Verilator integration with Windows/MSYS2 discovery variants. |
| 6 – Filelist + top-down reachability | `.f` parsing, `--top`-driven traversal. |
| 7 – Flow refinement | Streaming traversal stats. |
| 8 – Semantic coverage | Subroutines, bit/part-select writes, generate-if folding. |
| 9 – Expression coverage + differential CI | Tree-IR expressions, equivalence harness on Linux. |
| 10 – Streaming multi-file emission | Per-module `.hpp` files, mirrored directory layout, positional bindings. |
| A/B/C – pyslang migration | pyverilog frontend deleted; slang is the only frontend (see `docs/pyslang_migration.md`). |

## Up Next — Phase 11 (SV feature rollout + closing silent-risk gaps)

The full supported / unsupported / queued breakdown lives in
[`docs/syntax_coverage.md`](docs/syntax_coverage.md). Each step below
lands as an isolated PR with its own equivalence fixture; items that
have already landed are struck through here for history.

1. ~~**Wildcard `case`** — `casez` / `casex` lowered to a mask/match
   if-else chain.~~ Done.
2. ~~**SV `always_*` keywords** — `always_comb` / `always_ff` /
   `always_latch` trace fixtures.~~ Done.
3. ~~**`$signed` / `$unsigned` casts.**~~ Done: codegen emits real
   `sc_int<W>` / `sc_uint<W>` casts so arithmetic shifts behave
   correctly. Trace fixture `signed_shift_cast` pins behavior.
4. ~~**Unpacked-array memory** (`reg [W-1:0] mem [0:D-1]`).~~ Done:
   per-cell `sc_signal` array codegen, verified by `regfile_mem`.
5. ~~**Procedural `for` loops** inside `always` blocks (bit-reverse,
   parity, parametric reduce).~~ Done: unrolls at elaboration time with
   genvar substitution, verified by `procedural_for` fixture. Also fixed
   staged-context bug where RHS reads of staged signals incorrectly used
   `.read()` instead of `__next_` temporaries.
6. ~~**`typedef` + `enum`** flattened to bit-widths in `ModuleIR`.~~ Done:
   enum members are lowered to integer constants, and the alias metadata
   is recorded in `ModuleIR.type_aliases`.
7. ~~**Packed `struct`** (and `union`) flattened to a single
   `sc_uint<sum>` with field bit-offsets threaded through bit/part
   selects.~~ Done: alias metadata records packed fields, member access
   lowers to bit/part selects, and `packed_aggregate_demo` verifies struct
   and union overlays.
8. **`package` + `import`.** slang already resolves the names; mostly
   a "release the brake" change in the lowerer.
9. **`inout` ports.** Single-feature audit + fixture; needs to decide
   how to model bidirectional bus semantics under `SC_METHOD`.
10. **`interface` + `modport`.** Large enough to warrant its own design
    doc and an `InterfaceIR` concept. Park here until 1–9 land.

Cross-cutting hardening that runs alongside the above:

- tighten width inference for nested concat/repeat constructions
- extend driver-conflict analysis to recognize concat-LHS targets

## Risks

| Risk | Mitigation |
| --- | --- |
| pyslang 12.x ships with breaking API changes | `<12.0` upper bound + dedicated wheel smoke CI job. Migrate as a tracked PR after burn-in. |
| Semantic mismatch in complex scheduling | Equivalence CI is the gating signal — every new construct lands with a fixture before being claimed. |
| Multi-file include resolution edge cases | `frontend/preprocess` is the single resolver shared by the CLI and the equivalence harness, so the converter and the golden simulator always see the same `-I`/`-D` set. |
| Windows toolchain variability for Verilator | Multiple discovery variants for MSYS2/MinGW, with tests. |
