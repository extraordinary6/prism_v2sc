#!/usr/bin/env python3
"""RTL/SystemC consistency gate for the E203 ICB DMA block."""

from __future__ import annotations

import argparse
import difflib
import json
import os
import re
import shlex
import subprocess
import tempfile
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RTL = Path("/home/MicroE/ai_proj/DMA-Design-Based-on-E203-and-ICB-Bus/rtl/e203_dma.v")
FILELIST = ROOT / "verification/cases/dma_e203/dma_e203.f"


def run(command: list[str], cwd: Path, log: Path) -> None:
    with log.open("w", encoding="utf-8") as handle:
        result = subprocess.run(command, cwd=cwd, stdout=handle, stderr=subprocess.STDOUT)
    if result.returncode:
        raise RuntimeError(f"command failed ({result.returncode}): {' '.join(map(shlex.quote, command))}; see {log}")


def render_rtl_tb() -> str:
    return r'''`timescale 1ns/1ps
module tb;
  reg clk=0, rst_n=0;
  reg dma_icb_cmd_ready=1, dma_icb_rsp_valid=0, dma_icb_rsp_err=0;
  reg [31:0] dma_icb_rsp_rdata=0;
  wire dma_icb_cmd_valid, dma_icb_cmd_read, dma_icb_rsp_ready, dma_irq;
  wire [31:0] dma_icb_cmd_addr, dma_icb_cmd_wdata;
  wire [3:0] dma_icb_cmd_wmask;
  reg dma_cfg_icb_cmd_valid=0, dma_cfg_icb_cmd_read=0;
  reg [31:0] dma_cfg_icb_cmd_addr=0, dma_cfg_icb_cmd_wdata=0;
  reg [3:0] dma_cfg_icb_cmd_wmask=4'hf;
  reg dma_cfg_icb_rsp_ready=1;
  wire dma_cfg_icb_cmd_ready, dma_cfg_icb_rsp_valid, dma_cfg_icb_rsp_err;
  wire [31:0] dma_cfg_icb_rsp_rdata;
  reg [31:0] mem [0:255]; integer i, cycle;
  e203_dma dut(.*,.clk(clk),.rst_n(rst_n));
  always #5 clk=~clk;
  always @(posedge clk) begin
    dma_icb_rsp_valid <= dma_icb_cmd_valid && dma_icb_cmd_ready;
    dma_icb_rsp_err <= 0;
    if (dma_icb_cmd_valid && dma_icb_cmd_ready && dma_icb_cmd_read)
      dma_icb_rsp_rdata <= mem[dma_icb_cmd_addr[9:2]];
    else if (dma_icb_cmd_valid && dma_icb_cmd_ready && !dma_icb_cmd_read)
      mem[dma_icb_cmd_addr[9:2]] <= dma_icb_cmd_wdata;
  end
  task cfg_write(input [31:0] addr, input [31:0] data);
    begin @(negedge clk); dma_cfg_icb_cmd_addr=addr; dma_cfg_icb_cmd_wdata=data; dma_cfg_icb_cmd_read=0; dma_cfg_icb_cmd_valid=1;
      @(negedge clk); dma_cfg_icb_cmd_valid=0; end
  endtask
  task cfg_read(input [31:0] addr);
    begin @(negedge clk); dma_cfg_icb_cmd_addr=addr; dma_cfg_icb_cmd_wdata=0; dma_cfg_icb_cmd_read=1; dma_cfg_icb_cmd_valid=1;
      @(negedge clk); dma_cfg_icb_cmd_valid=0; end
  endtask
  initial begin
    for(i=0;i<256;i=i+1) mem[i]=32'h0;
    mem[8'h10]=32'h11223344; mem[8'h11]=32'haabbccdd; mem[8'h12]=32'h55667788;
    repeat(3) @(negedge clk); rst_n=1;
    cfg_write(32'h10000000,32'h40);
    cfg_write(32'h10000004,32'h80);
    cfg_write(32'h10000008,32'h2);
    cfg_read(32'h10000000); cfg_read(32'h10000008);
    cfg_write(32'h1000000c,32'h1);
    for(cycle=0;cycle<45;cycle=cycle+1) begin
      @(negedge clk); #1;
      $display("%0d %0d %08x %0d %08x %0d %0d %08x %0d %08x", cycle,
        dma_icb_cmd_valid,dma_icb_cmd_addr,dma_icb_cmd_read,dma_icb_cmd_wdata,
        dma_icb_rsp_ready,dma_cfg_icb_rsp_valid,dma_cfg_icb_rsp_rdata,dma_irq,dma_cfg_icb_rsp_err);
    end
    $finish;
  end
endmodule
'''


def render_sc_tb(header: Path) -> str:
    include = header.as_posix()
    return f'''#include <systemc>
#include <iomanip>
#include <iostream>
#include <array>
#include "{include}"
using namespace sc_core;
using namespace sc_dt;
SC_MODULE(tb) {{
  sc_clock clk{{"clk", 10, SC_NS}}; sc_signal<bool> rst_n;
  sc_signal<bool> dma_icb_cmd_valid, dma_icb_cmd_ready, dma_icb_cmd_read, dma_icb_rsp_valid, dma_icb_rsp_ready, dma_icb_rsp_err, dma_irq;
  sc_signal<sc_uint<32>> dma_icb_cmd_addr, dma_icb_cmd_wdata, dma_icb_rsp_rdata;
  sc_signal<sc_uint<4>> dma_icb_cmd_wmask;
  sc_signal<bool> dma_cfg_icb_cmd_valid, dma_cfg_icb_cmd_ready, dma_cfg_icb_cmd_read, dma_cfg_icb_rsp_valid, dma_cfg_icb_rsp_ready, dma_cfg_icb_rsp_err;
  sc_signal<sc_uint<32>> dma_cfg_icb_cmd_addr, dma_cfg_icb_cmd_wdata, dma_cfg_icb_rsp_rdata; sc_signal<sc_uint<4>> dma_cfg_icb_cmd_wmask;
  e203_dma<> dut{{"dut"}}; std::array<uint32_t,256> mem{{}};
  void memory() {{
    while(true) {{ wait(clk.posedge_event()); dma_icb_rsp_valid.write(dma_icb_cmd_valid.read() && dma_icb_cmd_ready.read()); dma_icb_rsp_err.write(false);
      if (dma_icb_cmd_valid.read() && dma_icb_cmd_ready.read()) {{ auto idx=(unsigned)(dma_icb_cmd_addr.read()>>2); if(dma_icb_cmd_read.read()) dma_icb_rsp_rdata.write(mem[idx]); else mem[idx]=dma_icb_cmd_wdata.read(); }} }}
  }}
  void drive() {{
    rst_n.write(false); dma_cfg_icb_cmd_valid.write(false); dma_cfg_icb_cmd_read.write(false); dma_icb_cmd_ready.write(true); dma_cfg_icb_rsp_ready.write(true);
    mem[0x10]=0x11223344; mem[0x11]=0xaabbccdd; mem[0x12]=0x55667788; for(int i=0;i<3;i++) wait(clk.negedge_event()); rst_n.write(true);
    cfg_write(0x10000000,0x40); cfg_write(0x10000004,0x80); cfg_write(0x10000008,2); cfg_read(0x10000000); cfg_read(0x10000008); cfg_write(0x1000000c,1);
    for(int cycle=0;cycle<45;cycle++) {{ wait(clk.negedge_event()); wait(SC_ZERO_TIME); std::cout<<cycle<<" "<<dma_icb_cmd_valid.read()<<" "<<std::hex<<std::setw(8)<<std::setfill('0')<<dma_icb_cmd_addr.read()<<std::dec<<" "<<dma_icb_cmd_read.read()<<" "<<std::hex<<std::setw(8)<<dma_icb_cmd_wdata.read()<<std::dec<<" "<<dma_icb_rsp_ready.read()<<" "<<dma_cfg_icb_rsp_valid.read()<<" "<<std::hex<<std::setw(8)<<dma_cfg_icb_rsp_rdata.read()<<std::dec<<" "<<dma_irq.read()<<" "<<dma_cfg_icb_rsp_err.read()<<"\\n"; }} sc_stop();
  }}
  void cfg_write(uint32_t addr,uint32_t data) {{ wait(clk.negedge_event()); dma_cfg_icb_cmd_addr.write(addr); dma_cfg_icb_cmd_wdata.write(data); dma_cfg_icb_cmd_read.write(false); dma_cfg_icb_cmd_valid.write(true); wait(clk.negedge_event()); dma_cfg_icb_cmd_valid.write(false); }}
  void cfg_read(uint32_t addr) {{ wait(clk.negedge_event()); dma_cfg_icb_cmd_addr.write(addr); dma_cfg_icb_cmd_wdata.write(0); dma_cfg_icb_cmd_read.write(true); dma_cfg_icb_cmd_valid.write(true); wait(clk.negedge_event()); dma_cfg_icb_cmd_valid.write(false); }}
  SC_CTOR(tb) : dut("dut") {{ dut.clk(clk); dut.rst_n(rst_n); dut.dma_icb_cmd_valid(dma_icb_cmd_valid); dut.dma_icb_cmd_ready(dma_icb_cmd_ready); dut.dma_icb_cmd_addr(dma_icb_cmd_addr); dut.dma_icb_cmd_read(dma_icb_cmd_read); dut.dma_icb_cmd_wdata(dma_icb_cmd_wdata); dut.dma_icb_cmd_wmask(dma_icb_cmd_wmask); dut.dma_icb_rsp_valid(dma_icb_rsp_valid); dut.dma_icb_rsp_ready(dma_icb_rsp_ready); dut.dma_icb_rsp_err(dma_icb_rsp_err); dut.dma_icb_rsp_rdata(dma_icb_rsp_rdata); dut.dma_irq(dma_irq); dut.dma_cfg_icb_cmd_valid(dma_cfg_icb_cmd_valid); dut.dma_cfg_icb_cmd_ready(dma_cfg_icb_cmd_ready); dut.dma_cfg_icb_cmd_addr(dma_cfg_icb_cmd_addr); dut.dma_cfg_icb_cmd_read(dma_cfg_icb_cmd_read); dut.dma_cfg_icb_cmd_wdata(dma_cfg_icb_cmd_wdata); dut.dma_cfg_icb_cmd_wmask(dma_cfg_icb_cmd_wmask); dut.dma_cfg_icb_rsp_valid(dma_cfg_icb_rsp_valid); dut.dma_cfg_icb_rsp_ready(dma_cfg_icb_rsp_ready); dut.dma_cfg_icb_rsp_err(dma_cfg_icb_rsp_err); dut.dma_cfg_icb_rsp_rdata(dma_cfg_icb_rsp_rdata); SC_THREAD(memory); SC_THREAD(drive); }}
}};
int sc_main(int argc,char**argv) {{ tb t("t"); sc_start(); return 0; }}
'''


def normalize_trace(lines: list[str]) -> list[tuple[int, ...]]:
    trace: list[tuple[int, ...]] = []
    for line in lines:
        if not re.match(r"^\d+\s", line):
            continue
        fields = line.split()
        if len(fields) != 10:
            continue
        trace.append(tuple(
            int(value, 16) if index in {2, 4, 7} else int(value, 10)
            for index, value in enumerate(fields)
        ))
    return trace


def analyze_rtl_behavior(trace: list[tuple[int, ...]]) -> list[dict[str, object]]:
    commands = [(row[0], row[2], row[3]) for row in trace if row[1]]
    findings: list[dict[str, object]] = []
    duplicates = [
        {"cycles": [left[0], right[0]], "address": f"0x{left[1]:08x}", "read": bool(left[2])}
        for left, right in zip(commands, commands[1:])
        if left[1:] == right[1:]
    ]
    if duplicates:
        findings.append({
            "code": "rtl_icb_command_reaccepted",
            "severity": "warning",
            "message": "cmd_valid remains asserted across ready cycles, allowing the same ICB command to be accepted more than once",
            "examples": duplicates,
        })
    below_base = [
        {"cycle": cycle, "address": f"0x{address:08x}", "read": bool(read)}
        for cycle, address, read in commands
        if (read and address < 0x40) or (not read and address < 0x80)
    ]
    if below_base:
        findings.append({
            "code": "rtl_dma_prebase_access",
            "severity": "warning",
            "message": "the first transfer accesses src_addr-4 and dst_addr-4 because cnt resets to 0xffffffff and address uses (cnt-1)*4",
            "examples": below_base,
        })
    reads = {address for _, address, read in commands if read and address >= 0x40}
    writes = {address for _, address, read in commands if not read and address >= 0x80}
    expected_writes = {0x80 + (address - 0x40) for address in reads}
    missing_writes = sorted(expected_writes - writes)
    if missing_writes:
        findings.append({
            "code": "rtl_dma_unpaired_final_read",
            "severity": "warning",
            "message": "the observed completion sequence contains a final source read without a corresponding destination write",
            "missing_destination_addresses": [f"0x{address:08x}" for address in missing_writes],
        })
    findings.append({
        "code": "rtl_cfg_backpressure_ignored",
        "severity": "warning",
        "message": "dma_cfg_icb_rsp_ready does not affect response valid, so configuration response backpressure is not implemented",
    })
    findings.append({
        "code": "rtl_cfg_write_mask_ignored",
        "severity": "warning",
        "message": "dma_cfg_icb_cmd_wmask does not affect configuration register writes",
    })
    return findings


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--work", type=Path, default=Path("build/dma_e203_consistency"))
    args = parser.parse_args(); work=args.work.resolve(); work.mkdir(parents=True,exist_ok=True)
    sc_out=work/"systemc"; sc_out.mkdir(exist_ok=True)
    env=os.environ.copy(); env["PYTHONPATH"]=str(ROOT/"src")
    run([sys.executable,"-m","prism_v2sc","--top","e203_dma","--filelist",str(FILELIST),"--fail-on-diagnostics","--out",str(sc_out)],ROOT,work/"convert.log")
    header=sc_out/"e203_dma.hpp"; (work/"tb_rtl.sv").write_text(render_rtl_tb()); (work/"tb_sc.cpp").write_text(render_sc_tb(header))
    run(["vcs","+v2k","-sverilog","-full64","-q","-timescale=1ns/1ps","+define+E203_ADDR_SIZE=32","+define+E203_XLEN=32",str(RTL),str(work/"tb_rtl.sv"),"-o","rtl_simv"],work,work/"vcs.log")
    run(["./rtl_simv"],work,work/"rtl.log")
    cxxflags=os.environ.get("SC_CXXFLAGS","-std=c++14 -I/usr/local/systemc-2.3.4/include").split(); ldflags=os.environ.get("SC_LDFLAGS","-L/usr/local/systemc-2.3.4/lib64 -Wl,-rpath,/usr/local/systemc-2.3.4/lib64").split(); libs=os.environ.get("SC_LIBS","-lsystemc -pthread").split()
    run([os.environ.get("CXX","g++"),"-std=c++14",f"-I{sc_out}",str(work/"tb_sc.cpp"),*cxxflags,*ldflags,*libs,"-o","sc_sim"],work,work/"g++.log")
    run(["./sc_sim"],work,work/"sc.log")
    rtl=normalize_trace((work/"rtl.log").read_text().splitlines()); sc=normalize_trace((work/"sc.log").read_text().splitlines());
    if rtl != sc:
        (work/"diff.log").write_text("".join(difflib.unified_diff(rtl,sc,fromfile="rtl",tofile="systemc"))); print("DMA consistency FAILED; see",work/"diff.log"); return 1
    findings = analyze_rtl_behavior(rtl)
    (work / "rtl_findings.json").write_text(json.dumps({"findings": findings}, indent=2) + "\n", encoding="utf-8")
    print(f"DMA E203 consistency passed: {len(rtl)} sampled cycles; {len(findings)} RTL finding(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
