# OFDM FFT/IFFT Real-design Evaluation

Date: 2026-07-09  
Last verified: 2026-07-10

## Case

External RTL under `/home/MicroE/ai_proj/Simulation-and-FFT-Implementation-of-OFDM-Communication-System/hardware/src`:

- Top: `fft_ifft_top`
- Source: `fft_ifft_top.v`
- Design shape: single-module FFT/IFFT datapath with wide signed packed vectors, packed buffer slices, indexed part-selects, unpacked LUT array, many sequential processes, and real-valued twiddle-factor constants converted into 16-bit integral LUT entries by slang.

## Command

Runnable smoke entry:

```bash
.venv/bin/python verification/cases/conversion/ofdm_fft_smoke.py
```

Runnable trace consistency entry:

```bash
.venv/bin/python verification/cases/consistency/ofdm_fft_trace_consistency.py --rtl-sim vcs
```

Equivalent conversion command:

```bash
.venv/bin/python -m prism_v2sc \
  --top fft_ifft_top \
  --out /tmp/prism_ofdm_fft_smoke \
  --metrics \
  --fail-on-diagnostics \
  /home/MicroE/ai_proj/Simulation-and-FFT-Implementation-of-OFDM-Communication-System/hardware/src/fft_ifft_top.v
```

Generated top compile smoke:

```bash
g++ -std=c++14 \
  -I/usr/local/systemc-2.3.4/include \
  -x c++ -c /tmp/prism_ofdm_fft_smoke/fft_ifft_top.hpp \
  -o /tmp/prism_ofdm_fft_smoke/fft_ifft_top.o
```

## Result

Current smoke result:

- 1 source file
- 1 visited module
- 0 error diagnostics
- 122 warning diagnostics
- `ir.json`, `metrics.json`, and `fft_ifft_top.hpp` generated
- generated `fft_ifft_top.hpp` compiles as C++14 with SystemC headers
- generated header has no `TODO`, unsupported-statement marker, or raw real-literal fallback
- RTL(VCS) vs generated SystemC sampled per-cycle trace consistency passes for
  9 deterministic 64-point cases over 380 sampled cycles each, comparing
  `data_out_valid`, `data_out_re`, and `data_out_im`:
  `fft_mixed`, `fft_zero`, `fft_impulse`, `fft_alternating`,
  `fft_saturation_edges`, `fft_dense_lcg`, `ifft_mixed`, `ifft_impulse`,
  and `ifft_saturation_edges`.

Warning breakdown:

```text
83 slang_ArithOpMismatch
21 slang_SignConversion
15 slang_ConstantConversion
 2 slang_WidthTruncate
 1 event_scheduler_approximated
```

The remaining compiler output is only:

```text
#pragma once in main file
```

This warning is expected for the smoke because it deliberately compiles a generated header as the translation unit.

## Issue Found And Fixed

The RTL initializes twiddle LUT entries using real-valued constant expressions:

```verilog
assign lut[1] = 0.9951847267 * 256;
```

slang evaluates the implicit real-to-integral conversion and warns about the rounded value, for example `254.7672900352` to `16'd255`. Before this evaluation, `prism_v2sc` treated the real literal as a raw fallback and emitted:

```cpp
lut[1].write((/* raw: 0.9951847267 */ 0 * 256));
```

That compiled but made the FFT twiddle LUT functionally wrong. The lowerer now recognizes implicit real-to-integral conversions and preserves slang's converted integer constant, producing:

```cpp
lut[1].write(255);
```

The focused regression is `tests/test_expr_coverage.py::test_implicit_real_constant_conversion_uses_slang_value`.

The expanded IFFT cases exposed a second converter bug in dynamic indexed
part-select width inference. The RTL sign-extends 15-bit indexed slices into a
118-bit buffer:

```verilog
assign temp2 = {{103{data_in_im[j*IM_W+15]}}, data_in_im[j*IM_W+:15]};
```

Before the fix, the dynamic `+:15` select carried no width in IR, so concat
width inference treated it as 1 bit and generated a 104-bit expression. Negative
IFFT inputs then lost the upper sign-extension bits. The lowerer now records
slang's result width on part-select IR nodes, and codegen uses that width during
concat/repeat rendering. The focused regression is
`tests/test_expr_coverage.py::test_dynamic_indexed_part_select_width_in_concat`.

The final full regression exposed a third issue in parameter-dependent wide
ports. A width such as `RE_W*N` was emitted as `sc_int<RE_W*N>` even when the
instantiated width was 1024, while the testbench correctly used
`sc_bigint<1024>`. Generated headers now use compile-time integer aliases for
symbolic widths and select `sc_int/sc_uint` or `sc_bigint/sc_biguint` after
template specialization. Pure constant arithmetic widths are folded first.
The focused regression is
`tests/test_codegen.py::test_parameterized_wide_ports_select_big_integer_types`.

## Assessment

This is a useful real-design conversion/compile smoke and behavior gate for algorithm-style RTL. It verifies that the converter can handle this design's wide packed buffers, indexed part-select reads/writes, unpacked array LUT, signed arithmetic, and large sequential datapath shape well enough to emit compilable SystemC and match RTL on deterministic end-to-end FFT and IFFT traces.

It is not an exhaustive functional proof. The current trace uses 9 deterministic
vectors across FFT and IFFT modes; broader confidence would still need randomized
or application-derived OFDM streams and additional reset/backpressure scenarios.
The main remaining risk is semantic, not structural: many signed/unsigned
arithmetic warnings and width truncation warnings come from the source RTL and
should stay visible even though the tested workloads match.

## Recommended Next Actions

1. Keep `verification/cases/conversion/ofdm_fft_smoke.py` as a manual real-design smoke.
2. Keep `verification/cases/consistency/ofdm_fft_trace_consistency.py` as the current OFDM behavior gate.
3. Consider adding randomized or captured OFDM frames once a stable golden stimulus set exists.
4. Review the 122 warning diagnostics and decide which are expected source-style warnings versus cases that need stronger converter diagnostics or signed-context handling.
