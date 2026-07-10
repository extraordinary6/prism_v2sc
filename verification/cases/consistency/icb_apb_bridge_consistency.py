#!/usr/bin/env python3
"""Event-level consistency test for the external ICB-to-APB bridge RTL.

Verification-only ``CHECK`` / bind content is removed from a temporary source
snapshot; the external RTL is never modified. ``DES`` remains enabled. RTL and
SystemC are compared at ICB responses and completed APB transactions, allowing
minor scheduler / cycle differences between the two models.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

from prism_v2sc.verify.static_checks import check_generated_systemc


DEFAULT_RTL_ROOT = Path(
    "/home/MicroE/ai_proj/Design-and-Verification-of-ICB-to-APB-Bus-Bridge/uvm_project/my_design/rtl"
)
DEFAULT_OUT = Path("/tmp/prism_icb_apb_consistency")
DEFAULT_SYSTEMC_INCLUDE = Path("/usr/local/systemc-2.3.4/include")
DEFAULT_SYSTEMC_LIB = Path("/usr/local/systemc-2.3.4/lib64")

RTL_SOURCES = (
    "icb_bus.sv",
    "apb_bus.sv",
    "fifo.sv",
    "codec_des.sv",
    "icb_slave.sv",
    "apb_master.sv",
    "top.sv",
)

FLAT_WRAPPER = r"""`timescale 1ns/1ps
module prism_icb_apb_flat_top(
    input logic icb_clk, input logic icb_rst_n,
    input logic apb_clk, input logic apb_rst_n,
    input logic icb_cmd_valid, output logic icb_cmd_ready,
    input logic [31:0] icb_cmd_addr, input logic icb_cmd_read,
    input logic [63:0] icb_cmd_wdata, input logic [7:0] icb_cmd_wmask,
    output logic icb_rsp_valid, input logic icb_rsp_ready,
    output logic [63:0] icb_rsp_rdata, output logic icb_rsp_err,
    output logic apb0_pwrite, output logic apb0_psel,
    output logic [31:0] apb0_paddr, output logic [31:0] apb0_pwdata,
    output logic apb0_penable, input logic [31:0] apb0_prdata, input logic apb0_pready,
    output logic apb1_pwrite, output logic apb1_psel,
    output logic [31:0] apb1_paddr, output logic [31:0] apb1_pwdata,
    output logic apb1_penable, input logic [31:0] apb1_prdata, input logic apb1_pready,
    output logic apb2_pwrite, output logic apb2_psel,
    output logic [31:0] apb2_paddr, output logic [31:0] apb2_pwdata,
    output logic apb2_penable, input logic [31:0] apb2_prdata, input logic apb2_pready,
    output logic apb3_pwrite, output logic apb3_psel,
    output logic [31:0] apb3_paddr, output logic [31:0] apb3_pwdata,
    output logic apb3_penable, input logic [31:0] apb3_prdata, input logic apb3_pready
);
  icb_bus icb(icb_clk, icb_rst_n);
  apb_bus apb0(apb_clk, apb_rst_n), apb1(apb_clk, apb_rst_n);
  apb_bus apb2(apb_clk, apb_rst_n), apb3(apb_clk, apb_rst_n);
  assign icb.icb_cmd_valid=icb_cmd_valid; assign icb_cmd_ready=icb.icb_cmd_ready;
  assign icb.icb_cmd_addr=icb_cmd_addr; assign icb.icb_cmd_read=icb_cmd_read;
  assign icb.icb_cmd_wdata=icb_cmd_wdata; assign icb.icb_cmd_wmask=icb_cmd_wmask;
  assign icb_rsp_valid=icb.icb_rsp_valid; assign icb.icb_rsp_ready=icb_rsp_ready;
  assign icb_rsp_rdata=icb.icb_rsp_rdata; assign icb_rsp_err=icb.icb_rsp_err;
  assign apb0_pwrite=apb0.pwrite; assign apb0_psel=apb0.psel; assign apb0_paddr=apb0.paddr;
  assign apb0_pwdata=apb0.pwdata; assign apb0_penable=apb0.penable;
  assign apb0.prdata=apb0_prdata; assign apb0.pready=apb0_pready;
  assign apb1_pwrite=apb1.pwrite; assign apb1_psel=apb1.psel; assign apb1_paddr=apb1.paddr;
  assign apb1_pwdata=apb1.pwdata; assign apb1_penable=apb1.penable;
  assign apb1.prdata=apb1_prdata; assign apb1.pready=apb1_pready;
  assign apb2_pwrite=apb2.pwrite; assign apb2_psel=apb2.psel; assign apb2_paddr=apb2.paddr;
  assign apb2_pwdata=apb2.pwdata; assign apb2_penable=apb2.penable;
  assign apb2.prdata=apb2_prdata; assign apb2.pready=apb2_pready;
  assign apb3_pwrite=apb3.pwrite; assign apb3_psel=apb3.psel; assign apb3_paddr=apb3.paddr;
  assign apb3_pwdata=apb3.pwdata; assign apb3_penable=apb3.penable;
  assign apb3.prdata=apb3_prdata; assign apb3.pready=apb3_pready;
  dut_top dut(.icb_bus(icb.slave), .apb_bus_0(apb0.master), .apb_bus_1(apb1.master),
              .apb_bus_2(apb2.master), .apb_bus_3(apb3.master));
endmodule
"""


def _run(cmd: list[str], *, cwd: Path, log: Path | None = None, env: dict[str, str] | None = None) -> None:
    print("+ " + " ".join(str(part) for part in cmd), flush=True)
    if log is None:
        subprocess.run(cmd, cwd=cwd, env=env, check=True)
        return
    with log.open("w", encoding="utf-8") as handle:
        handle.write("+ " + " ".join(str(part) for part in cmd) + "\n")
        handle.flush()
        subprocess.run(cmd, cwd=cwd, env=env, stdout=handle, stderr=subprocess.STDOUT, check=True)


def _des_encrypt(key: int, block: int) -> int:
    result = subprocess.run(
        ["openssl", "enc", "-des-ecb", "-K", f"{key:016x}", "-nopad"],
        input=block.to_bytes(8, "big"),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )
    return int.from_bytes(result.stdout, "big")


def _transactions() -> tuple[list[int], list[int]]:
    key = 0x133457799BBCDFF1
    read_blocks: list[int] = []
    write_blocks: list[int] = []
    for index in range(4):
        select = 1 << index
        read_addr = 0x100 + index * 4
        read_header = (read_addr << 8) | (select << 2)
        read_blocks.extend((_des_encrypt(key, read_header), _des_encrypt(key, 0x1)))

        write_addr = 0x200 + index * 4
        write_header = (write_addr << 8) | (select << 2) | 0x2
        write_data = ((0x10203040 + index * 0x1111111) << 1) | 0x1
        write_blocks.extend((_des_encrypt(key, write_header), _des_encrypt(key, write_data)))
    return read_blocks, write_blocks


def _rtl_tb(read_blocks: list[int], write_blocks: list[int]) -> str:
    read_params = "\n".join(
        f"  localparam [63:0] READ_C{index}=64'h{value:016x};" for index, value in enumerate(read_blocks)
    )
    write_params = "\n".join(
        f"  localparam [63:0] WRITE_C{index}=64'h{value:016x};" for index, value in enumerate(write_blocks)
    )
    sequence: list[str] = []
    for index in range(4):
        read_wait = "    idle_icb(20);"
        sequence.extend(
            (
                f'    icb_xfer("read_hdr_{index}",0,32\'h20000010,READ_C{2 * index},8\'h00);',
                read_wait,
                f'    icb_xfer("read_data_{index}",0,32\'h20000010,READ_C{2 * index + 1},8\'h00);',
                "    idle_icb(20);",
                f'    icb_xfer("read_rsp_{index}",1,32\'h20000018,0,8\'h00);',
                f'    icb_xfer("write_hdr_{index}",0,32\'h20000010,WRITE_C{2 * index},8\'h00);',
                "    idle_icb(20);",
                f'    icb_xfer("write_data_{index}",0,32\'h20000010,WRITE_C{2 * index + 1},8\'h00);',
                "    idle_icb(40);",
            )
        )
    sequence_text = "\n".join(sequence)
    return f"""`timescale 1ns/1ps
module tb;
  reg icb_clk=0, icb_rst_n=0, apb_clk=0, apb_rst_n=0;
  reg icb_cmd_valid=0, icb_cmd_read=0, icb_rsp_ready=1;
  reg [31:0] icb_cmd_addr=0; reg [63:0] icb_cmd_wdata=0; reg [7:0] icb_cmd_wmask=0;
  wire icb_cmd_ready, icb_rsp_valid, icb_rsp_err; wire [63:0] icb_rsp_rdata;
  wire apb0_pwrite,apb0_psel,apb0_penable; wire [31:0] apb0_paddr,apb0_pwdata;
  wire apb1_pwrite,apb1_psel,apb1_penable; wire [31:0] apb1_paddr,apb1_pwdata;
  wire apb2_pwrite,apb2_psel,apb2_penable; wire [31:0] apb2_paddr,apb2_pwdata;
  wire apb3_pwrite,apb3_psel,apb3_penable; wire [31:0] apb3_paddr,apb3_pwdata;
  reg [31:0] apb0_prdata=0,apb1_prdata=0,apb2_prdata=0,apb3_prdata=0;
  reg apb0_pready=0,apb1_pready=0,apb2_pready=0,apb3_pready=0;
  integer out, apb_seq=0, wait_count=0, active=0, active_idx=0;
  reg active_write; reg [31:0] active_addr,active_data;
{read_params}
{write_params}
  prism_icb_apb_flat_top dut(.*);
  always #5 icb_clk=~icb_clk;
  always #7 apb_clk=~apb_clk;

  task idle_icb(input integer cycles); begin repeat(cycles) @(posedge icb_clk); end endtask
  task icb_xfer(input [255:0] label,input bit rd,input [31:0] addr,input [63:0] data,input [7:0] mask);
    integer timeout; begin
      @(negedge icb_clk); icb_cmd_valid=1; icb_cmd_read=rd; icb_cmd_addr=addr;
      icb_cmd_wdata=data; icb_cmd_wmask=mask; timeout=0;
      begin @(posedge icb_clk); #1; timeout=timeout+1; end
      while(!icb_cmd_ready && timeout<1000) begin @(posedge icb_clk); #1; timeout=timeout+1; end
      if(timeout>=1000) begin $fdisplay(out,"TIMEOUT %0s",label); $finish; end
      @(negedge icb_clk); icb_cmd_valid=0;
      timeout=0;
      while(!icb_rsp_valid && timeout<20) begin @(posedge icb_clk); #1; timeout=timeout+1; end
      $fdisplay(out,"ICB %0s data=%016h err=%0d",label,icb_rsp_rdata,icb_rsp_err);
    end
  endtask

  always @(posedge apb_clk) begin
    if(!apb_rst_n) begin
      active<=0; apb0_pready<=0; apb1_pready<=0; apb2_pready<=0; apb3_pready<=0;
    end else begin
      apb0_pready<=0; apb1_pready<=0; apb2_pready<=0; apb3_pready<=0;
      if(active) begin
        if((active_idx==0&&apb0_pready)||(active_idx==1&&apb1_pready)||
           (active_idx==2&&apb2_pready)||(active_idx==3&&apb3_pready)) begin
          $fdisplay(out,"APB seq=%0d idx=%0d write=%0d addr=%08h data=%08h",
                    apb_seq,active_idx,active_write,active_addr,active_data);
          apb_seq<=apb_seq+1; active<=0;
        end else if(wait_count==0) begin
          case(active_idx) 0:apb0_pready<=1; 1:apb1_pready<=1; 2:apb2_pready<=1; 3:apb3_pready<=1; endcase
        end else wait_count<=wait_count-1;
      end else if(apb0_psel&&apb0_penable) begin
        active<=1; active_idx<=0; wait_count<=1; active_write<=apb0_pwrite; active_addr<=apb0_paddr;
        active_data<=apb0_pwrite?apb0_pwdata:(32'ha5000000^apb0_paddr); apb0_prdata<=32'ha5000000^apb0_paddr;
      end else if(apb1_psel&&apb1_penable) begin
        active<=1; active_idx<=1; wait_count<=2; active_write<=apb1_pwrite; active_addr<=apb1_paddr;
        active_data<=apb1_pwrite?apb1_pwdata:(32'ha4000000^apb1_paddr); apb1_prdata<=32'ha4000000^apb1_paddr;
      end else if(apb2_psel&&apb2_penable) begin
        active<=1; active_idx<=2; wait_count<=3; active_write<=apb2_pwrite; active_addr<=apb2_paddr;
        active_data<=apb2_pwrite?apb2_pwdata:(32'ha7000000^apb2_paddr); apb2_prdata<=32'ha7000000^apb2_paddr;
      end else if(apb3_psel&&apb3_penable) begin
        active<=1; active_idx<=3; wait_count<=4; active_write<=apb3_pwrite; active_addr<=apb3_paddr;
        active_data<=apb3_pwrite?apb3_pwdata:(32'ha6000000^apb3_paddr); apb3_prdata<=32'ha6000000^apb3_paddr;
      end
    end
  end

  initial begin
    out=$fopen("rtl_events.txt","w"); #40; icb_rst_n=1; apb_rst_n=1; idle_icb(4);
    icb_xfer("control_mask",0,32'h20000000,64'h1122334455667788,8'hf0);
    icb_xfer("control_mask_read",1,32'h20000000,0,0);
    icb_xfer("state_write_err",0,32'h20000008,64'h1,0);
    icb_xfer("rdata_write_err",0,32'h20000018,64'h1,0);
    icb_xfer("key_write",0,32'h20000020,64'h133457799bbcdff1,0);
    icb_xfer("key_read",1,32'h20000020,0,0);
    icb_xfer("control_enable",0,32'h20000000,64'h1,0);
{sequence_text}
    icb_xfer("unknown_read",1,32'h20000088,0,0);
    idle_icb(20); $fclose(out); $finish;
  end
endmodule
"""


def _sc_tb(read_blocks: list[int], write_blocks: list[int]) -> str:
    read_values = ", ".join(f"0x{value:016x}ULL" for value in read_blocks)
    write_values = ", ".join(f"0x{value:016x}ULL" for value in write_blocks)
    return f"""#include <array>
#include <fstream>
#include <iomanip>
#include <systemc>
#include "prism_icb_apb_flat_top.hpp"
using namespace sc_core; using namespace sc_dt;

int sc_main(int,char**) {{
  sc_clock icb_clk("icb_clk",10,SC_NS,0.5,0,SC_NS,false);
  sc_clock apb_clk("apb_clk",14,SC_NS,0.5,0,SC_NS,false);
  sc_signal<bool> icb_rst_n,apb_rst_n,icb_cmd_valid,icb_cmd_ready,icb_cmd_read;
  sc_signal<bool> icb_rsp_valid,icb_rsp_ready,icb_rsp_err;
  sc_signal<sc_uint<32>> icb_cmd_addr; sc_signal<sc_uint<64>> icb_cmd_wdata,icb_rsp_rdata;
  sc_signal<sc_uint<8>> icb_cmd_wmask;
  sc_signal<bool> apb0_pwrite,apb0_psel,apb0_penable,apb0_pready;
  sc_signal<bool> apb1_pwrite,apb1_psel,apb1_penable,apb1_pready;
  sc_signal<bool> apb2_pwrite,apb2_psel,apb2_penable,apb2_pready;
  sc_signal<bool> apb3_pwrite,apb3_psel,apb3_penable,apb3_pready;
  sc_signal<sc_uint<32>> apb0_paddr,apb0_pwdata,apb0_prdata;
  sc_signal<sc_uint<32>> apb1_paddr,apb1_pwdata,apb1_prdata;
  sc_signal<sc_uint<32>> apb2_paddr,apb2_pwdata,apb2_prdata;
  sc_signal<sc_uint<32>> apb3_paddr,apb3_pwdata,apb3_prdata;
  prism_icb_apb_flat_top dut("dut");
#define BIND(x) dut.x(x)
  BIND(icb_clk);BIND(icb_rst_n);BIND(apb_clk);BIND(apb_rst_n);
  BIND(icb_cmd_valid);BIND(icb_cmd_ready);BIND(icb_cmd_addr);BIND(icb_cmd_read);
  BIND(icb_cmd_wdata);BIND(icb_cmd_wmask);BIND(icb_rsp_valid);BIND(icb_rsp_ready);
  BIND(icb_rsp_rdata);BIND(icb_rsp_err);
  BIND(apb0_pwrite);BIND(apb0_psel);BIND(apb0_paddr);BIND(apb0_pwdata);BIND(apb0_penable);BIND(apb0_prdata);BIND(apb0_pready);
  BIND(apb1_pwrite);BIND(apb1_psel);BIND(apb1_paddr);BIND(apb1_pwdata);BIND(apb1_penable);BIND(apb1_prdata);BIND(apb1_pready);
  BIND(apb2_pwrite);BIND(apb2_psel);BIND(apb2_paddr);BIND(apb2_pwdata);BIND(apb2_penable);BIND(apb2_prdata);BIND(apb2_pready);
  BIND(apb3_pwrite);BIND(apb3_psel);BIND(apb3_paddr);BIND(apb3_pwdata);BIND(apb3_penable);BIND(apb3_prdata);BIND(apb3_pready);
#undef BIND
  std::ofstream out("sc_events.txt"); bool prev_i=false,prev_a=false;
  bool active=false,active_write=false; int active_idx=0,wait_count=0,apb_seq=0;
  sc_uint<32> active_addr=0,active_data=0;
  auto set_ready=[&](int idx,bool value){{ apb0_pready.write(idx==0&&value);apb1_pready.write(idx==1&&value);apb2_pready.write(idx==2&&value);apb3_pready.write(idx==3&&value); }};
  auto service_apb=[&](){{
    bool ready=(active_idx==0?apb0_pready.read():active_idx==1?apb1_pready.read():active_idx==2?apb2_pready.read():apb3_pready.read());
    if(active&&ready){{ out<<"APB seq="<<apb_seq++<<" idx="<<active_idx<<" write="<<(active_write?1:0)
      <<" addr="<<std::hex<<std::setw(8)<<std::setfill('0')<<active_addr.to_uint()
      <<" data="<<std::setw(8)<<active_data.to_uint()<<std::dec<<"\\n"; active=false;set_ready(0,false);return; }}
    if(active){{ if(wait_count==0)set_ready(active_idx,true);else --wait_count; return; }}
    int idx=-1; bool wr=false; sc_uint<32> addr=0,data=0;
    if(apb0_psel.read()&&apb0_penable.read()){{idx=0;wr=apb0_pwrite.read();addr=apb0_paddr.read();data=apb0_pwdata.read();}}
    else if(apb1_psel.read()&&apb1_penable.read()){{idx=1;wr=apb1_pwrite.read();addr=apb1_paddr.read();data=apb1_pwdata.read();}}
    else if(apb2_psel.read()&&apb2_penable.read()){{idx=2;wr=apb2_pwrite.read();addr=apb2_paddr.read();data=apb2_pwdata.read();}}
    else if(apb3_psel.read()&&apb3_penable.read()){{idx=3;wr=apb3_pwrite.read();addr=apb3_paddr.read();data=apb3_pwdata.read();}}
    if(idx<0)return; active=true;active_idx=idx;active_write=wr;active_addr=addr;wait_count=idx+1;
    sc_uint<32> rd=(idx==0?0xa5000000u:idx==1?0xa4000000u:idx==2?0xa7000000u:0xa6000000u)^addr;
    if(idx==0)apb0_prdata.write(rd);else if(idx==1)apb1_prdata.write(rd);else if(idx==2)apb2_prdata.write(rd);else apb3_prdata.write(rd);
    active_data=wr?data:rd;
  }};
  auto advance=[&](){{ sc_start(1,SC_NS);bool ni=icb_clk.read(),na=apb_clk.read();if(na&&!prev_a)service_apb();prev_i=ni;prev_a=na; }};
  auto wait_edge=[&](bool pos){{bool before=icb_clk.read();for(int n=0;n<100;n++){{advance();bool now=icb_clk.read();if((pos&&!before&&now)||(!pos&&before&&!now))return;before=now;}}}};
  auto idle=[&](int cycles){{for(int i=0;i<cycles;i++)wait_edge(true);}};
  auto xfer=[&](const char* label,bool rd,unsigned addr,unsigned long long data,unsigned mask){{
    wait_edge(false);icb_cmd_valid.write(true);icb_cmd_read.write(rd);icb_cmd_addr.write(addr);icb_cmd_wdata.write(data);icb_cmd_wmask.write(mask);
    int timeout=0;do{{wait_edge(true);++timeout;}}while(!icb_cmd_ready.read()&&timeout<1000);if(timeout>=1000)throw std::runtime_error("ICB timeout");
    wait_edge(false);icb_cmd_valid.write(false);timeout=0;while(!icb_rsp_valid.read()&&timeout++<20)wait_edge(true);
    out<<"ICB "<<label<<" data="<<std::hex<<std::setw(16)<<std::setfill('0')<<icb_rsp_rdata.read().to_uint64()
       <<std::dec<<" err="<<(icb_rsp_err.read()?1:0)<<"\\n";
  }};
  const std::array<unsigned long long,8> reads={{{read_values}}};
  const std::array<unsigned long long,8> writes={{{write_values}}};
  icb_rst_n.write(false);apb_rst_n.write(false);icb_rsp_ready.write(true);icb_cmd_valid.write(false);set_ready(0,false);
  for(int i=0;i<40;i++)advance();icb_rst_n.write(true);apb_rst_n.write(true);idle(4);
  xfer("control_mask",false,0x20000000,0x1122334455667788ULL,0xf0);
  xfer("control_mask_read",true,0x20000000,0,0);xfer("state_write_err",false,0x20000008,1,0);
  xfer("rdata_write_err",false,0x20000018,1,0);xfer("key_write",false,0x20000020,0x133457799bbcdff1ULL,0);
  xfer("key_read",true,0x20000020,0,0);xfer("control_enable",false,0x20000000,1,0);
  for(int i=0;i<4;i++){{
    std::string rh="read_hdr_"+std::to_string(i),rd="read_data_"+std::to_string(i),rs="read_rsp_"+std::to_string(i),wh="write_hdr_"+std::to_string(i),wd="write_data_"+std::to_string(i);
    xfer(rh.c_str(),false,0x20000010,reads[2*i],0);idle(20);xfer(rd.c_str(),false,0x20000010,reads[2*i+1],0);idle(20);xfer(rs.c_str(),true,0x20000018,0,0);
    xfer(wh.c_str(),false,0x20000010,writes[2*i],0);idle(20);xfer(wd.c_str(),false,0x20000010,writes[2*i+1],0);idle(40);
  }}
  xfer("unknown_read",true,0x20000088,0,0);idle(20);return 0;
}}
"""


def _snapshot(rtl_root: Path, out: Path) -> list[Path]:
    snapshot = out / "rtl_snapshot"
    snapshot.mkdir(parents=True, exist_ok=True)
    for name in RTL_SOURCES:
        shutil.copy2(rtl_root / name, snapshot / name)
    cfig = (rtl_root / "cfig.svh").read_text(encoding="utf-8")
    cfig = "\n".join(line for line in cfig.splitlines() if "`define CHECK" not in line) + "\n"
    (snapshot / "cfig.svh").write_text(cfig, encoding="utf-8")
    (snapshot / "prism_flat_top.sv").write_text(FLAT_WRAPPER, encoding="utf-8")
    return [snapshot / name for name in RTL_SOURCES] + [snapshot / "prism_flat_top.sv"]


def _normalized(path: Path) -> list[str]:
    lines = [line.strip().lower() for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
    return sorted(lines)


def _check_expected(events: list[str]) -> None:
    event_set = set(events)
    required = {
        "icb control_mask_read data=0000000055667788 err=0",
        "icb state_write_err data=0000000055667788 err=1",
        "icb rdata_write_err data=0000000055667788 err=1",
        "icb key_read data=133457799bbcdff1 err=0",
        "icb unknown_read data=0000000000000000 err=0",
    }
    key = 0x133457799BBCDFF1
    for index in range(4):
        read_addr = 0x100 + index * 4
        read_data = (0xA5000000 ^ (index << 24)) ^ read_addr
        read_cipher = _des_encrypt(key, read_data)
        required.add(f"icb read_rsp_{index} data={read_cipher:016x} err=0")
        required.add(
            f"apb seq={2 * index} idx={index} write=0 addr={read_addr:08x} data={read_data:08x}"
        )
        write_addr = 0x200 + index * 4
        write_data = 0x10203040 + index * 0x1111111
        required.add(
            f"apb seq={2 * index + 1} idx={index} write=1 addr={write_addr:08x} data={write_data:08x}"
        )
    missing = sorted(required - event_set)
    if missing:
        raise RuntimeError("missing expected semantic events: " + "; ".join(missing))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rtl-root", type=Path, default=DEFAULT_RTL_ROOT)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--systemc-include", type=Path, default=DEFAULT_SYSTEMC_INCLUDE)
    parser.add_argument("--systemc-lib", type=Path, default=DEFAULT_SYSTEMC_LIB)
    parser.add_argument("--cxx", default=os.environ.get("CXX", "g++"))
    parser.add_argument("--keep-out", action="store_true")
    args = parser.parse_args(argv)
    repo_root = Path(__file__).resolve().parents[3]
    rtl_root = args.rtl_root.expanduser().resolve()
    out = args.out.expanduser().resolve()
    missing = [rtl_root / name for name in (*RTL_SOURCES, "cfig.svh") if not (rtl_root / name).exists()]
    if missing:
        print("missing RTL: " + ", ".join(str(path) for path in missing), file=sys.stderr)
        return 2
    if out.exists() and not args.keep_out:
        shutil.rmtree(out)
    out.mkdir(parents=True, exist_ok=True)
    sources = _snapshot(rtl_root, out)
    sc_out = out / "systemc"
    _run([sys.executable,"-m","prism_v2sc","--top","prism_icb_apb_flat_top","--out",str(sc_out),
          "--metrics","--fail-on-diagnostics",*[str(path) for path in sources]], cwd=repo_root, log=out/"convert.log")
    headers = sorted(sc_out.rglob("*.hpp"))
    header_texts = [header.read_text(encoding="utf-8") for header in headers]
    issues = [issue for text in header_texts for issue in check_generated_systemc(text)]
    if any(issue.severity == "error" for issue in issues):
        raise RuntimeError("generated SystemC failed static checks")
    bad_markers = ("/* raw:", "/* unsupported expr:", "// Unsupported statement:", "TODO:")
    if any(marker in text for text in header_texts for marker in bad_markers):
        raise RuntimeError("generated SystemC contains fallback code")
    read_blocks, write_blocks = _transactions()
    rtl_tb = out / "tb_rtl.sv"; rtl_tb.write_text(_rtl_tb(read_blocks, write_blocks), encoding="utf-8")
    sc_tb = out / "tb_systemc.cpp"; sc_tb.write_text(_sc_tb(read_blocks, write_blocks), encoding="utf-8")
    vcs_env = os.environ.copy(); vcs_env.setdefault("VCS_TARGET_ARCH", "linux64")
    _run([os.environ.get("VCS","vcs"),"-full64","-sverilog",f"+incdir+{sources[0].parent}","-o","rtl_simv",
          str(rtl_tb),*[str(path) for path in sources]], cwd=out, log=out/"vcs.log", env=vcs_env)
    _run([str(out/"rtl_simv")], cwd=out, log=out/"rtl_run.log", env=vcs_env)
    sc_exe = out / "sc_sim"
    _run([args.cxx,"-std=c++14",f"-I{args.systemc_include}",f"-I{sc_out}",str(sc_tb),
          f"-L{args.systemc_lib}",f"-Wl,-rpath,{args.systemc_lib}","-lsystemc","-pthread","-o",str(sc_exe)],
         cwd=out, log=out/"systemc_build.log")
    _run([str(sc_exe)], cwd=out, log=out/"systemc_run.log")
    rtl_events, sc_events = _normalized(out/"rtl_events.txt"), _normalized(out/"sc_events.txt")
    _check_expected(rtl_events)
    if rtl_events != sc_events:
        (out/"event.diff").write_text("RTL:\n"+"\n".join(rtl_events)+"\n\nSystemC:\n"+"\n".join(sc_events)+"\n",encoding="utf-8")
        raise RuntimeError(f"event mismatch; see {out/'event.diff'}")
    print(f"ICB-to-APB consistency passed: {len(rtl_events)} events, {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
