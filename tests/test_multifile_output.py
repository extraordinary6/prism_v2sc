"""Tests for the per-module file output layout and streaming behavior."""

from __future__ import annotations

import json
import os
from pathlib import Path

from prism_v2sc.cli import main
from prism_v2sc.codegen.systemc import _render_module_implementation_chunks, emit_systemc_files
from prism_v2sc.frontend.flow import (
    compute_source_root,
    lower_design_top_down,
)
from prism_v2sc.ir.model import ModuleIR
from prism_v2sc.verify.harness import convert_with_metrics


def test_per_module_files_mirror_rtl_directory_structure(tmp_path: Path) -> None:
    rtl_root = tmp_path / "rtl"
    (rtl_root / "top").mkdir(parents=True)
    (rtl_root / "leaf").mkdir(parents=True)

    leaf = rtl_root / "leaf" / "leaf.v"
    top = rtl_root / "top" / "top.v"
    leaf.write_text(
        "module leaf(input wire a, output wire y); assign y = a; endmodule\n",
        encoding="utf-8",
    )
    top.write_text(
        """
module top(input wire a, output wire y);
  leaf u_leaf(.a(a), .y(y));
endmodule
""",
        encoding="utf-8",
    )

    out_dir = tmp_path / "sc"
    assert main(["--top", "top", "--out", str(out_dir), str(top), str(leaf)]) == 0

    # Each module gets its own file mirroring the source dir under rtl/.
    assert (out_dir / "top" / "top.hpp").is_file()
    assert (out_dir / "leaf" / "leaf.hpp").is_file()
    # No umbrella file.
    assert not (out_dir / "prism_v2sc.hpp").exists()

    top_hpp = (out_dir / "top" / "top.hpp").read_text(encoding="utf-8")
    # Parent must #include the child via the relative mirrored path.
    assert '#include "../leaf/leaf.hpp"' in top_hpp
    assert "SC_MODULE(top)" in top_hpp


def test_top_only_emits_single_file_when_source_is_alone(tmp_path: Path) -> None:
    rtl = tmp_path / "only.v"
    rtl.write_text(
        "module only(input wire a, output wire y); assign y = a; endmodule\n",
        encoding="utf-8",
    )
    out_dir = tmp_path / "sc"
    assert main(["--top", "only", "--out", str(out_dir), str(rtl)]) == 0

    assert (out_dir / "only.hpp").is_file()
    listed = sorted(p.name for p in out_dir.iterdir() if p.is_file())
    assert listed == ["ir.json", "only.hpp"]


def test_compile_friendly_mode_uses_shared_runtime_and_out_of_line_methods(tmp_path: Path) -> None:
    rtl = tmp_path / "friendly.v"
    rtl.write_text(
        "module friendly(input wire a, output wire y); assign y = ~a; endmodule\n",
        encoding="utf-8",
    )
    out_dir = tmp_path / "sc"

    assert main([
        "--top", "friendly", "--out", str(out_dir), "--compile-friendly", str(rtl),
    ]) == 0

    header = (out_dir / "friendly.hpp").read_text(encoding="utf-8")
    implementation = (out_dir / "friendly__impl_000.cpp").read_text(encoding="utf-8")
    runtime = (out_dir / "prism_v2sc_runtime.hpp").read_text(encoding="utf-8")
    assert '#include "prism_v2sc_runtime.hpp"' in header
    assert "#include <systemc>" not in header
    assert "void assign_0();" in header
    assert "void friendly::assign_0()" in implementation
    assert "#include <systemc>" in runtime


def test_compile_friendly_mode_hoists_reads_and_removes_exact_branch_casts(tmp_path: Path) -> None:
    rtl = tmp_path / "friendly_expr.sv"
    rtl.write_text(
        """
module friendly_expr(
  input logic sel,
  input logic [7:0] a,
  input logic [7:0] b,
  output logic [7:0] y,
  output logic [7:0] z
);
  always_comb begin
    y = sel ? a : b;
    z = (a ^ b) + a;
  end
endmodule
""",
        encoding="utf-8",
    )
    out_dir = tmp_path / "sc"

    assert main([
        "--top", "friendly_expr", "--out", str(out_dir),
        "--compile-friendly", str(rtl),
    ]) == 0

    implementation = (out_dir / "friendly_expr__impl_000.cpp").read_text(encoding="utf-8")
    assert "const auto __prism_read_" in implementation
    assert "sc_uint<8>(a.read())" not in implementation
    assert "sc_uint<8>(b.read())" not in implementation
    assert implementation.count("a.read()") == 1
    assert implementation.count("b.read()") == 1


def test_emit_is_post_order_so_children_exist_before_parents(tmp_path: Path) -> None:
    leaf = tmp_path / "leaf.v"
    top = tmp_path / "top.v"
    leaf.write_text(
        "module leaf(input wire a, output wire y); assign y = a; endmodule\n",
        encoding="utf-8",
    )
    top.write_text(
        """
module top(input wire a, output wire y);
  leaf u_leaf(.a(a), .y(y));
endmodule
""",
        encoding="utf-8",
    )

    emitted_order: list[str] = []
    out_dir = tmp_path / "sc"
    out_dir.mkdir()
    source_root = compute_source_root([top, leaf])

    flow = lower_design_top_down(
        [top, leaf],
        "top",
        emit_callback=lambda module, signatures: emitted_order.append(module.name),
    )
    # Bottom-up: leaf first, then top.
    assert emitted_order == ["leaf", "top"]
    # And the design.modules order is still discovery (top-down) order.
    assert [module.name for module in flow.design.modules] == ["top", "leaf"]

    # Streaming end-to-end via emit_systemc_files writes both files.
    paths = emit_systemc_files(
        flow.design,
        out_dir,
        source_root,
        signatures=flow.signatures,
    )
    names = sorted(path.name for path in paths)
    assert names == ["leaf.hpp", "top.hpp"]


def test_positional_port_bindings_resolved_via_signature(tmp_path: Path) -> None:
    rtl = tmp_path / "pos.v"
    rtl.write_text(
        """
module leaf(input wire a, input wire b, output wire y);
  assign y = a & b;
endmodule

module top(input wire x, input wire z, output wire q);
  leaf u(x, z, q);
endmodule
""",
        encoding="utf-8",
    )
    out_dir = tmp_path / "sc"
    assert main(["--top", "top", "--out", str(out_dir), str(rtl)]) == 0
    top_hpp = (out_dir / "top.hpp").read_text(encoding="utf-8")

    # Positional bindings should now be named through child's signature.
    assert "u.a(x);" in top_hpp
    assert "u.b(z);" in top_hpp
    assert "u.y(q);" in top_hpp
    assert "// Positional port binding not emitted" not in top_hpp


def test_each_source_parsed_once_under_streaming(tmp_path: Path) -> None:
    """A source defining two reachable modules is parsed only once.

    Eager-lower-on-parse means both modules are lowered together; subsequent
    visit calls return cached IR rather than re-parsing the source.
    """
    rtl = tmp_path / "duo.v"
    rtl.write_text(
        """
module leaf(input wire a, output wire y); assign y = a; endmodule
module top(input wire a, output wire y0, output wire y1);
  leaf u0(.a(a), .y(y0));
  leaf u1(.a(a), .y(y1));
endmodule
""",
        encoding="utf-8",
    )
    flow = lower_design_top_down([rtl], "top")
    assert flow.traversal.source_parse_count == 1
    assert flow.traversal.module_lower_count == 2


def test_incremental_codegen_reuses_unchanged_modules(tmp_path: Path) -> None:
    rtl = tmp_path / "cached.v"
    rtl.write_text(
        """
module leaf(input wire a, output wire y); assign y = a; endmodule
module top(input wire a, output wire y); leaf u(.a(a), .y(y)); endmodule
""",
        encoding="utf-8",
    )
    out = tmp_path / "out"
    args = ["--top", "top", "--out", str(out), "--incremental-codegen", "--no-ir", str(rtl)]

    assert main(args) == 0
    cache_path = out / ".prism_codegen_cache.json"
    first = json.loads(cache_path.read_text(encoding="utf-8"))
    mtimes = {path.name: path.stat().st_mtime_ns for path in out.glob("*.hpp")}
    assert first["last_run"] == {"bootstrapped": 0, "module_count": 2, "rendered": 2, "reused": 0}

    assert main(args) == 0
    second = json.loads(cache_path.read_text(encoding="utf-8"))
    assert second["last_run"] == {"bootstrapped": 0, "module_count": 2, "rendered": 0, "reused": 2}
    assert {path.name: path.stat().st_mtime_ns for path in out.glob("*.hpp")} == mtimes


def test_incremental_frontend_cache_invalidates_on_source_change(tmp_path: Path) -> None:
    rtl = tmp_path / "cached_frontend.v"
    rtl.write_text(
        "module cached_frontend(input wire a, output wire y); assign y = a; endmodule\n",
        encoding="utf-8",
    )
    out = tmp_path / "out"

    first = convert_with_metrics(
        [rtl],
        "cached_frontend",
        out_dir=out,
        source_root=tmp_path,
        incremental_codegen=True,
        track_memory=False,
    )
    second = convert_with_metrics(
        [rtl],
        "cached_frontend",
        out_dir=out,
        source_root=tmp_path,
        incremental_codegen=True,
        track_memory=False,
    )

    assert first.report.frontend_cache_hit is False
    assert second.report.frontend_cache_hit is True
    assert (out / ".prism_frontend_cache.pkl").is_file()

    rtl.write_text(
        "module cached_frontend(input wire a, output wire y); assign y = ~a; endmodule\n",
        encoding="utf-8",
    )
    changed = convert_with_metrics(
        [rtl],
        "cached_frontend",
        out_dir=out,
        source_root=tmp_path,
        incremental_codegen=True,
        track_memory=False,
    )
    assert changed.report.frontend_cache_hit is False


def test_large_module_emits_split_implementation_files(tmp_path: Path) -> None:
    rtl = tmp_path / "large_split.sv"
    signal_count = 300
    declarations = "\n".join(
        f"  logic [7:0] stage_{index};" for index in range(signal_count)
    )
    assignments = ["  assign stage_0 = a;"]
    assignments.extend(
        f"  assign stage_{index} = stage_{index - 1};"
        for index in range(1, signal_count)
    )
    assignments.append(f"  assign y = stage_{signal_count - 1};")
    rtl.write_text(
        "\n".join(
            [
                "module large_split(input logic [7:0] a, output logic [7:0] y);",
                declarations,
                *assignments,
                "endmodule",
            ]
        ),
        encoding="utf-8",
    )
    out = tmp_path / "out"

    assert main(["--top", "large_split", "--out", str(out), "--no-ir", str(rtl)]) == 0

    header = (out / "large_split.hpp").read_text(encoding="utf-8")
    implementations = sorted(out.glob("large_split__impl_*.cpp"))
    assert "void assign_group_0_63();" in header
    assert "inline void large_split::assign_group_0_63()" not in header
    assert implementations
    assert max(path.stat().st_size for path in implementations) < 300 * 1024
    implementation_text = "\n".join(path.read_text(encoding="utf-8") for path in implementations)
    assert "void large_split::assign_group_0_63()" in implementation_text


def test_heavy_expression_method_gets_dedicated_implementation_chunk(tmp_path: Path) -> None:
    module = ModuleIR(name="heavy_expression")
    chunks = _render_module_implementation_chunks(
        module,
        [
            ("ordinary_before", ("value.write(0);",)),
            ("heavy", ("value.write(" + "x" * (33 * 1024) + ");",)),
            ("ordinary_after", ("value.write(1);",)),
        ],
        tmp_path,
        tmp_path,
    )

    assert len(chunks) == 3
    assert "ordinary_before" in chunks[0][1]
    assert "heavy" in chunks[1][1]
    assert "ordinary_after" in chunks[2][1]


def test_reuse_generated_module_bootstraps_only_named_module(tmp_path: Path) -> None:
    rtl = tmp_path / "frozen.v"
    rtl.write_text(
        """
module leaf(input wire a, output wire y); assign y = a; endmodule
module top(input wire a, output wire y); leaf u(.a(a), .y(y)); endmodule
""",
        encoding="utf-8",
    )
    out = tmp_path / "out"
    out.mkdir()
    frozen = out / "leaf.hpp"
    frozen.write_text("// trusted pre-generated leaf\n", encoding="utf-8")

    assert main([
        "--top", "top", "--out", str(out), "--no-ir",
        "--reuse-generated-module", "leaf", str(rtl),
    ]) == 0
    cache = json.loads((out / ".prism_codegen_cache.json").read_text(encoding="utf-8"))
    assert frozen.read_text(encoding="utf-8") == "// trusted pre-generated leaf\n"
    assert cache["last_run"] == {"bootstrapped": 1, "module_count": 2, "rendered": 1, "reused": 0}

    assert main([
        "--top", "top", "--out", str(out), "--incremental-codegen", "--no-ir", str(rtl),
    ]) == 0
    refreshed = json.loads((out / ".prism_codegen_cache.json").read_text(encoding="utf-8"))
    assert frozen.read_text(encoding="utf-8").startswith("// Generated by prism_v2sc")
    assert refreshed["last_run"] == {
        "bootstrapped": 0,
        "module_count": 2,
        "rendered": 1,
        "reused": 1,
    }
