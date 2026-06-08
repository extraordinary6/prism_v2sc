"""Tests for Phase P6 - Profile collection."""

from __future__ import annotations

from pathlib import Path

from prism_v2sc.power.runner import (
    WorkloadMetadata,
    create_systemc_runner,
    parse_power_dump,
    create_power_profile_json,
)


def test_workload_metadata_creation() -> None:
    """Test creating workload metadata."""
    workload = WorkloadMetadata(
        name="test_workload",
        cycle_count=1000,
        top_module="test_top",
        sources=["test.v"],
    )

    assert workload.name == "test_workload"
    assert workload.cycle_count == 1000
    assert workload.top_module == "test_top"
    assert workload.reset_cycles == 10  # default


def test_create_systemc_runner_without_instrumentation() -> None:
    """Test creating SystemC runner without instrumentation."""
    runner_code = create_systemc_runner(Path("build"), instrumentation_enabled=False)

    assert "#include <systemc.h>" in runner_code
    assert "sc_main" in runner_code
    assert "sc_clock" in runner_code
    # Should not have dump code
    assert "prism_power_dump" not in runner_code


def test_create_systemc_runner_with_instrumentation() -> None:
    """Test creating SystemC runner with instrumentation."""
    runner_code = create_systemc_runner(Path("build"), instrumentation_enabled=True)

    assert "#include <systemc.h>" in runner_code
    assert "sc_main" in runner_code
    assert "prism_power_dump" in runner_code
    assert "Dumping power profile" in runner_code


def test_parse_power_dump(tmp_path: Path) -> None:
    """Test parsing power dump CSV."""
    dump_file = tmp_path / "dump.csv"
    dump_file.write_text(
        """# Power Profile Data
signal,sample_count,change_count,toggle_count
data_reg,1000,500,2500
counter,1000,800,3200
flag,1000,100,100
""",
        encoding="utf-8",
    )

    result = parse_power_dump(dump_file)

    assert "probes" in result
    assert len(result["probes"]) == 3

    # Check first probe
    probe = result["probes"][0]
    assert probe["signal"] == "data_reg"
    assert probe["sample_count"] == 1000
    assert probe["change_count"] == 500
    assert probe["toggle_count"] == 2500


def test_create_power_profile_json(tmp_path: Path) -> None:
    """Test creating power_profile.json from dump."""
    # Create dump file
    dump_file = tmp_path / "dump.csv"
    dump_file.write_text(
        """# Power Profile Data
signal,sample_count,change_count,toggle_count
test_signal,1000,500,2500
""",
        encoding="utf-8",
    )

    # Create workload metadata
    workload = WorkloadMetadata(
        name="test_workload",
        cycle_count=1000,
        top_module="test_top",
        sources=["test.v"],
    )

    # Generate profile JSON
    output_file = tmp_path / "profile.json"
    create_power_profile_json(dump_file, workload, output_file)

    # Verify output
    assert output_file.exists()

    import json
    with open(output_file, 'r', encoding='utf-8') as f:
        profile = json.load(f)

    assert profile["version"] == "1.0"
    assert profile["workload"]["name"] == "test_workload"
    assert profile["workload"]["total_cycles"] == 1000
    assert profile["workload"]["top_module"] == "test_top"
    assert len(profile["probes"]) == 1
    assert profile["probes"][0]["signal"] == "test_signal"


def test_parse_empty_dump(tmp_path: Path) -> None:
    """Test parsing empty dump file."""
    dump_file = tmp_path / "empty.csv"
    dump_file.write_text(
        """# Power Profile Data
signal,sample_count,change_count,toggle_count
""",
        encoding="utf-8",
    )

    result = parse_power_dump(dump_file)

    assert "probes" in result
    assert len(result["probes"]) == 0


def test_power_profile_json_format(tmp_path: Path) -> None:
    """Test that power_profile.json has correct format."""
    dump_file = tmp_path / "dump.csv"
    dump_file.write_text(
        """# Power Profile Data
signal,sample_count,change_count,toggle_count
sig1,100,50,250
sig2,100,30,120
""",
        encoding="utf-8",
    )

    workload = WorkloadMetadata(
        name="format_test",
        cycle_count=100,
        top_module="top",
        sources=["a.v", "b.v"],
        seed=42,
    )

    output_file = tmp_path / "profile.json"
    create_power_profile_json(dump_file, workload, output_file)

    import json
    with open(output_file, 'r', encoding='utf-8') as f:
        profile = json.load(f)

    # Check schema compliance
    assert "version" in profile
    assert "workload" in profile
    assert "probes" in profile

    # Check workload fields
    assert profile["workload"]["name"] == "format_test"
    assert profile["workload"]["total_cycles"] == 100
    assert profile["workload"]["sources"] == ["a.v", "b.v"]

    # Check probe fields
    assert len(profile["probes"]) == 2
    for probe in profile["probes"]:
        assert "signal" in probe
        assert "sample_count" in probe
        assert "change_count" in probe
        assert "toggle_count" in probe
