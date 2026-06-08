"""Tests for Phase P7 - Scoring and reporting."""

from __future__ import annotations

import json
from pathlib import Path

from prism_v2sc.power.scoring import (
    calculate_activity_rate,
    calculate_toggle_density,
    score_signal,
    combine_static_and_dynamic,
    generate_recommendation,
    generate_power_report,
)


def test_calculate_activity_rate() -> None:
    """Test activity rate calculation."""
    # 50% activity
    assert calculate_activity_rate(500, 1000) == 0.5

    # 100% activity
    assert calculate_activity_rate(1000, 1000) == 1.0

    # Low activity
    assert calculate_activity_rate(10, 1000) == 0.01

    # Zero samples
    assert calculate_activity_rate(0, 0) == 0.0


def test_calculate_toggle_density() -> None:
    """Test toggle density calculation."""
    # 1 toggle per bit per cycle
    assert calculate_toggle_density(1000, 10, 100) == 1.0

    # 0.5 toggles per bit per cycle
    assert calculate_toggle_density(500, 10, 100) == 0.5

    # Zero width or samples
    assert calculate_toggle_density(1000, 0, 100) == 0.0
    assert calculate_toggle_density(1000, 10, 0) == 0.0


def test_score_signal_basic() -> None:
    """Test basic signal scoring."""
    # High activity, wide signal
    score = score_signal(
        "test_sig",
        width=64,
        sample_count=1000,
        change_count=800,
        toggle_count=25600,  # 0.4 toggle per bit per cycle
        static_reasons=[],
    )

    # Should have significant score
    assert score > 20


def test_score_signal_with_static_reasons() -> None:
    """Test scoring with static analysis flags."""
    # Same signal, but with static reasons
    score_no_static = score_signal(
        "test_sig",
        width=64,
        sample_count=1000,
        change_count=800,
        toggle_count=25600,
        static_reasons=[],
    )

    score_with_static = score_signal(
        "test_sig",
        width=64,
        sample_count=1000,
        change_count=800,
        toggle_count=25600,
        static_reasons=["clock_gating_candidate", "counter_activity_candidate"],
    )

    # Score with static reasons should be higher
    assert score_with_static > score_no_static


def test_score_signal_caps_at_100() -> None:
    """Test that score is capped at 100."""
    # Extreme case
    score = score_signal(
        "extreme_sig",
        width=512,
        sample_count=1000,
        change_count=1000,
        toggle_count=512000,  # 1 toggle per bit per cycle
        static_reasons=["clock_gating_candidate"],
    )

    assert score <= 100


def test_combine_static_and_dynamic(tmp_path: Path) -> None:
    """Test combining static and dynamic data."""
    static_data = {
        "suspects": [
            {
                "signal": "sig1",
                "reason_code": "clock_gating_candidate",
                "source_loc": {"file": "test.v", "line": 10, "column": 5},
            },
            {
                "signal": "sig2",
                "reason_code": "high_fanout_candidate",
            },
        ]
    }

    profile_data = {
        "probes": [
            {
                "module": "test_module",
                "signal": "sig1",
                "width": 64,
                "sample_count": 1000,
                "change_count": 800,
                "toggle_count": 25600,
            },
            {
                "module": "test_module",
                "signal": "sig2",
                "width": 8,
                "sample_count": 1000,
                "change_count": 100,
                "toggle_count": 400,
            },
        ]
    }

    hotspots = combine_static_and_dynamic(static_data, profile_data)

    # Should have 2 hotspots
    assert len(hotspots) == 2

    # Should be ranked
    assert hotspots[0].rank == 1
    assert hotspots[1].rank == 2

    # Higher score should be rank 1
    assert hotspots[0].score > hotspots[1].score

    # Check static reasons
    sig1_hotspot = next(h for h in hotspots if h.signal == "sig1")
    assert "clock_gating_candidate" in sig1_hotspot.static_reasons

    # Check source location
    assert sig1_hotspot.source_loc is not None
    assert sig1_hotspot.source_loc["file"] == "test.v"


def test_generate_recommendation() -> None:
    """Test recommendation generation."""
    # Clock gating candidate
    rec = generate_recommendation(
        "sig1",
        score=80.0,
        static_reasons=["clock_gating_candidate"],
        change_count=800,
        sample_count=1000,
    )
    assert "clock gating" in rec.lower()

    # Counter with high activity
    rec = generate_recommendation(
        "counter",
        score=70.0,
        static_reasons=["counter_activity_candidate"],
        change_count=900,
        sample_count=1000,
    )
    assert "counter" in rec.lower() or "frequency" in rec.lower()

    # Low score
    rec = generate_recommendation(
        "low_sig",
        score=5.0,
        static_reasons=[],
        change_count=10,
        sample_count=1000,
    )
    assert "no action" in rec.lower() or "low" in rec.lower()


def test_generate_power_report(tmp_path: Path) -> None:
    """Test full power report generation."""
    # Create static analysis file
    static_file = tmp_path / "power_static.json"
    static_data = {
        "version": "1.0",
        "design": {"top_module": "test_top"},
        "suspects": [
            {
                "module": "cpu",
                "signal": "data_reg",
                "reason_code": "clock_gating_candidate",
                "message": "Wide register",
                "recommendation": "Add gating",
                "source_loc": {"file": "cpu.v", "line": 42, "column": 10},
            }
        ],
    }
    with open(static_file, 'w', encoding='utf-8') as f:
        json.dump(static_data, f)

    # Create profile file
    profile_file = tmp_path / "power_profile.json"
    profile_data = {
        "version": "1.0",
        "workload": {
            "name": "test_workload",
            "total_cycles": 1000,
            "top_module": "test_top",
        },
        "probes": [
            {
                "module": "cpu",
                "signal": "data_reg",
                "width": 64,
                "sample_count": 1000,
                "change_count": 800,
                "toggle_count": 25600,
            },
            {
                "module": "cpu",
                "signal": "flag",
                "width": 1,
                "sample_count": 1000,
                "change_count": 50,
                "toggle_count": 50,
            },
        ],
    }
    with open(profile_file, 'w', encoding='utf-8') as f:
        json.dump(profile_data, f)

    # Generate report
    output_file = tmp_path / "power_report.json"
    report = generate_power_report(static_file, profile_file, output_file)

    # Verify report structure
    assert report["version"] == "1.0"
    assert "hotspots" in report
    assert "summary" in report

    # Check hotspots
    assert len(report["hotspots"]) > 0
    hotspot = report["hotspots"][0]
    assert "rank" in hotspot
    assert "signal" in hotspot
    assert "score" in hotspot
    assert "recommendation" in hotspot

    # Check summary
    assert report["summary"]["total_signals"] == 2
    assert "analysis_note" in report["summary"]
    assert "workload" in report["summary"]["analysis_note"].lower()

    # Verify file was written
    assert output_file.exists()


def test_report_without_static_data(tmp_path: Path) -> None:
    """Test report generation without static analysis."""
    # Create profile file only
    profile_file = tmp_path / "power_profile.json"
    profile_data = {
        "version": "1.0",
        "workload": {
            "name": "test_workload",
            "total_cycles": 1000,
            "top_module": "test_top",
        },
        "probes": [
            {
                "module": "test",
                "signal": "sig1",
                "width": 32,
                "sample_count": 1000,
                "change_count": 500,
                "toggle_count": 8000,
            }
        ],
    }
    with open(profile_file, 'w', encoding='utf-8') as f:
        json.dump(profile_data, f)

    # Generate report without static data
    output_file = tmp_path / "report.json"
    report = generate_power_report(None, profile_file, output_file)

    # Should still work
    assert len(report["hotspots"]) == 1
    assert report["hotspots"][0]["static_reasons"] == []


def test_top_k_filtering(tmp_path: Path) -> None:
    """Test top-K hotspot filtering."""
    # Create profile with many signals
    profile_file = tmp_path / "profile.json"
    probes = [
        {
            "module": "test",
            "signal": f"sig{i}",
            "width": 8,
            "sample_count": 1000,
            "change_count": 100 + i * 10,
            "toggle_count": 800 + i * 80,
        }
        for i in range(100)
    ]

    profile_data = {
        "version": "1.0",
        "workload": {"name": "test", "total_cycles": 1000, "top_module": "test"},
        "probes": probes,
    }
    with open(profile_file, 'w', encoding='utf-8') as f:
        json.dump(profile_data, f)

    # Generate report with top_k=10
    output_file = tmp_path / "report.json"
    report = generate_power_report(None, profile_file, output_file, top_k=10)

    # Should only have top 10
    assert len(report["hotspots"]) == 10
    assert report["summary"]["hotspot_count"] == 10
    assert report["summary"]["total_signals"] == 100
