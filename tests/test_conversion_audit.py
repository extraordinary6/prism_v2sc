from __future__ import annotations

import json
from pathlib import Path

from prism_v2sc.cli import main


def test_conversion_audit_records_coverage_and_policy(tmp_path: Path) -> None:
    rtl = tmp_path / "top.v"
    rtl.write_text(
        "module top(input a, output y); assign y = a; endmodule\n",
        encoding="utf-8",
    )
    policy = tmp_path / "policy.json"
    policy.write_text(json.dumps({"version": 1, "fail_severities": ["error"]}), encoding="utf-8")
    audit_path = tmp_path / "audit.json"

    assert main([
        "--top", "top", "--diagnostic-policy", str(policy),
        "--conversion-audit", str(audit_path), str(rtl),
    ]) == 0
    audit = json.loads(audit_path.read_text(encoding="utf-8"))
    assert audit["status"] == "passed"
    assert audit["source_count"] == 1
    assert audit["reachable_module_count"] == 1
    assert audit["generated_module_count"] == 1
    assert audit["policy_failure_count"] == 0
    assert audit["source_category_counts"] == {"design": 1}
    assert audit["modules"] == [
        {"name": "top", "provider": "", "source": str(rtl.resolve()), "status": "generated"}
    ]


def test_diagnostic_policy_can_deny_warning(tmp_path: Path) -> None:
    rtl = tmp_path / "xz.v"
    rtl.write_text("module top(input a, output y); assign y = 1'bx; endmodule\n", encoding="utf-8")
    policy = tmp_path / "policy.json"
    policy.write_text(
        json.dumps({"version": 1, "fail_severities": [], "deny_codes": ["x_z_literal_approximated"]}),
        encoding="utf-8",
    )

    assert main([
        "--top", "top", "--diagnostic-policy", str(policy),
        "--out", str(tmp_path / "out"), str(rtl),
    ]) == 2
