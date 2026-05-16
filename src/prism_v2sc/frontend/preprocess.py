"""Source and filelist preprocessing for Verilog inputs."""

from __future__ import annotations

import os
import shlex
from dataclasses import dataclass, field
from pathlib import Path
from typing import Sequence


@dataclass(frozen=True)
class SourceSet:
    """Resolved Verilog sources and preprocessing options."""

    sources: tuple[Path, ...] = field(default_factory=tuple)
    include_dirs: tuple[Path, ...] = field(default_factory=tuple)
    defines: tuple[str, ...] = field(default_factory=tuple)


def parse_filelist(path: Path) -> SourceSet:
    """Parse a .f-style filelist and return raw source paths/options.

    Supported line forms:
    - one source path per line
    - -I <dir> and -I<dir>
    - +incdir+<dir>[+<dir>...]
    - -D <macro[=value]> and -D<macro[=value]>
    - -f <nested_filelist> and -f<nested_filelist>
    - blank lines are ignored
    - lines beginning with "#" or "//" are ignored
    """
    return _parse_filelist(path, active=())


def collect_sources(
    positional_sources: Sequence[Path],
    filelists: Sequence[Path],
) -> SourceSet:
    """Merge positional source files and filelist entries, then validate/dedupe."""
    merged: list[Path] = list(positional_sources)
    include_dirs: list[Path] = []
    defines: list[str] = []
    for filelist in filelists:
        parsed = parse_filelist(filelist)
        merged.extend(parsed.sources)
        include_dirs.extend(parsed.include_dirs)
        defines.extend(parsed.defines)
    return SourceSet(
        sources=tuple(validate_sources(merged)),
        include_dirs=tuple(validate_directories(include_dirs)),
        defines=tuple(_dedupe_strings(defines)),
    )


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


def validate_directories(directories: Sequence[Path]) -> list[Path]:
    """Return normalized include paths after checking they exist."""
    missing = [directory for directory in directories if not directory.is_dir()]
    if missing:
        formatted = ", ".join(str(directory) for directory in missing)
        raise FileNotFoundError(f"include dir(s) not found: {formatted}")
    return _dedupe_paths(directories)


def _parse_filelist(path: Path, active: tuple[Path, ...]) -> SourceSet:
    resolved_filelist = path.resolve()
    if not resolved_filelist.is_file():
        raise FileNotFoundError(f"filelist not found: {path}")
    if resolved_filelist in active:
        chain = " -> ".join(str(item) for item in (*active, resolved_filelist))
        raise ValueError(f"nested filelist cycle detected: {chain}")

    sources: list[Path] = []
    include_dirs: list[Path] = []
    defines: list[str] = []
    tokens = _filelist_tokens(resolved_filelist)
    index = 0
    while index < len(tokens):
        token = tokens[index]
        if token == "-I":
            value, index = _consume_option_value(tokens, index, "-I", resolved_filelist)
            include_dirs.append(_resolve_relative(value, resolved_filelist.parent))
        elif token.startswith("-I") and len(token) > 2:
            include_dirs.append(_resolve_relative(token[2:], resolved_filelist.parent))
        elif token.startswith("+incdir+"):
            for value in token.removeprefix("+incdir+").split("+"):
                if value:
                    include_dirs.append(_resolve_relative(value, resolved_filelist.parent))
        elif token == "-D":
            value, index = _consume_option_value(tokens, index, "-D", resolved_filelist)
            defines.append(value)
        elif token.startswith("-D") and len(token) > 2:
            defines.append(token[2:])
        elif token == "-f":
            value, index = _consume_option_value(tokens, index, "-f", resolved_filelist)
            nested = _parse_filelist(_resolve_relative(value, resolved_filelist.parent), (*active, resolved_filelist))
            sources.extend(nested.sources)
            include_dirs.extend(nested.include_dirs)
            defines.extend(nested.defines)
        elif token.startswith("-f") and len(token) > 2:
            nested = _parse_filelist(
                _resolve_relative(token[2:], resolved_filelist.parent),
                (*active, resolved_filelist),
            )
            sources.extend(nested.sources)
            include_dirs.extend(nested.include_dirs)
            defines.extend(nested.defines)
        elif token.startswith("-") or token.startswith("+"):
            raise ValueError(f"unsupported filelist option in {resolved_filelist}: {token}")
        else:
            sources.append(_resolve_relative(token, resolved_filelist.parent))
        index += 1

    return SourceSet(
        sources=tuple(sources),
        include_dirs=tuple(include_dirs),
        defines=tuple(defines),
    )


def _filelist_tokens(path: Path) -> list[str]:
    tokens: list[str] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or stripped.startswith("//"):
            continue
        tokens.extend(shlex.split(stripped, comments=False, posix=False))
    return tokens


def _consume_option_value(tokens: Sequence[str], index: int, option: str, path: Path) -> tuple[str, int]:
    next_index = index + 1
    if next_index >= len(tokens):
        raise ValueError(f"{option} in {path} requires a value")
    value = tokens[next_index]
    if value.startswith("-") or value.startswith("+"):
        raise ValueError(f"{option} in {path} requires a value, got option {value}")
    return value, next_index


def _resolve_relative(value: str, base: Path) -> Path:
    unquoted = value
    if unquoted.startswith('"') and unquoted.endswith('"') and len(unquoted) >= 2:
        unquoted = unquoted[1:-1]
    path = Path(unquoted)
    if path.is_absolute():
        return path
    return base / path


def _dedupe_paths(paths: Sequence[Path]) -> list[Path]:
    deduped: list[Path] = []
    seen: set[str] = set()
    for path in paths:
        resolved = path.resolve()
        key = str(resolved).casefold() if os.name == "nt" else str(resolved)
        if key in seen:
            continue
        seen.add(key)
        deduped.append(resolved)
    return deduped


def _dedupe_strings(values: Sequence[str]) -> list[str]:
    deduped: list[str] = []
    seen: set[str] = set()
    for value in values:
        if value in seen:
            continue
        seen.add(value)
        deduped.append(value)
    return deduped
