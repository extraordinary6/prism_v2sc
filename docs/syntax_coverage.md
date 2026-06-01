# Syntax Coverage

What `prism_v2sc` actually supports today, what it explicitly rejects, and where the silent risks are. Sourced from `frontend/lower.py` kind dispatch, `codegen/expr.py` operator map, the diagnostic table, and the `tests/equivalence/fixtures/` set. Update this doc whenever the lowerer's behavior changes.

The classification is by **evidence strength**, not by syntactic category — the question "is this safe to feed in?" is really "do we have a CI-level proof?" CI gives that proof in two flavors:

- **Trace-equivalence fixtures** (section A): co-simulate the RTL with `iverilog` and the generated SystemC with `libsystemc-dev`, diff per-cycle outputs.
- **Diagnostic fixtures** (section B): run `prism-v2sc` on RTL that's *supposed* to be rejected or flagged, assert the expected diagnostic codes land in `ir.json`. Lets us pin the contract for rejection/approximation paths that trace equivalence can't reach.

## A. Trace-equivalence-verified (cycle-accurate trace match)

Twenty-one fixtures under `tests/equivalence/fixtures/*.{v,sv}` plus `multi_file/`. Anything in this table is verified at trace-diff granularity by `.github/workflows/equivalence.yml`.

| Category | Verified surface |
| --- | --- |
| **Structure** | module def / inst, named + positional port binding, parameter override (slang elaborates), nested hierarchy, multi-file build with `+incdir+` / `-D` / nested `-f` filelists |
| **Ports & signals** | `input` / `output`, `wire`, `reg`, vector `[N:0]`, parameterized `[WIDTH-1:0]` |
| **Memories** | unpacked arrays (`reg [W-1:0] mem [0:D-1]`) lowered to a per-cell `sc_signal<sc_uint<W>>` array; per-cell `.write()` / `.read()` gives Verilog nonblocking semantics via SystemC delta cycles |
| **Combinational** | `always @(*)`, `always_comb`, `always_latch`, continuous `assign` |
| **Sequential** | `always @(posedge clk)`, `always_ff`, async reset (`posedge clk or negedge rst_n` style) |
| **Control flow** | `if`/`else`, ordinary `case` (no wildcard), `casez` / `casex` lowered to mask/match if-else chain, `default`, procedural `for` with constant bounds (unrolled at elaboration time) |
| **Operators** | full binary `+ - * / % == != < > <= >= && \|\| & \| ^ << >>`, ternary `?:`, unary `! ~ - +`, reduction `& \| ^ ~& ~\| ^~ ~^`; arithmetic `>>>` via `$signed` cast |
| **Selects** | bit-select `sig[i]` (read + write), part-select `sig[msb:lsb]` (read + write); LHS uses staged `__next_*` |
| **Aggregates** | `{a, b}` concat, `{N{x}}` replication |
| **Literals** | sized (`8'hFF`, `3'b010`, `4'd5`), unsized decimal; integer `value` field reflects the actual bit pattern |
| **Type aliases** | `typedef` / `enum` flattened to bit-width metadata in `ModuleIR.type_aliases`; enum members lower to integer constants |
| **Packed aggregates** | packed `struct` / `union` flattened to one vector; field reads and writes lower through bit/part-selects (`packed_aggregate_demo`) |
| **Generate** | `generate for` (slang unrolls), `generate if` (slang folds), bit-select bindings on the unrolled instances aggregate into a single writer per parent signal |
| **Functions** | synthesizable `function`, multi-parameter, `case` in body, called from `always @(*)` |
| **Multi-writer aggregation** | multiple procedural blocks writing different bit/part-select slices of the same parent signal land in one shadow-driven assembler — verified by the `slice_writers` fixture |
| **System calls** | `$signed(x)` / `$unsigned(x)` emit real `sc_int<W>` / `sc_uint<W>` casts (was a no-op before — silently dropped sign information) |

## B. Diagnostic-CI-verified (rejection / approximation contract)

Six fixtures under `tests/equivalence/fixtures/diagnostics/`. Each runs `prism-v2sc` on RTL designed to trigger specific diagnostic codes and asserts those codes appear in the resulting `ir.json`. These cover behavior trace equivalence can't reach: rejection cases, configurations the converter intentionally approximates, and slang's own elaboration diagnostics.

| Fixture | Asserts diagnostic code(s) | Why it's not a trace fixture |
| --- | --- | --- |
| `driver_conflict_procedural` | `multiple_procedural_drivers`, `multiple_always_ff_drivers` | two `always_ff` blocks writing the same whole signal — a real conflict that must be reported, not lowered |
| `mixed_assignment_styles` | `mixed_assignment_styles` | same signal driven with both `=` and `<=` — a style conflict |
| `blocking_in_always_ff` | `blocking_in_always_ff` | blocking `=` inside `always_ff` — fires as a warning |
| `xz_literal_approximated` | `x_z_literal_approximated` | X/Z literals are collapsed to 0; iverilog propagates X, so traces would necessarily diverge |
| `slang_unknown_module` | `slang_UnknownModule` | unknown instance target — iverilog also fails to elaborate, no trace to compare |
| `slang_duplicate_definition` | `slang_DuplicateDefinition` | duplicate module definition — same reason |

The driver-conflict-slice-aware variant moved out of this section into A: the
underlying multi-writer aggregation (`slice_writers` fixture) now verifies
trace-level correctness too.

## C. Explicitly rejected (loud diagnostic, no silent miscompile)

These all surface through diagnostic fixtures or unit tests already. Listed
here for documentation of the rejection contract.

| Diagnostic | What it rejects |
| --- | --- |
| `unsupported_multiport` | SystemVerilog multi-ports |
| `unsupported_interface_port` | `interface`-typed ports |
| `unsupported_initial` | `initial` blocks |
| `unsupported_task_first_round` | `task` (functions are supported) |
| `unsupported_<kind>` | any statement or expression kind the lowerer doesn't recognize; the slang node-class name lands in the diagnostic code so it's debuggable |

Use `--fail-on-diagnostics` in CI when error-level diagnostics must hard-fail the conversion.

## D. Priority 1 — common RTL that we *don't* fully support yet

These are the dangerous ones: most either silently miscompile or take the `unsupported_<kind>` exit path even though the construct is common in real designs. Each item needs a fixture (trace or diagnostic) before we can claim either way.

| Gap | Why it matters | Current behavior |
| --- | --- | --- |
| Procedural `while` / `repeat` | loop constructs in synthesizable RTL | `unsupported_<kind>` diagnostic |
| `inout` ports | bidirectional bus interfaces | no specific handling; needs an audit |
| `defparam` | legacy code | slang resolves it at elaboration; **no fixture pins behavior** |
| `signed`-declared ports in the equivalence harness | true signed-port designs (not just `$signed` casts) | the `Port` dataclass in `run_equivalence.py` doesn't carry a `signed` flag yet, so trace fixtures can't drive `sc_int` ports |

## E. Priority 2 — SystemVerilog feature rollout

slang already parses every entry here; the gap is `ModuleIR` doesn't carry the symbol shape yet. Land them one at a time, each with its own fixture.

| Feature | Where it lands | Estimated size |
| --- | --- | --- |
| ~~`typedef` + `enum` flattened to bit-width~~ | Done: `frontend/lower._lower_module` records the width mapping and enum member values | small |
| ~~Packed `struct` / `union` (flatten to one `sc_uint<sum>` with field bit-offsets)~~ | Done: alias metadata records fields and member access lowers to bit/part-selects | medium |
| `package` + `import` | slang already resolves names; lowerer just consumes the resulting symbols | small (mostly free) |
| `interface` + `modport` | a new `InterfaceIR` concept end-to-end; currently rejected outright | large — needs its own design doc |

## F. Priority 3 — intentionally out of scope

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
8. **`package` / `import`.** slang has already resolved them; mostly a "release the brake" change.
9. **`inout` ports.** Single-feature audit + fixture; needs to decide how to model bidirectional bus semantics under `SC_METHOD`.
10. **`interface` / `modport`.** Separate design doc first; large enough to warrant its own milestone.

Updated whenever a row in C / D / E moves into A or B.
