"""Resource-aware SystemC/C++ build support.

The converter deliberately emits ordinary C++ sources.  This module keeps the
build policy separate from code generation so callers can choose a conservative
single-process build or an incremental, PCH-backed, bounded parallel build.
"""

from __future__ import annotations

from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
import hashlib
import json
import os
from pathlib import Path
import shlex
import subprocess
import time
from typing import Sequence


@dataclass(frozen=True)
class SystemCBuildOptions:
    """Compiler and resource policy for one SystemC executable build."""

    cxx: str = "g++"
    standard: str = "c++17"
    cxx_flags: tuple[str, ...] = ()
    ld_flags: tuple[str, ...] = ()
    libs: tuple[str, ...] = ("-lsystemc", "-lpthread")
    include_dirs: tuple[Path, ...] = ()
    pch_headers: tuple[Path, ...] = ()
    jobs: int = 1
    use_pch: bool = False
    incremental: bool = False
    timeout_seconds: int | None = None


@dataclass(frozen=True)
class SystemCBuildResult:
    """Small machine-readable summary of a completed build."""

    elapsed_seconds: float
    compiled_sources: int
    reused_objects: int
    jobs: int
    pch_used: bool
    link_reused: bool
    output: Path


class SystemCBuildError(RuntimeError):
    """Raised when a PCH, compile, or link command fails."""


def build_systemc(
    sources: Sequence[Path],
    output: Path,
    work_dir: Path,
    *,
    options: SystemCBuildOptions = SystemCBuildOptions(),
    log_path: Path | None = None,
) -> SystemCBuildResult:
    """Compile and link SystemC sources with bounded parallelism.

    Each source is compiled to a separately cached object.  Dependency files
    emitted by the compiler are recorded, so a header change invalidates only
    the objects that include it.  ``jobs`` is clamped to at least one and can
    be set explicitly by a server-side wrapper.
    """
    source_paths = tuple(Path(source).resolve() for source in sources)
    if not source_paths:
        raise SystemCBuildError("SystemC build received no source files")
    if any(not source.is_file() for source in source_paths):
        missing = next(source for source in source_paths if not source.is_file())
        raise SystemCBuildError(f"SystemC source does not exist: {missing}")

    work_dir = Path(work_dir).resolve()
    output = Path(output).resolve()
    obj_dir = work_dir / "obj"
    log_path = Path(log_path).resolve() if log_path is not None else work_dir / "systemc_build.log"
    work_dir.mkdir(parents=True, exist_ok=True)
    obj_dir.mkdir(parents=True, exist_ok=True)
    log_path.parent.mkdir(parents=True, exist_ok=True)

    jobs = max(1, int(options.jobs))
    include_dirs = tuple(Path(item).resolve() for item in options.include_dirs)
    common_flags = (
        f"-std={options.standard}",
        "-O0",
        "-g",
        *(f"-I{item}" for item in include_dirs),
        *options.cxx_flags,
    )
    pch_path: Path | None = None
    pch_signature: str | None = None
    pch_used = False
    log_lines: list[str] = []
    start = time.perf_counter()

    if options.use_pch:
        pch_path = work_dir / "prism_systemc_pch.hpp"
        pch_headers = tuple(Path(header).resolve() for header in options.pch_headers)
        runtime_path = _write_pch_source(pch_path, include_dirs, pch_headers)
        pch_output = Path(str(pch_path) + ".gch")
        pch_dep = pch_path.with_suffix(".d")
        pch_meta = pch_path.with_suffix(".json")
        pch_base_key = _pch_key(options, common_flags, pch_path, runtime_path, pch_headers)
        pch_command = [
            options.cxx,
            *common_flags,
            "-x",
            "c++-header",
            "-MMD",
            "-MP",
            "-MF",
            str(pch_dep),
            str(pch_path),
            "-o",
            str(pch_output),
        ]
        pch_current = options.incremental and _pch_is_current(
            pch_output,
            pch_meta,
            pch_base_key,
        )
        if not pch_current:
            log_lines.append("$ " + shlex.join(pch_command))
            result = _run(pch_command, work_dir, options.timeout_seconds)
            log_lines.append((result.stdout or "") + (result.stderr or ""))
            if result.returncode != 0:
                _write_log(log_path, log_lines)
                raise SystemCBuildError(f"PCH compilation failed; see {log_path}")
            _write_json(
                pch_meta,
                {
                    "version": 1,
                    "key": pch_base_key,
                    "dependencies": [str(path) for path in _read_dependencies(pch_dep)],
                },
            )
        else:
            log_lines.append(f"reuse PCH: {pch_output}")
        pch_used = True
        pch_signature = f"{pch_base_key}:{pch_output.stat().st_mtime_ns}"

    cache_key = _build_key(options, include_dirs, pch_signature)
    compile_profile_path = work_dir / "compile_profile.json"
    compile_profile = _load_compile_profile(compile_profile_path)
    compile_jobs: list[tuple[Path, Path, Path, Path, list[str]]] = []
    reused = 0
    for index, source in enumerate(source_paths):
        token = hashlib.sha256(str(source).encode("utf-8")).hexdigest()[:16]
        object_path = obj_dir / f"{index:04d}_{token}.o"
        dep_path = object_path.with_suffix(".d")
        meta_path = object_path.with_suffix(".json")
        if options.incremental and _object_is_current(
            object_path,
            dep_path,
            meta_path,
            source,
            cache_key,
        ):
            reused += 1
            continue
        command = [
            options.cxx,
            *common_flags,
            "-MMD",
            "-MP",
            "-MF",
            str(dep_path),
            "-MT",
            str(object_path),
        ]
        if pch_path is not None:
            command.extend(("-include", str(pch_path)))
        command.extend(("-c", str(source), "-o", str(object_path)))
        compile_jobs.append((source, object_path, dep_path, meta_path, command))

    compile_jobs.sort(
        key=lambda item: (
            float(compile_profile.get(str(item[0]), 0.0)),
            item[0].stat().st_size,
        ),
        reverse=True,
    )

    failures: list[str] = []

    def compile_one(
        item: tuple[Path, Path, Path, Path, list[str]],
    ) -> tuple[Path, subprocess.CompletedProcess[str], float]:
        source, object_path, dep_path, meta_path, command = item
        compile_start = time.perf_counter()
        result = _run(command, work_dir, options.timeout_seconds)
        elapsed = time.perf_counter() - compile_start
        if result.returncode == 0:
            dependencies = _read_dependencies(dep_path)
            _write_json(
                meta_path,
                {
                    "version": 1,
                    "key": cache_key,
                    "source": str(source),
                    "dependencies": [str(path) for path in dependencies],
                },
            )
        return source, result, elapsed

    if compile_jobs:
        with ThreadPoolExecutor(max_workers=jobs) as executor:
            futures = {executor.submit(compile_one, item): item for item in compile_jobs}
            for future in as_completed(futures):
                item = futures[future]
                source, result, elapsed = future.result()
                compile_profile[str(source)] = elapsed
                _write_json(
                    compile_profile_path,
                    {
                        "version": 1,
                        "sources": compile_profile,
                    },
                )
                command = item[-1]
                log_lines.append("$ " + shlex.join(command))
                if result.stdout or result.stderr:
                    log_lines.append((result.stdout or "") + (result.stderr or ""))
                if result.returncode != 0:
                    failures.append(f"{source}: exit {result.returncode}")

    if failures:
        _write_log(log_path, log_lines)
        raise SystemCBuildError(
            "SystemC compilation failed for " + ", ".join(failures) + f"; see {log_path}"
        )

    objects = [
        obj_dir / f"{index:04d}_{hashlib.sha256(str(source).encode('utf-8')).hexdigest()[:16]}.o"
        for index, source in enumerate(source_paths)
    ]
    link_command = [
        options.cxx,
        f"-std={options.standard}",
        *[str(object_path) for object_path in objects],
        "-o",
        str(output),
        *options.ld_flags,
        *options.libs,
    ]
    link_meta = work_dir / "link.json"
    link_key = hashlib.sha256(shlex.join(link_command).encode("utf-8")).hexdigest()
    link_reused = options.incremental and _link_is_current(output, objects, link_meta, link_key)
    if link_reused:
        log_lines.append(f"reuse link: {output}")
    else:
        log_lines.append("$ " + shlex.join(link_command))
        result = _run(link_command, work_dir, options.timeout_seconds)
        log_lines.append((result.stdout or "") + (result.stderr or ""))
        if result.returncode == 0:
            _write_json(link_meta, {"version": 1, "key": link_key})
    _write_log(log_path, log_lines)
    if not link_reused and result.returncode != 0:
        raise SystemCBuildError(f"SystemC link failed; see {log_path}")

    return SystemCBuildResult(
        elapsed_seconds=time.perf_counter() - start,
        compiled_sources=len(compile_jobs),
        reused_objects=reused,
        jobs=jobs,
        pch_used=pch_used,
        link_reused=link_reused,
        output=output,
    )


def _build_key(
    options: SystemCBuildOptions,
    include_dirs: Sequence[Path],
    pch_signature: str | None,
) -> str:
    payload = {
        "cxx": options.cxx,
        "standard": options.standard,
        "cxx_flags": options.cxx_flags,
        "include_dirs": [str(path) for path in include_dirs],
        "pch": pch_signature,
    }
    return hashlib.sha256(json.dumps(payload, sort_keys=True).encode("utf-8")).hexdigest()


def _object_is_current(
    object_path: Path,
    dep_path: Path,
    meta_path: Path,
    source: Path,
    cache_key: str,
) -> bool:
    if not object_path.is_file() or not dep_path.is_file() or not meta_path.is_file():
        return False
    try:
        metadata = json.loads(meta_path.read_text(encoding="utf-8"))
        if metadata.get("key") != cache_key:
            return False
        dependencies = [Path(item) for item in metadata.get("dependencies", [])]
    except (OSError, ValueError, TypeError):
        return False
    if source not in dependencies:
        dependencies.append(source)
    object_stamp = object_path.stat().st_mtime_ns
    return all(path.is_file() and path.stat().st_mtime_ns <= object_stamp for path in dependencies)


def _write_pch_source(
    path: Path,
    include_dirs: Sequence[Path],
    headers: Sequence[Path] = (),
) -> Path | None:
    runtime = next(
        (directory / "prism_v2sc_runtime.hpp" for directory in include_dirs if (directory / "prism_v2sc_runtime.hpp").is_file()),
        None,
    )
    include = f'#include "{runtime.name}"' if runtime is not None else "#include <systemc>\n#include <array>\n#include <string>\n#include <type_traits>"
    generated_includes = "".join(f'#include "{header}"\n' for header in headers)
    content = "// Generated by prism_v2sc\n" + include + "\n" + generated_includes
    if not path.is_file() or path.read_text(encoding="utf-8") != content:
        path.write_text(content, encoding="utf-8")
    return runtime


def _pch_key(
    options: SystemCBuildOptions,
    common_flags: Sequence[str],
    pch_path: Path,
    runtime_path: Path | None,
    headers: Sequence[Path],
) -> str:
    digest = hashlib.sha256()
    digest.update(options.cxx.encode("utf-8"))
    digest.update("\0".join(common_flags).encode("utf-8"))
    digest.update(pch_path.read_bytes())
    if runtime_path is not None:
        digest.update(runtime_path.read_bytes())
    for header in headers:
        digest.update(str(header).encode("utf-8"))
    return digest.hexdigest()


def _pch_is_current(output: Path, metadata_path: Path, key: str) -> bool:
    if not output.is_file() or not metadata_path.is_file():
        return False
    try:
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    except (OSError, ValueError, TypeError):
        return False
    dependencies = metadata.get("dependencies", ())
    if not isinstance(dependencies, list):
        return False
    try:
        output_stamp = output.stat().st_mtime_ns
    except OSError:
        return False
    return metadata.get("key") == key and all(
        isinstance(item, str)
        and Path(item).is_file()
        and Path(item).stat().st_mtime_ns <= output_stamp
        for item in dependencies
    )


def _link_is_current(
    output: Path,
    objects: Sequence[Path],
    metadata_path: Path,
    key: str,
) -> bool:
    if not output.is_file() or not metadata_path.is_file():
        return False
    try:
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
        output_stamp = output.stat().st_mtime_ns
    except (OSError, ValueError, TypeError):
        return False
    return metadata.get("key") == key and all(
        object_path.is_file() and object_path.stat().st_mtime_ns <= output_stamp
        for object_path in objects
    )


def _read_dependencies(path: Path) -> tuple[Path, ...]:
    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        return ()
    text = text.replace("\\\n", " ")
    try:
        values = shlex.split(text)
    except ValueError:
        values = text.split()
    # GCC emits one additional ``header:`` rule per dependency with ``-MP``.
    # Those rule targets are not dependencies of the object itself.
    return tuple(
        Path(value).resolve()
        for value in values
        if value and not value.endswith(":")
    )


def _run(command: Sequence[str], cwd: Path, timeout: int | None) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            list(command),
            cwd=cwd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=timeout,
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        output = exc.stdout or ""
        return subprocess.CompletedProcess(command, 124, output, output)


def _write_json(path: Path, payload: object) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    temporary.replace(path)


def _load_compile_profile(path: Path) -> dict[str, float]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
        sources = payload.get("sources", {})
        if payload.get("version") != 1 or not isinstance(sources, dict):
            return {}
        return {
            str(source): float(elapsed)
            for source, elapsed in sources.items()
            if isinstance(source, str) and isinstance(elapsed, (int, float)) and elapsed >= 0
        }
    except (OSError, ValueError, TypeError):
        return {}


def _write_log(path: Path, lines: Sequence[str]) -> None:
    path.write_text("\n".join(lines) + ("\n" if lines else ""), encoding="utf-8")


def main(argv: Sequence[str] | None = None) -> int:
    """Small command-line wrapper used by CI and build benchmarks."""
    import argparse

    parser = argparse.ArgumentParser(description="Build generated SystemC C++ sources.")
    parser.add_argument("sources", nargs="+", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--work", required=True, type=Path)
    parser.add_argument("--include-dir", action="append", default=[], type=Path)
    parser.add_argument("--pch-header", action="append", default=[], type=Path)
    parser.add_argument("--cxx", default="g++")
    parser.add_argument("--standard", default="c++17")
    parser.add_argument("--cxx-flag", action="append", default=[])
    parser.add_argument("--ld-flag", action="append", default=[])
    parser.add_argument("--lib", action="append", dest="libs", default=[])
    parser.add_argument("--jobs", type=int, default=1)
    parser.add_argument("--pch", action="store_true")
    parser.add_argument("--incremental", action="store_true")
    parser.add_argument("--timeout", type=int)
    parser.add_argument("--log", type=Path)
    args = parser.parse_args(argv)
    try:
        result = build_systemc(
            args.sources,
            args.output,
            args.work,
            options=SystemCBuildOptions(
                cxx=args.cxx,
                standard=args.standard,
                cxx_flags=tuple(args.cxx_flag),
                ld_flags=tuple(args.ld_flag),
                libs=tuple(args.libs) or ("-lsystemc", "-lpthread"),
                include_dirs=tuple(args.include_dir),
                pch_headers=tuple(args.pch_header),
                jobs=max(1, args.jobs),
                use_pch=args.pch,
                incremental=args.incremental,
                timeout_seconds=args.timeout,
            ),
            log_path=args.log,
        )
    except SystemCBuildError as exc:
        print(exc)
        return 1
    print(
        f"elapsed={result.elapsed_seconds:.3f}s compiled={result.compiled_sources} "
        f"reused={result.reused_objects} jobs={result.jobs} pch={result.pch_used} "
        f"link_reused={result.link_reused}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
