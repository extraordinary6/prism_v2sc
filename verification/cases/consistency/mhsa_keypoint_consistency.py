#!/usr/bin/env python3
"""Approximate keypoint consistency checks for external MHSA submodules.

The checks compare RTL and generated SystemC only at a small set of
meaningful sample points. They intentionally avoid full per-cycle trace
matching because the goal here is a pragmatic real-design behavior gate.
The external MHSA RTL is referenced in-place and is never modified.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "src"))
from prism_v2sc.systemc_build import SystemCBuildError, SystemCBuildOptions, build_systemc


DEFAULT_MHSA_ROOT = Path("/home/MicroE/MHSA")
DEFAULT_OUT = Path("/tmp/prism_mhsa_keypoints")
DEFAULT_SYSTEMC_INCLUDE = Path("/usr/local/systemc-2.3.4/include")
DEFAULT_SYSTEMC_LIB = Path("/usr/local/systemc-2.3.4/lib64")


@dataclass(frozen=True)
class KeypointCase:
    name: str
    top: str
    source_rels: tuple[str, ...]
    rtl_tb: str
    sc_tb: str


SCALE_CORE_RTL_TB = r"""
`timescale 1ns/1ps
module tb;
  reg clk = 1'b0;
  reg rst_n = 1'b0;
  reg [63:0] input_bar = 64'h0;
  reg bar_valid = 1'b0;
  wire [63:0] output_bar;
  wire output_valid;
  integer out;

  scale_core dut(
    .clk(clk),
    .rst_n(rst_n),
    .input_bar(input_bar),
    .bar_valid(bar_valid),
    .output_bar(output_bar),
    .output_valid(output_valid)
  );

  task tick;
    begin
      #1 clk = 1'b0;
      #1 clk = 1'b1;
      #1 clk = 1'b0;
    end
  endtask

  task sample;
    input [127:0] label;
    begin
      $fdisplay(out, "%0s valid=%0d bar=%016h", label, output_valid, output_bar);
    end
  endtask

  task drive_valid;
    input [127:0] label;
    input [63:0] value;
    begin
      input_bar = value;
      bar_valid = 1'b1;
      tick();
      sample(label);
    end
  endtask

  initial begin
    out = $fopen("rtl_keypoints.txt", "w");
    rst_n = 1'b0;
    bar_valid = 1'b0;
    input_bar = 64'h0;
    tick();
    sample("reset");

    rst_n = 1'b1;
    drive_valid("sample_a", 64'h4030201008070201);

    bar_valid = 1'b0;
    input_bar = 64'h0;
    tick();
    sample("idle");

    drive_valid("sample_b", 64'hff804422110f0703);
    drive_valid("sample_c", 64'h0001020304050607);
    drive_valid("sample_d", 64'h7f80818283848586);
    drive_valid("sample_e", 64'hffffffff00000000);

    $fclose(out);
    $finish;
  end
endmodule
"""


SCALE_CORE_SC_TB = r"""
#include <fstream>
#include <iomanip>
#include <systemc>
#include "scale_core.hpp"

using namespace sc_core;
using namespace sc_dt;

int sc_main(int, char**) {
  sc_signal<bool> clk;
  sc_signal<bool> rst_n;
  sc_signal<sc_uint<64>> input_bar;
  sc_signal<bool> bar_valid;
  sc_signal<sc_uint<64>> output_bar;
  sc_signal<bool> output_valid;
  scale_core dut("dut");

  dut.clk(clk);
  dut.rst_n(rst_n);
  dut.input_bar(input_bar);
  dut.bar_valid(bar_valid);
  dut.output_bar(output_bar);
  dut.output_valid(output_valid);

  auto tick = [&]() {
    clk.write(false);
    sc_start(1, SC_NS);
    clk.write(true);
    sc_start(1, SC_NS);
    clk.write(false);
    sc_start(1, SC_NS);
  };
  auto sample = [&](std::ofstream& out, const char* label) {
    out << label << " valid=" << (output_valid.read() ? 1 : 0)
        << " bar=" << std::hex << std::setw(16) << std::setfill('0')
        << output_bar.read().to_uint64() << std::dec << "\n";
  };
  auto drive_valid = [&](std::ofstream& out, const char* label, unsigned long long value) {
    input_bar.write(value);
    bar_valid.write(true);
    tick();
    sample(out, label);
  };

  std::ofstream out("sc_keypoints.txt");
  rst_n.write(false);
  bar_valid.write(false);
  input_bar.write(0);
  tick();
  sample(out, "reset");

  rst_n.write(true);
  drive_valid(out, "sample_a", 0x4030201008070201ULL);

  bar_valid.write(false);
  input_bar.write(0);
  tick();
  sample(out, "idle");

  drive_valid(out, "sample_b", 0xff804422110f0703ULL);
  drive_valid(out, "sample_c", 0x0001020304050607ULL);
  drive_valid(out, "sample_d", 0x7f80818283848586ULL);
  drive_valid(out, "sample_e", 0xffffffff00000000ULL);

  return 0;
}
"""


PE_RTL_TB = r"""
`timescale 1ns/1ps
module tb;
  reg clk = 1'b0;
  reg rst_n = 1'b0;
  reg flush = 1'b0;
  reg signed [7:0] row_i = 8'sd0;
  reg signed [7:0] col_i = 8'sd0;
  reg din_valid = 1'b0;
  wire [7:0] row_o;
  wire [7:0] col_o;
  wire dout_valid;
  wire signed [31:0] res;
  integer out;

  pe dut(
    .clk(clk),
    .rst_n(rst_n),
    .flush(flush),
    .row_i(row_i),
    .col_i(col_i),
    .din_valid(din_valid),
    .row_o(row_o),
    .col_o(col_o),
    .dout_valid(dout_valid),
    .res(res)
  );

  task tick;
    begin
      #1 clk = 1'b0;
      #1 clk = 1'b1;
      #1 clk = 1'b0;
    end
  endtask

  task sample;
    input [127:0] label;
    begin
      $fdisplay(out, "%0s row=%02h col=%02h valid=%0d res=%0d", label, row_o, col_o, dout_valid, res);
    end
  endtask

  initial begin
    out = $fopen("rtl_keypoints.txt", "w");
    rst_n = 1'b0;
    flush = 1'b0;
    din_valid = 1'b0;
    tick();
    sample("reset");

    rst_n = 1'b1;
    row_i = 8'sd3;
    col_i = -8'sd4;
    din_valid = 1'b1;
    tick();
    sample("mul_neg");

    row_i = -8'sd2;
    col_i = -8'sd5;
    din_valid = 1'b1;
    tick();
    sample("accum_pos");

    row_i = 8'sd10;
    col_i = 8'sd11;
    din_valid = 1'b0;
    tick();
    sample("hold");

    flush = 1'b1;
    tick();
    sample("flush");

    flush = 1'b0;
    row_i = 8'sd127;
    col_i = 8'sd2;
    din_valid = 1'b1;
    tick();
    sample("sat_pos");

    row_i = -8'sd128;
    col_i = 8'sd1;
    tick();
    sample("accum_min");

    din_valid = 1'b0;
    row_i = -8'sd7;
    col_i = 8'sd9;
    tick();
    sample("hold_extreme");

    rst_n = 1'b0;
    tick();
    sample("reset_again");

    $fclose(out);
    $finish;
  end
endmodule
"""


PE_SC_TB = r"""
#include <fstream>
#include <iomanip>
#include <systemc>
#include "pe.hpp"

using namespace sc_core;
using namespace sc_dt;

int sc_main(int, char**) {
  sc_signal<bool> clk;
  sc_signal<bool> rst_n;
  sc_signal<bool> flush;
  sc_signal<sc_int<8>> row_i;
  sc_signal<sc_int<8>> col_i;
  sc_signal<bool> din_valid;
  sc_signal<sc_uint<8>> row_o;
  sc_signal<sc_uint<8>> col_o;
  sc_signal<bool> dout_valid;
  sc_signal<sc_int<32>> res;
  pe dut("dut");

  dut.clk(clk);
  dut.rst_n(rst_n);
  dut.flush(flush);
  dut.row_i(row_i);
  dut.col_i(col_i);
  dut.din_valid(din_valid);
  dut.row_o(row_o);
  dut.col_o(col_o);
  dut.dout_valid(dout_valid);
  dut.res(res);

  auto tick = [&]() {
    clk.write(false);
    sc_start(1, SC_NS);
    clk.write(true);
    sc_start(1, SC_NS);
    clk.write(false);
    sc_start(1, SC_NS);
  };
  auto sample = [&](std::ofstream& out, const char* label) {
    out << label << " row=" << std::hex << std::setw(2) << std::setfill('0')
        << row_o.read().to_uint()
        << " col=" << std::setw(2) << col_o.read().to_uint()
        << std::dec << " valid=" << (dout_valid.read() ? 1 : 0)
        << " res=" << res.read().to_int() << "\n";
  };

  std::ofstream out("sc_keypoints.txt");
  rst_n.write(false);
  flush.write(false);
  din_valid.write(false);
  row_i.write(0);
  col_i.write(0);
  tick();
  sample(out, "reset");

  rst_n.write(true);
  row_i.write(3);
  col_i.write(-4);
  din_valid.write(true);
  tick();
  sample(out, "mul_neg");

  row_i.write(-2);
  col_i.write(-5);
  din_valid.write(true);
  tick();
  sample(out, "accum_pos");

  row_i.write(10);
  col_i.write(11);
  din_valid.write(false);
  tick();
  sample(out, "hold");

  flush.write(true);
  tick();
  sample(out, "flush");

  flush.write(false);
  row_i.write(127);
  col_i.write(2);
  din_valid.write(true);
  tick();
  sample(out, "sat_pos");

  row_i.write(-128);
  col_i.write(1);
  tick();
  sample(out, "accum_min");

  din_valid.write(false);
  row_i.write(-7);
  col_i.write(9);
  tick();
  sample(out, "hold_extreme");

  rst_n.write(false);
  tick();
  sample(out, "reset_again");

  return 0;
}
"""


ICB_MHSA_RTL_TB = r"""
`timescale 1ns/1ps
module tb;
  reg clk = 1'b0;
  reg rst_n = 1'b0;
  reg icb_cmd_valid = 1'b0;
  wire icb_cmd_ready;
  reg icb_cmd_read = 1'b0;
  reg [31:0] icb_cmd_addr = 32'h0;
  reg [31:0] icb_cmd_wdata = 32'h0;
  reg [3:0] icb_cmd_wmask = 4'hf;
  wire icb_rsp_valid;
  reg icb_rsp_ready = 1'b1;
  wire [31:0] icb_rsp_rdata;
  wire icb_rsp_err;
  integer out;
  reg [31:0] rd;

  icb_mhsa dut(
    .clk(clk),
    .rst_n(rst_n),
    .icb_cmd_valid(icb_cmd_valid),
    .icb_cmd_ready(icb_cmd_ready),
    .icb_cmd_read(icb_cmd_read),
    .icb_cmd_addr(icb_cmd_addr),
    .icb_cmd_wdata(icb_cmd_wdata),
    .icb_cmd_wmask(icb_cmd_wmask),
    .icb_rsp_valid(icb_rsp_valid),
    .icb_rsp_ready(icb_rsp_ready),
    .icb_rsp_rdata(icb_rsp_rdata),
    .icb_rsp_err(icb_rsp_err)
  );

  task tick;
    begin
      #1 clk = 1'b0;
      #1 clk = 1'b1;
      #1 clk = 1'b0;
    end
  endtask

  task issue;
    input do_read;
    input [31:0] addr;
    input [31:0] data;
    output [31:0] rdata;
    begin
      icb_cmd_valid = 1'b1;
      icb_cmd_read = do_read;
      icb_cmd_addr = addr;
      icb_cmd_wdata = data;
      icb_cmd_wmask = 4'hf;
      tick();
      tick();
      rdata = icb_rsp_rdata;
      icb_cmd_valid = 1'b0;
      icb_cmd_read = 1'b0;
      tick();
    end
  endtask

  task sample;
    input [127:0] label;
    input [31:0] rdata;
    begin
      $fdisplay(out, "%0s ready=%0d rsp=%0d err=%0d rdata=%08h", label, icb_cmd_ready, icb_rsp_valid, icb_rsp_err, rdata);
    end
  endtask

  initial begin
    out = $fopen("rtl_keypoints.txt", "w");
    rst_n = 1'b0;
    tick();
    sample("reset", 32'h0);

    rst_n = 1'b1;
    tick();

    issue(1'b0, 32'h00070008, 32'h12345678, rd);
    issue(1'b1, 32'h00070008, 32'h0, rd);
    sample("input_base", rd);

    issue(1'b0, 32'h0007000c, 32'hdeadbeef, rd);
    issue(1'b1, 32'h0007000c, 32'h0, rd);
    sample("output_base", rd);

    issue(1'b1, 32'h00070010, 32'h0, rd);
    sample("default_read", rd);

    issue(1'b0, 32'h00050000, 32'h11223344, rd);
    issue(1'b0, 32'h00050004, 32'h55667788, rd);
    tick();
    issue(1'b1, 32'h00050000, 32'h0, rd);
    sample("usram_hi", rd);
    issue(1'b1, 32'h00050004, 32'h0, rd);
    sample("usram_lo", rd);

    issue(1'b0, 32'h00051000, 32'haabbccdd, rd);
    issue(1'b0, 32'h00051004, 32'h01020304, rd);
    tick();
    issue(1'b1, 32'h00051000, 32'h0, rd);
    sample("usram_bar1_hi", rd);
    issue(1'b1, 32'h00051004, 32'h0, rd);
    sample("usram_bar1_lo", rd);

    $fclose(out);
    $finish;
  end
endmodule
"""


ICB_MHSA_SC_TB = r"""
#include <fstream>
#include <iomanip>
#include <systemc>
#include "icb_mhsa.hpp"

using namespace sc_core;
using namespace sc_dt;

int sc_main(int, char**) {
  sc_signal<bool> clk;
  sc_signal<bool> rst_n;
  sc_signal<bool> icb_cmd_valid;
  sc_signal<bool> icb_cmd_ready;
  sc_signal<bool> icb_cmd_read;
  sc_signal<sc_uint<32>> icb_cmd_addr;
  sc_signal<sc_uint<32>> icb_cmd_wdata;
  sc_signal<sc_uint<4>> icb_cmd_wmask;
  sc_signal<bool> icb_rsp_valid;
  sc_signal<bool> icb_rsp_ready;
  sc_signal<sc_uint<32>> icb_rsp_rdata;
  sc_signal<bool> icb_rsp_err;
  icb_mhsa dut("dut");

  dut.clk(clk);
  dut.rst_n(rst_n);
  dut.icb_cmd_valid(icb_cmd_valid);
  dut.icb_cmd_ready(icb_cmd_ready);
  dut.icb_cmd_read(icb_cmd_read);
  dut.icb_cmd_addr(icb_cmd_addr);
  dut.icb_cmd_wdata(icb_cmd_wdata);
  dut.icb_cmd_wmask(icb_cmd_wmask);
  dut.icb_rsp_valid(icb_rsp_valid);
  dut.icb_rsp_ready(icb_rsp_ready);
  dut.icb_rsp_rdata(icb_rsp_rdata);
  dut.icb_rsp_err(icb_rsp_err);

  auto tick = [&]() {
    clk.write(false);
    sc_start(1, SC_NS);
    clk.write(true);
    sc_start(1, SC_NS);
    clk.write(false);
    sc_start(1, SC_NS);
  };
  auto issue = [&](bool do_read, unsigned addr, unsigned data) {
    icb_cmd_valid.write(true);
    icb_cmd_read.write(do_read);
    icb_cmd_addr.write(addr);
    icb_cmd_wdata.write(data);
    icb_cmd_wmask.write(0xf);
    tick();
    tick();
    unsigned rdata = static_cast<unsigned>(icb_rsp_rdata.read().to_uint64());
    icb_cmd_valid.write(false);
    icb_cmd_read.write(false);
    tick();
    return rdata;
  };
  auto sample = [&](std::ofstream& out, const char* label, unsigned rdata) {
    out << label
        << " ready=" << (icb_cmd_ready.read() ? 1 : 0)
        << " rsp=" << (icb_rsp_valid.read() ? 1 : 0)
        << " err=" << (icb_rsp_err.read() ? 1 : 0)
        << " rdata=" << std::hex << std::setw(8) << std::setfill('0') << rdata
        << std::dec << "\n";
  };

  std::ofstream out("sc_keypoints.txt");
  icb_cmd_valid.write(false);
  icb_cmd_read.write(false);
  icb_cmd_addr.write(0);
  icb_cmd_wdata.write(0);
  icb_cmd_wmask.write(0xf);
  icb_rsp_ready.write(true);
  rst_n.write(false);
  tick();
  sample(out, "reset", 0);

  rst_n.write(true);
  tick();

  unsigned rd = issue(false, 0x00070008, 0x12345678);
  rd = issue(true, 0x00070008, 0);
  sample(out, "input_base", rd);

  rd = issue(false, 0x0007000c, 0xdeadbeef);
  rd = issue(true, 0x0007000c, 0);
  sample(out, "output_base", rd);

  rd = issue(true, 0x00070010, 0);
  sample(out, "default_read", rd);

  rd = issue(false, 0x00050000, 0x11223344);
  rd = issue(false, 0x00050004, 0x55667788);
  tick();
  rd = issue(true, 0x00050000, 0);
  sample(out, "usram_hi", rd);
  rd = issue(true, 0x00050004, 0);
  sample(out, "usram_lo", rd);

  rd = issue(false, 0x00051000, 0xaabbccdd);
  rd = issue(false, 0x00051004, 0x01020304);
  tick();
  rd = issue(true, 0x00051000, 0);
  sample(out, "usram_bar1_hi", rd);
  rd = issue(true, 0x00051004, 0);
  sample(out, "usram_bar1_lo", rd);

  return 0;
}
"""


CASES: dict[str, KeypointCase] = {
    "scale_core": KeypointCase(
        name="scale_core",
        top="scale_core",
        source_rels=("rtl_design/scale_core.sv",),
        rtl_tb=SCALE_CORE_RTL_TB,
        sc_tb=SCALE_CORE_SC_TB,
    ),
    "pe": KeypointCase(
        name="pe",
        top="pe",
        source_rels=("rtl_design/mm_pe.sv",),
        rtl_tb=PE_RTL_TB,
        sc_tb=PE_SC_TB,
    ),
    "icb_mhsa": KeypointCase(
        name="icb_mhsa",
        top="icb_mhsa",
        source_rels=(
            "icb_mhsa/icb_mhsa.sv",
            "icb_mhsa/imu.sv",
            "rtl_design/attmm.sv",
            "rtl_design/connect.sv",
            "rtl_design/linear.sv",
            "rtl_design/mem.sv",
            "rtl_design/mem_wk.sv",
            "rtl_design/mem_wq.sv",
            "rtl_design/mem_wv.sv",
            "rtl_design/mem_x.sv",
            "rtl_design/mhsa_acc_top.sv",
            "rtl_design/mhsa_acc_wrapper.sv",
            "rtl_design/mm_pe.sv",
            "rtl_design/mm_systolic.sv",
            "rtl_design/qkmm.sv",
            "rtl_design/scale_core.sv",
            "rtl_design/softmax.sv",
        ),
        rtl_tb=ICB_MHSA_RTL_TB,
        sc_tb=ICB_MHSA_SC_TB,
    ),
}


def _run(cmd: list[str], *, cwd: Path, log: Path | None = None, env: dict[str, str] | None = None) -> None:
    print("+ " + " ".join(str(part) for part in cmd), flush=True)
    if log is None:
        subprocess.run(cmd, cwd=cwd, env=env, check=True)
        return
    with log.open("w", encoding="utf-8") as handle:
        handle.write("+ " + " ".join(str(part) for part in cmd) + "\n")
        handle.flush()
        subprocess.run(cmd, cwd=cwd, env=env, stdout=handle, stderr=subprocess.STDOUT, check=True)


def _write_if_changed(path: Path, content: str) -> None:
    try:
        if path.read_text(encoding="utf-8") == content:
            return
    except (FileNotFoundError, OSError):
        pass
    path.write_text(content, encoding="utf-8")


def _convert(
    case: KeypointCase,
    mhsa_root: Path,
    out_dir: Path,
    repo_root: Path,
    *,
    compile_friendly: bool = False,
    incremental: bool = False,
) -> Path:
    sc_out = out_dir / "systemc"
    sources = [mhsa_root / source_rel for source_rel in case.source_rels]
    convert_cmd = [
        sys.executable,
        "-m",
        "prism_v2sc",
        "--top",
        case.top,
        "--out",
        str(sc_out),
        "--fail-on-diagnostics",
    ]
    if compile_friendly:
        convert_cmd.append("--compile-friendly")
    if incremental:
        convert_cmd.append("--incremental-codegen")
    convert_cmd.extend(str(source) for source in sources)
    _run(
        convert_cmd,
        cwd=repo_root,
        log=out_dir / "convert.log",
    )
    matches = sorted(sc_out.rglob(f"{case.top}.hpp"))
    if not matches:
        raise RuntimeError(f"generated header not found for {case.name}")
    return matches[0]


def _run_rtl(case: KeypointCase, mhsa_root: Path, out_dir: Path, rtl_sim: str) -> Path:
    rtl_tb = out_dir / "tb_rtl.sv"
    _write_if_changed(rtl_tb, case.rtl_tb)
    sources = [mhsa_root / source_rel for source_rel in case.source_rels]
    if rtl_sim != "vcs":
        raise RuntimeError(f"unsupported RTL simulator for this script: {rtl_sim}")
    vcs = os.environ.get("VCS", "vcs")
    vcs_flags = [flag for flag in os.environ.get("VCS_FLAGS", "-full64 -sverilog -timescale=1ns/1ps").split() if flag]
    vcs_env = os.environ.copy()
    vcs_env.setdefault("VCS_TARGET_ARCH", "linux64")
    exe = out_dir / "rtl_simv"
    _run(
        [
            vcs,
            *vcs_flags,
            "-o",
            exe.name,
            str(rtl_tb.resolve()),
            *[str(source.resolve()) for source in sources],
        ],
        cwd=out_dir,
        log=out_dir / "vcs.log",
        env=vcs_env,
    )
    _run([str(exe), *os.environ.get("VCS_RUN_FLAGS", "").split()], cwd=out_dir, log=out_dir / "rtl_run.log", env=vcs_env)
    return out_dir / "rtl_keypoints.txt"


def _run_systemc(
    case: KeypointCase,
    out_dir: Path,
    header: Path,
    *,
    cxx: str,
    systemc_include: Path,
    systemc_lib: Path,
    build_mode: str = "legacy",
    build_jobs: int = 1,
    build_pch: bool = False,
    build_incremental: bool = False,
) -> Path:
    sc_tb = out_dir / "tb_systemc.cpp"
    _write_if_changed(sc_tb, case.sc_tb)
    exe = out_dir / "sc_tb"
    generated_implementations = sorted(header.parents[1].rglob("*__impl_*.cpp"))
    optimized = (
        build_mode == "optimized"
        or build_jobs > 1
        or build_pch
        or build_incremental
    )
    if optimized:
        try:
            result = build_systemc(
                (sc_tb, *generated_implementations),
                exe,
                out_dir / "systemc_build",
                options=SystemCBuildOptions(
                    cxx=cxx,
                    standard="c++14",
                    cxx_flags=(f"-I{systemc_include}",),
                    ld_flags=(f"-L{systemc_lib}", f"-Wl,-rpath,{systemc_lib}"),
                    libs=("-lsystemc", "-pthread"),
                    include_dirs=(header.parents[1], header.parent),
                    pch_headers=(header,) if len(generated_implementations) >= 16 else (),
                    jobs=max(1, build_jobs),
                    use_pch=build_pch or build_mode == "optimized",
                    incremental=build_incremental or build_mode == "optimized",
                ),
                log_path=out_dir / "systemc_build.log",
            )
            print(
                f"{case.name}: SystemC build elapsed={result.elapsed_seconds:.3f}s "
                f"compiled={result.compiled_sources} reused={result.reused_objects} "
                f"jobs={result.jobs} pch={result.pch_used} "
                f"link_reused={result.link_reused}"
            )
        except SystemCBuildError as exc:
            raise RuntimeError(str(exc)) from exc
    else:
        _run(
            [
                cxx,
                "-std=c++14",
                f"-I{systemc_include}",
                f"-I{header.parents[1]}",
                f"-I{header.parent}",
                str(sc_tb),
                *[str(path) for path in generated_implementations],
                f"-L{systemc_lib}",
                f"-Wl,-rpath,{systemc_lib}",
                "-lsystemc",
                "-pthread",
                "-o",
                str(exe),
            ],
            cwd=out_dir,
            log=out_dir / "systemc_build.log",
        )
    _run([str(exe)], cwd=out_dir, log=out_dir / "systemc_run.log")
    return out_dir / "sc_keypoints.txt"


def _compare(case: KeypointCase, rtl_trace: Path, sc_trace: Path, out_dir: Path) -> None:
    rtl = rtl_trace.read_text(encoding="utf-8").splitlines()
    sc = sc_trace.read_text(encoding="utf-8").splitlines()
    if rtl == sc:
        print(f"{case.name}: keypoint consistency passed ({len(rtl)} samples)")
        return
    diff = out_dir / "keypoint.diff"
    with diff.open("w", encoding="utf-8") as handle:
        handle.write("RTL keypoints:\n")
        handle.write("\n".join(rtl) + "\n\n")
        handle.write("SystemC keypoints:\n")
        handle.write("\n".join(sc) + "\n")
    raise RuntimeError(f"{case.name}: keypoint mismatch; see {diff}")


def _run_case(
    case: KeypointCase,
    *,
    mhsa_root: Path,
    out_root: Path,
    repo_root: Path,
    rtl_sim: str,
    cxx: str,
    systemc_include: Path,
    systemc_lib: Path,
    build_mode: str,
    build_jobs: int,
    build_pch: bool,
    build_incremental: bool,
    compile_friendly: bool,
    skip_rtl: bool,
) -> None:
    out_dir = out_root / case.name
    out_dir.mkdir(parents=True, exist_ok=True)
    header = _convert(
        case,
        mhsa_root,
        out_dir,
        repo_root,
        compile_friendly=compile_friendly or build_mode == "optimized",
        incremental=build_incremental or build_mode == "optimized",
    )
    rtl_trace = None if skip_rtl else _run_rtl(case, mhsa_root, out_dir, rtl_sim)
    sc_trace = _run_systemc(
        case,
        out_dir,
        header,
        cxx=cxx,
        systemc_include=systemc_include,
        systemc_lib=systemc_lib,
        build_mode=build_mode,
        build_jobs=build_jobs,
        build_pch=build_pch,
        build_incremental=build_incremental,
    )
    if rtl_trace is not None:
        _compare(case, rtl_trace, sc_trace, out_dir)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mhsa-root", type=Path, default=DEFAULT_MHSA_ROOT)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--case", choices=sorted(CASES), action="append")
    parser.add_argument("--rtl-sim", choices=("vcs",), default="vcs")
    parser.add_argument("--systemc-include", type=Path, default=DEFAULT_SYSTEMC_INCLUDE)
    parser.add_argument("--systemc-lib", type=Path, default=DEFAULT_SYSTEMC_LIB)
    parser.add_argument("--cxx", default=os.environ.get("CXX", "g++"))
    parser.add_argument("--keep-out", action="store_true")
    parser.add_argument("--skip-rtl", action="store_true", help="Only convert and build SystemC; reuse no RTL simulation.")
    parser.add_argument("--sc-build-mode", choices=("legacy", "optimized"), default="legacy")
    parser.add_argument("--sc-build-jobs", type=int, default=1)
    parser.add_argument("--sc-build-pch", action="store_true")
    parser.add_argument("--sc-build-incremental", action="store_true")
    parser.add_argument("--sc-compile-friendly", action="store_true")
    args = parser.parse_args(argv)

    repo_root = Path(__file__).resolve().parents[3]
    mhsa_root = args.mhsa_root.expanduser().resolve()
    out_root = args.out.expanduser().resolve()
    selected = args.case or sorted(CASES)

    missing = [
        mhsa_root / source_rel
        for name in selected
        for source_rel in CASES[name].source_rels
        if not (mhsa_root / source_rel).exists()
    ]
    if missing:
        for path in missing:
            print(f"missing source: {path}", file=sys.stderr)
        return 2
    if not args.systemc_include.exists():
        print(f"missing SystemC include dir: {args.systemc_include}", file=sys.stderr)
        return 2
    if not args.systemc_lib.exists():
        print(f"missing SystemC lib dir: {args.systemc_lib}", file=sys.stderr)
        return 2
    if out_root.exists() and not args.keep_out:
        shutil.rmtree(out_root)
    out_root.mkdir(parents=True, exist_ok=True)

    failures: list[str] = []
    for name in selected:
        try:
            _run_case(
                CASES[name],
                mhsa_root=mhsa_root,
                out_root=out_root,
                repo_root=repo_root,
                rtl_sim=args.rtl_sim,
                cxx=args.cxx,
                systemc_include=args.systemc_include,
                systemc_lib=args.systemc_lib,
                build_mode=args.sc_build_mode,
                build_jobs=max(1, args.sc_build_jobs),
                build_pch=args.sc_build_pch,
                build_incremental=args.sc_build_incremental,
                compile_friendly=args.sc_compile_friendly,
                skip_rtl=args.skip_rtl,
            )
        except Exception as exc:
            failures.append(f"{name}: {exc}")
            print(f"ERROR: {failures[-1]}", file=sys.stderr)

    if failures:
        print("MHSA keypoint consistency failed:", file=sys.stderr)
        for failure in failures:
            print(f"  {failure}", file=sys.stderr)
        return 1
    print(f"MHSA keypoint consistency passed: {out_root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
