"""Preprocessing placeholders for Verilog inputs."""

from __future__ import annotations

import os
from pathlib import Path
from typing import Sequence


def parse_filelist(path: Path) -> list[Path]:
    """Parse a .f-style filelist and return raw source paths.

    Supported line forms:
    - one source path per line
    - blank lines are ignored
    - lines beginning with "#" or "//" are ignored
    """
    if not path.is_file():
        raise FileNotFoundError(f"filelist not found: {path}")

    sources: list[Path] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("#") or stripped.startswith("//"):
            continue
        if stripped.startswith('"') and stripped.endswith('"') and len(stripped) >= 2:
            stripped = stripped[1:-1]
        source = Path(stripped)
        if not source.is_absolute():
            source = path.parent / source
        sources.append(source)
    return sources


def collect_sources(
    positional_sources: Sequence[Path],
    filelists: Sequence[Path],
) -> list[Path]:
    """Merge positional source files and filelist entries, then validate/dedupe."""
    merged: list[Path] = list(positional_sources)
    for filelist in filelists:
        merged.extend(parse_filelist(filelist))
    return validate_sources(merged)


def validate_sources(sources: Sequence[Path]) -> list[Path]:
    """Return normalized source paths after checking they exist."""
    missing = [source for source in sources if not source.is_file()]
    if missing:
        formatted = ", ".join(str(source) for source in missing)
        raise FileNotFoundError(f"source file(s) not found: {formatted}")

    deduped: list[Path] = []
    seen: set[str] = set()
    for source in sources:
        resolved = source.resolve()
        key = str(resolved).casefold() if os.name == "nt" else str(resolved)
        if key in seen:
            continue
        seen.add(key)
        deduped.append(resolved)
    return deduped
