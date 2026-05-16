"""Driver analysis placeholders."""

from __future__ import annotations


def has_multiple_drivers(drivers: list[str]) -> bool:
    """Return whether a signal has more than one syntactic driver."""
    return len(set(drivers)) > 1

