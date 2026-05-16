"""Preprocessing placeholders for Verilog inputs."""

from __future__ import annotations

from pathlib import Path


def validate_sources(sources: list[Path]) -> list[Path]:
    """Return normalized source paths after checking they exist."""
    missing = [source for source in sources if not source.is_file()]
    if missing:
        formatted = ", ".join(str(source) for source in missing)
        raise FileNotFoundError(f"source file(s) not found: {formatted}")
    return [source.resolve() for source in sources]

