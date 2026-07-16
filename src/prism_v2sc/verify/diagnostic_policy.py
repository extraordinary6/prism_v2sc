"""Versioned diagnostic policy used to gate approximate conversions."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence

from prism_v2sc.ir.model import DiagnosticIR


@dataclass(frozen=True)
class DiagnosticPolicy:
    version: int = 1
    fail_severities: tuple[str, ...] = ("error",)
    allow_codes: tuple[str, ...] = ()
    deny_codes: tuple[str, ...] = ()
    path: str = ""


def load_diagnostic_policy(path: Path) -> DiagnosticPolicy:
    resolved = path.resolve()
    payload = json.loads(resolved.read_text(encoding="utf-8"))
    if not isinstance(payload, dict) or payload.get("version", 1) != 1:
        raise ValueError("diagnostic policy must be a version 1 object")
    fail_severities = _string_list(payload, "fail_severities", ("error",))
    invalid = set(fail_severities) - {"warning", "error"}
    if invalid:
        raise ValueError(f"unsupported fail severity: {sorted(invalid)[0]}")
    return DiagnosticPolicy(
        fail_severities=fail_severities,
        allow_codes=_string_list(payload, "allow_codes", ()),
        deny_codes=_string_list(payload, "deny_codes", ()),
        path=str(resolved),
    )


def failing_diagnostics(
    diagnostics: Sequence[DiagnosticIR], policy: DiagnosticPolicy
) -> tuple[DiagnosticIR, ...]:
    allowed = set(policy.allow_codes)
    denied = set(policy.deny_codes)
    fail_severities = set(policy.fail_severities)
    return tuple(
        diagnostic
        for diagnostic in diagnostics
        if diagnostic.code not in allowed
        and (diagnostic.code in denied or diagnostic.severity in fail_severities)
    )


def _string_list(payload: dict, key: str, default: tuple[str, ...]) -> tuple[str, ...]:
    value = payload.get(key, default)
    if not isinstance(value, (list, tuple)) or not all(isinstance(item, str) for item in value):
        raise ValueError(f"diagnostic policy '{key}' must be a list of strings")
    return tuple(value)
