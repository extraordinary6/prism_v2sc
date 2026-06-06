# Known Differences

`prism_v2sc` emits **approximate** SystemC for a constrained synthesizable RTL subset. It does not claim full Verilog/SystemVerilog equivalence. This document enumerates the places where generated SystemC diverges from full RTL semantics; everything not listed here is exercised by the differential CI.

## Output Shape

- One ``.hpp`` per module. The output directory mirrors the source RTL directory layout under `--out`. Each header `#include`s the headers of every child it instantiates; there is no umbrella header. Users only include the top header.
- Emission is **bottom-up (post-order DFS)**: a parent file is written only after every child file is already on disk, so the `#include` chain is always valid mid-run.
- slang elaborates the whole design into a single `Compilation` up front; the lowerer then walks the elaborated instance tree and lazily lowers only the modules reachable from `--top`.

## Process Semantics

- Each process becomes its own `SC_METHOD`. Arbitrary delta-cycle ordering is not modeled; we trade exact event scheduling for predictable, readable output.
- Combinational `always` and continuous `assign` outputs use a per-output ``__next_<signal>`` staging pattern. Inter-statement reads of a just-written signal therefore see the **pre-block** value rather than the just-staged value. This is rare in synthesizable RTL but worth knowing.
- Nonblocking assignments inside `always @(posedge ...)` blocks share the same staged ``__next_*`` pattern, including for bit-select and part-select LHS.
- Modules with multiple procedural blocks emit an `event_scheduler_approximated` warning. The recommended (and CI-exercised) style is **one procedural block per output**.

## Expression Lowering

- Concatenation `{a, b}` and replication `{N{x}}` lower to explicit shift-OR chains with `sc_uint<W>` operand casts. Widths are inferred from declared port/signal widths and from sized literals; if a width cannot be inferred it falls back to 1.
- Reduction operators `&x`, `|x`, `^x` (and their inverted forms) lower to `sc_uint`'s `and_reduce()` / `or_reduce()` / `xor_reduce()` methods.
- X/Z values inside literals are approximated as zero in generated C++ expressions. The IR records `has_xz=true` so downstream tooling can still see the original intent.
- Signed declarations and explicit signedness casts lower to `sc_int<W>` / `sc_uint<W>`. The implementation preserves signed based literals such as `8'shFF` as a signed value for codegen while keeping the raw bit pattern in IR. Full SystemVerilog mixed signed/unsigned context sizing is still not exhaustively modeled.

## Selects and Bindings

- Bit-select reads (`sig[i]`) lower to `sig.read()[i]`. Part-select reads (`sig[msb:lsb]`) lower to `range(msb, lsb)`.
- Bit-select / part-select **LHS** in sequential blocks use the staged ``__next_*`` pattern.
- `generate` bit-select bindings (`vector[i]` in port maps under a generate-for) use generated scalar bridge signals.
- Direct instance bit-select bindings (`vector[constant]` / `vector[index]` in port maps) also use scalar bridge signals.
- Positional port bindings (e.g. ``mod u(a, b, c);``) are resolved against the child's cached signature, recovering port names by position. Named bindings remain the recommended style.

## Resolution and Elaboration

- `generate if` and `generate for` are resolved by slang during elaboration (statically resolvable conditions only) and reach the lowerer as a fully-folded / fully-unrolled instance tree.
- Parameter overrides are applied by slang before lowering, so port widths and constant expressions reach codegen as concrete integers.
- Unknown instance targets surface as `slang_UnknownModule` diagnostics. Duplicate module definitions surface as `slang_DuplicateDefinition` diagnostics.

## Case Statements

- Ordinary `case` lowers to a C++ `switch`. The case-item integer values are correctly resolved (`3'b001` → 1, `8'hFF` → 255, etc.) and the original literal text is preserved in the IR's `raw` field.
- `casez` / `casex` with literal wildcard patterns lower to a mask/match `if` / `else-if` chain. This is verified by trace fixtures for two-state stimulus. It is still not a full four-state model: selector X/Z propagation is outside the converter's two-state expression domain, and non-literal wildcard labels fall back to strict equality.

## SystemVerilog Surface

- The supported surface is bounded by slang (IEEE 1800-2023 synthesizable subset) and by lowering coverage in this project.
- Synthesizable `function` is supported.
- Dynamic SV (classes, randomization, programs, runtime assertions/properties) is out of scope and surfaces as diagnostics rather than partial lowering.
- The supported SV surface now includes typedefs/enums, packed structs/unions, packages/imports, unpacked-array memories, whole-vector `inout`, and a simple packed-signal `interface`/`modport` flattening subset. More complex SV constructs remain queued; see `plan.md`.

## Policy

- Unsupported constructs **must** produce diagnostics or explicit comments rather than silently degrade.
- Use `--fail-on-diagnostics` in CI when error-level constructs must hard-fail the conversion.
