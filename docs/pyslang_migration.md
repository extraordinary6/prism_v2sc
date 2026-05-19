# pyslang Migration Plan

Status: **Phase A + B + C landed on `feat/pyslang-migration`** (pyverilog fully removed). Last updated: 2026-05-19.

This document is the agreed-upon roadmap for replacing the pyverilog frontend with pyslang, so that prism_v2sc can ingest synthesizable SystemVerilog (interfaces, packages, typedefs, packed structs, enums, `always_comb/ff/latch`, packed/unpacked arrays). Dynamic SV (classes, randomization, programs) stays out of scope.

## 1. Why migrate

Two reasons, in this order:

1. **Cover synthesizable SystemVerilog.** pyverilog's SV support is partial and mostly frozen. slang (pyslang's C++ backend) tracks IEEE 1800-2023 and is the most compliant open SV frontend; its Python bindings ship on PyPI with prebuilt wheels for the platforms we care about.
2. **Drop a lot of our own elaboration code.** slang returns a fully elaborated `RootSymbol`: parameter overrides resolved, generate-if/for unrolled, typedefs/packages/enums resolved, port widths computed. Many handwritten passes in our lowering become redundant:
   - `frontend/lower._const_eval_expr` (generate-if const-folding)
   - `frontend/lower._parameter_value_map` / `_parse_simple_constant`
   - The string-based width/parameter substitution in `codegen/expr._eval_text`
   - Future typedef / struct / enum infrastructure we'd otherwise have to write from scratch
3. **(Bonus) The Verilog path inherits these benefits.** Verilog 1364 is a strict subset of SV, so slang handles plain Verilog correctly. Dual-frontend is therefore an unnecessary terminal architecture.

## 2. Why not keep a dual frontend permanently

A long-lived pyverilog + pyslang split was considered and rejected:

| Dimension | Dual frontend forever | Phased replacement |
| --- | --- | --- |
| Terminal LOC | Two lowerers + a router | One lowerer |
| Maintenance | Double, indefinitely | One-time migration cost |
| Elaboration benefits on plain Verilog | No | Yes |
| Migration risk profile | Same, plus router complexity | Phased, reversible |

A dual frontend is only useful as a **migration scaffold** — to derisk the swap. It is the means, not the end.

## 3. Target architecture

```
.v / .vh / .sv / .svh sources
        │
        ▼
  frontend/pyslang_parser.parse_sources()   ← pyslang.Compilation
        │
        ▼
  frontend/lower.lower_design()              ← walks RootSymbol
        │
        ▼
        ModuleIR + ModuleSignature           ← unchanged
        │
        ▼
  flow / codegen                             ← unchanged
```

`ModuleIR` shape stays exactly as it is today; **the IR is the load-bearing invariant of this migration**. Anything beyond the lowerer (flow, codegen, harness, CLI, equivalence) is untouched in Phases A and B.

## 4. Three-phase migration

### Phase A — Add pyslang as an opt-in frontend (pyverilog stays default)

**Goal:** prove `pyslang → same ModuleIR → same generated SystemC` on every existing fixture.

**Concrete steps:**

1. Add `pyslang>=11.0,<12.0` to `pyproject.toml` as a required dependency. Both Windows and Ubuntu CI have prebuilt wheels.
2. Add a CI smoke job that does `python -c "import pyslang; pyslang.syntax.SyntaxTree.fromText('module a; endmodule')"` on every platform we care about. This catches wheel breakage independently of the rest of the migration.
3. New file `src/prism_v2sc/frontend/pyslang_parser.py` exposing `parse_sources(sources, include_dirs, defines) -> Compilation` mirroring the surface of `pyverilog_parser.parse_verilog`.
4. New file `src/prism_v2sc/frontend/lower_sv.py` (temporary name) with `lower_design(compilation, top) -> DesignIR` and `lower_module(instance_symbol, source_path) -> ModuleIR`. Walks `RootSymbol.topInstances`, emits the same IR shape as `frontend/lower.py`.
5. CLI gains a hidden `--frontend {pyverilog,pyslang}` flag, defaulting to `pyverilog`. Wire it through `convert_with_metrics`.
6. New test file `tests/test_frontend_equivalence.py`: for each of the 9 equivalence fixtures + the inline-RTL unit-test fixtures, parse with both frontends and assert the resulting IR (modulo `source_path` and ordering-only fields) is identical. Fail loudly on any mismatch.
7. Extend `tests/equivalence/run_equivalence.py` to optionally run each fixture under `--frontend pyslang` and diff RTL/SC traces. Wire as a CI matrix (`frontend: [pyverilog, pyslang]`).

**Exit criteria for Phase A:**

- All 55+ unit tests green under both frontends.
- All 9 equivalence fixtures pass under both frontends in CI on Linux.
- IR diff test confirms byte-identical IR JSON output (or documented, minimal, intentional differences).

**Phase A status (2026-05-18):**

- 65/65 unit tests green on the local Windows workstation (55 pre-existing
  + 10 new `tests/test_frontend_equivalence.py`). Equivalence-on-CI for
  pyslang is wired through the `frontend: [pyverilog, pyslang]` matrix in
  `.github/workflows/equivalence.yml` but has not yet completed a Linux
  CI run.
- 8 of 9 fixtures emit **byte-identical** SystemC under both frontends
  (mux2, adder, byteswap, counter, fsm_handshake, shift_register, alu,
  pipeline8).
- The remaining fixture (`multi_file`, which uses ``\`define WIDTH 8``)
  emits *functionally* identical SystemC: slang resolves the port width
  to the integer `8`, so we emit ``sc_uint<8>`` where the pyverilog path
  emits ``sc_uint<(((8 - 1)) - (0) + 1)>``. Both compile to the same C++
  type; this is one of the "documented minimal differences" the exit
  criteria explicitly allows.
- `pyproject.toml` now depends on `pyslang>=11.0,<12.0`. A dedicated
  smoke workflow (`.github/workflows/pyslang_smoke.yml`) guards against
  pyslang wheel regressions on Ubuntu and Windows across Python 3.11 / 3.12.

**Rollback:** delete the new files and the flag; default behavior unchanged.

### Phase B — Flip the default, simplify lowering

**Goal:** make pyslang the default frontend and start collecting the elaboration dividend.

**Concrete steps:**

1. Change CLI default to `--frontend pyslang`. `--frontend pyverilog` remains as an escape hatch.
2. Soak in CI for one cycle (≈ 1 week of pushes / a few PRs).
3. Begin simplifying the now-elaborated path. Each of the following becomes a small standalone PR with its own tests:
   - Delete `_const_eval_expr` and `_parameter_value_map` from `frontend/lower.py` (slang already chose the generate-if branch and resolved every parameter).
   - Replace `_parse_simple_constant` in `frontend/lower.py` and the equivalent in `codegen/expr.py` with direct integer reads from the elaborated symbol.
   - Replace `codegen/expr._eval_text` / `_width_from_pair` string evaluators with direct width reads — port widths are concrete integers now.
   - Remove the regex-based `_convert_verilog_constants` in `codegen/systemc.py` for literal handling — slang gives us typed literals.
4. Diagnostics: ensure slang's diagnostic stream is surfaced in our `DiagnosticIR` (mapping `slang.DiagCode → DiagnosticIR.code`).

**Exit criteria for Phase B:**

- Default `--frontend` is pyslang for ≥ 1 week with no CI regressions.
- Net code-size delta in `src/prism_v2sc/` is **negative** by at least the LOC of the deleted const-fold paths.

**Rollback:** flip the default back; deleted code recovered via `git revert`.

**Phase B status (2026-05-18):**

- Step 1 (flip default) done. ``--frontend`` defaults to ``pyslang`` in
  ``prism_v2sc.cli``, ``verify.harness.convert_with_metrics``,
  ``frontend.flow.lower_design_top_down``, and the equivalence harness.
  ``--frontend pyverilog`` stays available as a fully-featured escape
  hatch.
- Step 2 (soak in CI) is intentionally skipped on this branch; we'll
  rely on the existing test + equivalence matrix instead of a calendar
  soak.
- Step 3 (simplify pyverilog-only elaboration helpers) is **deferred to
  Phase C**. Rationale: every named helper (``_const_eval_expr``,
  ``_parameter_value_map``, ``_parse_simple_constant``,
  ``codegen/expr._eval_text`` / ``_width_from_pair``,
  ``codegen/systemc._convert_verilog_constants``) still has a live
  caller on the pyverilog path. Removing them now would silently
  degrade the escape hatch (generate-if folding, width-expression
  evaluation, Verilog literal conversion) for the entire Phase B
  window. Since Phase C deletes the entire pyverilog path anyway,
  there is no LOC dividend lost — we cut the code once, at one cut
  point, when the escape hatch goes away.
- Step 4 (slang diagnostics) done. ``frontend/flow._collect_slang_diagnostics``
  runs slang's ``DiagnosticEngine`` over every ``Compilation``,
  formats each diagnostic via the engine, and surfaces the result as
  ``DiagnosticIR(code="slang_<DiagCodeName>")`` entries on the
  ``DesignIR``. Severity ``Error``/``Fatal`` map to ``error``;
  everything else maps to ``warning``.

The Phase B exit criterion on "negative LOC delta" is therefore not
met on this branch; it migrates to Phase C as part of the pyverilog
removal.

### Phase C — Remove pyverilog

**Goal:** one frontend, one bug surface.

**Concrete steps:**

1. Remove `--frontend` flag from CLI (or accept `pyverilog` with a deprecation error).
2. Delete `src/prism_v2sc/frontend/pyverilog_parser.py`.
3. Delete pyverilog-specific lowering: the `pyverilog.vparser` imports, the `vast.*` type-switching, the `_lower_port` / `_lower_always` / `_structured_statement` functions in `frontend/lower.py` whose only consumer was the pyverilog AST.
4. Rename `frontend/lower_sv.py` → `frontend/lower.py`. The terminal architecture has a single lowerer that happens to be slang-based — there is no need to advertise the SV-ness in the filename.
5. Remove `pyverilog` from `pyproject.toml`.
6. Update README, plan.md, docs/* to remove all pyverilog references.

**Exit criteria for Phase C:**

- All tests green.
- No `pyverilog` strings in `src/`.
- `pip install -e .` does not pull pyverilog.

**Rollback:** harder once we're here, but recoverable via revert. By design we don't move to Phase C until we've burned in Phase B for long enough that this is unlikely to be needed.

**Phase C status (2026-05-19):**

- Step 1 (drop the ``--frontend`` flag) done. ``cli.py``,
  ``verify/harness.py``, ``frontend/flow.py``, and the equivalence
  harness no longer expose or accept the flag.
- Step 2 (delete ``frontend/pyverilog_parser.py``) done.
- Step 3 (delete pyverilog-specific lowering) done. The old
  ``vast.*`` / ``vparser`` lowering path, plus the const-fold helpers
  (``_const_eval_expr``, ``_parameter_value_map``,
  ``_parse_simple_constant``, ``codegen/expr._eval_text`` /
  ``_width_from_pair``, ``codegen/systemc._convert_verilog_constants``)
  that only existed to support that path are gone with it.
- Step 4 (``lower_sv.py`` → ``lower.py``) done; ``frontend/lower.py``
  is now the slang-only lowerer and ``frontend/module_index.py``
  (pyverilog-only) was removed alongside the rename.
- Step 5 (drop pyverilog from ``pyproject.toml``) done.
- Step 6 (docs/CI cleanup) done. README installs pyslang;
  ``.github/workflows/equivalence.yml`` runs a single (non-matrix)
  pyslang job; this migration plan is the only remaining file in the
  repo that mentions pyverilog, intentionally, as the migration record.

Exit criteria status:

- ✅ all tests green under the pyslang-only path
- ✅ no ``pyverilog`` strings under ``src/``
- ✅ ``pip install -e .`` no longer pulls pyverilog

## 5. After migration — SV feature rollout

The migration plan above does **not** add new SV features beyond what pyverilog already covers. Once Phase C lands, we enable SV constructs incrementally, each with its own fixture and equivalence test:

1. `always_comb` / `always_ff` / `always_latch` keyword recognition (slang already parses these; lowering needs minor updates).
2. `typedef` + `enum` flattened to bit-widths in `ModuleIR`.
3. Packed `struct` (flatten to a single `sc_uint<N>` with width sum).
4. `package` + `import` (resolved by slang; we just consume symbols).
5. `interface` + `modport` (this one is large; IR needs an `InterfaceIR` concept — separate design doc).
6. Unpacked arrays (require an array signal IR).

None of these are migration concerns; they are post-migration features.

## 6. Risk register

| Risk | Likelihood | Mitigation |
| --- | --- | --- |
| pyslang misbehaves on some Verilog edge case our existing fixtures pass | Medium | Phase A IR-diff test on all fixtures catches this before Phase B. Bug filed upstream + workaround in lowering. |
| pyslang 12.x ships during migration with breaking changes | Medium | `<12.0` upper bound in pyproject. Migrate to 12.x as a separate PR after Phase C burn-in. |
| Native wheel unavailable on some platform we add later (e.g. 32-bit ARM) | Low | Phase A smoke job catches this immediately. Documented platform support narrows to "platforms with pyslang wheels" — explicit and acceptable. |
| Existing tests break because they grep pyverilog-specific IR strings | Low | IR is the invariant; if pyslang produces structurally-identical IR these tests pass. Tests that *do* depend on pyverilog quirks (e.g. specific node class names) get rewritten in Phase A. |
| Reviewers / users surprised by a hard-cut migration | Low | The three phases all live behind the `--frontend` flag until Phase C; people who want to stay on pyverilog can do so during the whole Phase B period. |

## 7. Out of scope

- Class-based dynamic SV, randomization, programs, assertions/properties as runtime checkers.
- A pure-Python install (slang is C++; we accept the native-wheel dependency).
- Replacing Icarus Verilog as the RTL golden simulator. The equivalence CI loop is orthogonal to which Python frontend we use to lower.

## 8. First concrete action (when we start)

The smallest reversible step that produces signal:

> Add `pyslang>=11.0,<12.0` to `pyproject.toml`. Add a CI job that runs `python -c "import pyslang; t = pyslang.syntax.SyntaxTree.fromText('module a; endmodule')"` on every platform we use. Land it, watch CI for a week.

If this is green everywhere, Phase A is unblocked.

## References

- pyslang on PyPI: https://pypi.org/project/pyslang/
- slang releases: https://github.com/MikePopoloski/slang/releases
- slang docs: https://sv-lang.com/
- IEEE 1800-2023 (SystemVerilog standard)
