#!/usr/bin/env python3
"""Run the versioned real-design benchmark manifest and write a JSON report."""

from __future__ import annotations

import argparse
import json
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_manifest(path: Path) -> list[dict[str, object]]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict) or payload.get("version") != 1:
        raise ValueError("benchmark manifest must be a version 1 object")
    benchmarks = payload.get("benchmarks")
    if not isinstance(benchmarks, list):
        raise ValueError("benchmark manifest requires a benchmarks list")
    names: set[str] = set()
    for index, item in enumerate(benchmarks):
        if not isinstance(item, dict):
            raise ValueError(f"benchmarks[{index}] must be an object")
        for key in ("name", "domain", "source_root", "command", "contract"):
            if key not in item:
                raise ValueError(f"benchmarks[{index}] is missing {key}")
        name = item["name"]
        command = item["command"]
        if not isinstance(name, str) or not name or name in names:
            raise ValueError(f"benchmarks[{index}] has an invalid or duplicate name")
        if not isinstance(command, list) or not command or not all(isinstance(x, str) for x in command):
            raise ValueError(f"benchmarks[{index}].command must be a string list")
        names.add(name)
    return benchmarks


def run_suite(manifest: Path, selected: set[str], output: Path, list_only: bool) -> int:
    benchmarks = load_manifest(manifest)
    if selected:
        unknown = selected - {str(item["name"]) for item in benchmarks}
        if unknown:
            raise ValueError("unknown benchmark(s): " + ", ".join(sorted(unknown)))
        benchmarks = [item for item in benchmarks if item["name"] in selected]
    if list_only:
        for item in benchmarks:
            print(f"{item['name']}: {item['domain']} - {item['contract']}")
        return 0

    results: list[dict[str, object]] = []
    overall = 0
    output.parent.mkdir(parents=True, exist_ok=True)

    def write_report() -> None:
        output.write_text(
            json.dumps({"version": 1, "results": results}, indent=2) + "\n",
            encoding="utf-8",
        )

    for item in benchmarks:
        source_root = Path(str(item["source_root"]))
        if not source_root.is_absolute():
            source_root = ROOT / source_root
        if not source_root.exists():
            results.append({**item, "status": "unavailable", "elapsed_seconds": 0.0})
            write_report()
            overall = 1
            continue
        start = time.perf_counter()
        log_path = output.parent / f"{item['name']}.log"
        timeout_seconds = int(item.get("timeout_seconds", 1800))
        try:
            with log_path.open("w", encoding="utf-8") as log:
                process = subprocess.Popen(
                    item["command"], cwd=ROOT, text=True, stdout=log, stderr=subprocess.STDOUT
                )
                try:
                    returncode = process.wait(timeout=timeout_seconds)
                    timed_out = False
                except subprocess.TimeoutExpired:
                    process.kill()
                    returncode = process.wait()
                    timed_out = True
        except OSError as exc:
            returncode = 127
            timed_out = False
            log_path.write_text(str(exc) + "\n", encoding="utf-8")
        elapsed = time.perf_counter() - start
        combined_output = log_path.read_text(encoding="utf-8", errors="replace")
        status = "passed" if returncode == 0 else "failed"
        if timed_out:
            status = "timeout"
        if returncode and any(
            marker in combined_output.lower()
            for marker in ("license server", "failed to obtain license", "cannot connect to the license")
        ):
            status = "infrastructure_failed"
        results.append({
            **item,
            "status": status,
            "returncode": returncode,
            "elapsed_seconds": round(elapsed, 3),
            "timeout_seconds": timeout_seconds,
            "log": str(log_path),
            "output_tail": "\n".join(combined_output.splitlines()[-20:]),
        })
        write_report()
        if returncode:
            overall = 1
    print(f"wrote benchmark report: {output}")
    for result in results:
        print(f"{result['name']}: {result['status']}")
    return overall


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, default=ROOT / "verification/benchmarks.json")
    parser.add_argument("--cases", nargs="*", default=[])
    parser.add_argument("--output", type=Path, default=ROOT / "build/benchmark_report.json")
    parser.add_argument("--list", action="store_true")
    args = parser.parse_args()
    try:
        return run_suite(args.manifest.resolve(), set(args.cases), args.output.resolve(), args.list)
    except (FileNotFoundError, ValueError, json.JSONDecodeError) as exc:
        parser.error(str(exc))


if __name__ == "__main__":
    raise SystemExit(main())
