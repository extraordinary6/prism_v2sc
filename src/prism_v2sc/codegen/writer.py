"""Small indentation-aware code writer."""

from __future__ import annotations


class CodeWriter:
    """Collect lines with C/C++ style indentation."""

    def __init__(self, indent: str = "  ") -> None:
        self._indent = indent
        self._level = 0
        self._lines: list[str] = []

    def line(self, text: str = "") -> None:
        if text:
            self._lines.append(f"{self._indent * self._level}{text}")
        else:
            self._lines.append("")

    def indent(self) -> None:
        self._level += 1

    def dedent(self) -> None:
        if self._level == 0:
            raise RuntimeError("cannot dedent below zero")
        self._level -= 1

    def render(self) -> str:
        return "\n".join(self._lines) + "\n"
