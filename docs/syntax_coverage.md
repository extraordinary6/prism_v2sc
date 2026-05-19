# Syntax Coverage

What `prism_v2sc` actually supports today, what it explicitly rejects, and where the silent risks are. Sourced from `frontend/lower.py` kind dispatch, `codegen/expr.py` operator map, the diagnostic table, and the `tests/equivalence/fixtures/` set. Update this doc whenever the lowerer's behavior changes.

The classification is by **evidence strength**, not by syntactic category — because the question "is this safe to feed in?" is really "do we have a trace-level proof?"

## A. Equivalence-CI-verified (cycle-accurate trace match)

Eleven fixtures under `tests/equivalence/fixtures/` co-simulate the RTL with `iverilog` and the generated SystemC with `libsystemc-dev`. Anything in this table is verified at trace-diff granularity.

| Category | Verified surface |
| --- | --- |
| **Structure** | module def / inst, named + positional port binding, parameter override (slang elaborates), nested hierarchy, multi-file build with `+incdir+` / `-D` / nested `-f` filelists |
| **Ports & signals** | `input` / `output`, `wire`, `reg`, vector `[N:0]`, parameterized `[WIDTH-1:0]` |
| **Combinational** | `always @(*)`, continuous `assign` |
| **Sequential** | `always @(posedge clk)`, async reset (`posedge clk or negedge rst_n` style) |
| **Control flow** | `if`/`else`, ordinary `case` (no wildcard), `default` |
| **Operators** | full binary `+ - * / % == != < > <= >= && \|\| & \| ^ << >>`, ternary `?:`, unary `! ~ - +`, reduction `& \| ^ ~& ~\| ^~ ~^` |
| **Selects** | bit-select `sig[i]` (read + write), part-select `sig[msb:lsb]` (read + write); LHS uses staged `__next_*` |
| **Aggregates** | `{a, b}` concat, `{N{x}}` replication |
| **Literals** | sized (`8'hFF`, `3'b010`, `4'd5`), unsized decimal; integer `value` field reflects the actual bit pattern |
| **Generate** | `generate for` (slang unrolls), `generate if` (slang folds), bit-select bindings on the unrolled instances aggregate into a single writer per parent signal |
| **Functions** | synthesizable `function`, multi-parameter, `case` in body, called from `always @(*)` |

## B. Unit-test-only (no equivalence fixture yet)

Behavior is pinned by unit tests but never compiled and trace-diffed:

- multiple procedural blocks in one module — `event_scheduler_approximated` warning behaves correctly
- driver-conflict diagnostics: `multiple_procedural_drivers`, `multiple_always_ff_drivers`, `mixed_assignment_styles`, `blocking_in_always_ff`, bit-select slice-aware variant
- X/Z literals collapse to 0 with `x_z_literal_approximated` diagnostic
- slang elaboration diagnostics (`slang_UnknownModule`, `slang_DuplicateDefinition`, …) reach `DesignIR.diagnostics`

Moving these into the equivalence fixture set is cheap and removes a class of "looked fine in unit tests, blew up in real RTL" surprises.

## C. Explicitly rejected (loud diagnostic, no silent miscompile)

| Diagnostic | What it rejects |
| --- | --- |
| `unsupported_multiport` | SystemVerilog multi-ports |
| `unsupported_interface_port` | `interface`-typed ports |
| `unsupported_initial` | `initial` blocks |
| `unsupported_task_first_round` | `task` (functions are supported) |
| `unsupported_<kind>` | any statement or expression kind the lowerer doesn't recognize; the slang node-class name lands in the diagnostic code so it's debuggable |

Use `--fail-on-diagnostics` in CI when error-level diagnostics must hard-fail the conversion.

## D. Priority 1 — common RTL that we *don't* fully support yet

These are the dangerous ones: most either silently miscompile or take the `unsupported_<kind>` exit path even though the construct is common in real designs. Each item needs an equivalence fixture before we can claim either way.

| Gap | Why it matters | Current behavior |
| --- | --- | --- |
| `casex` / `casez` | FSM optimization, ROM decode, instruction decode | falls through to plain `switch`; **wildcard matching is silently lost** |
| Procedural `for` / `while` / `repeat` | bus encoders/decoders, parity trees, parametric reduce | `unsupported_<kind>` diagnostic |
| `inout` ports | bidirectional bus interfaces | no specific handling; needs an audit |
| Unpacked arrays (`reg [7:0] mem [0:255]`) | every RAM / ROM / FIFO | likely `unsupported_<kind>` from slang's symbol kind; needs verification |
| `signed` arithmetic | DSP paths, signed comparators, arithmetic shifts | `<<<` / `>>>` are mapped to **unsigned** shifts in `_CPP_BINARY_OP_MAP` and labeled "approximated" — silent miscompile on negative values |
| `defparam` | legacy code | slang resolves it at elaboration; **no fixture pins behavior** |

## E. Priority 2 — SystemVerilog feature rollout

slang already parses every entry here; the gap is `ModuleIR` doesn't carry the symbol shape yet. Land them one at a time, each with its own fixture.

| Feature | Where it lands | Estimated size |
| --- | --- | --- |
| `typedef` + `enum` flattened to bit-width | `frontend/lower._lower_module` recognizes the symbols and records the width mapping | small |
| Packed `struct` / `union` (flatten to one `sc_uint<sum>` with field bit-offsets) | extends the typedef work + threads offsets through bit/part-select | medium |
| `package` + `import` | slang already resolves names; lowerer just consumes the resulting symbols | small (mostly free) |
| `always_comb` / `always_ff` / `always_latch` keywords | already recognized; needs explicit fixtures, not new code | trivial |
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

The roadmap below feeds Phase 11 in `plan.md`. Each step lands as an isolated PR with a corresponding equivalence fixture.

1. **Surface the silent risks first.** Add fixtures for `casex` / `casez`, `signed` shift, unpacked-array memory. Let the equivalence harness give a binary answer on the current state before we change any code.
2. **Pin the keyword variants.** Add `always_comb` / `always_ff` / `always_latch` fixtures. Likely zero code changes; pure coverage win.
3. **`typedef` + `enum`.** Cheapest SV feature with broad payoff; small IR change.
4. **Procedural `for`.** Common in synthesizable RTL (bit reverse, parity, parametric reduce); lowering is mechanical.
5. **Packed `struct`.** Builds on the typedef work.
6. **`package` / `import`.** slang has already resolved them; mostly a "release the brake" change.
7. **`inout` ports.** Single-feature audit + fixture.
8. **`interface` / `modport`.** Separate design doc first; large enough to warrant its own milestone.

Updated whenever a row in C / D / E moves into A or B.
