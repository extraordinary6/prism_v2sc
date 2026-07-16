# Syntax Coverage

What `prism_v2sc` actually supports today, what it explicitly rejects, and where the silent risks are. Sourced from `frontend/lower.py` kind dispatch, `codegen/expr.py` operator map, the diagnostic table, and the `tests/equivalence/fixtures/` set. Update this doc whenever the lowerer's behavior changes.

The input contract is Verilog/SystemVerilog RTL. Chisel, FIRRTL, Scala, and
other generator languages are not parsed or converted; use a fixed generated
`.v`/`.sv` snapshot as the input boundary.

The classification is by **evidence strength**, not by syntactic category — the question "is this safe to feed in?" is really "do we have a CI-level proof?" CI gives that proof in three flavors:

- **Trace-equivalence fixtures** (section A): co-simulate the RTL with `iverilog` and the generated SystemC with `libsystemc-dev`, diff sampled per-cycle outputs.
- **Conversion-only fixtures** (section B): run `prism-v2sc`, validate `ir.json` and generated headers, and assert no error diagnostics for SV constructs that Icarus cannot compile.
- **Diagnostic fixtures** (section C): run `prism-v2sc` on RTL that's *supposed* to be rejected or flagged, assert the expected diagnostic codes land in `ir.json`. Lets us pin the contract for rejection/approximation paths that trace equivalence can't reach.

Outside CI, `verification/` also holds manual real-design gates (section D). Those are useful evidence for broader RTL shapes, but they are intentionally not counted as CI trace-equivalence proof.

## A. Trace-equivalence-verified (near-cycle trace match)

Forty-one fixtures under `tests/equivalence/fixtures/*.{v,sv}` plus the registered multifile cases. Anything in this table is verified at trace-diff granularity by `.github/workflows/equivalence.yml`.

| Category | Verified surface |
| --- | --- |
| **Structure** | module def / inst, named + positional port binding, parameter override (slang elaborates), nested hierarchy, multi-file build with `+incdir+` / `-D` / nested `-f` filelists; parent-scope parameter/localparam overrides instantiate children with concrete template arguments while unsafe child template defaults are sanitized (`param_hierarchy_edges`); net declaration assignments such as `wire n = expr` preserve continuous-assignment semantics (`net_decl_assign`) |
| **Ports & signals** | `input` / `output`, whole-vector `inout`, `wire`, `reg`, vector `[N:0]`, parameterized `[WIDTH-1:0]`, signed declarations lowered to `sc_int<W>` / `sc_bigint<W>` (`bool` is used only for unsigned 1-bit); unsigned vectors wider than 64 bits lower to `sc_biguint<W>`; parameter-dependent widths use compile-time aliases that select ordinary or big SystemC integer types after template specialization; mismatched packed widths on simple hierarchical bindings use typed bridges for RTL-compatible truncation/extension; `inout` lowers to SystemC resolved vectors and is verified for mutually exclusive external/DUT drivers across a whole-bus hierarchical binding |
| **Memories** | unpacked arrays (`reg [W-1:0] mem [0:D-1]`) lowered to a per-cell `sc_signal<sc_uint<W>>` array; per-cell `.write()` / `.read()` gives Verilog nonblocking semantics via SystemC delta cycles; reset initialization, write enable, independent read/write addresses, and same-cycle old-value reads are trace-verified (`memory_edges`) |
| **Combinational** | `always @(*)`, `always_comb`, `always_latch`, continuous `assign`; blocking read-after-write and longer blocking chains within one combinational process are trace-verified through `__next_*` staging (`staged_read_after_write`, `blocking_comb_chain`); latch hold plus partial assignment is trace-verified (`latch_edges`); sensitivity inference through function-call args, selects, concat, and replication is trace-verified (`sensitivity_edges`) |
| **Sequential** | `always @(posedge clk)`, `always_ff`, async reset (`posedge clk or negedge rst_n`, plus active-high `posedge rst` in `async_reset_edges`); nonblocking assignment chains preserve pre-edge RHS values (`nba_chain`) |
| **Control flow** | `if`/`else`, ordinary `case` (no wildcard), `casez` / `casex` lowered to mask/match if-else chain, `default`, nested ternary selection, procedural `for` with constant bounds including decrementing loops, non-zero starts, and nested loops (unrolled at elaboration time) |
| **Operators** | full binary `+ - * / % == != < > <= >= && \|\| & \| ^ << >>`, ternary `?:`, unary `! ~ - +`, reduction `& \| ^ ~& ~\| ^~ ~^`; arithmetic `>>>` via `$signed` cast; known-width multi-bit complement preserves Verilog width before later shifts; division/modulo use a two-state zero-denominator guard to prevent host `SIGFPE`; mixed signed/unsigned comparisons normalize to a common unsigned bit width; other signed/unsigned boundary arithmetic is verified when RTL explicitly extends/casts operands (`signed_mixed_context`); 1/2/31/32/33/63/64/65-bit expression and concat boundaries (`width_boundaries`) |
| **Selects** | bit-select `sig[i]` (read + write), part-select `sig[msb:lsb]` and indexed part-select `sig[base +: width]` / `sig[base -: width]` (read + write); dynamic indexed select widths are preserved from slang type info for concat/repeat contexts; LHS uses staged `__next_*`; out-of-order non-overlapping bit/part-select writes in one combinational process are trace-verified (`part_select_assembly`) |
| **Aggregates** | `{a, b}` concat, `{N{x}}` replication |
| **Literals** | sized (`8'hFF`, `3'b010`, `4'd5`, 65-bit based literals), signed based (`8'shFF`), unsized decimal, and sized literals whose slang syntax retains balanced wrapping parentheses; integer `value` field reflects the actual bit pattern and signed based literals also carry `signed_value`; based literals wider than 64 bits emit string-constructed `sc_biguint` / `sc_bigint` values; implicit real-to-integral constant conversions preserve slang's converted integer value for LUT-style assignments (`ofdm_fft_smoke`) |
| **Type aliases** | `typedef` / `enum` flattened to bit-width metadata in `ModuleIR.type_aliases`; enum members lower to integer constants |
| **Packed aggregates** | packed `struct` / `union` flattened to one vector; field reads and writes lower through bit/part-selects (`packed_aggregate_demo`) |
| **Packages** | `package` + `import pkg::*` / `import pkg::item` extract functions, typedefs, and parameters from packages; package parameters emit as template arguments (`package_import`) |
| **Bidirectional buses** | whole-vector `inout` ports and whole-vector hierarchical `inout` bindings use `sc_inout_rv` / `sc_signal_rv`; high-Z assignment branches emit `sc_lv<W>("ZZ...")`; mutually exclusive DUT/external drive and resolved-value sampling through top and child modules are trace-verified (`inout_bus`, `inout_edges`) |
| **Generate** | `generate for` (slang unrolls), `generate if` (slang folds), bit-select bindings on the unrolled instances aggregate into a single writer per parent signal |
| **Functions** | synthesizable `function`, multi-parameter, `case` in body, called from `always @(*)`, `return` statement supported; calls participate in inferred combinational sensitivity (`sensitivity_edges`) |
| **Multi-writer aggregation** | multiple procedural blocks, continuous assignments, or child output bit/part-select bindings writing different constant-foldable slices of the same parent signal land in one assembler process; slice assignment width conversion is preserved — procedural behavior is trace-verified by `slice_writers`, child output assembly by unit regression plus E203 execution, and arithmetic procedural/continuous slices by unit regressions and tinyNPU |
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
| `dynamic_sv_rejected` | `unsupported_classtype` | class/randomization constructs stay outside the supported subset; the assertion/property content in the same fixture is intentionally ignored |
| `slang_unknown_module` | `slang_UnknownModule` | unknown instance target — iverilog also fails to elaborate, no trace to compare |
| `slang_duplicate_definition` | `slang_DuplicateDefinition` | duplicate module definition — same reason |

The driver-conflict-slice-aware variant moved out of this section into A: the
underlying multi-writer aggregation (`slice_writers` fixture) now verifies
trace-level correctness too.

## D. Verification-workspace / real-design verified

These checks live under `verification/` and may depend on local external RTL or VCS. They are not normal CI fixtures, but they capture real-design behavior that is too large or too project-specific for the focused equivalence harness.

| Gate | Verified surface | Evidence |
| --- | --- | --- |
| `verification/cases/conversion/mhsa_icb_smoke.py` | External `/home/MicroE/MHSA` `icb_mhsa` design converts with 17 sources, 16 visited modules, 83 instances, 72 processes, 0 error diagnostics, and generated `icb_mhsa.hpp` compiling as C++14/SystemC. This exercises parameterized hierarchy, generated PE grids, multidimensional unpacked arrays, array-element port bridges, concat-LHS assignment splitting, expression input port bridges, unconnected output dummies, local-int procedural `for`, indexed part-selects, and default-template child instances. | `verification/notes/mhsa_icb_real_design_eval.md` |
| `verification/cases/conversion/ofdm_fft_smoke.py` + `verification/cases/consistency/ofdm_fft_trace_consistency.py` | External OFDM `fft_ifft_top` RTL converts with 1 source, 1 module, 0 error diagnostics, and generated `fft_ifft_top.hpp` compiling as C++14/SystemC. The trace gate uses VCS RTL golden simulation and generated SystemC on 9 deterministic 64-point FFT/IFFT cases, comparing sampled `data_out_valid/re/im` for 380 cycles per case. This exercises wide signed packed buffers, indexed part-select reads/writes, dynamic indexed part-select width in sign-extension concat, unpacked LUT arrays, many sequential blocks, and slang-evaluated real-valued twiddle constants converted to integral LUT entries. | `verification/notes/ofdm_fft_real_design_eval.md` |
| `verification/cases/consistency/mhsa_keypoint_consistency.py` | Near-cycle RTL(VCS) vs generated SystemC keypoint consistency for `icb_mhsa`, `pe`, and `scale_core`: top-level CSR reads/writes, two ICB-to-USRAM 64-bit write/read paths across bar0/bar1, signed PE multiply/accumulate/hold/flush/reset samples, and scaled-input byte extraction. | latest recorded result: `icb_mhsa` 8 samples, `pe` 9 samples, `scale_core` 7 samples |
| `verification/cases/consistency/icb_apb_bridge_consistency.py` | External interface-based ICB-to-APB bridge converts from an untouched RTL tree via a temporary synthesizable snapshot and flat wrapper. The generated top compiles and matches RTL at 36 ICB/APB transaction events, covering register mask/error behavior, DES-enabled command decoding, asynchronous FIFO crossing, all four APB ports, reads/writes, and varied APB wait states. | `verification/notes/icb_apb_bridge_real_design_eval.md` |
| `verification/cases/consistency/tinynpu_consistency.py` | External 15-module tinyNPU accelerator hierarchy converts, compiles, and matches VCS RTL plus an independent Python golden model in both 4x4 and 8x8 configurations. Six total GEMM jobs cover APB control/error paths, SRAM loading, signed INT8 GEMM, K/N tiling, bias, ReLU, global/per-channel requantization, back-to-back jobs, OFM writes/reads, and invalid zero dimensions. The 8x8 full case uses `M=8, N=16, K=16`. | `verification/notes/tinynpu_real_design_eval.md` |
| `verification/cases/consistency/model_memory_provider_consistency.py` | The built-in external-model memory provider is differential-tested against VCS RTL for one-cycle synchronous single-port `read_first`, `write_first`, and `no_change` behavior, including same-address writes, subsequent reads, and disabled output hold. | `/tmp/prism_model_memory_consistency` run artifacts |
| `verification/cases/consistency/e203_cpu_consistency.py` | External E203 `e203_cpu_top` converts from 51 source files into 94 reachable/specialized modules and compiles as C++14/SystemC. Six VCS/SystemC programs cover reset/clock gating, RV32I ALU and taken/not-taken branches, M-extension multiply/divide/remainder and divide-by-zero, byte/halfword DTCM masks and load extension, CSR read/write, and timer-interrupt trap entry. Ordered first-occurrence PC events and 10 DTCM words match; the interrupt case intentionally permits a one-loop response-latency difference. ITCM/DTCM use the manifest-backed masked memory provider. | `verification/notes/e203_cpu_real_design_eval.md` |

Treat this section as a stronger signal than unit-only coverage, but weaker than a focused trace-equivalence fixture that runs in CI.

## E. Explicitly rejected (loud diagnostic, no silent miscompile)

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

## F. Priority 1 — common RTL that we *don't* fully support yet

These are the dangerous ones: most either silently miscompile or take the `unsupported_<kind>` exit path even though the construct is common in real designs. Each item needs a fixture (trace, conversion, or diagnostic) before we can claim either way.

| Gap | Why it matters | Current behavior |
| --- | --- | --- |
| bit-select hierarchical `inout` bindings | child `inout` ports connected to `bus[i]` need a carefully audited proxy model | not trace-equivalence-verified; use whole-vector `inout` bindings for the supported path |
| complex interfaces | clocking blocks, interface tasks/functions, nested interfaces, interface arrays, modport expressions/exports | outside the packed-signal/simple-modport subset; `interface_complex_rejected` pins the diagnostic path |
| `defparam` | legacy code | slang resolves it at elaboration; **no fixture pins behavior** |
| complex mixed signed/unsigned context sizing | SV expression signedness and width can be context-determined across nested mixed operands | partially covered by declared signed ports/signals and explicit casts; full expression-level signedness propagation is not modeled exhaustively. See `docs/signed_mixed_semantics.md` |

## G. Priority 2 — SystemVerilog feature rollout

Most entries here have landed; the table is kept as rollout history. New entries should still land one at a time with trace, conversion, diagnostic, unit, or real-design verification evidence.

| Feature | Where it lands | Estimated size |
| --- | --- | --- |
| ~~`typedef` + `enum` flattened to bit-width~~ | Done: `frontend/lower._lower_module` records the width mapping and enum member values | small |
| ~~Packed `struct` / `union` (flatten to one `sc_uint<sum>` with field bit-offsets)~~ | Done: alias metadata records fields and member access lowers to bit/part-selects | medium |
| ~~`package` + `import`~~ | Done: wildcard and explicit imports extract functions, typedefs, and parameters from packages | small (mostly free) |
| ~~`interface` + `modport`~~ | Done for the simple packed-signal/modport subset: interface instances and ports flatten into ordinary `bus__field` signals/ports, verified by the `interface_modport` conversion fixture; complex interface constructs remain a Priority 1 gap | medium |

## H. Priority 3 — intentionally outside the synthesized model

These are non-synthesizable or require runtime infrastructure SystemC's `SC_METHOD` model does not provide. Dynamic language/testbench constructs remain rejected; verification-only assertion metadata and statements are ignored.

- classes, inheritance, polymorphism
- randomization (`rand`, `randc`, `dist`, `constraint`)
- `program` blocks
- assertions / properties / sequences as runtime checkers: ignored, with no generated behavior
- DPI, `$display` / `$finish` and other system tasks (non-synthesizable)
- `event` type, `->` trigger
- string literals, runtime `real` / `shortreal` storage or datapaths. Real-valued constant expressions are supported only when slang inserts an implicit conversion to an integral target.
- streaming `{<<{a,b}}` / `{>>{a,b}}`, `inside` expressions, queue/array methods

## Historical rollout note

The following list is retained only as compact historical context. Current
feature status and evidence are maintained in the tables above and in
`docs/rtl_coverage_registry.json`; project progress is tracked in
`docs/rtl_conversion_roadmap.md`.

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

This historical list is not a second progress tracker.
