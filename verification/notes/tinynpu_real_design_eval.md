# tinyNPU Real-design Evaluation

Date: 2026-07-11  
Last verified: 2026-07-11

## Case

External synthesizable RTL under `/home/MicroE/ai_proj/tinyNPU/rtl`:

- Main top: `tinyNPU_top`
- Verification wrappers: `tb/test_top/top_harness.sv` and
  `tb/test_top_8x8/top_harness_8x8.sv`
- 15 RTL modules covering APB CSR control, SRAM wrappers/loaders, systolic
  arrays, K/N tiling, accumulation, bias, ReLU, global/per-channel
  requantization, and OFM writes
- External RTL is read-only for this evaluation; no source changes are made

Assertion/property/bind/UVM content is outside the synthesizable conversion
view and is not needed by these wrappers.

## Commands

4x4 array:

```bash
.venv/bin/python verification/cases/consistency/tinynpu_consistency.py
```

8x8 array:

```bash
.venv/bin/python verification/cases/consistency/tinynpu_consistency.py --array-size 8
```

Each command performs all of the following:

1. converts the 15-module RTL hierarchy and selected harness;
2. rejects converter error diagnostics;
3. compiles and runs the RTL testbench with VCS;
4. compiles and runs the generated C++14 SystemC hierarchy;
5. compares both event traces with an independent Python GEMM/requantization
   golden model.

## Result

4x4 result:

- 15 visited modules
- 0 error diagnostics, 33 warning diagnostics
- 3 GEMM jobs, 11 checked 32-bit OFM words, 25 checked events
- RTL, generated SystemC, and independent golden traces match exactly

8x8 result:

- 15 visited modules
- 0 error diagnostics, 34 warning diagnostics
- 3 GEMM jobs, 25 checked 64-bit OFM words, 53 checked events
- RTL, generated SystemC, and independent golden traces match exactly

The 8x8 full case uses `M=8`, `N=16`, and `K=16`, so it exercises two K
tiles and two N tiles together with bias, ReLU, and per-channel
requantization. The complete gate also covers:

- APB ID read and invalid-address error response
- basic signed INT8 GEMM
- global ReLU and requantization
- bias + ReLU + per-channel requantization
- back-to-back accelerator jobs without reset
- OFM write address/data events and SRAM backdoor reads
- invalid zero-dimension start, error pulse, idle return, and no OFM write

Latest surrounding regressions after the tinyNPU fixes:

```text
pytest:                         194 passed
VCS equivalence harness:       59 / 59 passed
OFDM FFT/IFFT trace gate:       9 / 9 cases passed
MHSA keypoint gate:             all selected samples passed
ICB-to-APB consistency gate:    36 events passed
```

## Converter Defects Found And Fixed

The real design exposed issues that smaller fixtures had not covered:

1. Arithmetic constant part-selects were treated as overlapping drivers.
   Driver analysis now safely folds name-free arithmetic indices.
2. Generate-local declarations collided after scope flattening. Generate
   scope renaming now keeps each elaborated declaration unique.
3. Fixed-width signed unary literals, reduction operands, concat/repeat
   expressions, part-selects, conditionals, and signed assignment boundaries
   needed explicit SystemC typing.
4. `$clog2` localparams were emitted with an incorrect fallback value.
   Generated C++14 now uses `prism_v2sc_clog2` for parameter expressions.
5. Multiple procedural blocks writing disjoint arithmetic slices produced
   multiple SystemC writers for one `sc_signal`. Constant-folded slices now
   use per-slice shadows and one parent assembler method.
6. Multiple continuous assignments writing disjoint slices had the same
   writer-policy failure. They now use the same single-writer assembly model,
   while preserving the original part-select width conversion.
7. Mixed signed/unsigned comparisons did not apply SystemVerilog common-type
   coercion. This made a 3-bit sized cast of 7 compare as signed -1 in C++ and
   stalled the valid generator. Mixed comparisons now normalize both operands
   to a common unsigned bit width.
8. A legal 512-bit parent net connected to a 256-bit child input failed C++
   port binding in the 8x8 design. Width-mismatched simple bindings now use an
   explicit typed bridge that performs RTL-compatible truncation/extension.

Focused regressions are in `tests/test_frontend.py`,
`tests/test_interface_array_hardening.py`, `tests/test_expr_coverage.py`,
`tests/test_codegen.py`, and `tests/test_phase8.py`.

## Warning Assessment

4x4 warning breakdown:

```text
11 slang_SignConversion
10 event_scheduler_approximated
 9 slang_CaseRedundantDefault
 2 slang_SignCompare
 1 slang_ArithOpMismatch
```

The 8x8 configuration adds one `slang_PortWidthTruncate` warning for the
intentional 512-bit to 256-bit request-parameter loader connection. The new
width bridge preserves that truncation explicitly. The scheduler warnings are
expected under the project's near-cycle-accurate SystemC model; functional
event ordering and results are checked by both consistency runs.

## Assessment

tinyNPU is now a strong real-design behavior gate for synthesizable accelerator
RTL. It proves that the current converter can elaborate, compile, run, and
functionally match this hierarchy at meaningful protocol and datapath events in
both 4x4 and 8x8 configurations.

This is not a formal equivalence proof or exhaustive input-space proof. It does
not establish exact delta-cycle identity for every internal signal. Remaining
risk is concentrated in untested parameter combinations, arbitrary randomized
matrices, overflow extremes beyond the selected cases, and exact internal
per-cycle scheduling outside the checked events.

## Recommended Maintenance

1. Keep both array-size commands as release-blocking real-design gates.
2. Add deterministic random-seed cases if runtime budget permits, while keeping
   the current fixed cases for reproducibility.
3. Retain the independent Python golden comparison; RTL-vs-SystemC agreement
   alone could otherwise reproduce the same testbench or packing mistake.
