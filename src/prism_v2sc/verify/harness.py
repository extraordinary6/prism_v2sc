"""Phase 5 conversion measurement helpers."""

from __future__ import annotations

import json
import os
import ctypes
import shutil
import subprocess
import sys
import tempfile
import time
import tracemalloc
from ctypes import wintypes
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Callable, Sequence, TypeVar

from prism_v2sc.codegen.systemc import generate_systemc_header
from prism_v2sc.frontend.lower import lower_design
from prism_v2sc.frontend.pyverilog_parser import parse_verilog
from prism_v2sc.ir.model import DesignIR

T = TypeVar("T")


@dataclass(frozen=True)
class Measurement:
    """Elapsed time and peak traced Python allocation for one operation."""

    elapsed_seconds: float
    peak_python_bytes: int
    observed_process_bytes: int | None = None


@dataclass(frozen=True)
class ToolMeasurement:
    """Best-effort measurement for an external tool."""

    tool: str
    available: bool
    executable: str = ""
    elapsed_seconds: float | None = None
    peak_process_bytes: int | None = None
    returncode: int | None = None
    stdout: str = ""
    stderr: str = ""
    note: str = ""


@dataclass(frozen=True)
class ConversionReport:
    """Phase 5 conversion result and scale metrics."""

    top: str
    sources: tuple[str, ...]
    parse_lower: Measurement
    codegen: Measurement
    total_elapsed_seconds: float
    peak_python_bytes: int
    observed_process_bytes: int | None
    module_count: int
    port_count: int
    signal_count: int
    process_count: int
    instance_count: int
    generate_for_count: int
    diagnostic_count: int
    verilator_lint: ToolMeasurement = field(default_factory=lambda: ToolMeasurement(tool="verilator", available=False))

    def to_dict(self) -> dict[str, object]:
        """Return a JSON-serializable report."""
        return asdict(self)


@dataclass(frozen=True)
class ConversionArtifacts:
    """In-memory conversion artifacts plus the Phase 5 report."""

    design: DesignIR
    header: str
    report: ConversionReport


def smoke_result() -> str:
    """Return a stable smoke-test marker."""
    return "ok"


def convert_with_metrics(
    sources: Sequence[Path],
    top: str,
    *,
    compare_verilator: bool = False,
) -> ConversionArtifacts:
    """Parse, lower, emit SystemC, and measure time and peak Python allocation."""
    normalized_sources = tuple(str(source) for source in sources)
    total_start = time.perf_counter()

    parse_lower_measurement, design = _measure(lambda: lower_design(parse_verilog(list(sources)), top))
    codegen_measurement, header = _measure(lambda: generate_systemc_header(design))
    total_elapsed = time.perf_counter() - total_start

    verilator_command = _find_verilator_command()
    verilator = _measure_verilator_lint(sources, top, verilator_command) if compare_verilator else ToolMeasurement(
        tool="verilator",
        available=verilator_command is not None,
        executable=verilator_command[0] if verilator_command else "",
        note="not requested",
    )

    report = ConversionReport(
        top=top,
        sources=normalized_sources,
        parse_lower=parse_lower_measurement,
        codegen=codegen_measurement,
        total_elapsed_seconds=total_elapsed,
        peak_python_bytes=max(
            parse_lower_measurement.peak_python_bytes,
            codegen_measurement.peak_python_bytes,
        ),
        observed_process_bytes=_max_optional(
            parse_lower_measurement.observed_process_bytes,
            codegen_measurement.observed_process_bytes,
        ),
        module_count=len(design.modules),
        port_count=sum(len(module.ports) for module in design.modules),
        signal_count=sum(len(module.signals) for module in design.modules),
        process_count=sum(len(module.processes) for module in design.modules),
        instance_count=sum(len(module.instances) for module in design.modules),
        generate_for_count=sum(len(module.generate_fors) for module in design.modules),
        diagnostic_count=len(design.diagnostics),
        verilator_lint=verilator,
    )
    return ConversionArtifacts(design=design, header=header, report=report)


def write_report(report: ConversionReport, path: Path) -> None:
    """Write a stable JSON metrics report."""
    path.write_text(json.dumps(report.to_dict(), indent=2, sort_keys=True) + "\n", encoding="utf-8")


def _measure(operation: Callable[[], T]) -> tuple[Measurement, T]:
    tracemalloc.start()
    start_rss = _current_process_memory_bytes()
    start = time.perf_counter()
    try:
        result = operation()
        _current, peak = tracemalloc.get_traced_memory()
        end_rss = _current_process_memory_bytes()
        return (
            Measurement(
                elapsed_seconds=time.perf_counter() - start,
                peak_python_bytes=peak,
                observed_process_bytes=_max_optional(start_rss, end_rss),
            ),
            result,
        )
    finally:
        tracemalloc.stop()


def _measure_verilator_lint(
    sources: Sequence[Path],
    top: str,
    command_prefix: tuple[str, ...] | None,
) -> ToolMeasurement:
    if command_prefix is None:
        return ToolMeasurement(
            tool="verilator",
            available=False,
            note="verilator executable not found on PATH",
        )

    command = [*command_prefix, "--lint-only", "--top-module", top, *[str(source) for source in sources]]
    env = os.environ.copy()
    verilator_root = _infer_verilator_root(command_prefix)
    if verilator_root is not None:
        env["VERILATOR_ROOT"] = str(verilator_root)
    start = time.perf_counter()
    with tempfile.TemporaryFile("w+", encoding="utf-8") as stdout_file, tempfile.TemporaryFile(
        "w+",
        encoding="utf-8",
    ) as stderr_file:
        process = subprocess.Popen(command, stdout=stdout_file, stderr=stderr_file, text=True, env=env)
        peak_process_bytes = _process_memory_bytes(process.pid)
        while process.poll() is None:
            peak_process_bytes = _max_optional(peak_process_bytes, _process_memory_bytes(process.pid))
            time.sleep(0.01)
        stdout_file.seek(0)
        stderr_file.seek(0)
        stdout = stdout_file.read()
        stderr = stderr_file.read()
    elapsed = time.perf_counter() - start
    return ToolMeasurement(
        tool="verilator",
        available=True,
        executable=command_prefix[0],
        elapsed_seconds=elapsed,
        peak_process_bytes=peak_process_bytes,
        returncode=process.returncode,
        stdout=stdout,
        stderr=stderr,
    )


def _find_verilator_command() -> tuple[str, ...] | None:
    executable = shutil.which("verilator")
    if executable is not None:
        return (executable,)

    if sys.platform != "win32":
        return None

    for directory in os.environ.get("PATH", "").split(os.pathsep):
        if not directory:
            continue
        candidate = Path(directory) / "verilator"
        if not candidate.is_file():
            continue
        perl = candidate.parent.parent / "usr" / "bin" / "perl.exe"
        msys_wrapper = candidate.parent.parent / "share" / "verilator" / "bin" / "verilator"
        if perl.is_file() and msys_wrapper.is_file():
            return (str(perl), str(msys_wrapper))
        msys_binary = candidate.parent.parent / "share" / "verilator" / "bin" / "verilator_bin.exe"
        if msys_binary.is_file():
            return (str(msys_binary),)
        if perl.is_file():
            return (str(perl), str(candidate))
    return None


def _infer_verilator_root(command_prefix: tuple[str, ...]) -> Path | None:
    for item in command_prefix:
        path = Path(item)
        if path.name.lower() in {"verilator", "verilator_bin.exe"} and path.parent.name == "bin":
            root = path.parent.parent
            if (root / "include" / "verilated_std.sv").is_file():
                return root
    return None


def _max_optional(*values: int | None) -> int | None:
    present = [value for value in values if value is not None]
    return max(present) if present else None


def _current_process_memory_bytes() -> int | None:
    if sys.platform == "win32":
        return _process_memory_bytes(os.getpid())
    try:
        import resource

        usage = resource.getrusage(resource.RUSAGE_SELF)
    except (AttributeError, OSError):
        return None
    # Linux reports KiB; macOS reports bytes.
    return int(usage.ru_maxrss if sys.platform == "darwin" else usage.ru_maxrss * 1024)


def _process_memory_bytes(pid: int) -> int | None:
    if sys.platform == "win32":
        return _windows_peak_working_set_bytes(pid)
    return None


def _windows_peak_working_set_bytes(pid: int) -> int | None:
    class ProcessMemoryCounters(ctypes.Structure):
        _fields_ = [
            ("cb", wintypes.DWORD),
            ("PageFaultCount", wintypes.DWORD),
            ("PeakWorkingSetSize", ctypes.c_size_t),
            ("WorkingSetSize", ctypes.c_size_t),
            ("QuotaPeakPagedPoolUsage", ctypes.c_size_t),
            ("QuotaPagedPoolUsage", ctypes.c_size_t),
            ("QuotaPeakNonPagedPoolUsage", ctypes.c_size_t),
            ("QuotaNonPagedPoolUsage", ctypes.c_size_t),
            ("PagefileUsage", ctypes.c_size_t),
            ("PeakPagefileUsage", ctypes.c_size_t),
        ]

    process_query_limited_information = 0x1000
    process_vm_read = 0x0010
    handle = ctypes.windll.kernel32.OpenProcess(
        process_query_limited_information | process_vm_read,
        False,
        pid,
    )
    if not handle:
        return None
    counters = ProcessMemoryCounters()
    counters.cb = ctypes.sizeof(ProcessMemoryCounters)
    try:
        ok = ctypes.windll.psapi.GetProcessMemoryInfo(
            handle,
            ctypes.byref(counters),
            counters.cb,
        )
        if not ok:
            return None
        return int(counters.PeakWorkingSetSize)
    finally:
        ctypes.windll.kernel32.CloseHandle(handle)
