from __future__ import annotations

from pathlib import Path

from prism_v2sc.frontend.preprocess import collect_sources, parse_filelist


def test_parse_filelist_supports_include_define_and_nested_filelists(tmp_path: Path) -> None:
    include_dir = tmp_path / "inc"
    rtl_dir = tmp_path / "rtl"
    include_dir.mkdir()
    rtl_dir.mkdir()
    top = rtl_dir / "top.v"
    leaf = rtl_dir / "leaf.v"
    nested = tmp_path / "nested.f"
    root = tmp_path / "root.f"
    top.write_text("module top; endmodule\n", encoding="utf-8")
    leaf.write_text("module leaf; endmodule\n", encoding="utf-8")
    nested.write_text(
        """
-D CHILD_FLAG=1
rtl/leaf.v
""",
        encoding="utf-8",
    )
    root.write_text(
        """
# comment
// comment
-I inc
+incdir+inc
-DROOT_FLAG
-f nested.f
rtl/top.v
""",
        encoding="utf-8",
    )

    parsed = parse_filelist(root)

    assert parsed.sources == (leaf, top)
    assert parsed.include_dirs == (include_dir, include_dir)
    assert parsed.defines == ("ROOT_FLAG", "CHILD_FLAG=1")


def test_collect_sources_dedupes_sources_include_dirs_and_defines(tmp_path: Path) -> None:
    include_dir = tmp_path / "inc"
    include_dir.mkdir()
    top = tmp_path / "top.v"
    filelist = tmp_path / "sources.f"
    top.write_text("module top; endmodule\n", encoding="utf-8")
    filelist.write_text(
        """
-I inc
-Iinc
-D FLAG
-DFLAG
top.v
""",
        encoding="utf-8",
    )

    collected = collect_sources([top], [filelist])

    assert collected.sources == (top.resolve(),)
    assert collected.include_dirs == (include_dir.resolve(),)
    assert collected.defines == ("FLAG",)


def test_nested_filelist_cycle_is_reported(tmp_path: Path) -> None:
    root = tmp_path / "root.f"
    child = tmp_path / "child.f"
    root.write_text("-f child.f\n", encoding="utf-8")
    child.write_text("-f root.f\n", encoding="utf-8")

    try:
        parse_filelist(root)
    except ValueError as exc:
        assert "nested filelist cycle detected" in str(exc)
    else:
        raise AssertionError("expected nested filelist cycle to raise ValueError")


def test_unsupported_filelist_option_is_reported(tmp_path: Path) -> None:
    filelist = tmp_path / "sources.f"
    filelist.write_text("+libext+.v\n", encoding="utf-8")

    try:
        parse_filelist(filelist)
    except ValueError as exc:
        assert "unsupported filelist option" in str(exc)
        assert "+libext+.v" in str(exc)
    else:
        raise AssertionError("expected unsupported option to raise ValueError")
