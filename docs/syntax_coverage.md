# Syntax Coverage

What `prism_v2sc` actually supports today, what it explicitly rejects, and where the silent risks are. Sourced from `frontend/lower.py` kind dispatch, `codegen/expr.py` operator map, the diagnostic table, and the `tests/equivalence/fixtures/` set. Update this doc whenever the lowerer's behavior changes.

The classification is by **evidence strength**, not by syntactic category — the question "is this safe to feed in?" is really "do we have a CI-level proof?" CI gives that proof in three flavors:

- **Trace-equivalence fixtures** (section A): co-simulate the RTL with `iverilog` and the generated SystemC with `libsystemc-dev`, diff per-cycle outputs.
- **Conversion-only fixtures** (section B): run `prism-v2sc`, validate `ir.json` and generated headers, and assert no error diagnostics for SV constructs that Icarus cannot compile.
- **Diagnostic fixtures** (section C): run `prism-v2sc` on RTL that's *supposed* to be rejected or flagged, assert the expected diagnostic codes land in `ir.json`. Lets us pin the contract for rejection/approximation paths that trace equivalence can't reach.

## A. Trace-equivalence-verified (cycle-accurate trace match)

Forty fixtures under `tests/equivalence/fixtures/*.{v,sv}` plus `multi_file/`. Anything in this table is verified at trace-diff granularity by `.github/workflows/equivalence.yml`.

| Category | Verified surface |
| --- | --- |
| **Structure** | module def / inst, named + positional port binding, parameter override (slang elaborates), nested hierarchy, multi-file build with `+incdir+` / `-D` / nested `-f` filelists; parent-scope parameter/localparam overrides instantiate children with concrete template arguments while unsafe child template defaults are sanitized (`param_hierarchy_edges`) |
| **Ports & signals** | `input` / `output`, whole-vector `inout`, `wire`, `reg`, vector `[N:0]`, parameterized `[WIDTH-1:0]`, signed declarations lowered to `sc_int<W>` / `sc_bigint<W>` (`bool` is used only for unsigned 1-bit); unsigned vectors wider than 64 bits lower to `sc_biguint<W>`; `inout` lowers to SystemC resolved vectors and is verified for mutually exclusive external/DUT drivers across a whole-bus hierarchical binding |
| **Memories** | unpacked arrays (`reg [W-1:0] mem [0:D-1]`) lowered to a per-cell `sc_signal<sc_uint<W>>` array; per-cell `.write()` / `.read()` gives Verilog nonblocking semantics via SystemC delta cycles; reset initialization, write enable, independent read/write addresses, and same-cycle old-value reads are trace-verified (`memory_edges`) |
| **Combinational** | `always @(*)`, `always_comb`, `always_latch`, continuous `assign`; blocking read-after-write and longer blocking chains within one combinational process are trace-verified through `__next_*` staging (`staged_read_after_write`, `blocking_comb_chain`); latch hold plus partial assignment is trace-verified (`latch_edges`); sensitivity inference through function-call args, selects, concat, and replication is trace-verified (`sensitivity_edges`) |
| **Sequential** | `always @(posedge clk)`, `always_ff`, async reset (`posedge clk or negedge rst_n`, plus active-high `posedge rst` in `async_reset_edges`); nonblocking assignment chains preserve pre-edge RHS values (`nba_chain`) |
| **Control flow** | `if`/`else`, ordinary `case` (no wildcard), `casez` / `casex` lowered to mask/match if-else chain, `default`, nested ternary selection, procedural `for` with constant bounds including decrementing loops, non-zero starts, and nested loops (unrolled at elaboration time) |
| **Operators** | full binary `+ - * / % == != < > <= >= && \|\| & \| ^ << >>`, ternary `?:`, unary `! ~ - +`, reduction `& \| ^ ~& ~\| ^~ ~^`; arithmetic `>>>` via `$signed` cast; signed/unsigned boundary expressions when the RTL explicitly extends/casts operands to the intended common type (`signed_mixed_context`); 1/2/31/32/33/63/64/65-bit expression and concat boundaries (`width_boundaries`) |
| **Selects** | bit-select `sig[i]` (read + write), part-select `sig[msb:lsb]` (read + write); LHS uses staged `__next_*`; out-of-order non-overlapping bit/part-select writes in one combinational process are trace-verified (`part_select_assembly`) |
| **Aggregates** | `{a, b}` concat, `{N{x}}` replication |
| **Literals** | sized (`8'hFF`, `3'b010`, `4'd5`, 65-bit based literals), signed based (`8'shFF`), unsized decimal; integer `value` field reflects the actual bit pattern and signed based literals also carry `signed_value`; based literals wider than 64 bits emit string-constructed `sc_biguint` / `sc_bigint` values |
| **Type aliases** | `typedef` / `enum` flattened to bit-width metadata in `ModuleIR.type_aliases`; enum members lower to integer constants |
| **Packed aggregates** | packed `struct` / `union` flattened to one vector; field reads and writes lower through bit/part-selects (`packed_aggregate_demo`) |
| **Packages** | `package` + `import pkg::*` / `import pkg::item` extract functions, typedefs, and parameters from packages; package parameters emit as template arguments (`package_import`) |
| **Bidirectional buses** | whole-vector `inout` ports and whole-vector hierarchical `inout` bindings use `sc_inout_rv` / `sc_signal_rv`; high-Z assignment branches emit `sc_lv<W>("ZZ...")`; mutually exclusive DUT/external drive and resolved-value sampling through top and child modules are trace-verified (`inout_bus`, `inout_edges`) |
| **Generate** | `generate for` (slang unrolls), `generate if` (slang folds), bit-select bindings on the unrolled instances aggregate into a single writer per parent signal |
| **Functions** | synthesizable `function`, multi-parameter, `case` in body, called from `always @(*)`, `return` statement supported; calls participate in inferred combinational sensitivity (`sensitivity_edges`) |
| **Multi-writer aggregation** | multiple procedural blocks writing different bit/part-select slices of the same parent signal land in one shadow-driven assembler — verified by the `slice_writers` fixture |
| **Casts** | `$signed(x)` / `$unsigned(x)` and explicit SV casts such as `signed'(x)` / `unsigned'(x)` emit real `sc_int<W>` / `sc_uint<W>` or `sc_bigint<W>` / `sc_biguint<W>` casts; signed ternary branches that are both known signed are cast to a common signed SystemC integer type to avoid C++ conditional type ambiguity |

## B. Conversion-CI-verified (lowering / header contract)

Five fixtures run through the default `.github/workflows/equivalence.yml` harness without RTL trace-diffing. These cover SV source that pyslang/prism lowers but Icarus Verilog cannot compile as a golden RTL simulator, or constructs where the current trace harness is not the right proof shape.

| Fixture | Verified surface | Why it is not a trace fixture |
| --- | --- | --- |
| `interface_modport` | simple interfaces containing packed variables plus simple `modport` input/output directions flatten to ordinary module ports/signals named `iface__field`; generated headers contain flattened top signals and producer/consumer bindings | Icarus rejects the interface port declarations (`stream_if.master bus`, `stream_if.slave bus`) used by the fixture |
| `interface_modport_variants` | multiple simple interface instances and modport directions flatten to stable top-level signals and child bindings | same interface-port golden-simulator limitation |
| `package_multifile` | package typedefs, parameters, and functions resolve across multiple source files; generated header contains the expected local signal and staged writes | conversion-only keeps this independent from simulator package support variance |
| `generate_named_blocks` | named generate hierarchy elaborates to stable instance names and scalar bridge bindings in the top header | header/name contract is the important behavior here |
| `typedef_package_enum` | package enum typedefs lower to integer constants, local storage, and stable switch labels/header snippets | conversion-only asserts the IR/header contract without relying on simulator enum package support |

## C. Diagnostic-CI-verified (rejection / approximation contract)

Fourteen fixtures under `tests/equivalence/fixtures/diagnostics/`. Each runs `prism-v2sc` on RTL designed to trigger specific diagnostic codes, asserts those codes appear in the resulting `ir.json`, and checks `--fail-on-diagnostics` exits 2 for error-level diagnostics and 0 for warning-only diagnostics. These cover behavior trace equivalence can't reach: rejection cases, configurations the converter intentionally approximates, and slang's own elaboration diagnostics.

| Fixture | Asserts diagnostic code(s) | Why it's not a trace fixture |
| --- | --- | --- |
| `driver_conflict_procedural` | `multiple_procedural_drivers`, `multiple_always_ff_drivers` | two `always_ff` blocks writing the same whole signal — a real conflict that must be reported, not lowered |
| `mixed_assignment_styles` | `mixed_assignment_styles` | same signal driven with both `=` and `<=` — a style conflict |
| `blocking_in_always_ff` | `blocking_in_always_ff` | blocking `=` inside `always_ff` — fires as a warning |
| `comb_process_order` | `event_scheduler_approximated` | mutually dependent combinational always blocks rely on event scheduling that generated `SC_METHOD`s do not fully model |
| `xz_literal_approximated` | `x_z_literal_approximated` | outside resolved `inout` drive contexts, X/Z literals are collapsed to 0; iverilog propagates X, so traces would necessarily diverge |
| `xz_logic_rejected` | `x_z_literal_approximated` | non-inout X/Z logic must warn rather than claim two-state trace equivalence |
| `overlap_slice_writers` | `overlapping_procedural_writes` | overlapping procedural slice writers cannot be safely shadow-assembled |
| `mixed_assignment_deeper` | `mixed_assignment_styles` | nested mixed blocking/nonblocking writes to the same slice remain an error |
| `while_repeat_rejected` | `unsupported_whileloop`, `unsupported_repeatloop` | unsupported procedural loops must not be silently emitted as partial SystemC |
| `interface_complex_rejected` | `unsupported_interface_port` | interface/modport shapes outside the packed-signal subset cannot be flattened |
| `task_system_task_rejected` | `unsupported_task_first_round`, `unsupported_expression_statement_call` | tasks and system-task expression statements are not lowered |
| `dynamic_sv_rejected` | `unsupported_classtype` | dynamic/non-synthesizable SV constructs stay outside the supported subset |
| `slang_unknown_module` | `slang_UnknownModule` | unknown instance target — iverilog also fails to elaborate, no trace to compare |
| `slang_duplicate_definition` | `slang_DuplicateDefinition` | duplicate module definition — same reason |

The driver-conflict-slice-aware variant moved out of this section into A: the
underlying multi-writer aggregation (`slice_writers` fixture) now verifies
trace-level correctness too.

## D. Explicitly rejected (loud diagnostic, no silent miscompile)

These all surface through diagnostic fixtures or unit tests already. Listed
here for documentation of the rejection contract.

| Diagnostic | What it rejects |
| --- | --- |
| `unsupported_multiport` | SystemVerilog multi-ports |
| `unsupported_interface_port` | interface-typed ports that cannot be flattened into the simple packed-signal/modport subset |
| `unsupported_initial` | `initial` blocks |
| `unsupported_task_first_round` | `task` (functions are supported) |
| `unsupported_expression_statement_<kind>` | expression statements other than assignments, including system-task calls such as `$display` |
| `overlapping_procedural_writes` | overlapping writes to the same vector from different procedural blocks |
| `unsupported_<kind>` | any statement or expression kind the lowerer doesn't recognize; the slang node-class name lands in the diagnostic code so it's debuggable |

Use `--fail-on-diagnostics` in CI when error-level diagnostics must hard-fail the conversion.

## E. Priority 1 — common RTL that we *don't* fully support yet

These are the dangerous ones: most either silently miscompile or take the `unsupported_<kind>` exit path even though the construct is common in real designs. Each item needs a fixture (trace, conversion, or diagnostic) before we can claim either way.

| Gap | Why it matters | Current behavior |
| --- | --- | --- |
| bit-select hierarchical `inout` bindings | child `inout` ports connected to `bus[i]` need a carefully audited proxy model | not trace-equivalence-verified; use whole-vector `inout` bindings for the supported path |
| complex interfaces | clocking blocks, interface tasks/functions, nested interfaces, interface arrays, modport expressions/exports | outside the packed-signal/simple-modport subset; `interface_complex_rejected` pins the diagnostic path |
| `defparam` | legacy code | slang resolves it at elaboration; **no fixture pins behavior** |
| complex mixed signed/unsigned context sizing | SV expression signedness and width can be context-determined across nested mixed operands | partially covered by declared signed ports/signals and explicit casts; full expression-level signedness propagation is not modeled exhaustively. See `docs/signed_mixed_semantics.md` |

## F. Priority 2 — SystemVerilog feature rollout

slang already parses every entry here; the gap is `ModuleIR` doesn't carry the symbol shape yet. Land them one at a time, each with its own trace, conversion, or diagnostic fixture.

| Feature | Where it lands | Estimated size |
| --- | --- | --- |
| ~~`typedef` + `enum` flattened to bit-width~~ | Done: `frontend/lower._lower_module` records the width mapping and enum member values | small |
| ~~Packed `struct` / `union` (flatten to one `sc_uint<sum>` with field bit-offsets)~~ | Done: alias metadata records fields and member access lowers to bit/part-selects | medium |
| ~~`package` + `import`~~ | Done: wildcard and explicit imports extract functions, typedefs, and parameters from packages | small (mostly free) |
| ~~`interface` + `modport`~~ | Done for the simple packed-signal/modport subset: interface instances and ports flatten into ordinary `bus__field` signals/ports, verified by the `interface_modport` conversion fixture; complex interface constructs remain a Priority 1 gap | medium |

## G. Priority 3 — intentionally out of scope

Stays rejected. These are either non-synthesizable or require runtime infrastructure SystemC's `SC_METHOD` model doesn't provide.

- classes, inheritance, polymorphism
- randomization (`rand`, `randc`, `dist`, `constraint`)
- `program` blocks
- runtime assertions / properties / sequences
- DPI, `$display` / `$finish` and other system tasks (non-synthesizable)
- `event` type, `->` trigger
- string / real / shortreal literals
- streaming `{<<{a,b}}` / `{>>{a,b}}`, `inside` expressions, queue/array methods

## Ordering for the next phase

The roadmap below feeds Phase 11 in `plan.md`. Each step lands as an isolated PR with its corresponding fixture (trace or diagnostic, whichever fits). Items that have moved into A/B since the last revision are struck through.

1. ~~**Surface the silent risks first** — `casex` / `casez`.~~ Done: now in A with the mask/match if-else chain codegen.
2. ~~**Pin the keyword variants** — `always_comb` / `always_ff` / `always_latch`.~~ Done: trace fixtures land them in A.
3. ~~**`$signed` / `$unsigned` casts** previously discarded the sign change.~~ Done: codegen now emits real `sc_int<W>` / `sc_uint<W>` casts, verified by `signed_shift_cast`.
4. ~~**Unpacked-array memory** (`reg [W-1:0] mem [0:D-1]`).~~ Done: per-cell `sc_signal` array codegen, verified by `regfile_mem`.
5. ~~**Procedural `for`.** Common in synthesizable RTL (bit reverse, parity, parametric reduce); lowering is mechanical — slang gives constant-bounds-resolved loops.~~ Done: unrolls at elaboration time with genvar substitution, verified by `procedural_for` fixture. Also fixed staged-context bug where RHS reads of staged signals incorrectly used `.read()` instead of `__next_` temporaries.
6. ~~**`typedef` + `enum`.** Cheapest SV feature with broad payoff; small IR change.~~ Done: `typedef_enum_fsm` verifies enum members and aliased state storage.
7. ~~**Packed `struct`.** Builds on the typedef work.~~ Done: `packed_aggregate_demo` verifies packed struct fields and packed union overlays.
8. ~~**`package` / `import`.** slang has already resolved them; mostly a "release the brake" change.~~ Done: `package_import` verifies wildcard imports extract functions, typedefs, enum members, and parameters. Also added `return` statement support for function bodies.
9. ~~**`inout` ports.** Single-feature audit + fixture; needs to decide how to model bidirectional bus semantics under `SC_METHOD`.~~ Done: whole-vector `inout` ports use resolved SystemC vectors, high-Z RHS branches emit real `sc_lv` Z drives, and `inout_bus` verifies mutually exclusive external/DUT drivers across a hierarchical whole-bus binding.
10. ~~**`interface` / `modport`.** Separate design doc first; large enough to warrant its own milestone.~~ Done for the simple packed-signal/modport subset: interface instances and ports flatten into ordinary `bus__field` signals/ports, verified by the `interface_modport` conversion fixture.

Updated whenever a row in D / E / F moves into A, B, or C.
