# MHSA ICB Real-design Evaluation

Date: 2026-07-09

## Case

External RTL under `/home/MicroE/MHSA`:

- Top: `icb_mhsa`
- Sources: `icb_mhsa/*.sv` plus `rtl_design/*.sv`
- Design shape: ICB-facing accelerator wrapper, SRAM-style memories, MHSA control pipeline,
  systolic-array datapath, parameterized hierarchy, generate-expanded PE grid, signed arithmetic,
  procedural loops, unpacked arrays.

## Commands

Runnable smoke entry:

```bash
.venv/bin/python verification/cases/conversion/mhsa_icb_smoke.py
```

Runnable keypoint consistency entry:

```bash
.venv/bin/python verification/cases/consistency/mhsa_keypoint_consistency.py
```

Conversion smoke:

```bash
.venv/bin/python -m prism_v2sc \
  --top icb_mhsa \
  --out /tmp/prism_mhsa_icb_smoke \
  --metrics \
  --fail-on-diagnostics \
  /home/MicroE/MHSA/icb_mhsa/icb_mhsa.sv \
  /home/MicroE/MHSA/icb_mhsa/imu.sv \
  /home/MicroE/MHSA/rtl_design/*.sv
```

Generated top compile smoke:

```bash
g++ -std=c++14 \
  -I/usr/local/systemc-2.3.4/include \
  -I/tmp/prism_mhsa_icb_smoke/icb_mhsa \
  -I/tmp/prism_mhsa_icb_smoke/rtl_design \
  -x c++ -c /tmp/prism_mhsa_icb_smoke/icb_mhsa/icb_mhsa.hpp \
  -o /tmp/prism_mhsa_icb_smoke/icb_mhsa.o
```

## Result

Current smoke result:

- 17 source files
- 16 visited modules
- 83 instances
- 72 procedural processes
- 0 error diagnostics
- 54 warning diagnostics
- all per-module SystemC headers and `ir.json` generated
- generated `icb_mhsa.hpp` compiles as C++14 with SystemC headers

Warning breakdown:

```text
14 event_scheduler_approximated
 9 slang_ArithOpMismatch
 8 slang_EmptyOutputPortConn
 5 slang_SignConversion
 2 slang_UnnamedGenerate
 1 slang_CaseDefault
 1 slang_IntBoolConv
 1 slang_InvalidUTF8Seq
13 slang_NewlineEOF
```

The remaining compiler output is only:

```text
#pragma once in main file
```

This warning is expected for the smoke because it deliberately compiles a generated header as
the translation unit.

Issues found and fixed during this evaluation:

- `scale_core.sv` uses a synthesizable loop-local declaration and post-increment step:

```systemverilog
for (int i = 0; i < 8; i++) begin
```

- `mm_systolic.sv` uses multi-dimensional unpacked arrays and array element PE connections.
- `mm_systolic.sv` uses concat lvalue continuous assignment:
  `assign {row_0, ..., row_7} = row_bar;`
- `icb_mhsa.sv` connects a child input port to an expression:
  `.acc_done({31'b0, done})`
- PE-grid array element bridges cross signed child ports and unsigned parent signals.
- Parameterized child instances without explicit overrides require `child<>` under C++14.
- Nested ternaries with an unsized `0` branch require explicit SystemC casts.
- Array sensitivity expansion must preserve `sig[i][j]` syntax instead of sanitizing it into
  non-existent identifiers.
- Indexed part-selects such as `input_bar[i*8 +: 8]` must lower to
  `range(base + width - 1, base)`, not `range(base, width)`.
- Level-sensitive event controls inside an `always_ff`-kind block, such as
  `always_ff @( clk )` in `mhsa_acc_wrapper.sv`, must still generate a SystemC
  sensitivity entry (`sensitive << clk;`). Without that, the delayed SRAM bank
  selects never update and top-level ICB SRAM reads return stale zeroes.

## Keypoint Consistency

The keypoint consistency gate is intentionally near-cycle-accurate rather than a full per-cycle
trace diff. It compares RTL and generated SystemC only at meaningful sample points.

Current cases:

- `scale_core`: reset, five valid 64-bit scaled-input samples covering low bytes, high bytes,
  all-ones/all-zero halves, and idle zeroing.
- `pe`: reset, signed negative multiply, signed positive accumulate, hold with invalid input,
  flush, max positive multiply, min negative accumulation, hold after extreme values, and reset
  again.
- `icb_mhsa`: top-level ICB reset/control state, CSR write/read of `input_base`, CSR write/read
  of `output_base`, default CSR read, and two 64-bit ICB-to-USRAM write/read pairs covering
  bar0 and bar1 address regions.

Latest result:

```text
icb_mhsa: keypoint consistency passed (8 samples)
pe: keypoint consistency passed (9 samples)
scale_core: keypoint consistency passed (7 samples)
MHSA keypoint consistency passed: /tmp/prism_mhsa_keypoints
```

## Assessment

This is now a useful real-design conversion/compile smoke and should remain under
`verification/cases/conversion`. It also has a pragmatic behavior gate under
`verification/cases/consistency`.

It is valuable because it exercises project-relevant synthesizable RTL that the current focused
fixtures only cover in smaller pieces: hierarchy, parameter propagation, bus wrapper logic,
SRAM arbitration, generated PE arrays, signed datapath arithmetic, procedural loops, and
memory-style modules.

The current gates prove:

1. conversion produces `ir.json` and all module headers;
2. no unexpected error diagnostics;
3. generated hierarchy is C++14/SystemC-compilable at the top header level.
4. selected real MHSA modules and top-level ICB CSR/USRAM paths match RTL at key sample points.

It does not attempt full cycle-by-cycle RTL/SystemC equivalence for the complete MHSA compute
transaction. That is a higher-cost signoff target. For the current project stage, the keypoint
gate is the intended practical check.

## Recommended Next Actions

1. Keep `verification/cases/conversion/mhsa_icb_smoke.py` as a manual real-design smoke.
2. Keep `verification/cases/consistency/mhsa_keypoint_consistency.py` as the practical
   RTL/SystemC behavior gate for MHSA.
3. If stronger coverage is needed later, extend the keypoint gate with a bounded accelerator
   start/done scenario that checks selected output SRAM words.
4. Review the 54 conversion warnings and classify which are expected limitations versus warnings
   that should become unsupported diagnostics.
