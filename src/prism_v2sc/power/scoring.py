"""Power scoring and hotspot reporting.

This module combines static analysis with dynamic profiling data to generate
scored power hotspot reports.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass
class PowerHotspot:
    """A scored power hotspot."""

    rank: int
    module: str
    signal: str
    score: float
    width: int | None
    toggle_count: int
    activity_rate: float
    static_reasons: list[str]
    recommendation: str
    source_loc: dict[str, Any] | None
    confidence: str = "medium"  # low, medium, high
    signal_class: str = "unknown"
    instance_path: str | None = None
    dimensions: list[str] | None = None
    metrics: dict[str, Any] | None = None
    limitations: list[str] | None = None


def calculate_activity_rate(change_count: int, sample_count: int) -> float:
    """Calculate activity rate (change rate).

    Args:
        change_count: Number of value changes
        sample_count: Number of samples

    Returns:
        Activity rate between 0.0 and 1.0
    """
    if sample_count == 0:
        return 0.0
    return min(change_count / sample_count, 1.0)


def calculate_toggle_density(toggle_count: int, width: int, sample_count: int) -> float:
    """Calculate toggle density (toggles per bit per cycle).

    Args:
        toggle_count: Total bit toggles
        width: Signal width in bits
        sample_count: Number of samples

    Returns:
        Toggle density
    """
    if sample_count == 0 or width == 0:
        return 0.0
    return toggle_count / (width * sample_count)


def score_signal(
    signal_name: str,
    width: int | None,
    sample_count: int,
    change_count: int,
    toggle_count: int,
    static_reasons: list[str],
) -> float:
    """Calculate power score for a signal.

    Scoring combines:
    - Width (wider signals consume more power)
    - Activity rate (more changes = more power)
    - Toggle count (absolute toggles)
    - Static analysis flags (structural risks)

    Args:
        signal_name: Signal name
        width: Signal width (None = 1)
        sample_count: Number of samples
        change_count: Number of value changes
        toggle_count: Total bit toggles
        static_reasons: List of static reason codes

    Returns:
        Power score (0-100, higher = more power)
    """
    if width is None:
        width = 1

    # Base score from toggles
    # Normalize to per-bit per-cycle
    if sample_count > 0 and width > 0:
        toggle_density = toggle_count / (width * sample_count)
    else:
        toggle_density = 0.0

    # Activity rate
    activity_rate = calculate_activity_rate(change_count, sample_count)

    # Width factor (wider signals are more significant)
    width_factor = min(width / 32.0, 2.0)  # Cap at 2x for very wide signals

    # Static analysis multiplier
    static_multiplier = 1.0
    high_risk_codes = [
        "clock_gating_candidate",
        "counter_activity_candidate",
        "wide_mux_candidate",
    ]
    for reason in static_reasons:
        if reason in high_risk_codes:
            static_multiplier += 0.3

    # Combined score
    # Base: toggle density * 100 (0-100 range)
    # Modified by: activity, width, static flags
    base_score = toggle_density * 100
    score = base_score * activity_rate * width_factor * static_multiplier

    # Cap at 100
    return min(score, 100.0)


def combine_static_and_dynamic(
    static_data: dict[str, Any],
    profile_data: dict[str, Any],
) -> list[PowerHotspot]:
    """Combine static analysis with profile data to generate hotspots.

    Args:
        static_data: power_static.json data
        profile_data: power_profile.json data

    Returns:
        List of scored hotspots
    """
    # Build static reason map
    static_map: dict[tuple[str, str], list[str]] = {}
    static_by_signal: dict[str, list[str]] = {}
    for suspect in static_data.get("suspects", []):
        signal = suspect["signal"]
        module = suspect.get("module", "unknown")
        static_map.setdefault((module, signal), []).append(suspect["reason_code"])
        static_by_signal.setdefault(signal, []).append(suspect["reason_code"])

    # Build source location map
    loc_map: dict[tuple[str, str], dict[str, Any]] = {}
    loc_by_signal: dict[str, dict[str, Any]] = {}
    for suspect in static_data.get("suspects", []):
        signal = suspect["signal"]
        module = suspect.get("module", "unknown")
        if "source_loc" in suspect and suspect["source_loc"]:
            loc_map[(module, signal)] = suspect["source_loc"]
            loc_by_signal[signal] = suspect["source_loc"]

    # Score each probe
    hotspots = []
    for probe in profile_data.get("probes", []):
        signal = probe["signal"]
        module = probe.get("module", "unknown")
        sample_count = probe.get("sample_count", 0)
        change_count = probe.get("change_count", 0)
        toggle_count = probe.get("toggle_count", 0)
        width = probe.get("width", 1)

        static_reasons = static_map.get((module, signal), static_by_signal.get(signal, []))
        metrics = calculate_probe_metrics(probe)

        # Calculate score
        score = score_signal(
            signal,
            width,
            sample_count,
            change_count,
            toggle_count,
            static_reasons,
        )

        # Generate recommendation
        recommendation = generate_recommendation(
            signal, score, static_reasons, change_count, sample_count
        )

        # Determine confidence
        confidence = "high" if sample_count > 100 else "medium" if sample_count > 10 else "low"
        dimensions = classify_score_dimensions(probe, static_reasons, metrics)
        limitations = ["relative", "workload_scoped", "non_signoff"]
        if "glitch_risk_structural" in static_reasons:
            limitations.append("glitch_static_only")

        hotspot = PowerHotspot(
            rank=0,  # Will be assigned after sorting
            module=module,
            signal=signal,
            score=score,
            width=width,
            toggle_count=toggle_count,
            activity_rate=calculate_activity_rate(change_count, sample_count),
            static_reasons=static_reasons,
            recommendation=recommendation,
            source_loc=probe.get("source_loc") or loc_map.get((module, signal)) or loc_by_signal.get(signal),
            confidence=confidence,
            signal_class=probe.get("signal_class", "unknown"),
            instance_path=probe.get("instance_path"),
            dimensions=dimensions,
            metrics=metrics,
            limitations=limitations,
        )

        hotspots.append(hotspot)

    # Sort by score (descending)
    hotspots.sort(key=lambda h: h.score, reverse=True)

    # Assign ranks
    for i, hotspot in enumerate(hotspots):
        hotspot.rank = i + 1

    return hotspots


def calculate_probe_metrics(probe: dict[str, Any]) -> dict[str, Any]:
    """Calculate per-probe power metrics."""
    width = max(int(probe.get("width", 1) or 1), 1)
    sample_count = int(probe.get("sample_count", 0) or 0)
    change_count = int(probe.get("change_count", 0) or 0)
    toggle_count = int(probe.get("toggle_count", 0) or 0)
    change_rate = calculate_activity_rate(change_count, sample_count)
    toggle_rate = calculate_toggle_density(toggle_count, width, sample_count)
    metrics = {
        "total_bit_toggles": toggle_count,
        "toggle_rate": toggle_rate,
        "change_rate": change_rate,
        "idle_ratio": max(0.0, 1.0 - change_rate),
        "width_weighted_activity": toggle_rate * width,
    }
    bit_counts = probe.get("bit_toggle_counts")
    if isinstance(bit_counts, list) and bit_counts:
        metrics["bit_utilization"] = calculate_bit_utilization(bit_counts, sample_count)
    high_cycle_count = probe.get("high_cycle_count")
    if high_cycle_count is not None and sample_count > 0:
        metrics["one_density"] = min(float(high_cycle_count) / (sample_count * width), 1.0)
    return metrics


def calculate_bit_utilization(bit_toggle_counts: list[int], sample_count: int) -> dict[str, Any]:
    """Summarize per-bit toggle use for width-reduction diagnostics."""
    if sample_count <= 0:
        rates = [0.0 for _count in bit_toggle_counts]
    else:
        rates = [max(count, 0) / sample_count for count in bit_toggle_counts]
    active_bits = sum(1 for rate in rates if rate > 0.0)
    inactive_msb_count = 0
    for rate in reversed(rates):
        if rate > 0.0:
            break
        inactive_msb_count += 1
    return {
        "bit_count": len(bit_toggle_counts),
        "active_bits": active_bits,
        "inactive_bits": len(bit_toggle_counts) - active_bits,
        "inactive_msb_count": inactive_msb_count,
        "per_bit_toggle_rates": [round(rate, 6) for rate in rates],
    }


def classify_score_dimensions(
    probe: dict[str, Any],
    static_reasons: list[str],
    metrics: dict[str, Any],
) -> list[str]:
    dimensions: list[str] = []
    if metrics.get("toggle_rate", 0.0) > 0.0:
        dimensions.append("toggle_activity")
    if "clock_gating_candidate" in static_reasons and metrics.get("idle_ratio", 0.0) > 0.2:
        dimensions.append("clock_gating_opportunity")
    if "wide_mux_candidate" in static_reasons:
        dimensions.append("operand_isolation_opportunity")
    if any(reason in static_reasons for reason in ("high_fanout_candidate", "glitch_risk_structural")):
        dimensions.append("structural_complexity")
    if "glitch_risk_structural" in static_reasons:
        dimensions.append("glitch_risk_static_only")
    if probe.get("signal_class") == "memory_cell":
        dimensions.append("memory_activity")
    if "bit_utilization" in metrics:
        dimensions.append("bit_level_utilization")
    return dimensions


def generate_recommendation(
    signal: str,
    score: float,
    static_reasons: list[str],
    change_count: int,
    sample_count: int,
) -> str:
    """Generate recommendation for a hotspot.

    Args:
        signal: Signal name
        score: Power score
        static_reasons: Static reason codes
        change_count: Number of changes
        sample_count: Number of samples

    Returns:
        Recommendation string
    """
    if score < 10:
        return "Low power impact - no action needed"

    recommendations = []

    # Based on static reasons
    if "clock_gating_candidate" in static_reasons:
        recommendations.append("Add clock gating with enable signal")

    if "counter_activity_candidate" in static_reasons:
        activity_rate = change_count / max(sample_count, 1)
        if activity_rate > 0.8:
            recommendations.append("Consider reducing counter update frequency")

    if "wide_mux_candidate" in static_reasons:
        recommendations.append("Reduce mux width or split into narrower muxes")

    if "high_fanout_candidate" in static_reasons:
        recommendations.append("Add buffering to reduce fanout load")

    if "glitch_risk_structural" in static_reasons:
        recommendations.append("Insert pipeline registers to reduce glitches")

    # Generic recommendation based on score
    if not recommendations:
        if score > 50:
            recommendations.append("High activity signal - investigate gating opportunities")
        else:
            recommendations.append("Moderate activity - consider optimization if critical path")

    return "; ".join(recommendations)


def generate_power_report(
    static_path: Path | None,
    profile_path: Path,
    output_path: Path | None = None,
    top_k: int = 50,
) -> dict[str, Any]:
    """Generate power report from static and dynamic data.

    Args:
        static_path: Path to power_static.json (optional)
        profile_path: Path to power_profile.json
        output_path: Output path for power_report.json
        top_k: Number of top hotspots to include

    Returns:
        Report dictionary
    """
    if output_path is None:
        output_path = Path("power_report.json")

    # Load profile data
    with open(profile_path, 'r', encoding='utf-8') as f:
        profile_data = json.load(f)

    # Load static data if available
    static_data = {"suspects": []}
    if static_path and static_path.exists():
        with open(static_path, 'r', encoding='utf-8') as f:
            static_data = json.load(f)

    # Combine and score
    all_hotspots = combine_static_and_dynamic(static_data, profile_data)

    # Keep top K
    top_hotspots = all_hotspots[:top_k]

    # Calculate summary
    total_toggles = sum(h.toggle_count for h in all_hotspots)
    total_signals = len(all_hotspots)
    probe_count = len(profile_data.get("probes", []))
    counter_count = probe_count * 3

    # Module breakdown
    module_stats: dict[str, dict[str, int]] = {}
    for h in all_hotspots:
        if h.module not in module_stats:
            module_stats[h.module] = {
                "signal_count": 0,
                "total_toggles": 0,
                "hotspot_count": 0,
            }
        module_stats[h.module]["signal_count"] += 1
        module_stats[h.module]["total_toggles"] += h.toggle_count
        if h.rank <= top_k:
            module_stats[h.module]["hotspot_count"] += 1

    # Create report
    report = {
        "version": "1.0",
        "design": {
            "top_module": profile_data.get("workload", {}).get("top_module", "unknown"),
        },
        "workload": profile_data.get("workload", {}),
        "hotspots": [
            {
                "rank": h.rank,
                "module": h.module,
                "instance_path": h.instance_path,
                "signal": h.signal,
                "score": round(h.score, 2),
                "width": h.width,
                "signal_class": h.signal_class,
                "toggle_count": h.toggle_count,
                "activity_rate": round(h.activity_rate, 3),
                "metrics": _round_metrics(h.metrics or {}),
                "dimensions": h.dimensions or [],
                "static_reasons": h.static_reasons,
                "recommendation": h.recommendation,
                "source_loc": h.source_loc,
                "confidence": h.confidence,
                "limitations": h.limitations or [],
            }
            for h in top_hotspots
        ],
        "summary": {
            "total_signals": total_signals,
            "total_toggles": total_toggles,
            "hotspot_count": len(top_hotspots),
            "probe_count": probe_count,
            "estimated_counter_count": counter_count,
            "estimated_counter_bytes": counter_count * 8,
            "analysis_note": "Power scores are relative and workload-dependent. Not for sign-off.",
            "limitations": [
                "No absolute watts or sign-off power.",
                "Glitch risk is structural/static unless explicitly modeled elsewhere.",
                "Dynamic conclusions are scoped to the supplied workload.",
                "Unsupported RTL may degrade to static diagnostics only.",
            ],
            "memory_summary": profile_data.get("memory_summary", []),
            "modules": [
                {
                    "module": module,
                    "signal_count": stats["signal_count"],
                    "total_toggles": stats["total_toggles"],
                    "hotspot_count": stats["hotspot_count"],
                }
                for module, stats in module_stats.items()
            ],
        },
    }

    # Write report
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2)

    return report


def select_deep_profile_targets(
    static_data: dict[str, Any],
    profile_data: dict[str, Any],
    *,
    top_k: int = 10,
) -> list[dict[str, Any]]:
    """Select pass-2 targets for per-bit/T1 counters from a coarse profile."""
    hotspots = combine_static_and_dynamic(static_data, profile_data)
    selected = []
    for hotspot in hotspots[:top_k]:
        selected.append(
            {
                "module": hotspot.module,
                "instance_path": hotspot.instance_path,
                "signal": hotspot.signal,
                "score": round(hotspot.score, 2),
                "width": hotspot.width,
                "reason": "top_k_coarse_hotspot",
                "dimensions": hotspot.dimensions or [],
            }
        )
    return selected


def generate_workload_comparison_report(
    profile_paths: list[Path],
    static_path: Path | None = None,
    output_path: Path | None = None,
    *,
    top_k: int = 20,
) -> dict[str, Any]:
    """Compare ranked hotspots across workloads without averaging them away."""
    static_data = {"suspects": []}
    if static_path and static_path.exists():
        with open(static_path, "r", encoding="utf-8") as f:
            static_data = json.load(f)

    workloads: list[dict[str, Any]] = []
    signal_scores: dict[tuple[str, str], list[tuple[str, float]]] = {}
    top_sets: list[set[tuple[str, str]]] = []
    for path in profile_paths:
        with open(path, "r", encoding="utf-8") as f:
            profile_data = json.load(f)
        workload_name = profile_data.get("workload", {}).get("name", path.stem)
        hotspots = combine_static_and_dynamic(static_data, profile_data)
        top_hotspots = hotspots[:top_k]
        top_set = {(hotspot.module, hotspot.signal) for hotspot in top_hotspots}
        top_sets.append(top_set)
        workloads.append(
            {
                "name": workload_name,
                "path": str(path),
                "top_hotspots": [
                    {
                        "module": hotspot.module,
                        "instance_path": hotspot.instance_path,
                        "signal": hotspot.signal,
                        "score": round(hotspot.score, 2),
                        "dimensions": hotspot.dimensions or [],
                    }
                    for hotspot in top_hotspots
                ],
            }
        )
        for hotspot in hotspots:
            signal_scores.setdefault((hotspot.module, hotspot.signal), []).append(
                (workload_name, hotspot.score)
            )

    stable = set.intersection(*top_sets) if top_sets else set()
    stable_hotspots = [
        {"module": module, "signal": signal}
        for module, signal in sorted(stable)
    ]

    outliers: list[dict[str, Any]] = []
    for (module, signal), scores in signal_scores.items():
        if len(scores) < 2:
            continue
        values = [score for _workload, score in scores]
        mean = sum(values) / len(values)
        if mean <= 0:
            continue
        max_workload, max_score = max(scores, key=lambda item: item[1])
        if max_score >= mean * 1.75 and max_score > 5.0:
            outliers.append(
                {
                    "module": module,
                    "signal": signal,
                    "workload": max_workload,
                    "score": round(max_score, 2),
                    "mean_score": round(mean, 2),
                }
            )

    report = {
        "version": "1.0",
        "workloads": workloads,
        "stable_hotspots": stable_hotspots,
        "workload_specific_outliers": sorted(
            outliers,
            key=lambda item: item["score"],
            reverse=True,
        ),
        "summary": {
            "workload_count": len(workloads),
            "analysis_note": "Hotspots are reported per workload; no cross-workload averaging is used.",
        },
    }
    if output_path is not None:
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2)
    return report


def export_saif_like(
    profile_path: Path,
    output_path: Path,
) -> str:
    """Export optional SAIF-like TC/T1/T0 data from mature profile counters."""
    with open(profile_path, "r", encoding="utf-8") as f:
        profile_data = json.load(f)
    lines = ["(SAIFILE", '  (SAIFVERSION "2.0")', '  (DIRECTION "backward")', "  (DESIGN prism_v2sc)"]
    for probe in profile_data.get("probes", []):
        signal = str(probe.get("signal", "unknown"))
        width = max(int(probe.get("width", 1) or 1), 1)
        samples = int(probe.get("sample_count", 0) or 0)
        toggles = int(probe.get("toggle_count", 0) or 0)
        high = int(probe.get("high_cycle_count", 0) or 0)
        total_bit_samples = samples * width
        low = max(total_bit_samples - high, 0)
        lines.append(f"  (NET {signal} (TC {toggles}) (T1 {high}) (T0 {low}))")
    lines.append(")")
    text = "\n".join(lines) + "\n"
    output_path.write_text(text, encoding="utf-8")
    return text


def _round_metrics(metrics: dict[str, Any]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in metrics.items():
        if isinstance(value, float):
            result[key] = round(value, 6)
        elif isinstance(value, dict):
            result[key] = _round_metrics(value)
        elif isinstance(value, list):
            result[key] = [round(item, 6) if isinstance(item, float) else item for item in value]
        else:
            result[key] = value
    return result
