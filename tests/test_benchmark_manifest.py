import importlib.util
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("run_benchmark_suite", ROOT / "verification/run_benchmark_suite.py")
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


def test_real_design_benchmark_manifest_is_valid_and_diverse() -> None:
    benchmarks = MODULE.load_manifest(ROOT / "verification/benchmarks.json")
    assert len(benchmarks) >= 7
    assert {item["domain"] for item in benchmarks} >= {"cpu", "accelerator", "dsp", "bus", "model_provider"}
    assert all(item["contract"] for item in benchmarks)


def test_benchmark_runner_writes_incremental_report_for_unavailable_case(tmp_path: Path) -> None:
    manifest = tmp_path / "benchmarks.json"
    manifest.write_text(
        '{"version": 1, "benchmarks": [{"name": "missing", "domain": "test", '
        '"source_root": "missing", "command": ["false"], "contract": "smoke"}]}\n',
        encoding="utf-8",
    )
    report = tmp_path / "report.json"
    assert MODULE.run_suite(manifest, set(), report, False) == 1
    assert MODULE.json.loads(report.read_text(encoding="utf-8"))["results"][0]["status"] == "unavailable"


def test_benchmark_baseline_references_existing_evidence() -> None:
    root = Path(__file__).resolve().parents[1]
    payload = MODULE.json.loads((root / "verification/benchmark_baseline.json").read_text(encoding="utf-8"))
    assert payload["evidence_type"] == "documented_regression_baseline"
    assert len(payload["benchmarks"]) == 7
    assert all((root / item["evidence"]).exists() for item in payload["benchmarks"])
