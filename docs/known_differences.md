# Known Differences

`prism_v2sc` emits practical approximate SystemC for a constrained RTL subset. It does not claim full Verilog/SystemVerilog equivalence.

Current known differences:

- The generator writes **one ``.hpp`` per module**, mirroring the source directory layout under the output directory. Each module's hpp ``#include``s the hpps of every child it instantiates, so users only need to include the top module's hpp. There is no umbrella header.
- Emission is bottom-up (post-order DFS): a parent file is written only after all of its children are already on disk. Per-source eager lowering means each source is parsed at most once and its AST released right after lowering, bounding peak memory by the largest single source rather than total design size.
- Event scheduling is approximated with `SC_METHOD` processes; arbitrary delta-cycle ordering is not modeled.
- Combinational `always` and continuous `assign` outputs are emitted with a `__next_<signal>` staging pattern so that bit-select / part-select LHS, multi-statement writes, and case-driven default branches behave consistently. Inter-statement reads of a just-written signal therefore see the *pre-block* value rather than the just-staged value (rare in synthesizable RTL).
- Nonblocking assignments in supported sequential blocks use the same staged `__next_*` pattern, including for bit-select and part-select LHS.
- Concatenation `{a, b}` and replication `{N{x}}` are emitted as explicit shift-OR chains with `sc_uint<W>` operand casts. Operand widths are inferred from declared port/signal widths and from sized literals; if a width cannot be inferred it falls back to 1.
- `generate if` conditions must fold against locally-defined parameters / localparams. If the condition cannot be folded a diagnostic is emitted and the generate-if is skipped.
- X/Z values in Verilog literals are currently converted to zero for generated C++ expressions.
- The supported SystemVerilog subset is limited by Pyverilog and project lowering coverage.
- Source indexing for top-driven traversal is lightweight and regex-based before preprocessing.
- Case statements are emitted for ordinary `case` patterns; `casex`/`casez` wildcard semantics are not modeled as four-state matching.
- Generate bit-select bindings use generated scalar bridge signals for simple `vector[i]` patterns.
- Direct instance bit-select bindings use scalar bridge signals for simple `vector[constant]` and `vector[index]` patterns.
- Positional port bindings (e.g. ``mod u(a, b, c);``) are resolved against the child's cached signature, recovering port names from positions. Named bindings remain the recommended style.
- Modules with multiple procedural blocks emit an event-scheduler approximation warning. Per-signal `always` style (one block per output) is the recommended pattern and is exercised in the equivalence fixtures.

Policy:

- Unsupported constructs should produce diagnostics or explicit comments instead of silent behavior.
- `--fail-on-diagnostics` should be used in CI when error-level unsupported constructs must fail conversion.
