"""Top-driven streaming conversion flow.

Parsing is whole-design: every source is fed to slang in one
``Compilation`` and slang elaborates the entire design up-front
(parameter overrides applied, generate-if folded, generate-for unrolled).

Discovery is top-down (start from ``--top``, walk the elaborated instance
tree). Lowering is lazy: only the modules reachable from the top instance
are converted into ``ModuleIR``; unreachable definitions are ignored.

Emission is bottom-up (post-order DFS): a parent's hpp is written after
all its children have already been emitted, so children's ``#include``
paths are valid the moment a parent file lands on disk. Repeated
instantiations of the same module lower and emit it exactly once.

Memory profile:

- The slang ``Compilation`` holds the elaborated symbol table for the
  whole design; peak memory scales with total design size, not per-source.
- ``ModuleSignature`` and ``ModuleIR`` are kept per reachable module
  (needed for the JSON IR dump, parent-child binding resolution, and
  Phase 5 metrics). Both are small relative to the slang symbol table.
"""

from __future__ import annotations

import os
import re
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable, Sequence

from prism_v2sc.ir.model import DesignIR, DiagnosticIR, ModuleIR, ModuleSignature


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
    signatures: dict[str, ModuleSignature] = field(default_factory=dict)
    emit_order: tuple[str, ...] = ()


# Callback signature: (module_ir, signatures_so_far) -> None.
EmitCallback = Callable[[ModuleIR, dict[str, ModuleSignature]], None]


@dataclass
class _TraversalState:
    lowered_modules: dict[str, ModuleIR] = field(default_factory=dict)
    output_modules: list[ModuleIR] = field(default_factory=list)
    diagnostics: list[DiagnosticIR] = field(default_factory=list)
    visited: set[str] = field(default_factory=set)
    in_progress: set[str] = field(default_factory=set)
    missing: set[str] = field(default_factory=set)
    ambiguous: set[str] = field(default_factory=set)
    source_parse_count: int = 0
    parsed_sources: set[Path] = field(default_factory=set)
    signatures: dict[str, ModuleSignature] = field(default_factory=dict)
    emit_order: list[str] = field(default_factory=list)
    emitted: set[str] = field(default_factory=set)


def lower_design_top_down(
    sources: Sequence[Path],
    top: str,
    *,
    include_dirs: Sequence[Path] = (),
    defines: Sequence[str] = (),
    emit_callback: EmitCallback | None = None,
) -> FlowArtifacts:
    """Lower modules reachable from ``top`` with bottom-up emit.

    ``emit_callback`` is invoked once per module in post-order DFS (children
    before parents). When provided, this is the streaming write path that
    lets each per-module hpp land on disk as soon as its children are
    already on disk.

    slang elaborates the entire design across all sources in one
    ``Compilation`` before this function walks the instance tree.
    Unreachable definitions are never lowered; repeated instantiations
    of the same module lower exactly once.
    """
    from .lower import extract_signature as sv_extract_signature
    from .lower import lower_module as sv_lower_module
    from .pyslang_parser import parse_sources

    index_start = time.perf_counter()
    compilation = parse_sources(sources, include_dirs=include_dirs, defines=defines)
    source_index_elapsed = time.perf_counter() - index_start

    root = compilation.getRoot()
    top_instances = [ti for ti in root.topInstances if ti.definition.name == top]
    if not top_instances:
        known = ", ".join(sorted({ti.definition.name for ti in root.topInstances})) or "<none>"
        raise ValueError(f"top module '{top}' not found; known modules: {known}")

    traversal_start = time.perf_counter()

    signatures: dict[str, ModuleSignature] = {}
    lowered: dict[str, ModuleIR] = {}
    emit_order: list[str] = []
    visited: set[str] = set()
    discovery_order: list[str] = []
    emitted: set[str] = set()
    diagnostics_extra: list[DiagnosticIR] = list(_collect_slang_diagnostics(compilation))
    source_manager = compilation.sourceManager

    def visit(instance) -> None:
        definition_name = instance.definition.name
        if definition_name in visited:
            return
        visited.add(definition_name)
        # Cache the signature *before* descending into children so a parent
        # whose port list references this child gets the binding info.
        if definition_name not in signatures:
            signatures[definition_name] = sv_extract_signature(instance)
        if definition_name not in lowered:
            lowered[definition_name] = sv_lower_module(instance, source_manager=source_manager)
            discovery_order.append(definition_name)
        for child in _pyslang_child_instances(instance):
            visit(child)
        # Bottom-up emit: parent's hpp lands only after every child is on disk.
        if definition_name not in emitted:
            emitted.add(definition_name)
            if emit_callback is not None:
                emit_callback(lowered[definition_name], signatures)
                emit_order.append(definition_name)

    for top_instance in top_instances:
        visit(top_instance)

    traversal_elapsed = time.perf_counter() - traversal_start

    # ``design.modules`` follows top-down discovery order for stable
    # iteration; the emit_callback above already received them in
    # post-order so the on-disk write sequence is unchanged.
    modules = tuple(lowered[name] for name in discovery_order)
    diagnostics = tuple(d for module in modules for d in module.diagnostics) + tuple(diagnostics_extra)
    design = DesignIR(top=top, modules=modules, diagnostics=diagnostics)
    traversal = TraversalStats(
        module_parse_count=len(lowered),
        module_lower_count=len(lowered),
        source_parse_count=len(sources),
        visited_modules=tuple(module.name for module in modules),
        missing_modules=(),
        ambiguous_modules=(),
    )
    return FlowArtifacts(
        design=design,
        source_index=ModuleSourceIndex(by_module={}),
        traversal=traversal,
        source_index_elapsed_seconds=source_index_elapsed,
        traversal_elapsed_seconds=traversal_elapsed,
        signatures=signatures,
        emit_order=tuple(emit_order),
    )


def compute_source_root(sources: Sequence[Path]) -> Path:
    """Return the common parent directory of all sources for output mirroring.

    With a single source, returns its containing directory. With multiple,
    returns the deepest path that is a prefix of every source's parent.
    """
    if not sources:
        return Path.cwd()
    parents = [Path(source).resolve().parent for source in sources]
    if len(parents) == 1:
        return parents[0]
    try:
        common = os.path.commonpath([str(parent) for parent in parents])
    except ValueError:
        # Mixed drives on Windows fall back to the first parent.
        return parents[0]
    return Path(common)


def _pyslang_child_instances(instance) -> list:
    """Return the direct child instance symbols reachable from a parent."""
    from .lower import _child_instances

    return _child_instances(instance)


def _collect_slang_diagnostics(compilation) -> list[DiagnosticIR]:
    """Translate slang's elaboration diagnostics into ``DiagnosticIR`` rows.

    slang has its own ``DiagCode`` taxonomy. We surface the formatted
    message verbatim and tag the code as ``slang_<DiagCodeName>`` so the
    origin is unambiguous in downstream consumers (CI logs, IR dumps).
    """
    import pyslang as ps  # local import to avoid import-time hard dependency

    engine = ps.DiagnosticEngine(compilation.sourceManager)
    out: list[DiagnosticIR] = []
    diags = compilation.getAllDiagnostics()
    for index in range(len(diags)):
        diag = diags[index]
        severity = engine.getSeverity(diag.code, diag.location)
        message = engine.formatMessage(diag)
        code_name = str(diag.code).split("(", 1)[-1].rstrip(")")
        out.append(
            DiagnosticIR(
                severity="error" if str(severity).endswith("Error") or str(severity).endswith("Fatal") else "warning",
                module="",
                code=f"slang_{code_name}",
                message=message,
                node=code_name,
            )
        )
    return out
