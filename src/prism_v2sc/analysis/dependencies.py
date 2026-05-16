"""Dependency analysis placeholders."""

from __future__ import annotations


def no_dependencies() -> tuple[str, ...]:
    """Return an empty dependency set for placeholder flows."""
    return ()

