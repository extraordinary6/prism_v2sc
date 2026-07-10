# Known Differences

`prism_v2sc` emits **approximate** SystemC for a constrained synthesizable RTL subset. It does not claim full Verilog/SystemVerilog equivalence. This document enumerates the places where generated SystemC diverges from full RTL semantics; everything not listed here is exercised by the differential CI.

## Output Shape

- One ``.hpp`` per module. The output directory mirrors the source RTL directory layout under `--out`. Each header `#include`s the headers of every child it instantiates; there is no umbrella header. Users only include the top header.
- Emission is **bottom-up (post-order DFS)**: a parent file is written only after every child file is already on disk, so the `#include` chain is always valid mid-run.
- slang elaborates the whole design into a single `Compilation` up front; the lowerer then walks the elaborated instance tree and lazily lowers only the modules reachable from `--top`.

## Process Semantics

- Each process becomes its own `SC_METHOD`. Arbitrary delta-cycle ordering is not modeled; we trade exact event scheduling for predictable, readable output.
- Combinational `always` outputs use a per-output ``__next_<signal>`` staging pattern, and RHS reads of signals written earlier in the same process are routed through the staged value. Blocking read-after-write within one combinational process is trace-verified by `staged_read_after_write`.
- Nonblocking assignments inside `always @(posedge ...)` blocks schedule LHS updates through staged ``__next_*`` temporaries, including for bit-select and part-select LHS. RHS expressions read the pre-edge signal value, preserving Verilog NBA chain behavior; blocking temporaries assigned earlier in the same FF block are still read through their immediate staged value. `nba_chain` and `package_import` trace-verify these two paths.
- Modules with multiple procedural blocks emit an `event_scheduler_approximated` warning. Mutually dependent combinational blocks are pinned by the `comb_process_order` diagnostic fixture rather than being treated as fully scheduled Verilog semantics. The recommended (and CI-exercised) style is **one procedural block per output** unless a dedicated trace fixture covers the pattern.

## Expression Lowering

- Concatenation `{a, b}` and replication `{N{x}}` lower to explicit shift-OR chains with `sc_uint<W>` / `sc_biguint<W>` operand casts. Widths are inferred from declared port/signal widths, sized literals, and slang's select result widths; if a width cannot be inferred it falls back to 1.
- Reduction operators `&x`, `|x`, `^x` (and their inverted forms) lower to `sc_uint`'s `and_reduce()` / `or_reduce()` / `xor_reduce()` methods.
- X/Z values inside non-`inout` literals are approximated as zero in generated C++ expressions and emit `x_z_literal_approximated` diagnostics; `xz_logic_rejected` pins that this is a warning contract, not a trace-equivalent claim. The IR records `has_xz=true` so downstream tooling can still see the original intent.
- Real-valued constant expressions are supported only when slang inserts an implicit conversion to an integral target; codegen preserves slang's converted integer value. Runtime `real` / `shortreal` storage and datapaths remain outside the supported subset.
- Signed declarations and explicit signedness casts lower to `sc_int<W>` / `sc_uint<W>` for widths up to 64 bits and `sc_bigint<W>` / `sc_biguint<W>` beyond that. The implementation preserves signed based literals such as `8'shFF` as a signed value for codegen while keeping the raw bit pattern in IR. Mixed signed/unsigned equality and relational comparisons normalize both operands to a common unsigned bit width; full context sizing for every arithmetic/nested expression is still not exhaustively modeled.

## Selects and Bindings

- Bit-select reads (`sig[i]`) lower to `sig.read()[i]`. Part-select reads (`sig[msb:lsb]`) lower to `range(msb, lsb)`.
- Indexed part-select reads such as `sig[base +: width]` and `sig[base -: width]` lower to explicit `range(...)` bounds and preserve slang's result width for concat/repeat contexts. The implementation is verified by unit coverage, the MHSA `scale_core` keypoint gate, and the OFDM FFT/IFFT trace gate.
- Bit-select / part-select **LHS** in sequential blocks use the staged ``__next_*`` pattern.
- Concatenation LHS assignments split into assignments to the constituent targets.
- `generate` bit-select bindings (`vector[i]` in port maps under a generate-for) use generated scalar bridge signals.
- Direct instance bit-select bindings (`vector[constant]` / `vector[index]` in port maps) also use scalar bridge signals.
- Non-net expression input bindings, array-element port bindings, and simple parent/child bindings with different packed widths use generated bridge signals. Width bridges apply the child input or parent output assignment width explicitly, matching RTL truncation/extension while keeping SystemC port types bindable. Unconnected child outputs use dummy signals.
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
- Dynamic SV (classes, randomization, programs) is out of scope and surfaces as diagnostics rather than partial lowering. Verification-only assertion/property/sequence metadata and assertion statements are ignored in the synthesizable design view; UVM/testbench sources should not be included in the RTL source set.
- Tasks and system-task expression statements are out of scope; `task_system_task_rejected` pins both the task diagnostic and the unsupported expression-statement diagnostic.
- The supported SV surface now includes typedefs/enums, packed structs/unions, packages/imports, procedural `for`, unpacked-array memories, multidimensional unpacked-array cases used by the MHSA real design, whole-vector `inout`, and a simple packed-signal `interface`/`modport` flattening subset. More complex SV constructs remain queued; see `plan.md`.

## Policy

- Unsupported constructs **must** produce diagnostics or explicit comments rather than silently degrade.
- Use `--fail-on-diagnostics` in CI when error-level constructs must hard-fail the conversion.
