"""Procedural driver/conflict analysis for lowered processes."""

from __future__ import annotations

from dataclasses import dataclass
import re
from collections import defaultdict

from prism_v2sc.ir.model import DiagnosticIR, ProcessIR


@dataclass(frozen=True)
class AssignmentSite:
    """One procedural assignment site."""

    process_index: int
    process_kind: str
    assignment_kind: str
    target: str
    conflict_target: str


def analyze_process_drivers(module_name: str, processes: tuple[ProcessIR, ...]) -> tuple[DiagnosticIR, ...]:
    """Return diagnostics for conflicting procedural writes in a module."""
    assignments: list[AssignmentSite] = []
    for index, process in enumerate(processes):
        assignments.extend(_collect_process_assignments(process, index))

    if not assignments:
        return ()

    by_target: dict[str, list[AssignmentSite]] = defaultdict(list)
    for site in assignments:
        by_target[site.conflict_target].append(site)

    diagnostics: list[DiagnosticIR] = []
    for target in sorted(by_target):
        target_sites = by_target[target]
        driver_processes = sorted({site.process_index for site in target_sites})
        ff_driver_processes = sorted(
            {site.process_index for site in target_sites if site.process_kind == "always_ff"}
        )
        styles = {site.assignment_kind for site in target_sites}

        if len(driver_processes) > 1:
            diagnostics.append(
                DiagnosticIR(
                    severity="error",
                    module=module_name,
                    code="multiple_procedural_drivers",
                    message=(
                        f"signal '{target}' is assigned in multiple procedural blocks: "
                        f"{', '.join(str(index) for index in driver_processes)}"
                    ),
                    node="Always",
                )
            )

        if len(ff_driver_processes) > 1:
            diagnostics.append(
                DiagnosticIR(
                    severity="error",
                    module=module_name,
                    code="multiple_always_ff_drivers",
                    message=(
                        f"signal '{target}' is assigned in multiple always_ff blocks: "
                        f"{', '.join(str(index) for index in ff_driver_processes)}"
                    ),
                    node="Always",
                )
            )

        if styles == {"blocking", "nonblocking"}:
            diagnostics.append(
                DiagnosticIR(
                    severity="error",
                    module=module_name,
                    code="mixed_assignment_styles",
                    message=(
                        f"signal '{target}' is assigned with both blocking '=' and "
                        "nonblocking '<=' styles"
                    ),
                    node="Always",
                )
            )

    for index, process in enumerate(processes):
        if process.kind != "always_ff":
            continue
        if _process_has_blocking_assign(process):
            diagnostics.append(
                DiagnosticIR(
                    severity="warning",
                    module=module_name,
                    code="blocking_in_always_ff",
                    message=(
                        "always_ff block contains blocking '=' assignments; behavior can be "
                        "sensitive to statement ordering"
                    ),
                    node="Always",
                )
            )

    return tuple(diagnostics)


def _collect_process_assignments(process: ProcessIR, process_index: int) -> list[AssignmentSite]:
    sites: list[AssignmentSite] = []
    for statement in process.structured_statements:
        _collect_statement_assignments(process, process_index, statement, sites)
    return sites


def _collect_statement_assignments(
    process: ProcessIR,
    process_index: int,
    statement: dict[str, object],
    sites: list[AssignmentSite],
) -> None:
    kind = statement.get("type")
    if kind in {"blocking_assign", "nonblocking_assign"}:
        left = str(statement.get("left", "")).strip()
        base = _base_target(left)
        if base:
            sites.append(
                AssignmentSite(
                    process_index=process_index,
                    process_kind=process.kind,
                    assignment_kind="blocking" if kind == "blocking_assign" else "nonblocking",
                    target=left,
                    conflict_target=_conflict_target(left),
                )
            )
        return
    if kind == "case":
        for item in _as_case_items(statement.get("items")):
            for child in _as_statement_list(item.get("statements")):
                _collect_statement_assignments(process, process_index, child, sites)
        return
    if kind != "if":
        return

    for child in _as_statement_list(statement.get("true")):
        _collect_statement_assignments(process, process_index, child, sites)
    for child in _as_statement_list(statement.get("false")):
        _collect_statement_assignments(process, process_index, child, sites)


def _as_statement_list(value: object) -> list[dict[str, object]]:
    if not isinstance(value, list):
        return []
    return [item for item in value if isinstance(item, dict)]


def _as_case_items(value: object) -> list[dict[str, object]]:
    if not isinstance(value, list):
        return []
    return [item for item in value if isinstance(item, dict)]


def _base_target(target: str) -> str:
    match = re.match(r"^\s*(?P<name>[A-Za-z_][A-Za-z0-9_$]*)", target)
    if match is None:
        return ""
    return match.group("name")


def _conflict_target(target: str) -> str:
    target = target.strip()
    match = re.match(r"^(?P<name>[A-Za-z_][A-Za-z0-9_$]*)(?P<select>\[[^\]]+\])?$", target)
    if match is None:
        return _base_target(target)
    select = match.group("select")
    if not select:
        return match.group("name")
    return f"{match.group('name')}{select.replace(' ', '')}"


def _process_has_blocking_assign(process: ProcessIR) -> bool:
    for statement in process.structured_statements:
        if _statement_has_blocking_assign(statement):
            return True
    return False


def _statement_has_blocking_assign(statement: dict[str, object]) -> bool:
    kind = statement.get("type")
    if kind == "blocking_assign":
        return True
    if kind == "case":
        return any(
            _statement_has_blocking_assign(child)
            for item in _as_case_items(statement.get("items"))
            for child in _as_statement_list(item.get("statements"))
        )
    if kind != "if":
        return False
    return any(_statement_has_blocking_assign(child) for child in _as_statement_list(statement.get("true"))) or any(
        _statement_has_blocking_assign(child) for child in _as_statement_list(statement.get("false"))
    )
