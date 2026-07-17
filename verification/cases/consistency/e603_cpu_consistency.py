#!/usr/bin/env python3
"""Bounded E603 RTL/SystemC key-event consistency harness."""

from __future__ import annotations

import argparse
import hashlib
import pickle
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

from prism_v2sc.codegen.expr import build_module_context
from prism_v2sc.frontend.preprocess import parse_filelist
from prism_v2sc.systemc_build import SystemCBuildError, SystemCBuildOptions, build_systemc


ROOT = Path(__file__).resolve().parents[3]
CASE_DIR = ROOT / "examples/e603_cpu"
GENERATED = ROOT / "build/e603_cpu_consistency/generated"
WORK = ROOT / "build/e603_cpu_consistency/work"
FILELIST = CASE_DIR / "sources.f"
MODEL_MANIFEST = CASE_DIR / "models.json"
SYSTEMC_INCLUDE = Path("/usr/local/systemc-2.3.4/include")
SYSTEMC_LIB = Path("/usr/local/systemc-2.3.4/lib64")
TOP = "e603_core_rams"
TRACE_FIELDS = (
    "mem_arvalid",
    "mem_araddr",
    "mem_arlen",
    "mem_arid",
    "mem_rready",
    "i0_trace_cmt_ena",
    "i0_trace_iaddr",
    "i0_trace_instr",
    "sysrstreq",
)
DEBUG_TRACE_FIELDS = (
    "dbg_core_clk",
    "dbg_rst_core",
    "dbg_hart_under_reset",
)


def write_if_changed(path: Path, content: str) -> None:
    if path.is_file() and path.read_text(encoding="utf-8") == content:
        return
    path.write_text(content, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cycles", type=int, default=96)
    parser.add_argument("--reset-cycles", type=int, default=8)
    parser.add_argument("--skip-rtl", action="store_true")
    parser.add_argument("--skip-systemc", action="store_true")
    parser.add_argument("--skip-convert", action="store_true")
    parser.add_argument("--sc-build-mode", choices=("legacy", "optimized"), default="optimized")
    parser.add_argument("--sc-build-jobs", type=int, default=2)
    args = parser.parse_args()

    WORK.mkdir(parents=True, exist_ok=True)
    GENERATED.mkdir(parents=True, exist_ok=True)
    if not args.skip_convert:
        run_bounded(
            [
                sys.executable,
                "-m",
                "prism_v2sc",
                "--top",
                TOP,
                "--filelist",
                str(FILELIST),
                "--model-manifest",
                str(MODEL_MANIFEST),
                "--compile-friendly",
                "--incremental-codegen",
                "--no-ir",
                "--out",
                str(GENERATED),
            ],
            address_space=1879048192,
            timeout_seconds=300,
            log=WORK / "convert.log",
        )
    top, widths = load_top()
    rtl_trace = WORK / "rtl_trace.csv"
    sc_trace = WORK / "systemc_trace.csv"

    if not args.skip_rtl:
        rtl_tb = WORK / "tb_e603_consistency.sv"
        write_if_changed(rtl_tb, render_rtl_tb(top, widths, args.cycles, args.reset_cycles))
        run_rtl(rtl_tb)
    if not args.skip_systemc:
        sc_tb = WORK / "tb_e603_consistency.cpp"
        context = WORK / "e603_context.hpp"
        context_text = render_systemc_context(top, widths)
        binding_sources, binding_declarations = render_systemc_bindings(top)
        write_if_changed(context, context_text + "\n" + binding_declarations + "\n")
        model = WORK / "tb_e603_model.cpp"
        write_if_changed(model, render_systemc_model())
        binding_paths = []
        for file_name, source in binding_sources:
            path = WORK / file_name
            write_if_changed(path, source)
            binding_paths.append(path)
        write_if_changed(sc_tb, render_systemc_tb(top, widths, args.cycles, args.reset_cycles))
        run_systemc(
            sc_tb,
            extra_sources=(model, *binding_paths),
            build_mode=args.sc_build_mode,
            build_jobs=max(1, args.sc_build_jobs),
        )

    if not args.skip_rtl and not args.skip_systemc:
        compare_traces(rtl_trace, sc_trace)
    return 0


def load_top():
    cache_path = GENERATED / ".prism_frontend_cache.pkl"
    with cache_path.open("rb") as stream:
        payload = pickle.load(stream)
    design = payload["flow"].design
    top = next(module for module in design.modules if module.name == TOP)
    ctx = build_module_context(top)
    widths = {port.name: max(1, ctx.signal_widths[port.name]) for port in top.ports}
    return top, widths


def render_rtl_tb(top, widths: dict[str, int], cycles: int, reset_cycles: int) -> str:
    declarations: list[str] = []
    bindings: list[str] = []
    initializers: list[str] = []
    for port in top.ports:
        width = widths[port.name]
        packed = "" if width == 1 else f" [{width - 1}:0]"
        kind = "reg" if port.direction == "input" else "wire"
        declarations.append(f"  {kind}{packed} {port.name};")
        bindings.append(f"    .{port.name}({port.name})")
        if port.direction == "input" and port.name != "core_clk_aon":
            initializers.append(f"    {port.name} = '0;")

    sample = ",".join("%0h" for _ in (*TRACE_FIELDS, *DEBUG_TRACE_FIELDS))
    sample_args = ", ".join(
        (*TRACE_FIELDS, "dut.u_core.core_clk", "dut.u_core.rst_core", "dut.u_core.hart_under_reset")
    )
    return f"""`timescale 1ns/1ps
module tb_e603_consistency;
{chr(10).join(declarations)}
  integer trace_fd;
  integer cycle;

  {TOP} dut (
{(',' + chr(10)).join(bindings)}
  );

  initial begin
    core_clk_aon = 1'b0;
    forever #5 core_clk_aon = ~core_clk_aon;
  end

  initial begin
{chr(10).join(initializers)}
    mem_clk_en = 1'b1;
    clkgate_bypass = 1'b1;
    dcache_disable_init = 1'b1;
    icache_disable_init = 1'b1;
    mmu_tlb_disable_init = 1'b1;
    reset_vector = 40'h0080000000;
    hart_id = 10'h0;
    por_reset_n = 1'b0;
    core_reset_n = 1'b0;
    trace_fd = $fopen("rtl_trace.csv", "w");
    $fwrite(trace_fd, "cycle,{','.join((*TRACE_FIELDS, *DEBUG_TRACE_FIELDS))}\\n");
    for (cycle = 0; cycle < {cycles}; cycle = cycle + 1) begin
      @(negedge core_clk_aon);
      if (cycle == {reset_cycles}) begin
        por_reset_n = 1'b1;
        core_reset_n = 1'b1;
      end
      @(posedge core_clk_aon);
      #1;
      $fwrite(trace_fd, "%0d,{sample}\\n", cycle, {sample_args});
    end
    $fclose(trace_fd);
    $finish;
  end
endmodule
"""


def sc_type(width: int, signed: bool) -> str:
    if width == 1 and not signed:
        return "bool"
    family = "sc_int" if signed else "sc_uint"
    if width > 64:
        family = "sc_bigint" if signed else "sc_biguint"
    return f"{family}<{width}>"


def render_systemc_context(top, widths: dict[str, int]) -> str:
    declarations = []
    for port in top.ports:
        declarations.append(f"  sc_signal<{sc_type(widths[port.name], port.signed)}> {port.name};")
    return f"""#pragma once
#include <systemc>

using namespace sc_core;
using namespace sc_dt;

struct {TOP};
struct E603Context {{
{chr(10).join(declarations)}
  {TOP}* dut = nullptr;
}};

{TOP}* e603_create_model(sc_module_name name);
bool e603_debug_core_clk({TOP}& dut);
bool e603_debug_rst_core({TOP}& dut);
bool e603_debug_hart_under_reset({TOP}& dut);
"""


def render_systemc_model() -> str:
    return f"""#include \"e603_core_rams__impl_000.cpp\"

{TOP}* e603_create_model(sc_module_name name) {{
  return new {TOP}(name);
}}

bool e603_debug_core_clk({TOP}& dut) {{ return dut.u_core.core_clk.read(); }}
bool e603_debug_rst_core({TOP}& dut) {{ return dut.u_core.rst_core.read(); }}
bool e603_debug_hart_under_reset({TOP}& dut) {{ return dut.u_core.hart_under_reset.read(); }}
"""


def render_systemc_bindings(top, group_size: int = 24) -> list[tuple[str, str]]:
    groups = [top.ports[index : index + group_size] for index in range(0, len(top.ports), group_size)]
    rendered = []
    for index, group in enumerate(groups):
        lines = [
            '#include "e603_core_rams.hpp"',
            '#include "e603_context.hpp"',
            "",
            f"void e603_bind_ports_{index:03d}({TOP}& dut, E603Context& context) {{",
        ]
        lines.extend(f"  dut.{port.name}(context.{port.name});" for port in group)
        lines.extend(("}", ""))
        rendered.append((f"tb_e603_bind_{index:03d}.cpp", "\n".join(lines)))
    declarations = "\n".join(
        f"void e603_bind_ports_{index:03d}({TOP}& dut, E603Context& context);"
        for index in range(len(groups))
    )
    return rendered, declarations


def render_systemc_tb(top, widths: dict[str, int], cycles: int, reset_cycles: int) -> str:
    initializers: list[str] = []
    for port in top.ports:
        if port.direction == "input" and port.name != "core_clk_aon":
            value = "false" if widths[port.name] == 1 and not port.signed else "0"
            initializers.append(f"  context.{port.name}.write({value});")

    trace_values = []
    for name in TRACE_FIELDS:
        width = widths[name]
        suffix = "" if width == 1 else ".to_string(SC_HEX)"
        if width == 1:
            trace_values.append(f" << ',' << (context.{name}.read() ? 1 : 0)")
        else:
            trace_values.append(f" << ',' << context.{name}.read(){suffix}")
    trace_values.extend(
        (
            " << ',' << (e603_debug_core_clk(*context.dut) ? 1 : 0)",
            " << ',' << (e603_debug_rst_core(*context.dut) ? 1 : 0)",
            " << ',' << (e603_debug_hart_under_reset(*context.dut) ? 1 : 0)",
        )
    )
    return f"""#include <fstream>
#include \"e603_context.hpp\"

int sc_main(int, char**) {{
  E603Context context;
  context.dut = e603_create_model(\"dut\");
{chr(10).join(f"  e603_bind_ports_{index:03d}(*context.dut, context);" for index in range((len(top.ports) + 23) // 24))}
{chr(10).join(initializers)}
  context.mem_clk_en.write(true);
  context.clkgate_bypass.write(true);
  context.dcache_disable_init.write(true);
  context.icache_disable_init.write(true);
  context.mmu_tlb_disable_init.write(true);
  context.reset_vector.write(sc_uint<40>(0x80000000ULL));
  context.hart_id.write(0);
  context.por_reset_n.write(false);
  context.core_reset_n.write(false);
  context.core_clk_aon.write(false);
  sc_start(SC_ZERO_TIME);

  std::ofstream trace(\"systemc_trace.csv\");
  trace << \"cycle,{','.join((*TRACE_FIELDS, *DEBUG_TRACE_FIELDS))}\\n\";
  for (int cycle = 0; cycle < {cycles}; ++cycle) {{
    context.core_clk_aon.write(false);
    if (cycle == {reset_cycles}) {{
      context.por_reset_n.write(true);
      context.core_reset_n.write(true);
    }}
    sc_start(5, SC_NS);
    context.core_clk_aon.write(true);
    sc_start(5, SC_NS);
    trace << cycle{''.join(trace_values)} << '\\n';
  }}
  return 0;
}}
"""


def run_rtl(tb: Path) -> None:
    vcs = shutil.which("vcs")
    if vcs is None:
        raise RuntimeError("vcs is not available")
    exe = WORK / "rtl_simv"
    csrc = WORK / "rtl_csrc"
    parsed = parse_filelist(FILELIST)
    command = [
        vcs,
        "-full64",
        "-sverilog",
        "-timescale=1ns/1ps",
        "-top",
        "tb_e603_consistency",
        "-Mupdate",
        f"-Mdir={csrc}",
    ]
    command.extend(f"+define+{define}" for define in parsed.defines)
    command.extend(f"+incdir+{path}" for path in parsed.include_dirs)
    command.extend(str(path) for path in parsed.sources)
    command.extend((str(tb), "-o", str(exe)))
    run_bounded(
        command,
        address_space=3221225472,
        timeout_seconds=300,
        log=WORK / "vcs.log",
        cwd=WORK,
    )
    run_bounded(
        [str(exe)],
        address_space=1073741824,
        timeout_seconds=60,
        log=WORK / "rtl_run.log",
        cwd=WORK,
    )


def run_systemc(
    tb: Path,
    *,
    extra_sources: tuple[Path, ...] = (),
    build_mode: str = "legacy",
    build_jobs: int = 1,
) -> None:
    cxx = shutil.which("g++")
    if cxx is None:
        raise RuntimeError("g++ is not available")
    obj_dir = WORK / "obj"
    obj_dir.mkdir(exist_ok=True)
    objects: list[Path] = []
    digest_cache: dict[Path, str] = {}
    include_flags = [
        f"-I{GENERATED / 'core'}",
        f"-I{GENERATED / 'tech'}",
        f"-I{GENERATED / 'soc'}",
        f"-I{SYSTEMC_INCLUDE}",
    ]
    tb_include_flags = [*include_flags, f"-I{WORK}"]
    co_located_factory_source = GENERATED / "core" / "e603_core_rams__impl_000.cpp"
    generated_sources = tuple(
        source
        for source in sorted(GENERATED.rglob("*__impl_*.cpp"))
        if source != co_located_factory_source
    )
    if build_mode == "optimized":
        try:
            result = build_systemc(
                (*generated_sources, *extra_sources, tb),
                WORK / "systemc_sim_optimized",
                WORK / "optimized_build",
                options=SystemCBuildOptions(
                    cxx=cxx,
                    standard="c++14",
                    include_dirs=(
                        GENERATED / "core",
                        GENERATED / "tech",
                        GENERATED / "soc",
                        SYSTEMC_INCLUDE,
                        WORK,
                    ),
                    pch_headers=(GENERATED / "core" / "e603_core_rams.hpp",),
                    ld_flags=(f"-L{SYSTEMC_LIB}", f"-Wl,-rpath,{SYSTEMC_LIB}"),
                    libs=("-lsystemc", "-pthread"),
                    jobs=max(1, build_jobs),
                    use_pch=True,
                    incremental=True,
                    timeout_seconds=360,
                ),
                log_path=WORK / "systemc_build_optimized.log",
            )
        except SystemCBuildError as exc:
            raise RuntimeError(str(exc)) from exc
        print(
            "E603 optimized SystemC build: "
            f"elapsed={result.elapsed_seconds:.3f}s compiled={result.compiled_sources} "
            f"reused={result.reused_objects} jobs={result.jobs} "
            f"link_reused={result.link_reused}",
            flush=True,
        )
        run(
            [str(result.output)],
            cwd=WORK,
            log=WORK / "systemc_run.log",
        )
        return

    for source in sorted(GENERATED.rglob("*__impl_*.cpp")):
        if source == co_located_factory_source:
            continue
        obj = obj_dir / f"{source.stem}.o"
        dep = obj.with_suffix(".d")
        stamp = obj.with_suffix(".sha256")
        objects.append(obj)
        command = [
            cxx,
            "-std=c++14",
            "-O0",
            "-MMD",
            "-MF",
            str(dep),
            *include_flags,
            "-c",
            str(source),
            "-o",
            str(obj),
        ]
        compile_cached(
            command,
            obj=obj,
            dep=dep,
            stamp=stamp,
            digest_cache=digest_cache,
            address_space=1342177280,
            retry_address_spaces=(1879048192, 2415919104),
            timeout_seconds=240,
            log=WORK / f"compile_{source.stem}.log",
        )
    for source in (*extra_sources, tb):
        obj = obj_dir / f"{source.stem}.o"
        dep = obj.with_suffix(".d")
        stamp = obj.with_suffix(".sha256")
        objects.append(obj)
        command = [
            cxx,
            "-std=c++14",
            "-O0",
            "-MMD",
            "-MF",
            str(dep),
            *tb_include_flags,
            "-c",
            str(source),
            "-o",
            str(obj),
        ]
        compile_cached(
            command,
            obj=obj,
            dep=dep,
            stamp=stamp,
            digest_cache=digest_cache,
            address_space=1342177280,
            timeout_seconds=360,
            log=WORK / f"compile_{source.stem}.log",
            retry_address_spaces=(1879048192, 2415919104),
        )
    exe = WORK / "systemc_sim"
    run(
        [
            cxx,
            *[str(obj) for obj in objects],
            f"-L{SYSTEMC_LIB}",
            "-Wl,-rpath," + str(SYSTEMC_LIB),
            "-lsystemc",
            "-pthread",
            "-o",
            str(exe),
        ],
        cwd=WORK,
        log=WORK / "link_systemc.log",
    )
    run([str(exe)], cwd=WORK, log=WORK / "systemc_run.log")


def compile_cached(
    command: list[str],
    *,
    obj: Path,
    dep: Path,
    stamp: Path,
    digest_cache: dict[Path, str],
    address_space: int,
    timeout_seconds: int,
    log: Path,
    retry_address_spaces: tuple[int, ...] = (),
) -> None:
    fingerprint = dependency_fingerprint(command, dep, digest_cache)
    if (
        obj.is_file()
        and fingerprint is not None
        and stamp.is_file()
        and stamp.read_text(encoding="utf-8").strip() == fingerprint
    ):
        print(f"reuse {obj.name}", flush=True)
        return
    print(f"compile {obj.name}", flush=True)
    limits = (address_space, *retry_address_spaces)
    for index, limit in enumerate(limits):
        if index:
            print(
                f"retry {obj.name} with address-space limit {limit // (1024 * 1024)} MiB",
                flush=True,
            )
        try:
            run_bounded(
                command,
                address_space=limit,
                timeout_seconds=timeout_seconds,
                log=log,
            )
            break
        except RuntimeError as exc:
            failure = str(exc).lower()
            memory_limited = any(
                marker in failure
                for marker in ("out of memory", "virtual memory exhausted", "cannot allocate memory")
            )
            if not memory_limited or index == len(limits) - 1:
                raise
    fingerprint = dependency_fingerprint(command, dep, digest_cache)
    if fingerprint is None:
        raise RuntimeError(f"compiler did not write dependency file: {dep}")
    stamp.write_text(fingerprint + "\n", encoding="utf-8")


def dependency_fingerprint(
    command: list[str], dep: Path, digest_cache: dict[Path, str]
) -> str | None:
    if not dep.is_file():
        return None
    text = dep.read_text(encoding="utf-8", errors="replace").replace("\\\n", " ")
    if ":" not in text:
        return None
    dependencies = [Path(item) for item in shlex.split(text.split(":", 1)[1])]
    if not dependencies or any(not item.is_file() for item in dependencies):
        return None
    digest = hashlib.sha256("\0".join(command).encode("utf-8"))
    for item in dependencies:
        resolved = item.resolve()
        item_digest = digest_cache.get(resolved)
        if item_digest is None:
            item_digest = hashlib.sha256(resolved.read_bytes()).hexdigest()
            digest_cache[resolved] = item_digest
        digest.update(str(resolved).encode("utf-8"))
        digest.update(item_digest.encode("ascii"))
    return digest.hexdigest()


def run_bounded(
    command: list[str],
    *,
    address_space: int,
    timeout_seconds: int,
    log: Path,
    cwd: Path = ROOT,
) -> None:
    run(
        [
            "prlimit",
            f"--as={address_space}",
            "--",
            "timeout",
            f"{timeout_seconds}s",
            "nice",
            "-n",
            "15",
            *command,
        ],
        cwd=cwd,
        log=log,
    )


def run(command: list[str], *, cwd: Path, log: Path) -> None:
    with log.open("w", encoding="utf-8") as stream:
        result = subprocess.run(command, cwd=cwd, stdout=stream, stderr=subprocess.STDOUT, text=True)
    if result.returncode != 0:
        tail = "\n".join(log.read_text(encoding="utf-8", errors="replace").splitlines()[-40:])
        raise RuntimeError(f"command failed ({result.returncode}): {' '.join(command)}\n{tail}")


def parse_trace(path: Path) -> list[dict[str, int | None]]:
    lines = path.read_text(encoding="utf-8").splitlines()
    header = lines[0].split(",")
    rows: list[dict[str, int | None]] = []
    for line in lines[1:]:
        values = line.strip().split(",")
        if len(values) != len(header):
            continue
        row: dict[str, int | None] = {}
        for name, value in zip(header, values):
            clean = value.strip().lower().removeprefix("0x")
            row[name] = None if any(char in clean for char in "xz") else int(clean, 16 if name != "cycle" else 10)
        rows.append(row)
    return rows


def compare_traces(rtl_path: Path, sc_path: Path) -> None:
    rtl = parse_trace(rtl_path)
    systemc = parse_trace(sc_path)
    rtl_req = next((row for row in rtl if row["mem_arvalid"] == 1), None)
    sc_req = next((row for row in systemc if row["mem_arvalid"] == 1), None)
    if rtl_req is None or sc_req is None:
        raise RuntimeError(f"missing fetch request: rtl={rtl_req is not None}, systemc={sc_req is not None}")
    for field in ("mem_araddr", "mem_arlen", "mem_arid"):
        if rtl_req[field] != sc_req[field]:
            raise RuntimeError(f"first fetch mismatch for {field}: rtl={rtl_req[field]}, systemc={sc_req[field]}")
    cycle_delta = abs(int(rtl_req["cycle"]) - int(sc_req["cycle"]))
    if cycle_delta > 12:
        raise RuntimeError(
            f"first fetch cycle delta too large: rtl={rtl_req['cycle']}, systemc={sc_req['cycle']}"
        )
    print(
        "PASS: first fetch request matches "
        f"addr=0x{int(rtl_req['mem_araddr']):08x}, "
        f"rtl_cycle={rtl_req['cycle']}, systemc_cycle={sc_req['cycle']}, delta={cycle_delta}"
    )


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
