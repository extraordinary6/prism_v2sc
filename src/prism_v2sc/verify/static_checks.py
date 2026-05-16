"""Static checks for generated SystemC text."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class StaticCheckIssue:
    """One generated-code static check finding."""

    severity: str
    code: str
    message: str


def check_generated_systemc(header: str) -> tuple[StaticCheckIssue, ...]:
    """Return obvious generated-code issues that should not pass silently."""
    issues: list[StaticCheckIssue] = []
    if "TODO:" in header:
        issues.append(
            StaticCheckIssue(
                severity="error",
                code="generated_todo",
                message="generated SystemC contains TODO fallback text",
            )
        )
    if "// Unsupported statement:" in header:
        issues.append(
            StaticCheckIssue(
                severity="warning",
                code="generated_unsupported_statement",
                message="generated SystemC contains unsupported statement comments",
            )
        )
    if "#include <systemc>" not in header:
        issues.append(
            StaticCheckIssue(
                severity="error",
                code="missing_systemc_include",
                message="generated SystemC header is missing <systemc> include",
            )
        )
    if "SC_MODULE(" not in header:
        issues.append(
            StaticCheckIssue(
                severity="error",
                code="missing_sc_module",
                message="generated SystemC header contains no SC_MODULE declaration",
            )
        )
    return tuple(issues)
