#!/usr/bin/env python3
"""End-to-end RTL/SystemC consistency gate for the external tinyNPU RTL."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
from pathlib import Path
import shutil
import subprocess
import sys

from prism_v2sc.verify.static_checks import check_generated_systemc


DEFAULT_ROOT = Path("/home/MicroE/ai_proj/tinyNPU")
DEFAULT_OUT = Path("/tmp/prism_tinynpu_consistency")
DEFAULT_SYSTEMC_INCLUDE = Path("/usr/local/systemc-2.3.4/include")
DEFAULT_SYSTEMC_LIB = Path("/usr/local/systemc-2.3.4/lib64")

ROWS = 4
COLS = 4
TOP_MODULE = "top_harness"

RTL_NAMES = (
    "pe.sv",
    "ctrl_fsm.sv",
    "ofm_writer.sv",
    "bias_relu.sv",
    "requantize.sv",
    "weight_loader.sv",
    "apb_csr.sv",
    "req_param_loader.sv",
    "accumulator.sv",
    "bias_loader.sv",
    "ifm_feeder.sv",
    "sram_wrapper.sv",
    "row_accumulator.sv",
    "systolic_array.sv",
    "tinyNPU_top.sv",
)

A_CTRL = 0x004
A_M = 0x00C
A_N = 0x010
A_K = 0x014
A_IFM = 0x018
A_W = 0x01C
A_OFM = 0x020
A_BIAS = 0x024
A_FLAGS = 0x028
A_REQ_MULT = 0x02C
A_REQ_SHIFT = 0x030
A_REQ_MULT_BASE = 0x034
A_REQ_SHIFT_BASE = 0x038


@dataclass(frozen=True)
class GemmCase:
    name: str
    a: tuple[tuple[int, ...], ...]
    w: tuple[tuple[int, ...], ...]
    ifm_base: int
    w_base: int
    ofm_base: int
    flags: int = 0
    bias: tuple[int, ...] = ()
    bias_base: int = 0
    req_mult: int = 1
    req_shift: int = 0
    req_mults: tuple[int, ...] = ()
    req_shifts: tuple[int, ...] = ()
    req_mult_base: int = 0
    req_shift_base: int = 0

    @property
    def m(self) -> int:
        return len(self.a)

    @property
    def k(self) -> int:
        return len(self.a[0])

    @property
    def n(self) -> int:
        return len(self.w[0])


CASES_4X4 = (
    GemmCase(
        name="basic",
        a=((1, -2, 3, 4), (-5, 6, 2, -1), (7, 0, -3, 2)),
        w=((2, -1, 3, 1), (4, 2, -2, 0), (-1, 5, 1, -3), (3, -4, 2, 2)),
        ifm_base=0x00,
        w_base=0x20,
        ofm_base=0x40,
    ),
    GemmCase(
        name="global_req",
        a=((20, -30, 5, 7), (-8, 11, -4, 9)),
        w=((4, -2, 1, 3), (-1, 5, -3, 2), (6, 2, -4, -5), (3, -7, 8, 1)),
        ifm_base=0x10,
        w_base=0x28,
        ofm_base=0x50,
        flags=0b110,
        req_mult=3,
        req_shift=2,
    ),
    GemmCase(
        name="fused_tiled",
        a=(
            (1, -2, 3, 4, -1, 2, -3, 1),
            (-4, 5, 2, -1, 3, -2, 1, 4),
            (6, 0, -2, 3, -5, 1, 2, -1),
        ),
        w=(
            (2, -1, 1, 3, -2, 4, 1, 0),
            (1, 3, -2, 1, 2, -1, 0, 4),
            (-3, 2, 4, -1, 1, 2, -2, 3),
            (4, -2, 1, 2, 3, 0, 2, -1),
            (1, 2, -1, 3, -4, 1, 3, 2),
            (-2, 1, 3, 0, 2, -3, 1, 4),
            (3, -4, 2, 1, 0, 2, -1, 3),
            (2, 1, -3, 4, 1, -2, 4, 0),
        ),
        ifm_base=0x60,
        w_base=0x30,
        ofm_base=0xA0,
        flags=0b1111,
        bias=(-3, 5, -10, 2, 7, -4, 1, 9),
        bias_base=0x70,
        req_mults=(256, 192, 320, 128, 256, 384, 160, 256),
        req_shifts=(8, 8, 8, 7, 9, 9, 8, 8),
        req_mult_base=0x80,
        req_shift_base=0x90,
    ),
)


def _pattern_matrix(rows: int, cols: int, seed: int, amplitude: int) -> tuple[tuple[int, ...], ...]:
    span = 2 * amplitude + 1
    return tuple(
        tuple(((seed + row * 11 + col * 7 + row * col * 3) % span) - amplitude for col in range(cols))
        for row in range(rows)
    )


CASES_8X8 = (
    GemmCase(
        name="basic",
        a=_pattern_matrix(5, 8, 3, 5),
        w=_pattern_matrix(8, 8, 9, 5),
        ifm_base=0x00,
        w_base=0x20,
        ofm_base=0x60,
    ),
    GemmCase(
        name="global_req",
        a=_pattern_matrix(4, 8, 17, 15),
        w=_pattern_matrix(8, 8, 23, 12),
        ifm_base=0x10,
        w_base=0x24,
        ofm_base=0x70,
        flags=0b110,
        req_mult=1 << 18,
        req_shift=20,
    ),
    GemmCase(
        name="fused_tiled",
        a=_pattern_matrix(8, 16, 29, 7),
        w=_pattern_matrix(16, 16, 37, 7),
        ifm_base=0x00,
        w_base=0x20,
        ofm_base=0x80,
        flags=0b1111,
        bias=tuple(((index * 29 + 7) % 101) - 50 for index in range(16)),
        bias_base=0x30,
        req_mults=tuple(128 + (index % 5) * 32 for index in range(16)),
        req_shifts=tuple(8 + (index % 3) for index in range(16)),
        req_mult_base=0x40,
        req_shift_base=0x50,
    ),
)

CASES = CASES_4X4


def _run(cmd: list[str], *, cwd: Path, log: Path | None = None) -> None:
    print("+ " + " ".join(str(part) for part in cmd), flush=True)
    if log is None:
        subprocess.run(cmd, cwd=cwd, check=True)
        return
    with log.open("w", encoding="utf-8") as handle:
        handle.write("+ " + " ".join(str(part) for part in cmd) + "\n")
        handle.flush()
        subprocess.run(cmd, cwd=cwd, stdout=handle, stderr=subprocess.STDOUT, check=True)


def _pack(values: tuple[int, ...], width: int) -> int:
    result = 0
    mask = (1 << width) - 1
    for index, value in enumerate(values):
        result |= (value & mask) << (index * width)
    return result


def _ifm_words(case: GemmCase) -> list[tuple[int, int]]:
    words: list[tuple[int, int]] = []
    for tile in range(case.k // ROWS):
        for row, values in enumerate(case.a):
            words.append(
                (
                    case.ifm_base + tile * case.m + row,
                    _pack(values[tile * ROWS : tile * ROWS + ROWS], 8),
                )
            )
    return words


def _weight_words(case: GemmCase) -> list[tuple[int, int]]:
    words: list[tuple[int, int]] = []
    k_tiles = case.k // ROWS
    for n_tile in range(case.n // COLS):
        for k_tile in range(k_tiles):
            lanes = tuple(
                case.w[k_tile * ROWS + row][n_tile * COLS + col]
                for row in range(ROWS)
                for col in range(COLS)
            )
            words.append((case.w_base + n_tile * k_tiles + k_tile, _pack(lanes, 8)))
    if case.req_mults:
        for n_tile in range(case.n // COLS):
            mults = case.req_mults[n_tile * COLS : n_tile * COLS + COLS]
            shifts = case.req_shifts[n_tile * COLS : n_tile * COLS + COLS]
            words.append((case.req_mult_base + n_tile, _pack(mults, 32)))
            words.append((case.req_shift_base + n_tile, _pack(shifts, 32)))
    return words


def _bias_words(case: GemmCase) -> list[tuple[int, int]]:
    if not case.bias:
        return []
    return [
        (case.bias_base + tile, _pack(case.bias[tile * COLS : tile * COLS + COLS], 32))
        for tile in range(case.n // COLS)
    ]


def _requantize(value: int, mult: int, shift: int) -> int:
    round_bias = (1 << (shift - 1)) if shift else 0
    shifted = (value * mult + round_bias) >> shift
    return max(-128, min(127, shifted))


def _expected_matrix(case: GemmCase) -> list[list[int]]:
    result: list[list[int]] = []
    for row in range(case.m):
        output_row: list[int] = []
        for col in range(case.n):
            value = sum(case.a[row][index] * case.w[index][col] for index in range(case.k))
            if case.flags & 0b1:
                value += case.bias[col]
            if case.flags & 0b10:
                value = max(0, value)
            if case.flags & 0b100:
                if case.flags & 0b1000:
                    value = _requantize(value, case.req_mults[col], case.req_shifts[col])
                else:
                    value = _requantize(value, case.req_mult, case.req_shift)
            else:
                value &= 0xFF
                if value & 0x80:
                    value -= 0x100
            output_row.append(value)
        result.append(output_row)
    return result


def _expected_case_lines(case: GemmCase) -> list[str]:
    matrix = _expected_matrix(case)
    lines: list[str] = []
    data_digits = COLS * 2
    for tile in range(case.n // COLS):
        for row in range(case.m):
            word = _pack(tuple(matrix[row][tile * COLS : tile * COLS + COLS]), 8)
            addr = case.ofm_base + tile * case.m + row
            lines.append(f"WRITE case={case.name} addr={addr:02x} data={word:0{data_digits}x}")
    for tile in range(case.n // COLS):
        for row in range(case.m):
            word = _pack(tuple(matrix[row][tile * COLS : tile * COLS + COLS]), 8)
            addr = case.ofm_base + tile * case.m + row
            lines.append(f"READ case={case.name} addr={addr:02x} data={word:0{data_digits}x}")
    return lines


def _hex_digits(width: int) -> int:
    return max(1, (width + 3) // 4)


def _sc_uint_type(width: int) -> str:
    return f"sc_biguint<{width}>" if width > 64 else f"sc_uint<{width}>"


def _cpp_uint_value(value: int, width: int) -> str:
    digits = _hex_digits(width)
    return f'{_sc_uint_type(width)}("0x{value:0{digits}x}")'


def _sv_load_lines(case: GemmCase) -> str:
    ifm_width = ROWS * 8
    weight_width = ROWS * COLS * 8
    bias_width = COLS * 32
    lines = [
        f"    load_ifm(8'h{addr:02x},{ifm_width}'h{word:0{_hex_digits(ifm_width)}x});"
        for addr, word in _ifm_words(case)
    ]
    lines += [
        f"    load_w(8'h{addr:02x},{weight_width}'h{word:0{_hex_digits(weight_width)}x});"
        for addr, word in _weight_words(case)
    ]
    lines += [
        f"    load_bias(8'h{addr:02x},{bias_width}'h{word:0{_hex_digits(bias_width)}x});"
        for addr, word in _bias_words(case)
    ]
    return "\n".join(lines)


def _sv_case(case: GemmCase, index: int) -> str:
    reads = "\n".join(
        f"    read_ofm(8'h{case.ofm_base + tile * case.m + row:02x}, \"{case.name}\");"
        for tile in range(case.n // COLS)
        for row in range(case.m)
    )
    return f"""    active_case={index};
{_sv_load_lines(case)}
    configure(32'd{case.m},32'd{case.n},32'd{case.k},8'h{case.ifm_base:02x},8'h{case.w_base:02x},8'h{case.ofm_base:02x},
              32'h{case.flags:08x},32'h{case.req_mult & 0xFFFFFFFF:08x},32'd{case.req_shift},8'h{case.bias_base:02x},
              8'h{case.req_mult_base:02x},8'h{case.req_shift_base:02x});
    apb_write(12'h004,32'h1);
    wait_idle();
{reads}
"""


def _rtl_tb() -> str:
    cases = "\n".join(_sv_case(case, index + 1) for index, case in enumerate(CASES))
    ifm_width = ROWS * 8
    weight_width = ROWS * COLS * 8
    bias_width = COLS * 32
    ofm_width = COLS * 8
    data_digits = _hex_digits(ofm_width)
    return f"""`timescale 1ns/1ps
module tb;
  reg pclk=0,presetn=0,psel=0,penable=0,pwrite=0;
  reg [11:0] paddr=0; reg [31:0] pwdata=0; wire [31:0] prdata; wire pready,pslverr;
  reg bd_ifm_we=0; reg [7:0] bd_ifm_addr=0; reg [{ifm_width - 1}:0] bd_ifm_wdata=0;
  reg bd_w_we=0; reg [7:0] bd_w_addr=0; reg [{weight_width - 1}:0] bd_w_wdata=0;
  reg bd_bias_we=0; reg [7:0] bd_bias_addr=0; reg [{bias_width - 1}:0] bd_bias_wdata=0;
  reg bd_ofm_re=0; reg [7:0] bd_ofm_addr=0; wire [{ofm_width - 1}:0] bd_ofm_rdata;
  integer out,active_case=0,write_count=0,cycles=0,before_writes,saw_err,i;
  reg [31:0] rd; reg rd_err;
  {TOP_MODULE} dut(.*);
  always #5 pclk=~pclk;

  task tick; begin
    @(posedge pclk); #1; cycles=cycles+1;
    if(dut.top_ofm_we) begin
      write_count=write_count+1;
      case(active_case)
        1:$fdisplay(out,"WRITE case=basic addr=%02h data=%0{data_digits}h",dut.top_ofm_addr,dut.top_ofm_wdata);
        2:$fdisplay(out,"WRITE case=global_req addr=%02h data=%0{data_digits}h",dut.top_ofm_addr,dut.top_ofm_wdata);
        3:$fdisplay(out,"WRITE case=fused_tiled addr=%02h data=%0{data_digits}h",dut.top_ofm_addr,dut.top_ofm_wdata);
      endcase
    end
  end endtask
  task apb_write(input [11:0] addr,input [31:0] data); begin
    @(negedge pclk);psel=1;penable=0;pwrite=1;paddr=addr;pwdata=data;tick();
    @(negedge pclk);penable=1;tick();
    @(negedge pclk);psel=0;penable=0;pwrite=0;
  end endtask
  task apb_read(input [11:0] addr,output [31:0] data,output reg bus_err); begin
    @(negedge pclk);psel=1;penable=0;pwrite=0;paddr=addr;tick();
    @(negedge pclk);penable=1;tick();data=prdata;bus_err=pslverr;
    @(negedge pclk);psel=0;penable=0;
  end endtask
  task load_ifm(input [7:0] addr,input [{ifm_width - 1}:0] data); begin
    @(negedge pclk);bd_ifm_we=1;bd_ifm_addr=addr;bd_ifm_wdata=data;tick();
    @(negedge pclk);bd_ifm_we=0;
  end endtask
  task load_w(input [7:0] addr,input [{weight_width - 1}:0] data); begin
    @(negedge pclk);bd_w_we=1;bd_w_addr=addr;bd_w_wdata=data;tick();
    @(negedge pclk);bd_w_we=0;
  end endtask
  task load_bias(input [7:0] addr,input [{bias_width - 1}:0] data); begin
    @(negedge pclk);bd_bias_we=1;bd_bias_addr=addr;bd_bias_wdata=data;tick();
    @(negedge pclk);bd_bias_we=0;
  end endtask
  task read_ofm(input [7:0] addr,input [8*32-1:0] label); begin
    @(negedge pclk);bd_ofm_re=1;bd_ofm_addr=addr;tick();
    $fdisplay(out,"READ case=%0s addr=%02h data=%0{data_digits}h",label,addr,bd_ofm_rdata);
    @(negedge pclk);bd_ofm_re=0;
  end endtask
  task configure(input [31:0] m,n,k,input [7:0] ifm,w,ofm,input [31:0] flags,mult,shift,
                 input [7:0] bias,mult_base,shift_base); begin
    apb_write(12'h00c,m);apb_write(12'h010,n);apb_write(12'h014,k);
    apb_write(12'h018,ifm);apb_write(12'h01c,w);apb_write(12'h020,ofm);apb_write(12'h024,bias);
    apb_write(12'h028,flags);apb_write(12'h02c,mult);apb_write(12'h030,shift);
    apb_write(12'h034,mult_base);apb_write(12'h038,shift_base);
  end endtask
  task wait_idle; integer timeout,seen; begin
    timeout=0;seen=0;
    while(timeout<2000) begin
      tick();timeout=timeout+1;if(dut.u_dut.busy)seen=1;
      if(seen&&!dut.u_dut.busy) timeout=2000;
    end
    if(!seen||dut.u_dut.busy) begin $fdisplay(out,"TIMEOUT");$fatal;end
  end endtask

  initial begin
    out=$fopen("rtl_events.txt","w");
    repeat(4) tick();@(negedge pclk);presetn=1;tick();
    apb_read(12'h000,rd,rd_err);$fdisplay(out,"APB id=%08h err=%0d",rd,rd_err);
    apb_read(12'h3fc,rd,rd_err);$fdisplay(out,"APB invalid=%08h err=%0d",rd,rd_err);
{cases}
    active_case=0;before_writes=write_count;
  configure(0,{COLS},{ROWS},0,0,0,0,1,0,0,0,0);apb_write(12'h004,1);
    saw_err=0;for(i=0;i<12;i=i+1)begin tick();if(dut.u_dut.err)saw_err=1;end
    $fdisplay(out,"ZERO err=%0d busy=%0d writes=%0d",saw_err,dut.u_dut.busy,write_count-before_writes);
    $fclose(out);$finish;
  end
endmodule
"""


def _cpp_load_lines(case: GemmCase) -> str:
    ifm_width = ROWS * 8
    weight_width = ROWS * COLS * 8
    bias_width = COLS * 32
    lines = [
        f"  load_ifm(0x{addr:02x},{_cpp_uint_value(word, ifm_width)});"
        for addr, word in _ifm_words(case)
    ]
    lines += [
        f"  load_w(0x{addr:02x},{_cpp_uint_value(word, weight_width)});"
        for addr, word in _weight_words(case)
    ]
    lines += [
        f"  load_bias(0x{addr:02x},{_cpp_uint_value(word, bias_width)});"
        for addr, word in _bias_words(case)
    ]
    return "\n".join(lines)


def _cpp_case(case: GemmCase, index: int) -> str:
    reads = "\n".join(
        f'  read_ofm(0x{case.ofm_base + tile * case.m + row:02x},"{case.name}");'
        for tile in range(case.n // COLS)
        for row in range(case.m)
    )
    return f"""  active_case={index};
{_cpp_load_lines(case)}
  configure({case.m},{case.n},{case.k},0x{case.ifm_base:02x},0x{case.w_base:02x},0x{case.ofm_base:02x},
            0x{case.flags:08x}u,0x{case.req_mult & 0xFFFFFFFF:08x}u,{case.req_shift},0x{case.bias_base:02x},
            0x{case.req_mult_base:02x},0x{case.req_shift_base:02x});
  apb_write(0x004,1);if(!wait_idle())return 2;
{reads}
"""


def _systemc_tb() -> str:
    cases = "\n".join(_cpp_case(case, index + 1) for index, case in enumerate(CASES))
    ifm_width = ROWS * 8
    weight_width = ROWS * COLS * 8
    bias_width = COLS * 32
    ofm_width = COLS * 8
    data_digits = _hex_digits(ofm_width)
    return f"""#include <cstdint>
#include <fstream>
#include <iomanip>
#include <systemc>
#include "{TOP_MODULE}.hpp"
using namespace sc_core;using namespace sc_dt;
int sc_main(int,char**){{
  sc_signal<bool> pclk,presetn,psel,penable,pwrite,pready,pslverr;
  sc_signal<sc_uint<12>> paddr;sc_signal<sc_uint<32>> pwdata,prdata;
  sc_signal<bool> bd_ifm_we,bd_w_we,bd_bias_we,bd_ofm_re;
  sc_signal<sc_uint<8>> bd_ifm_addr,bd_w_addr,bd_bias_addr,bd_ofm_addr;
  sc_signal<{_sc_uint_type(ifm_width)}> bd_ifm_wdata;
  sc_signal<{_sc_uint_type(weight_width)}> bd_w_wdata;
  sc_signal<{_sc_uint_type(bias_width)}> bd_bias_wdata;
  sc_signal<{_sc_uint_type(ofm_width)}> bd_ofm_rdata;
  {TOP_MODULE}<> dut("dut");
#define BIND(x) dut.x(x)
  BIND(pclk);BIND(presetn);BIND(psel);BIND(penable);BIND(pwrite);BIND(paddr);BIND(pwdata);
  BIND(prdata);BIND(pready);BIND(pslverr);BIND(bd_ifm_we);BIND(bd_ifm_addr);BIND(bd_ifm_wdata);
  BIND(bd_w_we);BIND(bd_w_addr);BIND(bd_w_wdata);BIND(bd_bias_we);BIND(bd_bias_addr);
  BIND(bd_bias_wdata);BIND(bd_ofm_re);BIND(bd_ofm_addr);BIND(bd_ofm_rdata);
#undef BIND
  std::ofstream out("sc_events.txt");int active_case=0,write_count=0,cycles=0;
  const char* case_names[]={{"none","basic","global_req","fused_tiled"}};
  auto tick=[&](){{
    sc_start(1,SC_PS);
    pclk.write(true);sc_start(1,SC_NS);++cycles;
    if(dut.top_ofm_we.read()){{
      ++write_count;out<<"WRITE case="<<case_names[active_case]<<" addr="<<std::hex<<std::setw(2)
        <<std::setfill('0')<<dut.top_ofm_addr.read().to_uint()<<" data="<<std::setw({data_digits})
        <<dut.top_ofm_wdata.read().to_uint64()<<std::dec<<"\\n";
    }}
    sc_start(4,SC_NS);pclk.write(false);sc_start(5,SC_NS);
  }};
  auto apb_write=[&](uint32_t addr,uint32_t data){{
    psel.write(1);penable.write(0);pwrite.write(1);paddr.write(addr);pwdata.write(data);tick();
    penable.write(1);tick();psel.write(0);penable.write(0);pwrite.write(0);
  }};
  auto apb_read=[&](uint32_t addr){{
    psel.write(1);penable.write(0);pwrite.write(0);paddr.write(addr);tick();penable.write(1);tick();
    uint64_t value=prdata.read().to_uint64();bool error=pslverr.read();psel.write(0);penable.write(0);
    return std::make_pair(value,error);
  }};
  auto load_ifm=[&](uint32_t addr,const {_sc_uint_type(ifm_width)}& data){{bd_ifm_we.write(1);bd_ifm_addr.write(addr);bd_ifm_wdata.write(data);tick();bd_ifm_we.write(0);}};
  auto load_w=[&](uint32_t addr,const {_sc_uint_type(weight_width)}& data){{bd_w_we.write(1);bd_w_addr.write(addr);bd_w_wdata.write(data);tick();bd_w_we.write(0);}};
  auto load_bias=[&](uint32_t addr,const {_sc_uint_type(bias_width)}& data){{bd_bias_we.write(1);bd_bias_addr.write(addr);bd_bias_wdata.write(data);tick();bd_bias_we.write(0);}};
  auto read_ofm=[&](uint32_t addr,const char* name){{
    bd_ofm_re.write(1);bd_ofm_addr.write(addr);tick();
    out<<"READ case="<<name<<" addr="<<std::hex<<std::setw(2)<<std::setfill('0')<<addr
      <<" data="<<std::setw({data_digits})<<bd_ofm_rdata.read().to_uint64()<<std::dec<<"\\n";bd_ofm_re.write(0);
  }};
  auto configure=[&](uint32_t m,uint32_t n,uint32_t k,uint32_t ifm,uint32_t w,uint32_t ofm,
                     uint32_t flags,uint32_t mult,uint32_t shift,uint32_t bias,uint32_t mult_base,uint32_t shift_base){{
    apb_write(0x00c,m);apb_write(0x010,n);apb_write(0x014,k);apb_write(0x018,ifm);
    apb_write(0x01c,w);apb_write(0x020,ofm);apb_write(0x024,bias);apb_write(0x028,flags);
    apb_write(0x02c,mult);apb_write(0x030,shift);apb_write(0x034,mult_base);apb_write(0x038,shift_base);
  }};
  auto wait_idle=[&](){{
    bool seen=false;for(int timeout=0;timeout<2000;++timeout){{tick();seen=seen||dut.u_dut.busy.read();if(seen&&!dut.u_dut.busy.read())return true;}}
    out<<"TIMEOUT\\n";return false;
  }};
  pclk.write(0);presetn.write(0);psel.write(0);penable.write(0);pwrite.write(0);
  bd_ifm_we.write(0);bd_w_we.write(0);bd_bias_we.write(0);bd_ofm_re.write(0);sc_start(SC_ZERO_TIME);
  for(int i=0;i<4;++i)tick();presetn.write(1);tick();
  auto id=apb_read(0x000);out<<"APB id="<<std::hex<<std::setw(8)<<std::setfill('0')<<id.first<<std::dec<<" err="<<id.second<<"\\n";
  auto invalid=apb_read(0x3fc);out<<"APB invalid="<<std::hex<<std::setw(8)<<std::setfill('0')<<invalid.first<<std::dec<<" err="<<invalid.second<<"\\n";
{cases}
  active_case=0;int before_writes=write_count;
  configure(0,{COLS},{ROWS},0,0,0,0,1,0,0,0,0);apb_write(0x004,1);
  bool saw_err=false;for(int i=0;i<12;++i){{tick();saw_err=saw_err||dut.u_dut.err.read();}}
  out<<"ZERO err="<<saw_err<<" busy="<<dut.u_dut.busy.read()<<" writes="<<(write_count-before_writes)<<"\\n";
  return 0;
}}
"""


def _normalized_lines(path: Path) -> list[str]:
    return [line.strip().lower() for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def _expected_lines() -> list[str]:
    lines = ["apb id=4e505500 err=0", "apb invalid=00000000 err=1"]
    for case in CASES:
        lines.extend(_expected_case_lines(case))
    lines.append("zero err=1 busy=0 writes=0")
    return [line.lower() for line in lines]


def main() -> int:
    global ROWS, COLS, TOP_MODULE, CASES

    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    parser.add_argument("--out", type=Path)
    parser.add_argument("--array-size", type=int, choices=(4, 8), default=4)
    parser.add_argument("--systemc-include", type=Path, default=DEFAULT_SYSTEMC_INCLUDE)
    parser.add_argument("--systemc-lib", type=Path, default=DEFAULT_SYSTEMC_LIB)
    args = parser.parse_args()

    ROWS = COLS = args.array_size
    if args.array_size == 8:
        TOP_MODULE = "top_harness_8x8"
        CASES = CASES_8X8
        harness_rel = Path("tb/test_top_8x8/top_harness_8x8.sv")
        out = args.out or Path("/tmp/prism_tinynpu_8x8_consistency")
    else:
        TOP_MODULE = "top_harness"
        CASES = CASES_4X4
        harness_rel = Path("tb/test_top/top_harness.sv")
        out = args.out or DEFAULT_OUT

    rtl_root = args.root / "rtl"
    harness = args.root / harness_rel
    sources = [rtl_root / name for name in RTL_NAMES] + [harness]
    missing = [path for path in sources if not path.exists()]
    if missing:
        raise FileNotFoundError("missing tinyNPU sources: " + ", ".join(str(path) for path in missing))

    shutil.rmtree(out, ignore_errors=True)
    out.mkdir(parents=True)
    systemc_out = out / "systemc"
    convert = [
        sys.executable,
        "-m",
        "prism_v2sc",
        "--top",
        TOP_MODULE,
        "--out",
        str(systemc_out),
        "--metrics",
        "--fail-on-diagnostics",
        *(str(path) for path in sources),
    ]
    _run(convert, cwd=Path.cwd(), log=out / "convert.log")

    ir = json.loads((systemc_out / "ir.json").read_text(encoding="utf-8"))
    errors = [item for item in ir.get("diagnostics", []) if item.get("severity") == "error"]
    if errors:
        raise AssertionError(f"tinyNPU conversion emitted errors: {errors}")
    top_header = systemc_out / harness_rel.with_suffix(".hpp")
    issues = check_generated_systemc(top_header.read_text(encoding="utf-8"))
    if issues:
        raise AssertionError(f"generated tinyNPU top failed static checks: {issues}")

    rtl_tb = out / "tb_rtl.sv"
    rtl_tb.write_text(_rtl_tb(), encoding="utf-8")
    sc_tb = out / "tb_systemc.cpp"
    sc_tb.write_text(_systemc_tb(), encoding="utf-8")

    _run(
        ["vcs", "-full64", "-sverilog", "-timescale=1ns/1ps", "-o", "rtl_simv", str(rtl_tb), *(str(path) for path in sources)],
        cwd=out,
        log=out / "vcs_compile.log",
    )
    _run([str(out / "rtl_simv")], cwd=out, log=out / "rtl_run.log")
    _run(
        [
            "g++",
            "-std=c++14",
            f"-I{args.systemc_include}",
            f"-I{top_header.parent}",
            str(sc_tb),
            f"-L{args.systemc_lib}",
            f"-Wl,-rpath,{args.systemc_lib}",
            "-lsystemc",
            "-pthread",
            "-o",
            str(out / "sc_sim"),
        ],
        cwd=out,
        log=out / "sc_compile.log",
    )
    _run([str(out / "sc_sim")], cwd=out, log=out / "sc_run.log")

    rtl_lines = _normalized_lines(out / "rtl_events.txt")
    sc_lines = _normalized_lines(out / "sc_events.txt")
    expected = _expected_lines()
    if rtl_lines != expected:
        raise AssertionError(f"RTL trace differs from independent golden\nRTL={rtl_lines}\nEXP={expected}")
    if sc_lines != expected:
        raise AssertionError(f"SystemC trace differs from independent golden\nSC={sc_lines}\nEXP={expected}")
    if rtl_lines != sc_lines:
        raise AssertionError("tinyNPU RTL and SystemC event traces differ")

    metrics = json.loads((systemc_out / "metrics.json").read_text(encoding="utf-8"))
    print(
        "tinyNPU consistency passed: "
        f"{ROWS}x{COLS}, {len(CASES)} GEMM case(s), "
        f"{sum(case.m * (case.n // COLS) for case in CASES)} OFM words, "
        f"{metrics.get('module_count')} modules, {len(rtl_lines)} events, {out}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
