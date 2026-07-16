from pathlib import Path

from prism_v2sc.verify.coverage_registry import validate_coverage_registry


def test_checked_in_coverage_registry_has_real_evidence() -> None:
    root = Path(__file__).resolve().parents[1]
    counts = validate_coverage_registry(root / "docs/rtl_coverage_registry.json", root)
    assert counts["supported"] >= 6
    assert counts["rejected"] >= 1
    assert counts["not_tested"] >= 1
