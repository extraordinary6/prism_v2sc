"""RTL vs prism_v2sc-generated SystemC equivalence harness.

This script is intended to run in CI (Linux) where Icarus Verilog
(`iverilog`/`vvp`) or VCS, and SystemC (libsystemc-dev) are installed
alongside Python + pyslang. For each fixture it:

  1. Runs prism-v2sc to lower the RTL into a SystemC header.
  2. Generates a deterministic stimulus file.
  3. Generates a matching Verilog testbench and a SystemC testbench that
     both consume the same stimulus file.
  4. Builds and runs the RTL testbench with iverilog/vvp or VCS.
  5. Builds and runs the SystemC testbench with $CXX + -lsystemc.
  6. Diffs the per-cycle output traces.

The comparison is line-by-line (one trace line per stimulus cycle), with
an optional uniform shift tolerance for "near cycle accurate" alignment.
"""

from __future__ import annotations

import argparse
import json
import os
import random
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

THIS_FILE = Path(__file__).resolve()
PROJECT_ROOT = THIS_FILE.parents[2]
FIXTURE_DIR = THIS_FILE.parent / "fixtures"


@dataclass(frozen=True)
class Port:
    name: str
    width: int
    signed: bool = False
    external_drive_control: str | None = None
    external_drive_active: bool = True

    @property
    def is_bool(self) -> bool:
        return self.width == 1 and not self.signed

    @property
    def sc_type(self) -> str:
        if self.is_bool:
            return "bool"
        family = "bigint" if self.signed else "biguint"
        if self.width <= 64:
            family = "int" if self.signed else "uint"
        return f"sc_{family}<{self.width}>"

    @property
    def sc_rv_type(self) -> str:
        return f"sc_signal_rv<{self.width}>"


@dataclass(frozen=True)
class Fixture:
    name: str
    sources: tuple[str, ...]
    top: str
    inputs: tuple[Port, ...]
    outputs: tuple[Port, ...]
    sequential: bool
    inouts: tuple[Port, ...] = ()
    clock: str | None = None
    reset: str | None = None
    reset_active_low: bool = True
    cycles: int = 256
    reset_cycles: int = 3
    seed: int = 0xCAFEBABE
    sc_template_args: tuple[str, ...] = ()
    filelist: str | None = None


@dataclass(frozen=True)
class ConversionFixture:
    """A fixture that must convert cleanly but cannot be trace-tested here.

    Some SystemVerilog constructs are accepted by pyslang/prism but not by
    Icarus Verilog. These still run in CI through the same harness: conversion
    must succeed, ``ir.json`` must be valid, the top header must be emitted,
    and no error-level diagnostics may appear.
    """

    name: str
    sources: tuple[str, ...]
    top: str
    required_top_header_snippets: tuple[str, ...] = ()


FIXTURES: tuple[Fixture, ...] = (
    Fixture(
        name="mux2",
        sources=("mux2.v",),
        top="mux2",
        inputs=(Port("sel", 1), Port("a", 4), Port("b", 4)),
        outputs=(Port("y", 4),),
        sequential=False,
        cycles=64,
    ),
    Fixture(
        name="adder",
        sources=("adder.v",),
        top="adder",
        inputs=(Port("a", 8), Port("b", 8), Port("ci", 1)),
        outputs=(Port("sum", 8), Port("co", 1)),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="byteswap",
        sources=("byteswap.v",),
        top="byteswap",
        inputs=(Port("data_in", 32),),
        outputs=(Port("data_out", 32),),
        sequential=False,
        cycles=64,
    ),
    Fixture(
        name="alu",
        sources=("alu.v",),
        top="alu",
        inputs=(Port("a", 8), Port("b", 8), Port("op", 3)),
        outputs=(Port("result", 8), Port("zero", 1), Port("carry", 1)),
        sequential=False,
        cycles=256,
    ),
    Fixture(
        name="function_alu",
        sources=("function_alu.v",),
        top="function_alu",
        inputs=(Port("a", 8), Port("b", 8), Port("op", 3)),
        outputs=(Port("result", 8),),
        sequential=False,
        cycles=256,
    ),
    Fixture(
        name="counter",
        sources=("counter.v",),
        top="counter",
        inputs=(Port("en", 1),),
        outputs=(Port("count", 8),),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="shift_register",
        sources=("shift_register.v",),
        top="shift_register",
        inputs=(
            Port("load", 1),
            Port("shift_en", 1),
            Port("parallel_in", 8),
            Port("serial_in", 1),
        ),
        outputs=(Port("data_out", 8), Port("serial_out", 1)),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="fsm_handshake",
        sources=("fsm_handshake.v",),
        top="fsm_handshake",
        inputs=(Port("start", 1), Port("data_valid", 1)),
        outputs=(Port("ready", 1), Port("done", 1)),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="pipeline8",
        sources=("pipeline8.v",),
        top="pipeline8",
        inputs=(Port("valid_i", 1), Port("data_i", 8)),
        outputs=(Port("valid_o", 1), Port("data_o", 8)),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=256,
    ),
    Fixture(
        name="multi_file",
        sources=(),
        filelist="multi_file/sources.f",
        top="top_datapath",
        inputs=(Port("en", 1), Port("sel", 1), Port("a", 8), Port("b", 8)),
        outputs=(Port("y", 8),),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="filelist_edges",
        sources=(),
        filelist="filelist_edges/sources.f",
        top="filelist_edges_top",
        inputs=(Port("en", 1), Port("sel", 1), Port("a", 8), Port("b", 8)),
        outputs=(Port("y", 8), Port("comb", 8)),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="gen_demo",
        sources=("gen_demo.v",),
        top="gen_demo",
        inputs=(Port("a", 4),),
        outputs=(Port("y", 4),),
        sequential=False,
        cycles=64,
    ),
    Fixture(
        name="slice_writers",
        sources=("slice_writers.v",),
        top="slice_writers",
        inputs=(Port("a", 1), Port("b", 1)),
        outputs=(Port("q", 2),),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=64,
    ),
    Fixture(
        name="sv_always_comb",
        sources=("sv_always_comb.v",),
        top="sv_always_comb",
        inputs=(Port("a", 8), Port("b", 8), Port("sel", 1)),
        outputs=(Port("y", 8),),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="sv_always_ff",
        sources=("sv_always_ff.v",),
        top="sv_always_ff",
        inputs=(Port("d", 8),),
        outputs=(Port("q", 8),),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="sv_always_latch",
        sources=("sv_always_latch.v",),
        top="sv_always_latch",
        inputs=(Port("en", 1), Port("d", 8)),
        outputs=(Port("q", 8),),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="casez_priority",
        sources=("casez_priority.v",),
        top="casez_priority",
        inputs=(Port("op", 4),),
        outputs=(Port("y", 2),),
        sequential=False,
        cycles=64,
    ),
    Fixture(
        name="casex_priority",
        sources=("casex_priority.v",),
        top="casex_priority",
        inputs=(Port("op", 4),),
        outputs=(Port("y", 2),),
        sequential=False,
        cycles=64,
    ),
    Fixture(
        name="signed_shift_cast",
        sources=("signed_shift_cast.v",),
        top="signed_shift_cast",
        inputs=(Port("x", 8), Port("n", 3)),
        outputs=(Port("y", 8),),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="signed_declared_arith",
        sources=("signed_declared_arith.sv",),
        top="signed_declared_arith",
        inputs=(Port("a", 8, signed=True), Port("b", 8, signed=True), Port("sh", 3)),
        outputs=(
            Port("sum", 9, signed=True),
            Port("shifted", 8, signed=True),
            Port("lt", 1),
            Port("literal", 8, signed=True),
        ),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="signed_mixed_context",
        sources=("signed_mixed_context.sv",),
        top="signed_mixed_context",
        inputs=(
            Port("s", 8, signed=True),
            Port("u", 8),
            Port("narrow_s", 4, signed=True),
            Port("sh", 3),
            Port("sel", 1),
        ),
        outputs=(
            Port("sum_math", 9, signed=True),
            Port("diff_math", 9, signed=True),
            Port("lt_math", 1),
            Port("lt_bits", 1),
            Port("shifted_lo", 8, signed=True),
            Port("chosen", 9, signed=True),
        ),
        sequential=False,
        cycles=256,
    ),
    Fixture(
        name="width_boundaries",
        sources=("width_boundaries.v",),
        top="width_boundaries",
        inputs=(
            Port("a1", 1),
            Port("a2", 2),
            Port("a31", 31),
            Port("a32", 32),
            Port("a33", 33),
            Port("a63", 63),
            Port("a64", 64),
            Port("a65", 65),
            Port("sh", 6),
        ),
        outputs=(
            Port("y1", 1),
            Port("y2", 2),
            Port("y31", 31),
            Port("y32", 32),
            Port("y33", 33),
            Port("y63", 63),
            Port("y64", 64),
            Port("y65", 65),
            Port("cmp65", 1),
        ),
        sequential=False,
        cycles=256,
    ),
    Fixture(
        name="nested_selects",
        sources=("nested_selects.v",),
        top="nested_selects",
        inputs=(
            Port("sel", 3),
            Port("mode", 2),
            Port("a", 8),
            Port("b", 8),
            Port("c", 8),
            Port("d", 8),
        ),
        outputs=(
            Port("ternary_y", 8),
            Port("case_y", 8),
            Port("nested_case_y", 8),
        ),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="part_select_assembly",
        sources=("part_select_assembly.v",),
        top="part_select_assembly",
        inputs=(
            Port("n0", 4),
            Port("n1", 4),
            Port("n2", 4),
            Port("n3", 4),
            Port("lower", 16),
            Port("upper", 16),
            Port("flag", 1),
        ),
        outputs=(
            Port("assembled", 16),
            Port("wide", 33),
        ),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="staged_read_after_write",
        sources=("staged_read_after_write.v",),
        top="staged_read_after_write",
        inputs=(Port("a", 8), Port("b", 8), Port("sel", 1)),
        outputs=(Port("y", 8), Port("tap", 8)),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="blocking_comb_chain",
        sources=("blocking_comb_chain.v",),
        top="blocking_comb_chain",
        inputs=(Port("din", 8), Port("mask", 8), Port("mode", 2)),
        outputs=(Port("y", 8), Port("tap", 8)),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="regfile_mem",
        sources=("regfile_mem.v",),
        top="regfile_mem",
        inputs=(Port("we", 1), Port("addr", 3), Port("din", 8)),
        outputs=(Port("dout", 8),),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="memory_edges",
        sources=("memory_edges.v",),
        top="memory_edges",
        inputs=(Port("we", 1), Port("wr_addr", 2), Port("rd_addr", 2), Port("din", 8)),
        outputs=(Port("rd_data", 8), Port("wr_old", 8), Port("rd_xor", 8)),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="nba_chain",
        sources=("nba_chain.v",),
        top="nba_chain",
        inputs=(Port("en", 1), Port("din", 8), Port("salt", 8)),
        outputs=(Port("a", 8), Port("b", 8), Port("c", 8), Port("mix", 8)),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="async_reset_edges",
        sources=("async_reset_edges.v",),
        top="async_reset_edges",
        inputs=(Port("en", 1), Port("din", 8)),
        outputs=(Port("q", 8), Port("flag", 1)),
        sequential=True,
        clock="clk",
        reset="rst",
        reset_active_low=False,
        cycles=128,
    ),
    Fixture(
        name="param_hierarchy_edges",
        sources=("param_hierarchy_edges.v",),
        top="param_hierarchy_edges",
        inputs=(Port("a", 8), Port("b", 8)),
        outputs=(Port("sum", 9), Port("low_mix", 3), Port("folded", 8)),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="procedural_for",
        sources=("procedural_for.v",),
        top="procedural_for",
        inputs=(Port("din", 8),),
        outputs=(Port("reversed", 8), Port("parity", 1), Port("cleared", 8)),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="procedural_for_edges",
        sources=("procedural_for_edges.v",),
        top="procedural_for_edges",
        inputs=(Port("din", 8), Port("mask", 8)),
        outputs=(Port("down", 8), Port("window", 8), Port("nested", 8)),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="latch_edges",
        sources=("latch_edges.v",),
        top="latch_edges",
        inputs=(Port("load", 1), Port("hold_hi", 1), Port("din", 8), Port("hi", 4)),
        outputs=(Port("q", 8), Port("mirror", 8)),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="sensitivity_edges",
        sources=("sensitivity_edges.v",),
        top="sensitivity_edges",
        inputs=(Port("a", 8), Port("b", 8), Port("idx", 2), Port("sel", 1)),
        outputs=(Port("y", 8), Port("picked", 1)),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="typedef_enum_fsm",
        sources=("typedef_enum_fsm.sv",),
        top="typedef_enum_fsm",
        inputs=(Port("start", 1), Port("ack", 1)),
        outputs=(Port("busy", 1), Port("done", 1), Port("state_bits", 2)),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="packed_aggregate_demo",
        sources=("packed_aggregate_demo.sv",),
        top="packed_aggregate_demo",
        inputs=(Port("a", 4), Port("b", 4), Port("flag", 1)),
        outputs=(Port("hi", 4), Port("lo", 4), Port("mirror", 8)),
        sequential=False,
        cycles=64,
    ),
    Fixture(
        name="package_import",
        sources=("package_import.sv",),
        top="package_import",
        inputs=(Port("a", 8), Port("b", 8), Port("op_sel", 2)),
        outputs=(Port("result", 8),),
        sequential=True,
        clock="clk",
        reset="rst_n",
        reset_active_low=True,
        cycles=128,
    ),
    Fixture(
        name="inout_bus",
        sources=("inout_bus.sv",),
        top="inout_bus",
        inputs=(Port("oe", 1), Port("din", 4)),
        inouts=(Port("bus", 4, external_drive_control="oe", external_drive_active=False),),
        outputs=(Port("seen", 4), Port("mixed", 4)),
        sequential=False,
        cycles=128,
    ),
    Fixture(
        name="inout_edges",
        sources=("inout_edges.sv",),
        top="inout_edges",
        inputs=(Port("oe", 1), Port("din", 8)),
        inouts=(Port("bus", 8, external_drive_control="oe", external_drive_active=False),),
        outputs=(Port("child_seen", 8), Port("folded", 8), Port("top_seen", 8)),
        sequential=False,
        cycles=128,
    ),
)


CONVERSION_FIXTURES: tuple[ConversionFixture, ...] = (
    ConversionFixture(
        name="interface_modport",
        sources=("interface_modport.sv",),
        top="interface_modport",
        required_top_header_snippets=(
            "sc_signal<sc_uint<8>> bus__req;",
            "sc_signal<sc_uint<8>> bus__rsp;",
            "sc_signal<bool> bus__valid;",
            "u_src.bus__req(bus__req);",
            "u_sink.bus__rsp(bus__rsp);",
        ),
    ),
    ConversionFixture(
        name="interface_modport_variants",
        sources=("interface_modport_variants/interface_modport_variants.sv",),
        top="interface_modport_variants",
        required_top_header_snippets=(
            "sc_signal<sc_uint<4>> lane_a__req;",
            "sc_signal<sc_uint<4>> lane_b__rsp;",
            "src_a.lane__req(lane_a__req);",
            "snk_b.lane__rsp(lane_b__rsp);",
        ),
    ),
    ConversionFixture(
        name="package_multifile",
        sources=(
            "package_multifile/pkg_defs.sv",
            "package_multifile/package_multifile.sv",
        ),
        top="package_multifile",
        required_top_header_snippets=(
            "sc_signal<sc_uint<8>> tmp;",
            "tmp.write(__next_tmp);",
            "y.write(__next_y);",
        ),
    ),
    ConversionFixture(
        name="generate_named_blocks",
        sources=("generate_named_blocks/generate_named_blocks.v",),
        top="generate_named_blocks",
        required_top_header_snippets=(
            "gen_named_cell lane_0_even_u;",
            "lane_0_even_u.a(__bridge_lane_0_even_u_a);",
            "assign_0",
        ),
    ),
    ConversionFixture(
        name="typedef_package_enum",
        sources=(
            "typedef_package_enum/enum_pkg.sv",
            "typedef_package_enum/typedef_package_enum.sv",
        ),
        top="typedef_package_enum",
        required_top_header_snippets=(
            "sc_signal<sc_uint<2>> op;",
            "op_seen.write(__next_op_seen);",
            "case 0:",
        ),
    ),
)


@dataclass(frozen=True)
class DiagnosticFixture:
    """A fixture asserting that ``prism-v2sc`` emits specific diagnostic codes.

    Used for rejection-class behavior that can't be trace-equivalence tested
    (driver conflicts, unknown modules, duplicate definitions, X/Z literal
    approximation, etc.). Each entry runs prism-v2sc on the given RTL,
    reads the resulting ``ir.json``, and asserts every code in
    ``expected_codes`` appears in either the design-level or any module-level
    ``diagnostics`` list.
    """

    name: str
    sources: tuple[str, ...]
    top: str
    expected_codes: tuple[str, ...]


DIAGNOSTIC_FIXTURES: tuple[DiagnosticFixture, ...] = (
    DiagnosticFixture(
        name="driver_conflict_procedural",
        sources=("diagnostics/driver_conflict_procedural.v",),
        top="dc_proc",
        # Two always_ff blocks writing the same whole signal trigger both
        # the generic procedural-driver check and the always_ff-specific one.
        expected_codes=("multiple_procedural_drivers", "multiple_always_ff_drivers"),
    ),
    DiagnosticFixture(
        name="mixed_assignment_styles",
        sources=("diagnostics/mixed_assignment_styles.v",),
        top="mixed_assign",
        expected_codes=("mixed_assignment_styles",),
    ),
    DiagnosticFixture(
        name="blocking_in_always_ff",
        sources=("diagnostics/blocking_in_always_ff.v",),
        top="blk_in_ff",
        expected_codes=("blocking_in_always_ff",),
    ),
    DiagnosticFixture(
        name="comb_process_order",
        sources=("diagnostics/comb_process_order.v",),
        top="comb_process_order",
        expected_codes=("event_scheduler_approximated",),
    ),
    DiagnosticFixture(
        name="xz_literal_approximated",
        sources=("diagnostics/xz_literal.v",),
        top="xz_lit",
        expected_codes=("x_z_literal_approximated",),
    ),
    DiagnosticFixture(
        name="xz_logic_rejected",
        sources=("diagnostics/xz_logic_rejected.v",),
        top="xz_logic_rejected",
        expected_codes=("x_z_literal_approximated",),
    ),
    DiagnosticFixture(
        name="overlap_slice_writers",
        sources=("diagnostics/overlap_slice_writers.v",),
        top="overlap_slice_writers",
        expected_codes=("overlapping_procedural_writes",),
    ),
    DiagnosticFixture(
        name="mixed_assignment_deeper",
        sources=("diagnostics/mixed_assignment_deeper.v",),
        top="mixed_assignment_deeper",
        expected_codes=("mixed_assignment_styles",),
    ),
    DiagnosticFixture(
        name="while_repeat_rejected",
        sources=("diagnostics/while_repeat_rejected.v",),
        top="while_repeat_rejected",
        expected_codes=("unsupported_whileloop", "unsupported_repeatloop"),
    ),
    DiagnosticFixture(
        name="interface_complex_rejected",
        sources=("diagnostics/interface_complex_rejected.sv",),
        top="interface_complex_rejected",
        expected_codes=("unsupported_interface_port",),
    ),
    DiagnosticFixture(
        name="task_system_task_rejected",
        sources=("diagnostics/task_system_task_rejected.sv",),
        top="task_system_task_rejected",
        expected_codes=("unsupported_task_first_round", "unsupported_expression_statement_call"),
    ),
    DiagnosticFixture(
        name="dynamic_sv_rejected",
        sources=("diagnostics/dynamic_sv_rejected.sv",),
        top="dynamic_sv_rejected",
        expected_codes=("unsupported_classtype",),
    ),
    DiagnosticFixture(
        name="slang_unknown_module",
        sources=("diagnostics/slang_unknown_module.v",),
        top="su_top",
        expected_codes=("slang_UnknownModule",),
    ),
    DiagnosticFixture(
        name="slang_duplicate_definition",
        sources=("diagnostics/slang_duplicate_definition.v",),
        top="dup",
        expected_codes=("slang_DuplicateDefinition",),
    ),
)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--fixtures",
        nargs="*",
        default=None,
        help="Fixture names to run (default: all).",
    )
    parser.add_argument(
        "--work",
        type=Path,
        default=PROJECT_ROOT / "build" / "equivalence",
        help="Working/build directory.",
    )
    parser.add_argument(
        "--shift-tolerance",
        type=int,
        default=0,
        help="Allow the SystemC trace to lag the RTL trace by N cycles (drop first N SC entries before diffing).",
    )
    parser.add_argument(
        "--rtl-sim",
        choices=("auto", "iverilog", "vcs"),
        default="auto",
        help="RTL simulator backend for trace fixtures (default: auto).",
    )
    parser.add_argument(
        "--keep-going",
        action="store_true",
        help="Don't stop after the first failing fixture.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Generate SystemC, stimulus, and testbenches but skip iverilog/SystemC build and diff.",
    )
    args = parser.parse_args(argv)
    args.work = args.work.resolve()
    args.work.mkdir(parents=True, exist_ok=True)

    selected: list[Fixture] = [
        fixture for fixture in FIXTURES if args.fixtures is None or fixture.name in args.fixtures
    ]
    selected_conversion: list[ConversionFixture] = [
        fixture
        for fixture in CONVERSION_FIXTURES
        if args.fixtures is None or fixture.name in args.fixtures
    ]
    selected_diag: list[DiagnosticFixture] = [
        fixture
        for fixture in DIAGNOSTIC_FIXTURES
        if args.fixtures is None or fixture.name in args.fixtures
    ]
    if not selected and not selected_conversion and not selected_diag:
        print("error: no fixtures match the selection", file=sys.stderr)
        return 2

    rtl_sim = (
        select_rtl_simulator(args.rtl_sim)
        if selected and not args.dry_run
        else args.rtl_sim
    )
    if selected and not args.dry_run:
        require_tool(os.environ.get("CXX", "g++"))

    summary: list[tuple[str, str]] = []
    overall = 0
    for fixture in selected:
        print(f"\n=== fixture: {fixture.name} ===")
        rc = run_fixture(
            fixture,
            args.work / fixture.name,
            shift_tolerance=args.shift_tolerance,
            rtl_sim=rtl_sim,
            dry_run=args.dry_run,
        )
        summary.append((fixture.name, "PASS" if rc == 0 else "FAIL"))
        if rc != 0:
            overall = rc
            if not args.keep_going:
                break

    if overall == 0 or args.keep_going:
        for fixture in selected_conversion:
            print(f"\n=== conversion fixture: {fixture.name} ===")
            rc = run_conversion_fixture(fixture, args.work / fixture.name)
            summary.append((fixture.name, "PASS" if rc == 0 else "FAIL"))
            if rc != 0:
                overall = rc
                if not args.keep_going:
                    break

    if overall == 0 or args.keep_going:
        for fixture in selected_diag:
            print(f"\n=== diagnostic fixture: {fixture.name} ===")
            rc = run_diagnostic_fixture(fixture, args.work / fixture.name)
            summary.append((fixture.name, "PASS" if rc == 0 else "FAIL"))
            if rc != 0:
                overall = rc
                if not args.keep_going:
                    break

    print("\n=== summary ===")
    for name, status in summary:
        print(f"  {name}: {status}")
    return overall


def require_tool(name: str) -> None:
    if shutil.which(name) is None:
        print(f"error: required tool '{name}' not found on PATH", file=sys.stderr)
        sys.exit(2)


def select_rtl_simulator(requested: str) -> str:
    if requested == "iverilog":
        require_tool("iverilog")
        require_tool("vvp")
        return "iverilog"
    if requested == "vcs":
        require_tool(os.environ.get("VCS", "vcs"))
        return "vcs"

    if shutil.which("iverilog") is not None and shutil.which("vvp") is not None:
        return "iverilog"
    if shutil.which(os.environ.get("VCS", "vcs")) is not None:
        print("  note: iverilog/vvp not found; using VCS for RTL simulation")
        return "vcs"

    print(
        "error: no RTL simulator found; install iverilog/vvp or set VCS to a VCS executable",
        file=sys.stderr,
    )
    sys.exit(2)


def run_diagnostic_fixture(fixture: DiagnosticFixture, work: Path) -> int:
    """Run ``prism-v2sc`` on a fixture and assert every expected diagnostic
    code appears in the resulting ``ir.json``. Returns 0 on PASS, 1 on FAIL.
    """
    work.mkdir(parents=True, exist_ok=True)
    sources = [FIXTURE_DIR / source for source in fixture.sources]
    for source in sources:
        if not source.is_file():
            print(f"  ERROR: missing fixture source {source}")
            return 2

    out_dir = work / "systemc"
    out_dir.mkdir(parents=True, exist_ok=True)
    log_path = work / "prism.log"
    cmd = [
        sys.executable,
        "-m",
        "prism_v2sc",
        "--top",
        fixture.top,
        "--out",
        str(out_dir),
        *(str(source) for source in sources),
    ]
    env = os.environ.copy()
    new_path = str(PROJECT_ROOT / "src")
    existing = env.get("PYTHONPATH", "")
    env["PYTHONPATH"] = new_path + (os.pathsep + existing if existing else "")
    print(f"  $ {' '.join(cmd)}")
    with log_path.open("w", encoding="utf-8") as log:
        # prism-v2sc may exit non-zero for some diagnostic cases (e.g. when
        # slang refuses to elaborate); we still want to inspect ir.json if
        # it was produced. So we don't fail on a non-zero return code here.
        subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, env=env)

    ir_path = out_dir / "ir.json"
    if not ir_path.is_file():
        print(f"  ERROR: ir.json was not produced (see {log_path})")
        return 1
    try:
        payload = json.loads(ir_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        print(f"  ERROR: ir.json is malformed: {exc} (see {log_path})")
        return 1

    seen_codes: set[str] = set()
    for diagnostic in payload.get("diagnostics", ()):
        if isinstance(diagnostic, dict):
            seen_codes.add(str(diagnostic.get("code", "")))
    for module in payload.get("modules", ()):
        if not isinstance(module, dict):
            continue
        for diagnostic in module.get("diagnostics", ()):
            if isinstance(diagnostic, dict):
                seen_codes.add(str(diagnostic.get("code", "")))

    missing = [code for code in fixture.expected_codes if code not in seen_codes]
    if missing:
        print(f"  MISSING: expected diagnostic codes not found: {', '.join(missing)}")
        print(f"    seen codes: {sorted(seen_codes) or '<none>'}")
        print(f"    log: {log_path}")
        return 1

    expected_fail_rc = 2 if any(
        diagnostic.get("severity") == "error" for diagnostic in _all_diagnostics(payload)
    ) else 0
    fail_out_dir = work / "systemc_fail_on"
    fail_cmd = [
        sys.executable,
        "-m",
        "prism_v2sc",
        "--top",
        fixture.top,
        "--fail-on-diagnostics",
        "--out",
        str(fail_out_dir),
        *(str(source) for source in sources),
    ]
    fail_log_path = work / "prism_fail_on.log"
    print(f"  $ {' '.join(fail_cmd)}")
    with fail_log_path.open("w", encoding="utf-8") as log:
        fail_result = subprocess.run(fail_cmd, stdout=log, stderr=subprocess.STDOUT, env=env)
    if fail_result.returncode != expected_fail_rc:
        print(
            "  ERROR: --fail-on-diagnostics returned "
            f"{fail_result.returncode}, expected {expected_fail_rc} (see {fail_log_path})"
        )
        return 1

    print(f"  PASS: all {len(fixture.expected_codes)} expected diagnostic(s) present")
    return 0


def run_conversion_fixture(fixture: ConversionFixture, work: Path) -> int:
    """Run ``prism-v2sc`` and assert conversion succeeded without errors."""
    work.mkdir(parents=True, exist_ok=True)
    sources = [FIXTURE_DIR / source for source in fixture.sources]
    for source in sources:
        if not source.is_file():
            print(f"  ERROR: missing fixture source {source}")
            return 2

    sc_out_dir = work / "systemc"
    if not convert_with_prism(
        sources,
        fixture.top,
        sc_out_dir,
        log_path=work / "prism.log",
    ):
        return 1

    top_header_path = _locate_top_header(sc_out_dir, fixture.top)
    if top_header_path is None:
        print(f"  ERROR: top hpp for '{fixture.top}' not found under {sc_out_dir}")
        return 1

    ir_path = sc_out_dir / "ir.json"
    if not ir_path.is_file():
        print(f"  ERROR: ir.json was not produced (see {work / 'prism.log'})")
        return 1
    try:
        payload = json.loads(ir_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        print(f"  ERROR: ir.json is malformed: {exc} (see {work / 'prism.log'})")
        return 1

    errors = [
        diagnostic
        for diagnostic in _all_diagnostics(payload)
        if diagnostic.get("severity") == "error"
    ]
    if errors:
        rendered = ", ".join(
            str(diagnostic.get("code", "<unknown>")) for diagnostic in errors
        )
        print(f"  ERROR: conversion emitted error diagnostic(s): {rendered}")
        return 1

    header = top_header_path.read_text(encoding="utf-8", errors="ignore")
    missing = [
        snippet
        for snippet in fixture.required_top_header_snippets
        if snippet not in header
    ]
    if missing:
        print("  ERROR: generated top header is missing expected snippet(s):")
        for snippet in missing:
            print(f"    {snippet}")
        return 1

    print("  PASS: conversion generated ir.json and top header without error diagnostics")
    return 0


def _all_diagnostics(payload: dict[str, object]) -> list[dict[str, object]]:
    diagnostics: list[dict[str, object]] = []
    for diagnostic in payload.get("diagnostics", ()):
        if isinstance(diagnostic, dict):
            diagnostics.append(diagnostic)
    for module in payload.get("modules", ()):
        if not isinstance(module, dict):
            continue
        for diagnostic in module.get("diagnostics", ()):
            if isinstance(diagnostic, dict):
                diagnostics.append(diagnostic)
    return diagnostics


def run_fixture(
    fixture: Fixture,
    work: Path,
    *,
    shift_tolerance: int,
    rtl_sim: str,
    dry_run: bool = False,
) -> int:
    work.mkdir(parents=True, exist_ok=True)
    sources = [FIXTURE_DIR / source for source in fixture.sources]
    for source in sources:
        if not source.is_file():
            print(f"  ERROR: missing fixture source {source}")
            return 2

    filelist_path: Path | None = None
    extra_includes: list[Path] = []
    extra_defines: list[str] = []
    if fixture.filelist is not None:
        filelist_path = FIXTURE_DIR / fixture.filelist
        if not filelist_path.is_file():
            print(f"  ERROR: missing filelist {filelist_path}")
            return 2
        # Reuse the prism preprocess parser so the RTL simulator gets the same -I / -D set.
        sys.path.insert(0, str(PROJECT_ROOT / "src"))
        try:
            from prism_v2sc.frontend.preprocess import collect_sources
        finally:
            sys.path.pop(0)
        resolved = collect_sources([], [filelist_path])
        sources.extend(resolved.sources)
        extra_includes = list(resolved.include_dirs)
        extra_defines = list(resolved.defines)
        # Resolved sources from the filelist are absolute; dedupe deterministically.
        seen: set[str] = set()
        unique: list[Path] = []
        for source in sources:
            key = str(source.resolve()).casefold() if os.name == "nt" else str(source.resolve())
            if key in seen:
                continue
            seen.add(key)
            unique.append(source)
        sources = unique

    sc_out_dir = work / "systemc"
    if not convert_with_prism(
        sources if filelist_path is None else [],
        fixture.top,
        sc_out_dir,
        log_path=work / "prism.log",
        filelist=filelist_path,
    ):
        return 1

    top_header_path = _locate_top_header(sc_out_dir, fixture.top)
    if top_header_path is None:
        print(f"  ERROR: top hpp for '{fixture.top}' not found under {sc_out_dir}")
        return 1

    stim_path = work / "stim.txt"
    write_stimulus(fixture, stim_path)

    rtl_trace = work / "rtl_trace.txt"
    sc_trace = work / "sc_trace.txt"
    vtb_path = work / f"tb_{fixture.name}.v"
    sctb_path = work / f"tb_{fixture.name}.cpp"
    vtb_path.write_text(render_verilog_tb(fixture, stim_path, rtl_trace), encoding="utf-8")
    sctb_path.write_text(
        render_systemc_tb(fixture, stim_path, sc_trace, top_header_path, sc_out_dir),
        encoding="utf-8",
    )

    if dry_run:
        print("  dry-run: generated SystemC header, stimulus, Verilog TB, SystemC TB")
        return 0

    if run_rtl_testbench(
        rtl_sim,
        work,
        vtb_path,
        sources,
        include_dirs=extra_includes,
        defines=extra_defines,
    ) != 0:
        return 1

    sctb_exe = work / "tb_sc"
    cxx = os.environ.get("CXX", "g++")
    cxx_flags = [flag for flag in os.environ.get("SC_CXXFLAGS", "").split() if flag]
    ld_flags = [flag for flag in os.environ.get("SC_LDFLAGS", "").split() if flag]
    libs = os.environ.get("SC_LIBS", "-lsystemc -lpthread").split()
    sc_include = sc_out_dir.resolve()
    cxx_cmd = [
        cxx,
        "-std=c++17",
        "-O0",
        "-g",
        f"-I{sc_include}",
        *cxx_flags,
        str(sctb_path),
        "-o",
        str(sctb_exe),
        *ld_flags,
        *libs,
    ]
    if run_logged(cxx_cmd, work / "g++.log") != 0:
        print(f"  SystemC compile failed (see {work / 'g++.log'})")
        return 1
    if run_logged([str(sctb_exe)], work / "sc_run.log", cwd=work) != 0:
        print(f"  SystemC run failed (see {work / 'sc_run.log'})")
        return 1

    return diff_traces(
        rtl_trace.read_text(encoding="utf-8").splitlines(),
        sc_trace.read_text(encoding="utf-8").splitlines(),
        work,
        shift_tolerance,
    )


def run_rtl_testbench(
    rtl_sim: str,
    work: Path,
    testbench: Path,
    sources: list[Path],
    *,
    include_dirs: list[Path],
    defines: list[str],
) -> int:
    if rtl_sim == "iverilog":
        return run_iverilog_testbench(
            work,
            testbench,
            sources,
            include_dirs=include_dirs,
            defines=defines,
        )
    if rtl_sim == "vcs":
        return run_vcs_testbench(
            work,
            testbench,
            sources,
            include_dirs=include_dirs,
            defines=defines,
        )

    print(f"  ERROR: unsupported RTL simulator backend: {rtl_sim}")
    return 2


def run_iverilog_testbench(
    work: Path,
    testbench: Path,
    sources: list[Path],
    *,
    include_dirs: list[Path],
    defines: list[str],
) -> int:
    vvp_path = work / "rtl.vvp"
    iverilog_cmd = [
        "iverilog",
        "-g2012",
        *[f"-I{include_dir}" for include_dir in include_dirs],
        *[f"-D{define}" for define in defines],
        "-o",
        str(vvp_path),
        str(testbench),
        *[str(source) for source in sources],
    ]
    if run_logged(iverilog_cmd, work / "iverilog.log") != 0:
        print(f"  iverilog build failed (see {work / 'iverilog.log'})")
        return 1
    if run_logged(["vvp", str(vvp_path)], work / "vvp.log", cwd=work) != 0:
        print(f"  vvp run failed (see {work / 'vvp.log'})")
        return 1
    return 0


def run_vcs_testbench(
    work: Path,
    testbench: Path,
    sources: list[Path],
    *,
    include_dirs: list[Path],
    defines: list[str],
) -> int:
    vcs = os.environ.get("VCS", "vcs")
    vcs_flags = [
        flag
        for flag in os.environ.get(
            "VCS_FLAGS",
            "-full64 -sverilog -timescale=1ns/1ps",
        ).split()
        if flag
    ]
    vcs_run_flags = [flag for flag in os.environ.get("VCS_RUN_FLAGS", "").split() if flag]
    vcs_env = os.environ.copy()
    vcs_env.setdefault("VCS_TARGET_ARCH", "linux64")

    exe = work / "rtl_simv"
    vcs_cmd = [
        vcs,
        *vcs_flags,
        *[f"+incdir+{include_dir}" for include_dir in include_dirs],
        *[f"+define+{define}" for define in defines],
        "-o",
        exe.name,
        str(testbench.resolve()),
        *[str(source.resolve()) for source in sources],
    ]
    if run_logged(vcs_cmd, work / "vcs.log", cwd=work, env=vcs_env) != 0:
        print(f"  VCS build failed (see {work / 'vcs.log'})")
        return 1
    if (
        run_logged(
            [f"./{exe.name}", *vcs_run_flags],
            work / "vcs_run.log",
            cwd=work,
            env=vcs_env,
        )
        != 0
    ):
        print(f"  VCS run failed (see {work / 'vcs_run.log'})")
        return 1
    return 0


def convert_with_prism(
    sources: list[Path],
    top: str,
    out_dir: Path,
    *,
    log_path: Path,
    filelist: Path | None = None,
) -> bool:
    out_dir.mkdir(parents=True, exist_ok=True)
    cmd = [
        sys.executable,
        "-m",
        "prism_v2sc",
        "--top",
        top,
        "--out",
        str(out_dir),
    ]
    if filelist is not None:
        cmd.extend(["--filelist", str(filelist)])
    cmd.extend(str(source) for source in sources)
    env = os.environ.copy()
    new_path = str(PROJECT_ROOT / "src")
    existing = env.get("PYTHONPATH", "")
    env["PYTHONPATH"] = new_path + (os.pathsep + existing if existing else "")
    print(f"  $ {' '.join(cmd)}")
    with log_path.open("w", encoding="utf-8") as log:
        result = subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, env=env)
    if result.returncode != 0:
        print(f"  prism-v2sc conversion failed (see {log_path})")
        return False
    return True


def write_stimulus(fixture: Fixture, path: Path) -> None:
    rng = random.Random(fixture.seed)
    stimulus_ports = (*fixture.inputs, *fixture.inouts)
    masks = [(1 << port.width) - 1 for port in stimulus_ports]
    hex_io = _uses_hex_io(fixture)
    lines: list[str] = []
    for _ in range(fixture.cycles):
        values = [rng.randint(0, mask) for mask in masks]
        if hex_io:
            lines.append(" ".join(format(value, "x") for value in values))
        else:
            lines.append(" ".join(str(value) for value in values))
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def _uses_hex_io(fixture: Fixture) -> bool:
    ports = (*fixture.inputs, *fixture.outputs, *fixture.inouts)
    return any(port.width > 32 for port in ports)


def render_verilog_tb(fixture: Fixture, stim_path: Path, out_path: Path) -> str:
    inputs = fixture.inputs
    inouts = fixture.inouts
    outputs = fixture.outputs
    stimulus_ports = (*inputs, *inouts)
    trace_ports = (*outputs, *inouts)
    hex_io = _uses_hex_io(fixture)

    lines: list[str] = []
    lines.append("`timescale 1ns/1ps")
    lines.append("module tb;")

    if fixture.sequential:
        lines.append("  reg clk;")
        lines.append(f"  reg {fixture.reset};")
    for port in inputs:
        lines.append(f"  {_verilog_decl('reg', port)}")
    for port in inouts:
        lines.append(f"  {_verilog_decl('wire', port)}")
        lines.append(f"  {_verilog_decl('reg', port, name=f'_tb_drive_{port.name}')}")
    for port in outputs:
        lines.append(f"  {_verilog_decl('wire', port)}")
    for port in inouts:
        control_expr = _verilog_external_drive_expr(port)
        z_literal = "1'bz" if port.width == 1 else f"{port.width}'b{'z' * port.width}"
        lines.append(
            f"  assign {port.name} = ({control_expr}) ? _tb_drive_{port.name} : {z_literal};"
        )
    for i, port in enumerate(stimulus_ports):
        stim_width = port.width if hex_io else 32
        lines.append(f"  reg [{stim_width - 1}:0] _stim_{i};")
    lines.append("  integer stim_fd;")
    lines.append("  integer out_fd;")
    lines.append("  integer _r;")
    lines.append("")

    bindings: list[str] = []
    if fixture.sequential:
        bindings.append(f".{fixture.clock}(clk)")
        bindings.append(f".{fixture.reset}({fixture.reset})")
    for port in inputs:
        bindings.append(f".{port.name}({port.name})")
    for port in inouts:
        bindings.append(f".{port.name}({port.name})")
    for port in outputs:
        bindings.append(f".{port.name}({port.name})")
    lines.append(f"  {fixture.top} dut (")
    for i, binding in enumerate(bindings):
        suffix = "," if i < len(bindings) - 1 else ""
        lines.append(f"    {binding}{suffix}")
    lines.append("  );")
    lines.append("")

    if fixture.sequential:
        lines.append("  initial begin")
        lines.append("    clk = 1'b0;")
        lines.append("    forever #5 clk = ~clk;")
        lines.append("  end")
        lines.append("")

    lines.append("  initial begin")
    lines.append(f"    stim_fd = $fopen(\"{stim_path.name}\", \"r\");")
    lines.append(f"    out_fd = $fopen(\"{out_path.name}\", \"w\");")
    lines.append("    if (stim_fd == 0) begin")
    lines.append("      $display(\"failed to open stimulus file\");")
    lines.append("      $finish(1);")
    lines.append("    end")
    lines.append("    if (out_fd == 0) begin")
    lines.append("      $display(\"failed to open output file\");")
    lines.append("      $finish(1);")
    lines.append("    end")

    if fixture.sequential:
        reset_value = "1'b0" if fixture.reset_active_low else "1'b1"
        lines.append(f"    {fixture.reset} = {reset_value};")
    for port in inputs:
        if port.width == 1:
            lines.append(f"    {port.name} = 1'b0;")
        else:
            lines.append(f"    {port.name} = {port.width}'h0;")
    for port in inouts:
        if port.width == 1:
            lines.append(f"    _tb_drive_{port.name} = 1'b0;")
        else:
            lines.append(f"    _tb_drive_{port.name} = {port.width}'h0;")

    if fixture.sequential:
        for _ in range(fixture.reset_cycles):
            lines.append("    @(posedge clk);")
        deasserted = "1'b1" if fixture.reset_active_low else "1'b0"
        lines.append("    #1;")
        lines.append(f"    {fixture.reset} = {deasserted};")

    scan_token = "%h" if hex_io else "%d"
    scan_fmt = " ".join(scan_token for _ in stimulus_ports)
    scan_args = ", ".join(f"_stim_{i}" for i in range(len(stimulus_ports)))

    lines.append("    begin: stim_loop")
    lines.append("      while (1) begin")
    lines.append(f"        _r = $fscanf(stim_fd, \"{scan_fmt}\\n\", {scan_args});")
    lines.append(f"        if (_r != {len(stimulus_ports)}) disable stim_loop;")
    if fixture.sequential:
        lines.append("        @(negedge clk);")
    for i, port in enumerate(inputs):
        if port.width == 1:
            lines.append(f"        {port.name} = _stim_{i}[0];")
        else:
            lines.append(f"        {port.name} = _stim_{i}[{port.width - 1}:0];")
    inout_offset = len(inputs)
    for j, port in enumerate(inouts):
        stim_index = inout_offset + j
        if port.width == 1:
            lines.append(f"        _tb_drive_{port.name} = _stim_{stim_index}[0];")
        else:
            lines.append(
                f"        _tb_drive_{port.name} = _stim_{stim_index}[{port.width - 1}:0];"
            )
    if fixture.sequential:
        lines.append("        @(posedge clk);")
        lines.append("        #1;")
    else:
        lines.append("        #1;")
    out_token = "%0h" if hex_io else "%0d"
    out_fmt = " ".join(out_token for _ in trace_ports)
    out_args = ", ".join(port.name for port in trace_ports)
    lines.append(f"        $fwrite(out_fd, \"{out_fmt}\\n\", {out_args});")
    lines.append("      end")
    lines.append("    end")
    lines.append("    $fclose(stim_fd);")
    lines.append("    $fclose(out_fd);")
    lines.append("    $finish(0);")
    lines.append("  end")
    lines.append("endmodule")
    return "\n".join(lines) + "\n"


def render_systemc_tb(
    fixture: Fixture,
    stim_path: Path,
    out_path: Path,
    header_path: Path,
    include_root: Path,
) -> str:
    inputs = fixture.inputs
    inouts = fixture.inouts
    outputs = fixture.outputs
    stimulus_ports = (*inputs, *inouts)
    trace_ports = (*outputs, *inouts)
    hex_io = _uses_hex_io(fixture)

    try:
        include_rel = header_path.resolve().relative_to(include_root.resolve())
        include_directive = str(include_rel).replace(os.sep, "/")
    except ValueError:
        include_directive = header_path.name

    lines: list[str] = []
    lines.append("#include <fstream>")
    lines.append("#include <iostream>")
    lines.append("#include <string>")
    lines.append(f'#include "{include_directive}"')
    lines.append("")
    lines.append("int sc_main(int argc, char* argv[]) {")
    lines.append("  (void)argc; (void)argv;")
    if hex_io:
        lines.append("  auto __hex_token = [](const std::string& token) { return std::string(\"0x0\") + token; };")
        lines.append("  auto __trim_hex = [](std::string text) {")
        lines.append("    if (text.size() >= 2 && text[0] == '0' && (text[1] == 'x' || text[1] == 'X')) text.erase(0, 2);")
        lines.append("    while (text.size() > 1 && text[0] == '0') text.erase(0, 1);")
        lines.append("    return text.empty() ? std::string(\"0\") : text;")
        lines.append("  };")

    if fixture.sequential:
        lines.append("  sc_clock clk(\"clk\", 10, SC_NS, 0.5, 0, SC_NS, false);")
        lines.append(f"  sc_signal<bool> {fixture.reset};")
    for port in inputs:
        lines.append(f"  sc_signal<{port.sc_type}> {port.name};")
    for port in inouts:
        lines.append(f"  {port.sc_rv_type} {port.name};")
    for port in outputs:
        lines.append(f"  sc_signal<{port.sc_type}> {port.name};")
    lines.append("")

    sc_top = fixture.top
    if fixture.sc_template_args:
        sc_top = f"{sc_top}<{', '.join(fixture.sc_template_args)}>"
    elif _header_top_is_templated(header_path, fixture.top):
        sc_top = f"{sc_top}<>"
    lines.append(f"  {sc_top} dut(\"dut\");")
    if fixture.sequential:
        lines.append(f"  dut.{fixture.clock}(clk);")
        lines.append(f"  dut.{fixture.reset}({fixture.reset});")
    for port in inputs:
        lines.append(f"  dut.{port.name}({port.name});")
    for port in inouts:
        lines.append(f"  dut.{port.name}({port.name});")
    for port in outputs:
        lines.append(f"  dut.{port.name}({port.name});")
    lines.append("")

    lines.append(f"  std::ifstream stim(\"{stim_path.name}\");")
    lines.append(f"  std::ofstream out(\"{out_path.name}\");")
    lines.append("  if (!stim) { std::cerr << \"failed to open stimulus\\n\"; return 1; }")
    lines.append("  if (!out)  { std::cerr << \"failed to open output\\n\";   return 1; }")
    lines.append("")

    if fixture.sequential:
        reset_value = "false" if fixture.reset_active_low else "true"
        lines.append(f"  {fixture.reset}.write({reset_value});")
    for port in inputs:
        if port.is_bool:
            lines.append(f"  {port.name}.write(false);")
        else:
            lines.append(f"  {port.name}.write({port.sc_type}(0));")
    for port in inouts:
        lines.append(f"  {port.name}.write(sc_lv<{port.width}>(\"{'Z' * port.width}\"));")
    lines.append("")

    if fixture.sequential:
        lines.append(f"  sc_start({10 * fixture.reset_cycles}, SC_NS);")
        deasserted = "true" if fixture.reset_active_low else "false"
        lines.append(f"  {fixture.reset}.write({deasserted});")
    else:
        lines.append("  sc_start(1, SC_NS);")
    lines.append("")

    var_names = [f"v{i}" for i in range(len(stimulus_ports))]
    if hex_io:
        lines.append("  std::string " + ", ".join(var_names) + ";")
    else:
        lines.append("  long " + ", ".join(var_names) + ";")
    extract = "".join(f" >> {name}" for name in var_names)
    lines.append(f"  while (stim{extract}) {{")
    for i, port in enumerate(inputs):
        if port.is_bool:
            if hex_io:
                lines.append(f"    {port.name}.write({var_names[i]} != \"0\");")
            else:
                lines.append(f"    {port.name}.write({var_names[i]} != 0);")
        else:
            if hex_io:
                lines.append(
                    f"    {port.name}.write({port.sc_type}(__hex_token({var_names[i]}).c_str()));"
                )
            else:
                lines.append(f"    {port.name}.write({port.sc_type}({var_names[i]}));")
    inout_offset = len(inputs)
    for j, port in enumerate(inouts):
        stim_var = var_names[inout_offset + j]
        drive_expr = _systemc_external_drive_expr(fixture, port, var_names, hex_io=hex_io)
        if hex_io:
            drive_value = (
                f"sc_lv<{port.width}>({_systemc_unsigned_type(port.width)}"
                f"(__hex_token({stim_var}).c_str()))"
            )
        else:
            drive_value = f"sc_lv<{port.width}>(sc_uint<{port.width}>({stim_var}))"
        z_value = f"sc_lv<{port.width}>(\"{'Z' * port.width}\")"
        lines.append(
            f"    {port.name}.write(({drive_expr}) ? {drive_value} : {z_value});"
        )
    if fixture.sequential:
        lines.append("    sc_start(10, SC_NS);")
    else:
        lines.append("    sc_start(1, SC_NS);")

    out_parts: list[str] = []
    for port in trace_ports:
        if hex_io:
            if port in inouts:
                if port.is_bool:
                    out_parts.append(f"(({port.name}.read()[0] == sc_dt::SC_LOGIC_1) ? \"1\" : \"0\")")
                else:
                    out_parts.append(f"__trim_hex({port.name}.read().to_string(sc_dt::SC_HEX))")
            elif port.is_bool:
                out_parts.append(f"({port.name}.read() ? \"1\" : \"0\")")
            else:
                out_parts.append(f"__trim_hex({port.name}.read().to_string(sc_dt::SC_HEX))")
        elif port in inouts:
            if port.is_bool:
                out_parts.append(f"(int)({port.name}.read()[0] == sc_dt::SC_LOGIC_1)")
            elif port.signed:
                out_parts.append(f"sc_int<{port.width}>({port.name}.read().to_uint64()).to_int64()")
            else:
                out_parts.append(f"{port.name}.read().to_uint64()")
        elif port.is_bool:
            out_parts.append(f"(int){port.name}.read()")
        elif port.signed:
            out_parts.append(f"{port.name}.read().to_int64()")
        else:
            out_parts.append(f"{port.name}.read().to_uint64()")
    if len(out_parts) == 1:
        out_expr = out_parts[0]
    else:
        out_expr = (" << ' ' << ").join(out_parts)
    lines.append(f"    out << {out_expr} << '\\n';")
    lines.append("  }")
    lines.append("")
    lines.append("  sc_stop();")
    lines.append("  return 0;")
    lines.append("}")
    return "\n".join(lines) + "\n"


def _verilog_decl(kind: str, port: Port, *, name: str | None = None) -> str:
    signed = " signed" if port.signed else ""
    target = name or port.name
    if port.width == 1:
        return f"{kind}{signed} {target};"
    return f"{kind}{signed} [{port.width - 1}:0] {target};"


def _verilog_external_drive_expr(port: Port) -> str:
    if port.external_drive_control is None:
        return "1'b1"
    active = "1'b1" if port.external_drive_active else "1'b0"
    return f"{port.external_drive_control} == {active}"


def _systemc_external_drive_expr(
    fixture: Fixture,
    port: Port,
    var_names: list[str],
    *,
    hex_io: bool = False,
) -> str:
    if port.external_drive_control is None:
        return "true"
    for index, input_port in enumerate(fixture.inputs):
        if input_port.name == port.external_drive_control:
            if hex_io:
                active = '!= "0"' if port.external_drive_active else '== "0"'
            else:
                active = "!= 0" if port.external_drive_active else "== 0"
            return f"{var_names[index]} {active}"
    raise ValueError(
        f"inout port {port.name!r} references unknown external drive control "
        f"{port.external_drive_control!r}"
    )


def _systemc_unsigned_type(width: int) -> str:
    family = "biguint" if width > 64 else "uint"
    return f"sc_{family}<{width}>"


def diff_traces(rtl: list[str], sc: list[str], work: Path, shift: int) -> int:
    rtl_stripped = [line.strip() for line in rtl if line.strip() != ""]
    sc_stripped = [line.strip() for line in sc if line.strip() != ""]
    if shift > 0:
        sc_stripped = sc_stripped[shift:]
    n = min(len(rtl_stripped), len(sc_stripped))
    mismatches: list[tuple[int, str, str]] = []
    for i in range(n):
        if rtl_stripped[i] != sc_stripped[i]:
            mismatches.append((i, rtl_stripped[i], sc_stripped[i]))
    if len(rtl_stripped) != len(sc_stripped):
        print(f"  NOTE: trace length differs (rtl={len(rtl_stripped)} sc={len(sc_stripped)})")
    if mismatches:
        log_path = work / "diff.log"
        with log_path.open("w", encoding="utf-8") as log:
            for idx, r, s in mismatches:
                log.write(f"cycle {idx}: rtl={r!r} sc={s!r}\n")
        print(f"  MISMATCH: {len(mismatches)} of {n} cycle(s) differ (see {log_path})")
        for idx, r, s in mismatches[:5]:
            print(f"    cycle {idx}: rtl={r!r} sc={s!r}")
        return 1
    if n == 0:
        print("  ERROR: no cycles to compare")
        return 1
    print(f"  PASS: {n} cycle(s) match")
    return 0


def run_logged(
    cmd: list[str],
    log_path: Path,
    *,
    cwd: Path | None = None,
    env: dict[str, str] | None = None,
) -> int:
    print(f"  $ {' '.join(cmd)}")
    with log_path.open("w", encoding="utf-8") as log:
        result = subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, cwd=cwd, env=env)
    return result.returncode


def _locate_top_header(sc_out_dir: Path, top: str) -> Path | None:
    """Find the per-module hpp for ``top`` somewhere under ``sc_out_dir``."""
    candidate = sc_out_dir / f"{top}.hpp"
    if candidate.is_file():
        return candidate
    matches = sorted(sc_out_dir.rglob(f"{top}.hpp"))
    return matches[0] if matches else None


def _header_top_is_templated(header_path: Path, top: str) -> bool:
    """Return True when the generated SystemC header declares ``top`` as a template."""
    if not header_path.is_file():
        return False
    text = header_path.read_text(encoding="utf-8", errors="ignore")
    pattern = re.compile(
        rf"template\s*<[^>]*>\s*\n\s*SC_MODULE\(\s*{re.escape(top)}\s*\)",
        re.MULTILINE,
    )
    return bool(pattern.search(text))


if __name__ == "__main__":
    sys.exit(main())
