from __future__ import annotations

import json
import os
from pathlib import Path

from prism_v2sc.systemc_build import (
    _link_is_current,
    _object_is_current,
    _read_dependencies,
    _write_pch_source,
)


def test_dependency_parser_ignores_mp_rule_targets(tmp_path: Path) -> None:
    source = tmp_path / "model.cpp"
    header = tmp_path / "model.hpp"
    dep = tmp_path / "model.d"
    dep.write_text(
        f"{tmp_path / 'model.o'}: {source} \\\n {header}\n\n{header}:\n",
        encoding="utf-8",
    )

    assert _read_dependencies(dep) == (source.resolve(), header.resolve())


def test_object_cache_tracks_dependency_timestamps(tmp_path: Path) -> None:
    source = tmp_path / "model.cpp"
    header = tmp_path / "model.hpp"
    object_path = tmp_path / "model.o"
    dep_path = tmp_path / "model.d"
    meta_path = tmp_path / "model.json"
    source.write_text("int model();\n", encoding="utf-8")
    header.write_text("int model();\n", encoding="utf-8")
    dep_path.write_text(f"{object_path}: {source} {header}\n", encoding="utf-8")
    meta_path.write_text(
        json.dumps({"key": "same", "dependencies": [str(source), str(header)]}),
        encoding="utf-8",
    )
    object_path.write_bytes(b"object")
    object_path.touch()
    object_path.chmod(0o644)
    object_path_stat = object_path.stat()
    assert object_path_stat.st_mtime_ns >= source.stat().st_mtime_ns

    assert _object_is_current(object_path, dep_path, meta_path, source.resolve(), "same")

    header.touch()
    newer = object_path.stat().st_mtime_ns + 1_000_000
    os.utime(header, ns=(newer, newer))
    assert not _object_is_current(object_path, dep_path, meta_path, source.resolve(), "same")


def test_pch_source_prefers_generated_runtime_and_preserves_mtime(tmp_path: Path) -> None:
    runtime = tmp_path / "prism_v2sc_runtime.hpp"
    runtime.write_text("#include <systemc>\n", encoding="utf-8")
    pch = tmp_path / "pch.hpp"

    assert _write_pch_source(pch, (tmp_path,)) == runtime
    first_mtime = pch.stat().st_mtime_ns
    assert '#include "prism_v2sc_runtime.hpp"' in pch.read_text(encoding="utf-8")
    assert _write_pch_source(pch, (tmp_path,)) == runtime
    assert pch.stat().st_mtime_ns == first_mtime


def test_link_cache_requires_current_objects_and_matching_command(tmp_path: Path) -> None:
    object_path = tmp_path / "model.o"
    output = tmp_path / "model"
    metadata = tmp_path / "link.json"
    object_path.write_bytes(b"object")
    output.write_bytes(b"executable")
    metadata.write_text(json.dumps({"key": "link-key"}), encoding="utf-8")
    newer = object_path.stat().st_mtime_ns + 1_000_000
    os.utime(output, ns=(newer, newer))

    assert _link_is_current(output, (object_path,), metadata, "link-key")
    assert not _link_is_current(output, (object_path,), metadata, "different")
