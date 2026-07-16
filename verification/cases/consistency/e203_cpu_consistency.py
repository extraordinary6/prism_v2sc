#!/usr/bin/env python3
"""Key-event consistency test for the E203 CPU top.

The external RTL is read-only. A short RV32 program is placed directly in
the RTL simulation memory and the provider-backed SystemC memory. The test
compares ordered committed-PC events and the final DTCM store result; exact
per-cycle alignment is intentionally not required.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

from prism_v2sc.frontend.preprocess import parse_filelist


ROOT = Path(__file__).resolve().parents[3]
DEFAULT_OUT = Path("/tmp/prism_e203_cpu_consistency")
FILELIST = ROOT / "verification/cases/e203/e203_core.f"
MANIFEST = ROOT / "verification/cases/e203/e203_models.json"
SYSTEMC_INCLUDE = Path("/usr/local/systemc-2.3.4/include")
SYSTEMC_LIB = Path("/usr/local/systemc-2.3.4/lib64")

RESET_PC = 0x80000000


def r_type(rd: int, rs1: int, rs2: int, funct3: int, funct7: int = 0) -> int:
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | 0x33


def i_type(rd: int, rs1: int, imm: int, funct3: int, opcode: int = 0x13) -> int:
    return ((imm & 0xFFF) << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode


def s_type(rs2: int, rs1: int, imm: int, funct3: int) -> int:
    value = imm & 0xFFF
    return ((value >> 5) << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | ((value & 0x1F) << 7) | 0x23


def b_type(rs1: int, rs2: int, offset: int, funct3: int) -> int:
    value = offset & 0x1FFF
    return (
        (((value >> 12) & 1) << 31)
        | (((value >> 5) & 0x3F) << 25)
        | (rs2 << 20)
        | (rs1 << 15)
        | (funct3 << 12)
        | (((value >> 1) & 0xF) << 8)
        | (((value >> 11) & 1) << 7)
        | 0x63
    )


def jal(rd: int, offset: int) -> int:
    value = offset & 0x1FFFFF
    return (
        (((value >> 20) & 1) << 31)
        | (((value >> 1) & 0x3FF) << 21)
        | (((value >> 11) & 1) << 20)
        | (((value >> 12) & 0xFF) << 12)
        | (rd << 7)
        | 0x6F
    )


def lui(rd: int, upper: int) -> int:
    return ((upper & 0xFFFFF) << 12) | (rd << 7) | 0x37


def csr(rd: int, rs1: int, address: int, funct3: int) -> int:
    return (address << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | 0x73


@dataclass(frozen=True)
class Scenario:
    name: str
    program: tuple[int, ...]
    expected_words: tuple[tuple[int, int], ...]
    key_pcs: tuple[int, ...]


def scenario(name: str, program: tuple[int, ...], expected_words: tuple[tuple[int, int], ...]) -> Scenario:
    return Scenario(
        name=name,
        program=program,
        expected_words=expected_words,
        key_pcs=(RESET_PC, RESET_PC + (len(program) - 1) * 4),
    )


SCENARIOS = (
    scenario(
        "baseline",
        (
            i_type(1, 0, 5, 0),
            i_type(2, 0, 7, 0),
            r_type(3, 1, 2, 0),
            lui(4, 0x90000),
            s_type(3, 4, 0, 2),
            i_type(5, 4, 0, 2, 0x03),
            b_type(5, 3, 8, 0),
            i_type(6, 0, 1, 0),
            jal(0, 0),
        ),
        ((0, 0x0000000C),),
    ),
    scenario(
        "alu_branch",
        (
            i_type(1, 0, -8, 0),
            i_type(2, 0, 3, 0),
            r_type(3, 1, 2, 5, 0x20),
            r_type(4, 1, 2, 5),
            r_type(5, 1, 2, 2),
            r_type(6, 1, 2, 3),
            r_type(7, 3, 4, 4),
            r_type(7, 7, 5, 6),
            b_type(5, 6, 8, 0),
            i_type(7, 7, 2, 0),
            b_type(5, 6, 8, 1),
            i_type(7, 0, 0, 0),
            lui(8, 0x90000),
            s_type(7, 8, 4, 2),
            jal(0, 0),
        ),
        ((1, 0xE0000003),),
    ),
    scenario(
        "muldiv_bytes",
        (
            i_type(1, 0, 100, 0),
            i_type(2, 0, 7, 0),
            r_type(3, 1, 2, 0, 1),
            r_type(4, 3, 2, 4, 1),
            r_type(5, 3, 2, 6, 1),
            r_type(6, 4, 2, 0, 0x20),
            lui(8, 0x90000),
            s_type(3, 8, 8, 2),
            s_type(6, 8, 9, 0),
            s_type(4, 8, 10, 1),
            i_type(9, 8, 8, 2, 0x03),
            i_type(10, 8, 9, 4, 0x03),
            i_type(11, 8, 10, 5, 0x03),
            r_type(12, 10, 11, 0),
            s_type(12, 8, 12, 2),
            jal(0, 0),
        ),
        ((2, 0x00645DBC), (3, 0x000000C1)),
    ),
    scenario(
        "signed_divzero",
        (
            i_type(1, 0, -20, 0),
            i_type(2, 0, 3, 0),
            r_type(3, 1, 2, 4, 1),
            r_type(4, 1, 2, 6, 1),
            i_type(6, 0, 0, 0),
            r_type(7, 1, 6, 4, 1),
            r_type(9, 1, 6, 6, 1),
            lui(8, 0x90000),
            s_type(3, 8, 16, 2),
            s_type(4, 8, 20, 2),
            s_type(7, 8, 24, 2),
            s_type(9, 8, 28, 2),
            jal(0, 0),
        ),
        ((4, 0xFFFFFFFA), (5, 0xFFFFFFFE), (6, 0xFFFFFFFF), (7, 0xFFFFFFEC)),
    ),
    scenario(
        "csr",
        (
            i_type(1, 0, 0x5A, 0),
            csr(2, 1, 0x340, 1),
            csr(3, 0, 0x340, 2),
            lui(8, 0x90000),
            s_type(3, 8, 32, 2),
            jal(0, 0),
        ),
        ((8, 0x0000005A),),
    ),
    scenario(
        "timer_irq",
        (
            lui(1, 0x80000),
            i_type(1, 1, 0x80, 0),
            csr(0, 1, 0x305, 1),
            i_type(2, 0, 0x80, 0),
            csr(0, 2, 0x304, 2),
            i_type(3, 0, 8, 0),
            csr(0, 3, 0x300, 2),
            i_type(4, 4, 1, 0),
            jal(0, -4),
        )
        + (i_type(0, 0, 0, 0),) * 23
        + (
            lui(8, 0x90000),
            i_type(5, 0, 0x66, 0),
            s_type(5, 8, 36, 2),
            jal(0, 0),
        ),
        ((9, 0x00000066),),
    ),
)


def run(cmd: list[str], cwd: Path, log: Path, env: dict[str, str] | None = None) -> None:
    print("+ " + " ".join(cmd), flush=True)
    with log.open("w", encoding="utf-8") as handle:
        subprocess.run(cmd, cwd=cwd, env=env, stdout=handle, stderr=subprocess.STDOUT, check=True)


def width(port: dict[str, object]) -> int:
    spec = port.get("width")
    if not isinstance(spec, dict):
        return 1
    try:
        return abs(int(spec["msb"]) - int(spec["lsb"])) + 1
    except (KeyError, TypeError, ValueError):
        raise RuntimeError(f"non-concrete E203 top port width: {port}")


def rtl_tb(ports: list[dict[str, object]]) -> str:
    declarations: list[str] = []
    for port in ports:
        name = str(port["name"])
        bits = width(port)
        packed = "" if bits == 1 else f" [{bits - 1}:0]"
        if port["direction"] == "input":
            initial = " = 0" if name not in {"clk", "rst_n"} else " = 0"
            declarations.append(f"  reg{packed} {name}{initial};")
        else:
            declarations.append(f"  wire{packed} {name};")
    ready_inputs = [
        str(port["name"])
        for port in ports
        if port["direction"] == "input" and "ready" in str(port["name"])
    ]
    ready_init = "\n".join(f"    {name}=1;" for name in ready_inputs)
    preload_blocks: list[str] = []
    result_blocks: list[str] = []
    for index, test in enumerate(SCENARIOS):
        keyword = "if" if index == 0 else "else if"
        words: list[str] = []
        for word_index in range(0, len(test.program), 2):
            low = test.program[word_index]
            high = test.program[word_index + 1] if word_index + 1 < len(test.program) else 0x00000013
            words.append(
                "      dut.u_e203_srams.u_e203_itcm_ram.u_e203_itcm_gnrl_ram."
                f"u_sirv_sim_ram.mem_r[{word_index // 2}] = 64'h{high:08x}{low:08x};"
            )
        preload_blocks.append(
            f'    {keyword} (scenario_name == "{test.name}") begin\n'
            + "\n".join(words)
            + "\n    end"
        )
        displays = [
            "        $display(\"DTCM %08x %08x\", "
            f"32'h{word_index * 4:08x}, "
            "dut.u_e203_srams.u_e203_dtcm_ram.u_e203_dtcm_gnrl_ram."
            f"u_sirv_sim_ram.mem_r[{word_index}]);"
            for word_index, _expected in test.expected_words
        ]
        result_blocks.append(
            f'      {keyword} (scenario_name == "{test.name}") begin\n'
            + "\n".join(displays)
            + "\n      end"
        )
    preload = "\n".join(preload_blocks)
    results = "\n".join(result_blocks)
    return f"""module tb;
{chr(10).join(declarations)}
  integer cycles=0; reg [31:0] last_pc=32'hffffffff;
  reg [8*32-1:0] scenario_name;
  e203_cpu_top dut(.*);
  always #5 clk=~clk;
  always @(posedge clk) begin
    if(rst_n) begin
      cycles=cycles+1;
      if(scenario_name == "timer_irq" && cycles == 20) tmr_irq_a=1;
      if(inspect_pc !== last_pc && inspect_pc >= 32'h80000000 && inspect_pc < 32'h80000100) begin
        $display("PC %08x",inspect_pc); last_pc=inspect_pc;
      end
      if(cycles==1200) begin
{results}
        $finish;
      end
    end
  end
  initial begin
    if (!$value$plusargs("SCENARIO=%s", scenario_name)) scenario_name="baseline";
    pc_rtvec=32'h80000000; ext2itcm_icb_rsp_ready=1; ext2dtcm_icb_rsp_ready=1;
{ready_init}
{preload}
    #40 rst_n=1;
  end
endmodule
"""


def sc_type(bits: int, explicit_vector: bool) -> str:
    if bits == 1 and not explicit_vector:
        return "bool"
    return f"sc_uint<{bits}>" if bits <= 64 else f"sc_biguint<{bits}>"


def systemc_tb(ports: list[dict[str, object]]) -> str:
    declarations: list[str] = []
    bindings: list[str] = []
    inputs: list[str] = []
    for port in ports:
        name = str(port["name"])
        if name == "clk":
            bindings.append("  dut.clk(clk);")
            continue
        bits = width(port)
        declarations.append(
            f"  sc_signal<{sc_type(bits, port.get('width') is not None)}> {name};"
        )
        bindings.append(f"  dut.{name}({name});")
        if port["direction"] == "input" and name != "rst_n":
            value = "true" if "ready" in name else "false" if bits == 1 else "0"
            inputs.append(f"  {name}.write({value});")
    preload_blocks: list[str] = []
    result_blocks: list[str] = []
    for index, test in enumerate(SCENARIOS):
        keyword = "if" if index == 0 else "else if"
        words: list[str] = []
        for word_index in range(0, len(test.program), 2):
            low = test.program[word_index]
            high = test.program[word_index + 1] if word_index + 1 < len(test.program) else 0x00000013
            words.append(
                "    dut.u_e203_srams.u_e203_itcm_ram.u_e203_itcm_gnrl_ram."
                f"u_sirv_sim_ram.__model_mem[{word_index // 2}] = 0x{high:08x}{low:08x}ULL;"
            )
        preload_blocks.append(
            f'  {keyword} (scenario_name == "{test.name}") {{\n'
            + "\n".join(words)
            + "\n  }"
        )
        displays = [
            "    std::cout << \"DTCM "
            f"{word_index * 4:08x} \" << std::hex << std::setw(8) << std::setfill('0') << "
            "dut.u_e203_srams.u_e203_dtcm_ram.u_e203_dtcm_gnrl_ram."
            f"u_sirv_sim_ram.__model_mem[{word_index}].to_uint() << \"\\n\";"
            for word_index, _expected in test.expected_words
        ]
        result_blocks.append(
            f'  {keyword} (scenario_name == "{test.name}") {{\n'
            + "\n".join(displays)
            + "\n  }"
        )
    return f"""#include <iomanip>
#include <iostream>
#include <string>
#include <systemc>
#include "e203_cpu_top.hpp"
using namespace sc_core; using namespace sc_dt;
int sc_main(int argc,char** argv) {{
  std::string scenario_name = argc > 1 ? argv[1] : "baseline";
  sc_clock clk("clk",10,SC_NS,0.5,0,SC_NS,false);
{chr(10).join(declarations)}
  e203_cpu_top dut("dut");
{chr(10).join(bindings)}
{chr(10).join(inputs)}
  pc_rtvec.write(0x80000000u); rst_n.write(false);
{chr(10).join(preload_blocks)}
  uint32_t last_pc=0xffffffffu; int cycles=0; bool old_clk=false;
  while(cycles<1200) {{
    sc_start(1,SC_NS); bool now=clk.read();
    if(now&&!old_clk) {{
      if(sc_time_stamp()>=sc_time(40,SC_NS) && !rst_n.read()) rst_n.write(true);
      if(rst_n.read()) {{
        ++cycles;
        if(scenario_name == "timer_irq" && cycles == 20) tmr_irq_a.write(true);
        uint32_t pc=inspect_pc.read().to_uint();
        if(pc!=last_pc && pc>=0x80000000u && pc<0x80000100u) {{
          std::cout<<"PC "<<std::hex<<std::setw(8)<<std::setfill('0')<<pc<<"\\n"; last_pc=pc;
        }}
      }}
    }}
    old_clk=now;
  }}
{chr(10).join(result_blocks)}
  return 0;
}}
"""


def events(path: Path) -> tuple[list[str], dict[int, int]]:
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    pcs = [line.strip() for line in lines if line.startswith("PC ")]
    dtcm: dict[int, int] = {}
    for line in lines:
        match = re.fullmatch(r"DTCM ([0-9a-fA-F]{8}) ([0-9a-fA-F]{8})", line.strip())
        if match:
            dtcm[int(match.group(1), 16) // 4] = int(match.group(2), 16)
    return pcs, dtcm


def ordered_unique(values: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for value in values:
        if value not in seen:
            seen.add(value)
            result.append(value)
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)
    sc_out = out / "systemc"
    run(
        [sys.executable, "-m", "prism_v2sc", "--top", "e203_cpu_top", "--filelist", str(FILELIST), "--model-manifest", str(MANIFEST), "--fail-on-diagnostics", "--out", str(sc_out)],
        ROOT,
        out / "convert.log",
    )
    design = json.loads((sc_out / "ir.json").read_text(encoding="utf-8"))
    ports = next(module["ports"] for module in design["modules"] if module["name"] == "e203_cpu_top")
    (out / "tb_rtl.sv").write_text(rtl_tb(ports), encoding="utf-8")
    (out / "tb_systemc.cpp").write_text(systemc_tb(ports), encoding="utf-8")

    sources = parse_filelist(FILELIST)
    vcs_env = os.environ.copy()
    vcs_cmd = [
        "vcs",
        "+v2k",
        "-sverilog",
        "-full64",
        "-q",
        "+define+SYNTHESIS",
        "+define+DISABLE_SV_ASSERTION",
    ]
    vcs_cmd += [f"+incdir+{path}" for path in sources.include_dirs]
    vcs_cmd += [str(path) for path in sources.sources] + [str(out / "tb_rtl.sv"), "-o", "simv"]
    run(vcs_cmd, out, out / "vcs_compile.log", vcs_env)

    include_dirs = sorted({str(path.parent) for path in sc_out.rglob("*.hpp")})
    sc_cmd = ["g++", "-std=c++14", f"-I{SYSTEMC_INCLUDE}"]
    sc_cmd += [f"-I{path}" for path in include_dirs]
    sc_cmd += [str(out / "tb_systemc.cpp"), f"-L{SYSTEMC_LIB}", f"-Wl,-rpath,{SYSTEMC_LIB}", "-lsystemc", "-pthread", "-o", "sc_sim"]
    run(sc_cmd, out, out / "sc_compile.log")

    summaries: list[str] = []
    for test in SCENARIOS:
        rtl_log = out / f"rtl_{test.name}.log"
        sc_log = out / f"systemc_{test.name}.log"
        run([str(out / "simv"), f"+SCENARIO={test.name}"], out, rtl_log, vcs_env)
        run([str(out / "sc_sim"), test.name], out, sc_log)

        rtl_pcs, rtl_dtcm = events(rtl_log)
        sc_pcs, sc_dtcm = events(sc_log)
        required = {f"PC {pc:08x}" for pc in test.key_pcs}
        if not required.issubset(set(rtl_pcs)) or not required.issubset(set(sc_pcs)):
            raise RuntimeError(
                f"{test.name}: required PC events missing: rtl={rtl_pcs}, systemc={sc_pcs}"
            )
        expected_words = dict(test.expected_words)
        rtl_observed = {index: rtl_dtcm.get(index) for index in expected_words}
        sc_observed = {index: sc_dtcm.get(index) for index in expected_words}
        if rtl_observed != expected_words or sc_observed != expected_words:
            raise RuntimeError(
                f"{test.name}: DTCM mismatch: expected={expected_words}, "
                f"rtl={rtl_observed}, systemc={sc_observed}"
            )
        rtl_unique = ordered_unique(rtl_pcs)
        sc_unique = ordered_unique(sc_pcs)
        common_rtl = [pc for pc in rtl_unique if pc in set(sc_unique)]
        common_sc = [pc for pc in sc_unique if pc in set(rtl_unique)]
        if common_rtl != common_sc:
            raise RuntimeError(
                f"{test.name}: ordered PC event mismatch: rtl={common_rtl}, systemc={common_sc}"
            )
        summaries.append(
            f"{test.name}(rtl_pc={len(rtl_pcs)},sc_pc={len(sc_pcs)},words={len(expected_words)})"
        )
    print("E203 consistency passed: " + ", ".join(summaries))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
