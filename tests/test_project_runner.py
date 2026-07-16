from __future__ import annotations

import json
from pathlib import Path

import pytest

from prism_v2sc.project import load_project_manifest, run_project


def test_project_runner_converts_ordered_stages_and_writes_audits(tmp_path: Path) -> None:
    leaf = tmp_path / "leaf.v"
    top = tmp_path / "top.v"
    leaf.write_text("module leaf(input a, output y); assign y=a; endmodule\n", encoding="utf-8")
    top.write_text("module top(input a, output y); leaf u(.a(a),.y(y)); endmodule\n", encoding="utf-8")
    manifest_path = tmp_path / "project.json"
    manifest_path.write_text(json.dumps({
        "version": 1, "name": "demo", "output_root": "out",
        "stages": [
            {"name": "leaf", "top": "leaf", "sources": ["leaf.v"]},
            {"name": "integration", "top": "top", "sources": ["leaf.v", "top.v"],
             "depends_on": ["leaf"]},
        ],
    }), encoding="utf-8")

    manifest = load_project_manifest(manifest_path)
    assert run_project(manifest) == 0
    report = json.loads((tmp_path / "out/project_report.json").read_text(encoding="utf-8"))
    assert [stage["status"] for stage in report["stages"]] == ["passed", "passed"]
    assert (tmp_path / "out/leaf/conversion_audit.json").is_file()
    assert (tmp_path / "out/integration/systemc/top.hpp").is_file()


def test_project_manifest_rejects_forward_dependency(tmp_path: Path) -> None:
    rtl = tmp_path / "top.v"
    rtl.write_text("module top; endmodule\n", encoding="utf-8")
    manifest_path = tmp_path / "project.json"
    manifest_path.write_text(json.dumps({
        "version": 1,
        "stages": [
            {"name": "first", "top": "top", "sources": ["top.v"], "depends_on": ["later"]},
            {"name": "later", "top": "top", "sources": ["top.v"]},
        ],
    }), encoding="utf-8")
    with pytest.raises(ValueError, match="later stage or cycle"):
        load_project_manifest(manifest_path)
