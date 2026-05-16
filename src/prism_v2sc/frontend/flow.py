"""Top-driven conversion flow for reachable Verilog modules."""

from __future__ import annotations

import re
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Sequence

from prism_v2sc.ir.model import DesignIR, DiagnosticIR, ModuleIR

from .lower import instantiated_modules, lower_module
from .module_index import build_module_index
from .pyverilog_parser import parse_verilog


@dataclass(frozen=True)
class ModuleSourceIndex:
    """Lightweight module-name to source-file index."""

    by_module: dict[str, tuple[Path, ...]]


@dataclass(frozen=True)
class TraversalStats:
    """Observed top-down traversal behavior."""

    module_parse_count: int
    module_lower_count: int
    source_parse_count: int
    visited_modules: tuple[str, ...]
    missing_modules: tuple[str, ...]
    ambiguous_modules: tuple[str, ...]


@dataclass(frozen=True)
class FlowArtifacts:
    """Top-driven lowering output and traversal metrics."""

    design: DesignIR
    source_index: ModuleSourceIndex
    traversal: TraversalStats
    source_index_elapsed_seconds: float
    traversal_elapsed_seconds: float


@dataclass
class _TraversalState:
    parsed_sources: dict[Path, dict[str, object]] = field(default_factory=dict)
    lowered_modules: dict[str, ModuleIR] = field(default_factory=dict)
    output_modules: list[ModuleIR] = field(default_factory=list)
    diagnostics: list[DiagnosticIR] = field(default_factory=list)
    visited: set[str] = field(default_factory=set)
    in_progress: set[str] = field(default_factory=set)
    missing: set[str] = field(default_factory=set)
    ambiguous: set[str] = field(default_factory=set)
    source_parse_count: int = 0


def lower_design_top_down(
    sources: Sequence[Path],
    top: str,
    *,
    include_dirs: Sequence[Path] = (),
    defines: Sequence[str] = (),
) -> FlowArtifacts:
    """Lower only modules reachable from top using per-source parsing."""
    index_start = time.perf_counter()
    source_index = build_source_index(sources)
    source_index_elapsed = time.perf_counter() - index_start
    if top not in source_index.by_module:
        known = ", ".join(sorted(source_index.by_module)) or "<none>"
        raise ValueError(f"top module '{top}' not found; known modules: {known}")

    state = _TraversalState()

    traversal_start = time.perf_counter()
    _visit_module(top, owner=None, state=state, source_index=source_index, include_dirs=include_dirs, defines=defines)
    traversal_elapsed = time.perf_counter() - traversal_start

    modules = tuple(state.output_modules)
    diagnostics = tuple(diagnostic for module in modules for diagnostic in module.diagnostics) + tuple(state.diagnostics)
    design = DesignIR(top=top, modules=modules, diagnostics=diagnostics)
    traversal = TraversalStats(
        module_parse_count=len(state.lowered_modules),
        module_lower_count=len(state.lowered_modules),
        source_parse_count=state.source_parse_count,
        visited_modules=tuple(module.name for module in state.output_modules),
        missing_modules=tuple(sorted(state.missing)),
        ambiguous_modules=tuple(sorted(state.ambiguous)),
    )
    return FlowArtifacts(
        design=design,
        source_index=source_index,
        traversal=traversal,
        source_index_elapsed_seconds=source_index_elapsed,
        traversal_elapsed_seconds=traversal_elapsed,
    )


def build_source_index(sources: Sequence[Path]) -> ModuleSourceIndex:
    """Build a deterministic module-to-source index without retaining ASTs."""
    by_module: dict[str, list[Path]] = {}
    for source in sources:
        text = source.read_text(encoding="utf-8", errors="ignore")
        for module_name in _scan_module_names(text):
            by_module.setdefault(module_name, []).append(source)
    return ModuleSourceIndex(
        by_module={name: tuple(paths) for name, paths in by_module.items()}
    )


def _visit_module(
    module_name: str,
    *,
    owner: str | None,
    state: _TraversalState,
    source_index: ModuleSourceIndex,
    include_dirs: Sequence[Path],
    defines: Sequence[str],
) -> None:
    if module_name in state.visited:
        return
    if module_name in state.in_progress:
        state.diagnostics.append(
            DiagnosticIR(
                severity="error",
                module=owner or module_name,
                code="recursive_module_instance",
                message=f"recursive module instance cycle includes '{module_name}'",
                node="Instance",
            )
        )
        return

    source = _resolve_module_source(module_name, owner, state, source_index)
    if source is None:
        return

    state.in_progress.add(module_name)
    module = _load_module(module_name, source, state, include_dirs=include_dirs, defines=defines)
    state.output_modules.append(module)
    state.visited.add(module_name)

    for child in instantiated_modules(module):
        _visit_module(
            child,
            owner=module.name,
            state=state,
            source_index=source_index,
            include_dirs=include_dirs,
            defines=defines,
        )

    state.in_progress.remove(module_name)


def _resolve_module_source(
    module_name: str,
    owner: str | None,
    state: _TraversalState,
    source_index: ModuleSourceIndex,
) -> Path | None:
    candidates = source_index.by_module.get(module_name, ())
    if not candidates:
        state.missing.add(module_name)
        state.diagnostics.append(
            DiagnosticIR(
                severity="error",
                module=owner or module_name,
                code="unresolved_instance_module" if owner else "missing_top_module",
                message=f"instance refers to unknown module '{module_name}'" if owner else f"top module '{module_name}' not found",
                node="Instance" if owner else "ModuleDef",
            )
        )
        return None
    if len(candidates) > 1:
        state.ambiguous.add(module_name)
        formatted = ", ".join(str(candidate) for candidate in candidates)
        state.diagnostics.append(
            DiagnosticIR(
                severity="error",
                module=owner or module_name,
                code="ambiguous_module_definition",
                message=f"module '{module_name}' is defined in multiple sources: {formatted}",
                node="ModuleDef",
            )
        )
        return None
    return candidates[0]


def _load_module(
    module_name: str,
    source: Path,
    state: _TraversalState,
    *,
    include_dirs: Sequence[Path],
    defines: Sequence[str],
) -> ModuleIR:
    if module_name in state.lowered_modules:
        return state.lowered_modules[module_name]
    if source not in state.parsed_sources:
        ast = parse_verilog([source], include_dirs=include_dirs, defines=defines)
        state.parsed_sources[source] = build_module_index(ast)
        state.source_parse_count += 1
    module_index = state.parsed_sources[source]
    module_def = module_index[module_name]
    module = lower_module(module_def)
    state.lowered_modules[module_name] = module
    return module


def _scan_module_names(text: str) -> list[str]:
    pattern = re.compile(r"(?m)^\s*module\s+([A-Za-z_][A-Za-z0-9_$]*)\b")
    return [match.group(1) for match in pattern.finditer(text)]
