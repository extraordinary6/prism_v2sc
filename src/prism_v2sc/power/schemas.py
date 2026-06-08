"""JSON schema definitions for power analysis outputs.

This module defines the structure of all power analysis output files:
- power_static.json: Static analysis suspects
- power_profile.json: Dynamic profiling data (raw counts)
- power_report.json: Scored hotspots with recommendations
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any


# ==============================================================================
# power_static.json Schema
# ==============================================================================

POWER_STATIC_SCHEMA = {
    "type": "object",
    "required": ["version", "design", "suspects"],
    "properties": {
        "version": {
            "type": "string",
            "description": "Schema version",
            "const": "1.0"
        },
        "design": {
            "type": "object",
            "properties": {
                "top_module": {"type": "string"},
                "timestamp": {"type": "string"},
            }
        },
        "suspects": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["module", "signal", "reason_code", "message"],
                "properties": {
                    "module": {"type": "string"},
                    "signal": {"type": "string"},
                    "reason_code": {
                        "type": "string",
                        "enum": [
                            "clock_gating_candidate",
                            "counter_activity_candidate",
                            "wide_mux_candidate",
                            "high_fanout_candidate",
                            "glitch_risk_structural",
                            "width_reduction_candidate"
                        ]
                    },
                    "message": {"type": "string"},
                    "recommendation": {"type": "string"},
                    "severity": {
                        "type": "string",
                        "enum": ["info", "warning", "error"]
                    },
                    "width": {"type": "integer", "minimum": 1},
                    "source_loc": {
                        "type": "object",
                        "properties": {
                            "file": {"type": "string"},
                            "line": {"type": "integer"},
                            "column": {"type": "integer"}
                        }
                    },
                    "metrics": {"type": "object"}
                }
            }
        }
    }
}


# ==============================================================================
# power_profile.json Schema
# ==============================================================================

POWER_PROFILE_SCHEMA = {
    "type": "object",
    "required": ["version", "workload", "probes"],
    "properties": {
        "version": {
            "type": "string",
            "description": "Schema version",
            "const": "1.0"
        },
        "workload": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "timestamp": {"type": "string"},
                "total_cycles": {"type": "integer"},
                "top_module": {"type": "string"},
                "sources": {"type": "array", "items": {"type": "string"}},
                "seed": {"type": ["integer", "null"]},
                "reset_cycles": {"type": "integer"},
                "vector_file": {"type": ["string", "null"]},
                "vector_file_sha256": {"type": ["string", "null"]},
            }
        },
        "probes": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["module", "signal", "sample_count"],
                "properties": {
                    "module": {"type": "string"},
                    "signal": {"type": "string"},
                    "width": {"type": "integer"},
                    "signal_class": {
                        "type": "string",
                        "enum": ["state", "comb", "port", "memory_cell", "unknown"]
                    },
                    "sample_count": {"type": "integer", "minimum": 0},
                    "change_count": {"type": "integer", "minimum": 0},
                    "toggle_count": {"type": "integer", "minimum": 0},
                    "high_cycle_count": {"type": "integer", "minimum": 0},
                    "bit_toggle_counts": {
                        "type": "array",
                        "items": {"type": "integer", "minimum": 0}
                    },
                    "source_loc": {
                        "type": "object",
                        "properties": {
                            "file": {"type": "string"},
                            "line": {"type": "integer"},
                            "column": {"type": "integer"}
                        }
                    }
                }
            }
        },
        "memory_summary": {"type": "array"}
    }
}


# ==============================================================================
# power_report.json Schema
# ==============================================================================

POWER_REPORT_SCHEMA = {
    "type": "object",
    "required": ["version", "design", "workload", "hotspots", "summary"],
    "properties": {
        "version": {
            "type": "string",
            "description": "Schema version",
            "const": "1.0"
        },
        "design": {
            "type": "object",
            "properties": {
                "top_module": {"type": "string"},
            }
        },
        "workload": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "total_cycles": {"type": "integer"},
            }
        },
        "hotspots": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["rank", "module", "signal", "score"],
                "properties": {
                    "rank": {"type": "integer", "minimum": 1},
                    "module": {"type": "string"},
                    "signal": {"type": "string"},
                    "score": {"type": "number", "minimum": 0},
                    "width": {"type": "integer"},
                    "toggle_count": {"type": "integer"},
                    "activity_rate": {"type": "number"},
                    "metrics": {"type": "object"},
                    "dimensions": {
                        "type": "array",
                        "items": {"type": "string"}
                    },
                    "static_reasons": {
                        "type": "array",
                        "items": {"type": "string"}
                    },
                    "recommendation": {"type": "string"},
                    "source_loc": {
                        "type": "object",
                        "properties": {
                            "file": {"type": "string"},
                            "line": {"type": "integer"},
                            "column": {"type": "integer"}
                        }
                    },
                    "limitations": {
                        "type": "array",
                        "items": {"type": "string"}
                    }
                }
            }
        },
        "summary": {
            "type": "object",
            "properties": {
                "total_signals": {"type": "integer"},
                "total_toggles": {"type": "integer"},
                "hotspot_count": {"type": "integer"},
                "probe_count": {"type": "integer"},
                "estimated_counter_count": {"type": "integer"},
                "estimated_counter_bytes": {"type": "integer"},
                "limitations": {"type": "array"},
                "memory_summary": {"type": "array"},
                "modules": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "module": {"type": "string"},
                            "signal_count": {"type": "integer"},
                            "total_toggles": {"type": "integer"},
                            "hotspot_count": {"type": "integer"}
                        }
                    }
                }
            }
        }
    }
}


def export_power_static_json(suspects: list[Any], design_name: str) -> dict[str, Any]:
    """Export static analysis results to power_static.json format.

    Args:
        suspects: List of PowerSuspect objects
        design_name: Top module name

    Returns:
        Dictionary conforming to POWER_STATIC_SCHEMA
    """
    import datetime

    return {
        "version": "1.0",
        "design": {
            "top_module": design_name,
            "timestamp": datetime.datetime.now().isoformat(),
        },
        "suspects": [
            {
                "module": s.module,
                "signal": s.signal,
                "reason_code": s.reason_code,
                "message": s.message,
                "recommendation": s.recommendation,
                "severity": s.severity,
                "width": s.width,
                "source_loc": {
                    "file": s.loc.file,
                    "line": s.loc.line,
                    "column": s.loc.column,
                } if s.loc else None,
                "metrics": s.metrics or {},
            }
            for s in suspects
        ]
    }


def export_power_profile_json(profile_data: dict[str, Any], workload_name: str) -> dict[str, Any]:
    """Export profiling data to power_profile.json format.

    Args:
        profile_data: Raw profiling data from simulation
        workload_name: Name of the workload/testbench

    Returns:
        Dictionary conforming to POWER_PROFILE_SCHEMA
    """
    import datetime

    return {
        "version": "1.0",
        "workload": {
            "name": workload_name,
            "timestamp": datetime.datetime.now().isoformat(),
            "total_cycles": profile_data.get("total_cycles", 0),
        },
        "probes": profile_data.get("probes", [])
    }


def export_power_report_json(hotspots: list[Any], summary: dict[str, Any]) -> dict[str, Any]:
    """Export scored hotspot report to power_report.json format.

    Args:
        hotspots: List of scored hotspot objects
        summary: Summary statistics

    Returns:
        Dictionary conforming to POWER_REPORT_SCHEMA
    """
    return {
        "version": "1.0",
        "design": summary.get("design", {}),
        "workload": summary.get("workload", {}),
        "hotspots": [
            {
                "rank": i + 1,
                "module": h.get("module"),
                "signal": h.get("signal"),
                "score": h.get("score", 0.0),
                "width": h.get("width"),
                "toggle_count": h.get("toggle_count"),
                "activity_rate": h.get("activity_rate"),
                "static_reasons": h.get("static_reasons", []),
                "recommendation": h.get("recommendation", ""),
                "source_loc": h.get("source_loc"),
            }
            for i, h in enumerate(hotspots)
        ],
        "summary": summary,
    }
