#!/usr/bin/env python3
"""Trace consistency check for the external OFDM FFT/IFFT RTL.

The external RTL is referenced in-place and is never modified. This check
drives deterministic 64-sample FFT/IFFT vectors into the RTL and generated
SystemC model, then compares sampled per-cycle output traces.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


DEFAULT_RTL_ROOT = Path(
    "/home/MicroE/ai_proj/Simulation-and-FFT-Implementation-of-OFDM-Communication-System/hardware/src"
)
DEFAULT_OUT = Path("/tmp/prism_ofdm_fft_trace")
DEFAULT_SYSTEMC_INCLUDE = Path("/usr/local/systemc-2.3.4/include")
DEFAULT_SYSTEMC_LIB = Path("/usr/local/systemc-2.3.4/lib64")


@dataclass(frozen=True)
class TraceCase:
    name: str
    mode: int
    re_hex: str
    im_hex: str


def _run(cmd: list[str], *, cwd: Path) -> None:
    print("+ " + " ".join(cmd), flush=True)
    subprocess.run(cmd, cwd=cwd, check=True)


def _words_to_hex(words: list[int]) -> str:
    # Verilog part-selects use sample idx at bits idx*16 +: 16, so sample 0 is
    # the least-significant word. Hex text lists most-significant word first.
    return "".join(f"{word & 0xFFFF:04x}" for word in reversed(words))


def _mixed_vectors() -> tuple[str, str]:
    re_words: list[int] = []
    im_words: list[int] = []
    for idx in range(64):
        re = ((idx * 37 + 11) & 0x7FFF)
        im = ((idx * 19 + 5) & 0x7FFF)
        if idx % 5 == 0:
            re = ((-((idx * 23 + 17) & 0x7FFF)) & 0xFFFF)
        if idx % 7 == 0:
            im = ((-((idx * 29 + 9) & 0x7FFF)) & 0xFFFF)
        re_words.append(re & 0xFFFF)
        im_words.append(im & 0xFFFF)
    return _words_to_hex(re_words), _words_to_hex(im_words)


def _zero_vectors() -> tuple[str, str]:
    return _words_to_hex([0] * 64), _words_to_hex([0] * 64)


def _impulse_vectors() -> tuple[str, str]:
    re_words = [0] * 64
    im_words = [0] * 64
    re_words[0] = 0x1000
    im_words[1] = 0x0100
    return _words_to_hex(re_words), _words_to_hex(im_words)


def _alternating_vectors() -> tuple[str, str]:
    re_words = [0x7FFF if idx % 2 == 0 else 0x8001 for idx in range(64)]
    im_words = [0x4000 if idx % 3 == 0 else 0xC000 for idx in range(64)]
    return _words_to_hex(re_words), _words_to_hex(im_words)


def _saturation_edge_vectors() -> tuple[str, str]:
    pattern = [0x7FFF, 0x7FFE, 0x8000, 0x8001, 0x0001, 0xFFFF, 0x4000, 0xC000]
    re_words = [pattern[idx % len(pattern)] for idx in range(64)]
    im_words = [pattern[(idx * 3 + 1) % len(pattern)] for idx in range(64)]
    return _words_to_hex(re_words), _words_to_hex(im_words)


def _dense_lcg_vectors(seed: int) -> tuple[str, str]:
    state = seed & 0xFFFFFFFF
    re_words: list[int] = []
    im_words: list[int] = []
    for _ in range(64):
        state = (1664525 * state + 1013904223) & 0xFFFFFFFF
        re_words.append((state >> 8) & 0xFFFF)
        state = (1664525 * state + 1013904223) & 0xFFFFFFFF
        im_words.append((state >> 8) & 0xFFFF)
    return _words_to_hex(re_words), _words_to_hex(im_words)


def _all_cases() -> tuple[TraceCase, ...]:
    mixed_re, mixed_im = _mixed_vectors()
    zero_re, zero_im = _zero_vectors()
    impulse_re, impulse_im = _impulse_vectors()
    alternating_re, alternating_im = _alternating_vectors()
    saturation_re, saturation_im = _saturation_edge_vectors()
    dense_re, dense_im = _dense_lcg_vectors(0x5EED1234)
    return (
        TraceCase("fft_mixed", 0, mixed_re, mixed_im),
        TraceCase("fft_zero", 0, zero_re, zero_im),
        TraceCase("fft_impulse", 0, impulse_re, impulse_im),
        TraceCase("fft_alternating", 0, alternating_re, alternating_im),
        TraceCase("fft_saturation_edges", 0, saturation_re, saturation_im),
        TraceCase("fft_dense_lcg", 0, dense_re, dense_im),
        TraceCase("ifft_mixed", 1, mixed_re, mixed_im),
        TraceCase("ifft_impulse", 1, impulse_re, impulse_im),
        TraceCase("ifft_saturation_edges", 1, saturation_re, saturation_im),
    )


def _rtl_tb(case: TraceCase, cycles: int) -> str:
    return f"""`timescale 1ns/1ps
module tb;
  reg clk = 1'b0;
  reg rst_n = 1'b0;
  reg mode = 1'b{case.mode};
  reg signed [1023:0] data_in_re = 1024'h0;
  reg signed [1023:0] data_in_im = 1024'h0;
  reg data_in_valid = 1'b0;
  wire signed [1023:0] data_out_re;
  wire signed [1023:0] data_out_im;
  wire data_out_valid;
  integer out;
  integer cycle;

  localparam [1023:0] RE_VEC = 1024'h{case.re_hex};
  localparam [1023:0] IM_VEC = 1024'h{case.im_hex};

  fft_ifft_top dut(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .data_in_re(data_in_re),
    .data_in_im(data_in_im),
    .data_in_valid(data_in_valid),
    .data_out_re(data_out_re),
    .data_out_im(data_out_im),
    .data_out_valid(data_out_valid)
  );

  task tick_sample;
    begin
      #1 clk = 1'b0;
      #1 clk = 1'b1;
      #1;
      $fdisplay(out, "%0d valid=%0d re=%0256h im=%0256h",
                cycle, data_out_valid, data_out_re, data_out_im);
      cycle = cycle + 1;
      #1 clk = 1'b0;
    end
  endtask

  initial begin
    out = $fopen("rtl_trace.txt", "w");
    cycle = 0;
    rst_n = 1'b0;
    mode = 1'b{case.mode};
    data_in_valid = 1'b0;
    data_in_re = 1024'h0;
    data_in_im = 1024'h0;
    repeat (3) tick_sample();

    rst_n = 1'b1;
    data_in_re = RE_VEC;
    data_in_im = IM_VEC;
    data_in_valid = 1'b1;
    repeat (64) tick_sample();

    data_in_valid = 1'b0;
    repeat ({cycles - 67}) tick_sample();

    $fclose(out);
    $finish;
  end
endmodule
"""


def _sc_tb(case: TraceCase, cycles: int) -> str:
    return f"""#include <algorithm>
#include <cctype>
#include <fstream>
#include <iomanip>
#include <string>
#include <systemc>
#include "fft_ifft_top.hpp"

using namespace sc_core;
using namespace sc_dt;

static std::string hex1024(const sc_bigint<1024>& value) {{
  sc_biguint<1024> bits = value;
  std::string text = bits.to_string(SC_HEX, false);
  if (text.rfind("0x", 0) == 0 || text.rfind("0X", 0) == 0) {{
    text = text.substr(2);
  }}
  std::transform(text.begin(), text.end(), text.begin(), [](unsigned char c) {{
    return static_cast<char>(std::tolower(c));
  }});
  if (text.size() < 256) {{
    text.insert(text.begin(), 256 - text.size(), '0');
  }} else if (text.size() > 256) {{
    text = text.substr(text.size() - 256);
  }}
  return text;
}}

int sc_main(int, char**) {{
  sc_signal<bool> clk;
  sc_signal<bool> rst_n;
  sc_signal<bool> mode;
  sc_signal<sc_bigint<1024>> data_in_re;
  sc_signal<sc_bigint<1024>> data_in_im;
  sc_signal<bool> data_in_valid;
  sc_signal<sc_bigint<1024>> data_out_re;
  sc_signal<sc_bigint<1024>> data_out_im;
  sc_signal<bool> data_out_valid;

  fft_ifft_top<> dut("dut");
  dut.clk(clk);
  dut.rst_n(rst_n);
  dut.mode(mode);
  dut.data_in_re(data_in_re);
  dut.data_in_im(data_in_im);
  dut.data_in_valid(data_in_valid);
  dut.data_out_re(data_out_re);
  dut.data_out_im(data_out_im);
  dut.data_out_valid(data_out_valid);

  sc_bigint<1024> re_vec("0x{case.re_hex}");
  sc_bigint<1024> im_vec("0x{case.im_hex}");
  std::ofstream out("sc_trace.txt");
  int cycle = 0;

  auto tick_sample = [&]() {{
    clk.write(false);
    sc_start(1, SC_NS);
    clk.write(true);
    sc_start(1, SC_NS);
    out << cycle
        << " valid=" << (data_out_valid.read() ? 1 : 0)
        << " re=" << hex1024(data_out_re.read())
        << " im=" << hex1024(data_out_im.read()) << "\\n";
    ++cycle;
    clk.write(false);
    sc_start(1, SC_NS);
  }};

  rst_n.write(false);
  mode.write({str(bool(case.mode)).lower()});
  data_in_valid.write(false);
  data_in_re.write(0);
  data_in_im.write(0);
  for (int i = 0; i < 3; ++i) tick_sample();

  rst_n.write(true);
  data_in_re.write(re_vec);
  data_in_im.write(im_vec);
  data_in_valid.write(true);
  for (int i = 0; i < 64; ++i) tick_sample();

  data_in_valid.write(false);
  for (int i = 0; i < {cycles - 67}; ++i) tick_sample();

  return 0;
}}
"""


def _compile_rtl_iverilog(source: Path, tb: Path, out_dir: Path) -> None:
    _run(["iverilog", "-g2012", "-o", "rtl_simv", str(source), str(tb)], cwd=out_dir)
    _run(["vvp", "rtl_simv"], cwd=out_dir)


def _compile_rtl_vcs(source: Path, tb: Path, out_dir: Path, vcs: str) -> None:
    _run(
        [
            vcs,
            "-full64",
            "-sverilog",
            "-timescale=1ns/1ps",
            "-o",
            "rtl_simv",
            str(source),
            str(tb),
        ],
        cwd=out_dir,
    )
    _run(["./rtl_simv"], cwd=out_dir)


def _compare(rtl_trace: Path, sc_trace: Path, diff_log: Path) -> int:
    rtl_lines = rtl_trace.read_text(encoding="utf-8").splitlines()
    sc_lines = sc_trace.read_text(encoding="utf-8").splitlines()
    max_len = max(len(rtl_lines), len(sc_lines))
    diffs: list[str] = []
    for index in range(max_len):
        rtl = rtl_lines[index] if index < len(rtl_lines) else "<missing>"
        sc = sc_lines[index] if index < len(sc_lines) else "<missing>"
        if rtl != sc:
            diffs.append(f"cycle_index={index}\nrtl: {rtl}\n sc: {sc}\n")
            if len(diffs) >= 20:
                break
    if diffs:
        diff_log.write_text("\n".join(diffs), encoding="utf-8")
        return 1
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rtl-root", type=Path, default=DEFAULT_RTL_ROOT)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--systemc-include", type=Path, default=DEFAULT_SYSTEMC_INCLUDE)
    parser.add_argument("--systemc-lib", type=Path, default=DEFAULT_SYSTEMC_LIB)
    parser.add_argument("--cxx", default="g++")
    parser.add_argument("--rtl-sim", choices=("iverilog", "vcs"), default="vcs")
    parser.add_argument("--vcs", default="vcs")
    parser.add_argument("--cycles", type=int, default=380)
    parser.add_argument(
        "--cases",
        nargs="*",
        default=None,
        help="Optional subset of trace case names to run.",
    )
    parser.add_argument("--keep-out", action="store_true")
    args = parser.parse_args(argv)

    if args.cycles <= 67:
        print("--cycles must be greater than 67", file=sys.stderr)
        return 2

    repo_root = Path(__file__).resolve().parents[3]
    rtl_root = args.rtl_root.expanduser().resolve()
    out_dir = args.out.expanduser().resolve()
    source = rtl_root / "fft_ifft_top.v"
    if not source.exists():
        print(f"missing source: {source}", file=sys.stderr)
        return 2
    if not args.systemc_include.exists():
        print(f"missing SystemC include dir: {args.systemc_include}", file=sys.stderr)
        return 2
    if not args.systemc_lib.exists():
        print(f"missing SystemC lib dir: {args.systemc_lib}", file=sys.stderr)
        return 2

    if out_dir.exists() and not args.keep_out:
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    _run(
        [
            sys.executable,
            "-m",
            "prism_v2sc",
            "--top",
            "fft_ifft_top",
            "--out",
            str(out_dir / "systemc"),
            "--metrics",
            "--fail-on-diagnostics",
            str(source),
        ],
        cwd=repo_root,
    )

    cases_by_name = {case.name: case for case in _all_cases()}
    if args.cases is None:
        cases = tuple(cases_by_name.values())
    else:
        missing = [name for name in args.cases if name not in cases_by_name]
        if missing:
            print(f"unknown case(s): {', '.join(missing)}", file=sys.stderr)
            print("available cases: " + ", ".join(cases_by_name), file=sys.stderr)
            return 2
        cases = tuple(cases_by_name[name] for name in args.cases)

    failures: list[Path] = []
    for case in cases:
        print(f"== OFDM trace case: {case.name} mode={case.mode} ==", flush=True)
        case_dir = out_dir / case.name
        if case_dir.exists() and not args.keep_out:
            shutil.rmtree(case_dir)
        case_dir.mkdir(parents=True, exist_ok=True)
        rtl_tb = case_dir / "tb_rtl.v"
        sc_tb = case_dir / "tb_sc.cpp"
        rtl_tb.write_text(_rtl_tb(case, args.cycles), encoding="utf-8")
        sc_tb.write_text(_sc_tb(case, args.cycles), encoding="utf-8")

        if args.rtl_sim == "iverilog":
            _compile_rtl_iverilog(source, rtl_tb, case_dir)
        else:
            _compile_rtl_vcs(source, rtl_tb, case_dir, args.vcs)

        sc_exe = case_dir / "sc_sim"
        _run(
            [
                args.cxx,
                "-std=c++14",
                f"-I{args.systemc_include}",
                f"-I{out_dir / 'systemc'}",
                str(sc_tb),
                f"-L{args.systemc_lib}",
                f"-Wl,-rpath,{args.systemc_lib}",
                "-lsystemc",
                "-pthread",
                "-o",
                str(sc_exe),
            ],
            cwd=repo_root,
        )
        _run([str(sc_exe)], cwd=case_dir)

        diff_log = case_dir / "diff.log"
        result = _compare(case_dir / "rtl_trace.txt", case_dir / "sc_trace.txt", diff_log)
        if result:
            failures.append(diff_log)
            print(f"OFDM FFT/IFFT trace mismatch in {case.name}: {diff_log}", file=sys.stderr)
        else:
            print(f"OFDM FFT/IFFT trace case passed: {case.name}")

    if failures:
        print("OFDM FFT/IFFT trace consistency failed:", file=sys.stderr)
        for path in failures:
            print(f"  {path}", file=sys.stderr)
        return 1
    print(f"OFDM FFT/IFFT trace consistency passed: {len(cases)} case(s), {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
