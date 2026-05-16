from __future__ import annotations

import json
from pathlib import Path

from prism_v2sc.cli import main
from prism_v2sc.frontend.flow import build_source_index, lower_design_top_down


def test_source_index_maps_modules_to_files(tmp_path: Path) -> None:
    top = tmp_path / "top.v"
    leaf = tmp_path / "leaf.v"
    top.write_text("module top; endmodule\n", encoding="utf-8")
    leaf.write_text("module leaf; endmodule\n", encoding="utf-8")

    index = build_source_index([top, leaf])

    assert index.by_module == {"top": (top,), "leaf": (leaf,)}


def test_top_down_flow_skips_unused_sources_and_dedupes_repeated_instances(tmp_path: Path) -> None:
    leaf = tmp_path / "leaf.v"
    top = tmp_path / "top.v"
    unused = tmp_path / "unused.v"
    leaf.write_text(
        "module leaf(input wire a, output wire y); assign y = a; endmodule\n",
        encoding="utf-8",
    )
    top.write_text(
        """
module top(input wire a, output wire y0, output wire y1);
  leaf u0(.a(a), .y(y0));
  leaf u1(.a(a), .y(y1));
endmodule
""",
        encoding="utf-8",
    )
    unused.write_text(
        "module unused(input wire a, output wire y); assign y = ~a; endmodule\n",
        encoding="utf-8",
    )

    flow = lower_design_top_down([top, leaf, unused], "top")

    assert [module.name for module in flow.design.modules] == ["top", "leaf"]
    assert flow.traversal.source_parse_count == 2
    assert flow.traversal.module_lower_count == 2
    assert flow.traversal.visited_modules == ("top", "leaf")


def test_top_down_flow_reports_missing_and_ambiguous_modules(tmp_path: Path) -> None:
    top = tmp_path / "top.v"
    dup_a = tmp_path / "dup_a.v"
    dup_b = tmp_path / "dup_b.v"
    top.write_text(
        """
module top(input wire a, output wire y);
  missing u_missing(.a(a), .y(y));
  dup u_dup(.a(a), .y(y));
endmodule
""",
        encoding="utf-8",
    )
    dup_a.write_text("module dup(input wire a, output wire y); assign y = a; endmodule\n", encoding="utf-8")
    dup_b.write_text("module dup(input wire a, output wire y); assign y = ~a; endmodule\n", encoding="utf-8")

    flow = lower_design_top_down([top, dup_a, dup_b], "top")
    codes = {diagnostic.code for diagnostic in flow.design.diagnostics}

    assert codes == {"unresolved_instance_module", "ambiguous_module_definition"}
    assert flow.traversal.missing_modules == ("missing",)
    assert flow.traversal.ambiguous_modules == ("dup",)


def test_top_down_flow_rejects_missing_top(tmp_path: Path) -> None:
    rtl = tmp_path / "top.v"
    rtl.write_text("module top; endmodule\n", encoding="utf-8")

    try:
        lower_design_top_down([rtl], "missing")
    except ValueError as exc:
        assert "top module 'missing' not found" in str(exc)
        assert "known modules: top" in str(exc)
    else:
        raise AssertionError("expected missing top to raise ValueError")


def test_cli_metrics_include_phase7_traversal_fields(tmp_path: Path) -> None:
    leaf = tmp_path / "leaf.v"
    top = tmp_path / "top.v"
    filelist = tmp_path / "sources.f"
    out_dir = tmp_path / "systemc"
    leaf.write_text("module leaf(input wire a, output wire y); assign y = a; endmodule\n", encoding="utf-8")
    top.write_text(
        """
module top(input wire a, output wire y0, output wire y1);
  leaf u0(.a(a), .y(y0));
  leaf u1(.a(a), .y(y1));
endmodule
""",
        encoding="utf-8",
    )
    filelist.write_text("top.v\nleaf.v\n", encoding="utf-8")

    assert main(["--top", "top", "--filelist", str(filelist), "--metrics", "--out", str(out_dir)]) == 0

    metrics = json.loads((out_dir / "metrics.json").read_text(encoding="utf-8"))
    assert metrics["source_count"] == 2
    assert metrics["source_parse_count"] == 2
    assert metrics["module_lower_count"] == 2
    assert metrics["visited_modules"] == ["top", "leaf"]
    assert metrics["source_index"]["elapsed_seconds"] >= 0
    assert metrics["traversal"]["elapsed_seconds"] >= 0
