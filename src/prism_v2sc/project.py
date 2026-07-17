"""Project-level staged conversion runner for large RTL repositories."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Sequence


@dataclass(frozen=True)
class ProjectStage:
    name: str
    top: str
    sources: tuple[Path, ...]
    filelists: tuple[Path, ...]
    model_manifest: Path | None
    diagnostic_policy: Path | None
    depends_on: tuple[str, ...]
    no_ir: bool


@dataclass(frozen=True)
class ProjectManifest:
    path: Path
    name: str
    output_root: Path
    stages: tuple[ProjectStage, ...]


def load_project_manifest(path: Path) -> ProjectManifest:
    resolved = path.resolve()
    if resolved.suffix.lower() == ".json":
        payload = json.loads(resolved.read_text(encoding="utf-8"))
    elif resolved.suffix.lower() in {".toml", ".tml"}:
        import tomllib

        with resolved.open("rb") as handle:
            payload = tomllib.load(handle)
    else:
        raise ValueError("project manifest must use .json or .toml")
    if not isinstance(payload, dict) or payload.get("version", 1) != 1:
        raise ValueError("project manifest must be a version 1 object")
    base = resolved.parent
    name = payload.get("name", resolved.stem)
    output_root = payload.get("output_root", "build/project_conversion")
    raw_stages = payload.get("stages")
    if not isinstance(name, str) or not name:
        raise ValueError("project manifest requires a non-empty name")
    if not isinstance(output_root, str) or not output_root:
        raise ValueError("project manifest output_root must be a path string")
    if not isinstance(raw_stages, list) or not raw_stages:
        raise ValueError("project manifest requires a non-empty stages list")
    stages: list[ProjectStage] = []
    names: set[str] = set()
    for index, item in enumerate(raw_stages):
        if not isinstance(item, dict):
            raise ValueError(f"stages[{index}] must be an object")
        stage_name = item.get("name")
        top = item.get("top")
        if not isinstance(stage_name, str) or not stage_name or stage_name in names:
            raise ValueError(f"stages[{index}] has an invalid or duplicate name")
        if not isinstance(top, str) or not top:
            raise ValueError(f"stages[{index}] requires top")
        sources = _path_list(base, item.get("sources", []), f"stages[{index}].sources")
        filelists = _path_list(base, item.get("filelists", []), f"stages[{index}].filelists")
        if not sources and not filelists:
            raise ValueError(f"stages[{index}] requires sources or filelists")
        depends = item.get("depends_on", [])
        if not isinstance(depends, list) or not all(isinstance(value, str) for value in depends):
            raise ValueError(f"stages[{index}].depends_on must be a string list")
        no_ir = item.get("no_ir", False)
        if not isinstance(no_ir, bool):
            raise ValueError(f"stages[{index}].no_ir must be a boolean")
        stages.append(ProjectStage(
            name=stage_name,
            top=top,
            sources=sources,
            filelists=filelists,
            model_manifest=_optional_path(base, item.get("model_manifest")),
            diagnostic_policy=_optional_path(base, item.get("diagnostic_policy")),
            depends_on=tuple(depends),
            no_ir=no_ir,
        ))
        names.add(stage_name)
    for stage in stages:
        unknown = set(stage.depends_on) - names
        if unknown:
            raise ValueError(f"stage '{stage.name}' has unknown dependency: {sorted(unknown)[0]}")
    _validate_stage_order(stages)
    output = Path(output_root)
    if not output.is_absolute():
        output = base / output
    return ProjectManifest(resolved, name, output.resolve(), tuple(stages))


def run_project(manifest: ProjectManifest, report_path: Path | None = None) -> int:
    results: list[dict[str, Any]] = []
    statuses: dict[str, str] = {}
    overall = 0
    for stage in manifest.stages:
        stage_out = manifest.output_root / stage.name
        failed_dependencies = [name for name in stage.depends_on if statuses.get(name) != "passed"]
        if failed_dependencies:
            status = "skipped_dependency"
            results.append({"name": stage.name, "top": stage.top, "status": status,
                            "failed_dependencies": failed_dependencies})
            statuses[stage.name] = status
            overall = 1
            continue
        audit_path = stage_out / "conversion_audit.json"
        command = [sys.executable, "-m", "prism_v2sc", "--top", stage.top,
                   "--out", str(stage_out / "systemc"), "--conversion-audit", str(audit_path)]
        for filelist in stage.filelists:
            command.extend(("--filelist", str(filelist)))
        if stage.model_manifest is not None:
            command.extend(("--model-manifest", str(stage.model_manifest)))
        if stage.diagnostic_policy is not None:
            command.extend(("--diagnostic-policy", str(stage.diagnostic_policy)))
        if stage.no_ir:
            command.append("--no-ir")
        command.extend(str(source) for source in stage.sources)
        start = time.perf_counter()
        result = subprocess.run(command, text=True, capture_output=True)
        status = "passed" if result.returncode == 0 else "failed"
        statuses[stage.name] = status
        if result.returncode:
            overall = 1
        results.append({
            "name": stage.name, "top": stage.top, "status": status,
            "returncode": result.returncode,
            "elapsed_seconds": round(time.perf_counter() - start, 3),
            "output_dir": str(stage_out), "audit": str(audit_path),
            "command": command,
            "output_tail": "\n".join((result.stdout + result.stderr).splitlines()[-20:]),
        })
    report = report_path or manifest.output_root / "project_report.json"
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps({"version": 1, "project": manifest.name, "stages": results}, indent=2) + "\n",
                      encoding="utf-8")
    print(f"wrote project conversion report: {report}")
    for result in results:
        print(f"{result['name']}: {result['status']}")
    return overall


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args(argv)
    try:
        manifest = load_project_manifest(args.manifest)
        return run_project(manifest, args.report.resolve() if args.report else None)
    except (FileNotFoundError, ValueError, json.JSONDecodeError) as exc:
        parser.error(str(exc))


def _path_list(base: Path, value: object, label: str) -> tuple[Path, ...]:
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise ValueError(f"{label} must be a path string list")
    return tuple((Path(item) if Path(item).is_absolute() else base / item).resolve() for item in value)


def _optional_path(base: Path, value: object) -> Path | None:
    if value is None:
        return None
    if not isinstance(value, str):
        raise ValueError("optional manifest paths must be strings")
    path = Path(value)
    return (path if path.is_absolute() else base / path).resolve()


def _validate_stage_order(stages: list[ProjectStage]) -> None:
    completed: set[str] = set()
    for stage in stages:
        missing = set(stage.depends_on) - completed
        if missing:
            raise ValueError(
                f"stage '{stage.name}' depends on a later stage or cycle: {sorted(missing)[0]}"
            )
        completed.add(stage.name)


if __name__ == "__main__":
    raise SystemExit(main())
