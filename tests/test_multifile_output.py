"""Tests for the per-module file output layout and streaming behavior."""

from __future__ import annotations

import os
from pathlib import Path

from prism_v2sc.cli import main
from prism_v2sc.codegen.systemc import emit_systemc_files
from prism_v2sc.frontend.flow import (
    compute_source_root,
    lower_design_top_down,
)


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
