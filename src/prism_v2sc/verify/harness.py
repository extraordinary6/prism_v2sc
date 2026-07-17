"""Phase 5 conversion measurement helpers."""

from __future__ import annotations

import json
import os
import ctypes
import hashlib
import pickle
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

from prism_v2sc.codegen.systemc import emit_systemc_files, generate_systemc_header
from prism_v2sc.frontend.flow import compute_source_root, lower_design_top_down
from prism_v2sc.models.manifest import ModelManifest
from prism_v2sc.models.providers import ModelProviderRegistry
from prism_v2sc.models.resolver import (
    ModelResolutionReport,
    prepare_model_sources,
    resolve_design_models,
)
from prism_v2sc.ir.model import DesignIR

T = TypeVar("T")
MAX_CAPTURED_TOOL_OUTPUT_CHARS = 16_384


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
    stdout_truncated: bool = False
    stderr_truncated: bool = False
    note: str = ""


@dataclass(frozen=True)
class ConversionReport:
    """Phase 5 conversion result and scale metrics."""

    top: str
    sources: tuple[str, ...]
    parse_lower: Measurement
    source_index: Measurement
    traversal: Measurement
    codegen: Measurement
    total_elapsed_seconds: float
    peak_python_bytes: int
    observed_process_bytes: int | None
    source_count: int
    source_parse_count: int
    module_parse_count: int
    module_lower_count: int
    visited_modules: tuple[str, ...]
    missing_modules: tuple[str, ...]
    ambiguous_modules: tuple[str, ...]
    module_count: int
    port_count: int
    signal_count: int
    process_count: int
    instance_count: int
    generate_for_count: int
    diagnostic_count: int
    frontend_cache_hit: bool = False
    codegen_rendered_count: int = 0
    codegen_reused_count: int = 0
    codegen_bootstrapped_count: int = 0
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
    emitted_files: tuple[Path, ...] = field(default_factory=tuple)
    model_report: ModelResolutionReport | None = None


def smoke_result() -> str:
    """Return a stable smoke-test marker."""
    return "ok"


def convert_with_metrics(
    sources: Sequence[Path],
    top: str,
    *,
    include_dirs: Sequence[Path] = (),
    defines: Sequence[str] = (),
    compare_verilator: bool = False,
    out_dir: Path | None = None,
    source_root: Path | None = None,
    model_manifest: ModelManifest | None = None,
    model_registry: ModelProviderRegistry | None = None,
    track_memory: bool = True,
    incremental_codegen: bool = False,
    reuse_existing_modules: Sequence[str] = (),
    compile_friendly: bool = False,
) -> ConversionArtifacts:
    """Parse, lower, emit SystemC, and measure time and peak Python allocation.

    When ``out_dir`` is provided, the per-module SystemC files are written
    under it with directory mirroring rooted at ``source_root`` (defaulting
    to the common parent of the inputs).
    """
    model_report: ModelResolutionReport | None = None
    source_decisions = ()
    resolved_sources = tuple(Path(source) for source in sources)
    if model_manifest is not None:
        resolved_sources, source_decisions = prepare_model_sources(resolved_sources, model_manifest)
        if not resolved_sources:
            raise ValueError("model source rules ignored every input source")
    normalized_sources = tuple(str(source) for source in resolved_sources)
    total_start = time.perf_counter()

    frontend_cache_path = (
        Path(out_dir) / ".prism_frontend_cache.pkl"
        if out_dir is not None and incremental_codegen
        else None
    )
    parse_lower_measurement, (flow, frontend_cache_hit) = _measure(
        lambda: _load_or_lower_frontend(
            resolved_sources,
            top,
            include_dirs=include_dirs,
            defines=defines,
            cache_path=frontend_cache_path,
        ),
        track_allocations=track_memory,
    )
    design = flow.design
    if model_manifest is not None:
        design, model_report = resolve_design_models(
            design,
            model_manifest,
            source_decisions=source_decisions,
            registry=model_registry,
        )
    source_index_measurement = Measurement(
        elapsed_seconds=0.0 if frontend_cache_hit else flow.source_index_elapsed_seconds,
        peak_python_bytes=0,
    )
    traversal_measurement = Measurement(
        elapsed_seconds=0.0 if frontend_cache_hit else flow.traversal_elapsed_seconds,
        peak_python_bytes=0,
    )

    resolved_root = source_root if source_root is not None else compute_source_root(resolved_sources)
    emitted_files: tuple[Path, ...] = ()
    codegen_cache_stats: dict[str, int] = {}
    if out_dir is not None:
        codegen_measurement, written = _measure(
            lambda: emit_systemc_files(
                design,
                Path(out_dir),
                Path(resolved_root),
                signatures=flow.signatures,
                incremental=incremental_codegen,
                reuse_existing_modules=frozenset(reuse_existing_modules),
                compile_friendly=compile_friendly,
            ),
            track_allocations=track_memory,
        )
        emitted_files = tuple(written)
        if incremental_codegen or reuse_existing_modules:
            try:
                cache = json.loads((Path(out_dir) / ".prism_codegen_cache.json").read_text(encoding="utf-8"))
                last_run = cache.get("last_run", {})
                if isinstance(last_run, dict):
                    codegen_cache_stats = {
                        key: int(last_run.get(key, 0))
                        for key in ("rendered", "reused", "bootstrapped")
                    }
            except (FileNotFoundError, json.JSONDecodeError, OSError, TypeError, ValueError):
                codegen_cache_stats = {}
        # Per-module output is the authoritative artifact. Re-rendering the
        # complete design into one unused monolithic header doubles codegen
        # work and peak memory for large designs.
        header_text = ""
    else:
        codegen_measurement, header_text = _measure(
            lambda: generate_systemc_header(design),
            track_allocations=track_memory,
        )
    total_elapsed = time.perf_counter() - total_start

    verilator_command = _find_verilator_command()
    verilator = _measure_verilator_lint(
        resolved_sources,
        top,
        verilator_command,
        include_dirs=include_dirs,
        defines=defines,
    ) if compare_verilator else ToolMeasurement(
        tool="verilator",
        available=verilator_command is not None,
        executable=verilator_command[0] if verilator_command else "",
        note="not requested",
    )

    report = ConversionReport(
        top=top,
        sources=normalized_sources,
        parse_lower=parse_lower_measurement,
        source_index=source_index_measurement,
        traversal=traversal_measurement,
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
        source_count=len(resolved_sources),
        source_parse_count=flow.traversal.source_parse_count,
        module_parse_count=flow.traversal.module_parse_count,
        module_lower_count=flow.traversal.module_lower_count,
        visited_modules=flow.traversal.visited_modules,
        missing_modules=flow.traversal.missing_modules,
        ambiguous_modules=flow.traversal.ambiguous_modules,
        module_count=len(design.modules),
        port_count=sum(len(module.ports) for module in design.modules),
        signal_count=sum(len(module.signals) for module in design.modules),
        process_count=sum(len(module.processes) for module in design.modules),
        instance_count=sum(len(module.instances) for module in design.modules),
        generate_for_count=sum(len(module.generate_fors) for module in design.modules),
        diagnostic_count=len(design.diagnostics),
        frontend_cache_hit=frontend_cache_hit,
        codegen_rendered_count=codegen_cache_stats.get("rendered", len(emitted_files)),
        codegen_reused_count=codegen_cache_stats.get("reused", 0),
        codegen_bootstrapped_count=codegen_cache_stats.get("bootstrapped", 0),
        verilator_lint=verilator,
    )
    return ConversionArtifacts(
        design=design,
        header=header_text,
        report=report,
        emitted_files=emitted_files,
        model_report=model_report,
    )


_FRONTEND_CACHE_VERSION = 1
_RTL_SUFFIXES = frozenset({".v", ".sv", ".vh", ".svh"})


def _load_or_lower_frontend(
    sources: Sequence[Path],
    top: str,
    *,
    include_dirs: Sequence[Path],
    defines: Sequence[str],
    cache_path: Path | None,
):
    if cache_path is None:
        return (
            lower_design_top_down(sources, top, include_dirs=include_dirs, defines=defines),
            False,
        )

    cache_key = _frontend_cache_key(sources, top, include_dirs, defines)
    try:
        with cache_path.open("rb") as stream:
            payload = pickle.load(stream)
        if (
            isinstance(payload, dict)
            and payload.get("version") == _FRONTEND_CACHE_VERSION
            and payload.get("key") == cache_key
            and payload.get("flow") is not None
        ):
            return payload["flow"], True
    except (FileNotFoundError, OSError, EOFError, pickle.PickleError, AttributeError, ValueError):
        pass

    flow = lower_design_top_down(sources, top, include_dirs=include_dirs, defines=defines)
    cache_path.parent.mkdir(parents=True, exist_ok=True)
    temporary = cache_path.with_suffix(cache_path.suffix + ".tmp")
    try:
        with temporary.open("wb") as stream:
            pickle.dump(
                {"version": _FRONTEND_CACHE_VERSION, "key": cache_key, "flow": flow},
                stream,
                protocol=pickle.HIGHEST_PROTOCOL,
            )
        temporary.replace(cache_path)
    except OSError:
        try:
            temporary.unlink()
        except OSError:
            pass
    return flow, False


def _frontend_cache_key(
    sources: Sequence[Path],
    top: str,
    include_dirs: Sequence[Path],
    defines: Sequence[str],
) -> str:
    digest = hashlib.sha256()
    digest.update(f"version={_FRONTEND_CACHE_VERSION}\0top={top}\0".encode("utf-8"))
    for define in defines:
        digest.update(f"define={define}\0".encode("utf-8"))

    candidates = {Path(source).resolve() for source in sources}
    for include_dir in include_dirs:
        resolved_dir = Path(include_dir).resolve()
        digest.update(f"incdir={resolved_dir}\0".encode("utf-8"))
        if resolved_dir.is_dir():
            candidates.update(
                path.resolve()
                for path in resolved_dir.rglob("*")
                if path.is_file() and path.suffix.lower() in _RTL_SUFFIXES
            )

    implementation_files = [
        Path(__file__).parents[1] / "frontend" / "flow.py",
        Path(__file__).parents[1] / "frontend" / "lower.py",
        Path(__file__).parents[1] / "frontend" / "pyslang_parser.py",
        Path(__file__).parents[1] / "ir" / "model.py",
    ]
    for path in sorted((*candidates, *implementation_files), key=lambda item: str(item)):
        digest.update(f"file={path}\0".encode("utf-8"))
        try:
            with path.open("rb") as stream:
                for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                    digest.update(chunk)
        except OSError:
            digest.update(b"<missing>")
    return digest.hexdigest()


def write_report(report: ConversionReport, path: Path) -> None:
    """Write a stable JSON metrics report."""
    path.write_text(json.dumps(report.to_dict(), indent=2, sort_keys=True) + "\n", encoding="utf-8")


def _measure(operation: Callable[[], T], *, track_allocations: bool = True) -> tuple[Measurement, T]:
    if track_allocations:
        tracemalloc.start()
    start_rss = _current_process_memory_bytes()
    start = time.perf_counter()
    try:
        result = operation()
        peak = tracemalloc.get_traced_memory()[1] if track_allocations else 0
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
        if track_allocations:
            tracemalloc.stop()


def _measure_verilator_lint(
    sources: Sequence[Path],
    top: str,
    command_prefix: tuple[str, ...] | None,
    *,
    include_dirs: Sequence[Path] = (),
    defines: Sequence[str] = (),
) -> ToolMeasurement:
    if command_prefix is None:
        return ToolMeasurement(
            tool="verilator",
            available=False,
            note="verilator executable not found on PATH",
        )

    command = [
        *command_prefix,
        "--lint-only",
        "--top-module",
        top,
        *[f"-I{include_dir}" for include_dir in include_dirs],
        *[f"-D{define}" for define in defines],
        *[str(source) for source in sources],
    ]
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
        stdout_raw = stdout_file.read()
        stderr_raw = stderr_file.read()
        stdout, stdout_truncated = _truncate_text(stdout_raw, MAX_CAPTURED_TOOL_OUTPUT_CHARS)
        stderr, stderr_truncated = _truncate_text(stderr_raw, MAX_CAPTURED_TOOL_OUTPUT_CHARS)
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
        stdout_truncated=stdout_truncated,
        stderr_truncated=stderr_truncated,
        note="stdout/stderr truncated" if stdout_truncated or stderr_truncated else "",
    )


def _find_verilator_command() -> tuple[str, ...] | None:
    executable = shutil.which("verilator")
    if executable is not None:
        adapted = _adapt_windows_verilator_wrapper(Path(executable))
        if adapted is not None:
            return adapted
        return (executable,)

    if sys.platform != "win32":
        return None

    for directory in os.environ.get("PATH", "").split(os.pathsep):
        if not directory:
            continue
        candidate = Path(directory) / "verilator"
        if not candidate.is_file():
            continue
        adapted = _adapt_windows_verilator_wrapper(candidate)
        if adapted is not None:
            return adapted
    return None


def _adapt_windows_verilator_wrapper(candidate: Path) -> tuple[str, ...] | None:
    if sys.platform != "win32":
        return None
    if candidate.suffix.lower() == ".exe":
        return (str(candidate),)

    root = candidate.parent.parent
    real_root = root / "share" / "verilator"
    real_bin_dir = real_root / "bin"
    real_binary = real_bin_dir / "verilator_bin.exe"
    if real_binary.is_file():
        return (str(real_binary),)

    perl = root / "usr" / "bin" / "perl.exe"
    real_wrapper = real_bin_dir / "verilator"
    if perl.is_file() and real_wrapper.is_file():
        return (str(perl), str(real_wrapper))
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


def _truncate_text(text: str, limit: int) -> tuple[str, bool]:
    if len(text) <= limit:
        return text, False
    omitted = len(text) - limit
    suffix = f"\n... truncated {omitted} character(s) ...\n"
    keep = max(0, limit - len(suffix))
    return text[:keep] + suffix, True


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
