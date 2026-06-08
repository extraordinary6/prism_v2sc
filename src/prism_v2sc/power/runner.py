"""SystemC profile runner for power analysis.

This module provides utilities to run instrumented SystemC designs and
collect power profiling data without RTL simulation.
"""

from __future__ import annotations

import json
import csv
import hashlib
import re
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass
class WorkloadMetadata:
    """Metadata about the workload/testbench."""

    name: str
    cycle_count: int
    top_module: str
    sources: list[str]
    vector_file: str | None = None
    seed: int | None = None
    reset_cycles: int = 10


def create_systemc_runner(
    systemc_dir: Path,
    instrumentation_enabled: bool = True,
) -> str:
    """Create a simple SystemC test runner.

    Args:
        systemc_dir: Directory containing generated SystemC files
        instrumentation_enabled: Whether to enable power instrumentation

    Returns:
        C++ code for the test runner
    """
    runner_code = """
#include <systemc.h>
#include <iostream>
#include <fstream>

// Include generated module
// (User will need to adapt this for their design)

int sc_main(int argc, char* argv[]) {
    // Command-line arguments
    int cycles = 1000;
    std::string profile_output = "power_profile.json";

    if (argc > 1) {
        cycles = std::atoi(argv[1]);
    }
    if (argc > 2) {
        profile_output = argv[2];
    }

    // Create clock
    sc_clock clk("clk", 10, SC_NS);

    // TODO: Instantiate design under test
    // (This is a placeholder - user must adapt)

    std::cout << "Running " << cycles << " cycles..." << std::endl;

    // Run simulation
    sc_start(cycles * 10, SC_NS);

    std::cout << "Simulation complete" << std::endl;

    // Dump power profile if instrumentation enabled
"""

    if instrumentation_enabled:
        runner_code += """
    std::cout << "Dumping power profile to " << profile_output << std::endl;
    std::ofstream profile_file(profile_output);
    // TODO: Call prism_power_dump() on instrumented module
    // dut.prism_power_dump(profile_file);
    profile_file.close();
"""

    runner_code += """
    return 0;
}
"""

    return runner_code


def run_systemc_simulation(
    executable: Path,
    cycles: int,
    output_path: Path,
    timeout: int = 300,
) -> dict[str, Any]:
    """Run SystemC simulation and collect profile.

    Args:
        executable: Path to compiled SystemC executable
        cycles: Number of cycles to simulate
        output_path: Where to write power_profile.json
        timeout: Timeout in seconds

    Returns:
        Dictionary with simulation results
    """
    if not executable.exists():
        raise FileNotFoundError(f"Executable not found: {executable}")

    # Run simulation
    try:
        result = subprocess.run(
            [str(executable), str(cycles), str(output_path)],
            capture_output=True,
            text=True,
            timeout=timeout,
            check=True,
        )

        return {
            "success": True,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "profile_path": str(output_path),
        }

    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "error": f"Simulation timed out after {timeout}s",
        }

    except subprocess.CalledProcessError as e:
        return {
            "success": False,
            "error": f"Simulation failed: {e.stderr}",
            "returncode": e.returncode,
        }


def parse_power_dump(dump_path: Path) -> dict[str, Any]:
    """Parse power dump CSV into structured format.

    Args:
        dump_path: Path to dump file from prism_power_dump()

    Returns:
        Dictionary with parsed profile data
    """
    probes: list[dict[str, Any]] = []

    with open(dump_path, 'r', encoding='utf-8') as f:
        data_lines = [line for line in f.readlines() if line.strip() and not line.startswith("#")]

    if not data_lines:
        return {"probes": [], "memory_summary": []}

    reader = csv.DictReader(data_lines)
    for row in reader:
        bit_counts = _parse_bit_counts(row.get("bit_toggle_counts", ""))
        probe = {
            "signal": row.get("signal", ""),
            "module": row.get("module") or "unknown",
            "width": _parse_int(row.get("width"), default=1),
            "signal_class": row.get("signal_class") or "unknown",
            "sample_count": _parse_int(row.get("sample_count"), default=0),
            "change_count": _parse_int(row.get("change_count"), default=0),
            "toggle_count": _parse_int(row.get("toggle_count"), default=0),
        }
        instance_path = row.get("instance_path")
        if instance_path:
            probe["instance_path"] = instance_path
        high_cycle_count = _parse_int(row.get("high_cycle_count"), default=0)
        if high_cycle_count:
            probe["high_cycle_count"] = high_cycle_count
        if bit_counts:
            probe["bit_toggle_counts"] = bit_counts
        probes.append(probe)

    return {"probes": probes, "memory_summary": aggregate_memory_activity(probes)}


def create_power_profile_json(
    dump_path: Path,
    workload: WorkloadMetadata,
    output_path: Path,
) -> None:
    """Create power_profile.json from dump and metadata.

    Args:
        dump_path: Path to raw dump from simulation
        workload: Workload metadata
        output_path: Where to write power_profile.json
    """
    import datetime

    # Parse dump
    profile_data = parse_power_dump(dump_path)

    # Create full profile
    profile = {
        "version": "1.0",
        "workload": {
            "name": workload.name,
            "timestamp": datetime.datetime.now().isoformat(),
            "total_cycles": workload.cycle_count,
            "top_module": workload.top_module,
            "sources": workload.sources,
            "seed": workload.seed,
            "reset_cycles": workload.reset_cycles,
            "vector_file": workload.vector_file,
            "vector_file_sha256": _sha256_file(Path(workload.vector_file)) if workload.vector_file else None,
        },
        "probes": profile_data["probes"],
        "memory_summary": profile_data.get("memory_summary", []),
    }

    # Write to file
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(profile, f, indent=2)


def collect_profile(
    systemc_executable: Path,
    workload: WorkloadMetadata,
    output_path: Path | None = None,
) -> dict[str, Any]:
    """Collect power profile from instrumented SystemC.

    This is the main entry point for P6 profile collection.

    Args:
        systemc_executable: Path to compiled instrumented SystemC
        workload: Workload metadata
        output_path: Where to write power_profile.json (default: power_profile.json)

    Returns:
        Dictionary with collection results
    """
    if output_path is None:
        output_path = Path("power_profile.json")

    # Create temp file for raw dump
    with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as tmp:
        dump_path = Path(tmp.name)

    try:
        # Run simulation
        result = run_systemc_simulation(
            systemc_executable,
            workload.cycle_count,
            dump_path,
        )

        if not result["success"]:
            return result

        # Convert dump to profile JSON
        create_power_profile_json(dump_path, workload, output_path)

        return {
            "success": True,
            "profile_path": str(output_path),
            "workload": workload.name,
            "cycles": workload.cycle_count,
        }

    finally:
        # Clean up temp file
        if dump_path.exists():
            dump_path.unlink()


def aggregate_memory_activity(probes: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Aggregate per-cell memory probes into per-memory totals."""
    grouped: dict[tuple[str, str], dict[str, Any]] = {}
    for probe in probes:
        signal = str(probe.get("signal", ""))
        match = re.fullmatch(r"(?P<base>[A-Za-z_][A-Za-z0-9_$]*)(\[\d+\])+", signal)
        if match is None and probe.get("signal_class") != "memory_cell":
            continue
        base = match.group("base") if match is not None else signal.split("[", 1)[0]
        module = str(probe.get("module", "unknown"))
        key = (module, base)
        entry = grouped.setdefault(
            key,
            {
                "module": module,
                "memory": base,
                "cell_count": 0,
                "sample_count": 0,
                "change_count": 0,
                "toggle_count": 0,
            },
        )
        entry["cell_count"] += 1
        entry["sample_count"] += int(probe.get("sample_count", 0))
        entry["change_count"] += int(probe.get("change_count", 0))
        entry["toggle_count"] += int(probe.get("toggle_count", 0))
    return sorted(grouped.values(), key=lambda item: (item["module"], item["memory"]))


def _parse_int(value: str | None, *, default: int) -> int:
    if value in {None, ""}:
        return default
    try:
        return int(str(value))
    except ValueError:
        return default


def _parse_bit_counts(value: str | None) -> list[int]:
    if not value:
        return []
    result: list[int] = []
    for part in str(value).split(";"):
        if not part:
            continue
        try:
            result.append(int(part))
        except ValueError:
            return []
    return result


def _sha256_file(path: Path) -> str | None:
    if not path.exists():
        return None
    digest = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()
