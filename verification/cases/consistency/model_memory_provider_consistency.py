#!/usr/bin/env python3
"""RTL/SystemC differential gate for the built-in memory model provider."""

from __future__ import annotations

import json
from pathlib import Path
import shutil
import subprocess
import sys


OUT = Path("/tmp/prism_model_memory_consistency")
SYSTEMC_INCLUDE = Path("/usr/local/systemc-2.3.4/include")
SYSTEMC_LIB = Path("/usr/local/systemc-2.3.4/lib64")


def _run(command: list[str], cwd: Path, log: Path) -> None:
    print("+ " + " ".join(command), flush=True)
    with log.open("w", encoding="utf-8") as handle:
        subprocess.run(command, cwd=cwd, stdout=handle, stderr=subprocess.STDOUT, check=True)


def _rtl(mode: str) -> str:
    if mode == "read_first":
        body = """
      rdata <= storage[addr];
      if (we) storage[addr] <= wdata;
"""
    elif mode == "write_first":
        body = """
      if (we) begin storage[addr] <= wdata; rdata <= wdata; end
      else rdata <= storage[addr];
"""
    else:
        body = """
      if (we) storage[addr] <= wdata;
      else rdata <= storage[addr];
"""
    return f"""module sim_mem(
  input logic clk, input logic en, input logic we,
  input logic [3:0] addr, input logic [7:0] wdata,
  output logic [7:0] rdata
);
  logic [7:0] storage [0:15];
  always_ff @(posedge clk) begin
    if (en) begin
{body}    end
  end
endmodule
"""


def _manifest(mode: str) -> dict[str, object]:
    return {
        "version": 1,
        "strict": True,
        "module_rules": [
            {
                "module": "sim_mem",
                "provider": "memory",
                "config": {
                    "clock": "clk",
                    "enable": "en",
                    "write_enable": "we",
                    "address": "addr",
                    "write_data": "wdata",
                    "read_data": "rdata",
                    "depth": 16,
                    "read_latency": 1,
                    "write_mode": mode,
                },
            }
        ],
    }


def _rtl_tb(mode: str) -> str:
    return f"""`timescale 1ns/1ps
module tb;
  reg clk=0,en=0,we=0; reg [3:0] addr=0; reg [7:0] wdata=0; wire [7:0] rdata;
  integer out; sim_mem dut(.*); always #5 clk=~clk;
  task cycle(input e,input w,input [3:0] a,input [7:0] d); begin
    @(negedge clk); en=e;we=w;addr=a;wdata=d; @(posedge clk); #1;
  end endtask
  initial begin
    out=$fopen("rtl_events.txt","w");
    cycle(1,1,4'h1,8'ha5);
    cycle(1,0,4'h1,0); $fdisplay(out,"read_initial=%02h",rdata);
    cycle(1,1,4'h1,8'h3c); $fdisplay(out,"same_addr_{mode}=%02h",rdata);
    cycle(1,0,4'h1,0); $fdisplay(out,"read_final=%02h",rdata);
    cycle(0,0,0,0); $fdisplay(out,"disabled_hold=%02h",rdata);
    $fclose(out);$finish;
  end
endmodule
"""


def _systemc_tb(mode: str) -> str:
    return f"""#include <fstream>
#include <systemc>
#include "sim_mem.hpp"
using namespace sc_core;using namespace sc_dt;
int sc_main(int,char**){{
  sc_signal<bool> clk,en,we;sc_signal<sc_uint<4>> addr;sc_signal<sc_uint<8>> wdata,rdata;
  sim_mem dut("dut");dut.clk(clk);dut.en(en);dut.we(we);dut.addr(addr);dut.wdata(wdata);dut.rdata(rdata);
  std::ofstream out("sc_events.txt");clk.write(0);en.write(0);we.write(0);sc_start(SC_ZERO_TIME);
  auto cycle=[&](bool e,bool w,unsigned a,unsigned d){{
    en.write(e);we.write(w);addr.write(a);wdata.write(d);sc_start(1,SC_PS);
    clk.write(1);sc_start(1,SC_NS);clk.write(0);sc_start(9,SC_NS);
  }};
  cycle(1,1,1,0xa5);
  cycle(1,0,1,0);out<<"read_initial="<<std::hex<<rdata.read().to_uint()<<"\\n";
  cycle(1,1,1,0x3c);out<<"same_addr_{mode}="<<std::hex<<rdata.read().to_uint()<<"\\n";
  cycle(1,0,1,0);out<<"read_final="<<std::hex<<rdata.read().to_uint()<<"\\n";
  cycle(0,0,0,0);out<<"disabled_hold="<<std::hex<<rdata.read().to_uint()<<"\\n";
  return 0;
}}
"""


def _normalized(path: Path) -> list[str]:
    return [line.strip().lower() for line in path.read_text(encoding="utf-8").splitlines()]


def main() -> int:
    shutil.rmtree(OUT, ignore_errors=True)
    OUT.mkdir(parents=True)
    for mode in ("read_first", "write_first", "no_change"):
        case_dir = OUT / mode
        case_dir.mkdir()
        rtl = case_dir / "sim_mem.sv"
        manifest = case_dir / "models.json"
        rtl.write_text(_rtl(mode), encoding="utf-8")
        manifest.write_text(json.dumps(_manifest(mode), indent=2) + "\n", encoding="utf-8")
        systemc_dir = case_dir / "systemc"
        _run(
            [
                sys.executable,
                "-m",
                "prism_v2sc",
                "--top",
                "sim_mem",
                "--model-manifest",
                str(manifest),
                "--fail-on-diagnostics",
                "--out",
                str(systemc_dir),
                str(rtl),
            ],
            case_dir,
            case_dir / "convert.log",
        )
        rtl_tb = case_dir / "tb_rtl.sv"
        rtl_tb.write_text(_rtl_tb(mode), encoding="utf-8")
        _run(
            ["vcs", "-full64", "-sverilog", "-timescale=1ns/1ps", "-o", "rtl_simv", str(rtl), str(rtl_tb)],
            case_dir,
            case_dir / "vcs.log",
        )
        _run([str(case_dir / "rtl_simv")], case_dir, case_dir / "rtl_run.log")
        sc_tb = case_dir / "tb_sc.cpp"
        sc_tb.write_text(_systemc_tb(mode), encoding="utf-8")
        _run(
            [
                "g++",
                "-std=c++14",
                f"-I{SYSTEMC_INCLUDE}",
                f"-I{systemc_dir}",
                str(sc_tb),
                f"-L{SYSTEMC_LIB}",
                f"-Wl,-rpath,{SYSTEMC_LIB}",
                "-lsystemc",
                "-pthread",
                "-o",
                str(case_dir / "sc_sim"),
            ],
            case_dir,
            case_dir / "sc_compile.log",
        )
        _run([str(case_dir / "sc_sim")], case_dir, case_dir / "sc_run.log")

        rtl_events = _normalized(case_dir / "rtl_events.txt")
        sc_events = _normalized(case_dir / "sc_events.txt")
        expected_middle = "3c" if mode == "write_first" else "a5"
        expected = [
            "read_initial=a5",
            f"same_addr_{mode}={expected_middle}",
            "read_final=3c",
            "disabled_hold=3c",
        ]
        if rtl_events != expected or sc_events != expected:
            raise AssertionError(
                f"memory provider mismatch for {mode}: RTL={rtl_events}, SC={sc_events}, EXP={expected}"
            )
        print(f"memory provider consistency passed: {mode}")
    print(f"memory provider consistency passed: 3 modes, {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
