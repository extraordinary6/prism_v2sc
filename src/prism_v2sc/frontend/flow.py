"""Top-driven streaming conversion flow.

Discovery is top-down (start from ``--top``, walk instances). Emission is
bottom-up (post-order DFS): a parent's hpp is written after all its children
have already been emitted, so children's ``#include`` paths are valid the
moment a parent file lands on disk.

Memory profile:

- Each source is parsed at most once. Right after parsing we (a) cache a
  small ``ModuleSignature`` for every module defined in that source, and
  (b) eagerly lower every module the source defines, then drop the AST.
  This avoids re-parsing sources that contain multiple reachable modules.
- ``ModuleSignature`` is the only object retained for the entire flow at
  module granularity. It's a thin port + parameter list, so the cost is
  ~kB per module rather than the MB-per-source cost of holding ASTs.
- ``ModuleIR`` for already-lowered modules is also retained, since the IR
  is needed for the JSON IR dump and Phase 5 metrics. IR size is small
  relative to AST.

Frontend selection:

- ``frontend="pyverilog"`` (default) drives the per-source streaming model
  described above.
- ``frontend="pyslang"`` parses all sources together into a single slang
  ``Compilation`` (slang already elaborates the design across all files)
  and then walks the elaborated instance tree once. The same
  ``FlowArtifacts`` shape comes back, so downstream code is frontend-agnostic.
"""

from __future__ import annotations

import os
import re
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable, Sequence

from prism_v2sc.ir.model import DesignIR, DiagnosticIR, ModuleIR, ModuleSignature

from .lower import extract_signature, instantiated_modules, lower_module
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
    frontend: str = "pyslang",
) -> FlowArtifacts:
    """Lower modules reachable from ``top`` with bottom-up emit.

    ``emit_callback`` is invoked once per module in post-order DFS (children
    before parents). When provided, this is the streaming write path that
    lets each per-module hpp land on disk as soon as its children are
    already on disk.

    Each Verilog source is parsed at most once. After parsing, ASTs are
    discarded (only their already-lowered IRs and signatures survive),
    bounding peak memory regardless of design size.

    ``frontend`` selects the parser/lowerer backend; see the module
    docstring for details.
    """
    if frontend == "pyslang":
        return _lower_design_pyslang(
            sources,
            top,
            include_dirs=include_dirs,
            defines=defines,
            emit_callback=emit_callback,
        )
    if frontend != "pyverilog":
        raise ValueError(f"unknown frontend '{frontend}'; expected 'pyverilog' or 'pyslang'")

    index_start = time.perf_counter()
    source_index = build_source_index(sources)
    source_index_elapsed = time.perf_counter() - index_start
    if top not in source_index.by_module:
        known = ", ".join(sorted(source_index.by_module)) or "<none>"
        raise ValueError(f"top module '{top}' not found; known modules: {known}")

    state = _TraversalState()

    traversal_start = time.perf_counter()
    _visit_module(
        top,
        owner=None,
        state=state,
        source_index=source_index,
        include_dirs=include_dirs,
        defines=defines,
        emit_callback=emit_callback,
    )
    traversal_elapsed = time.perf_counter() - traversal_start

    modules = tuple(state.output_modules)
    diagnostics = tuple(diagnostic for module in modules for diagnostic in module.diagnostics) + tuple(
        state.diagnostics
    )
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
        signatures=dict(state.signatures),
        emit_order=tuple(state.emit_order),
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


def _visit_module(
    module_name: str,
    *,
    owner: str | None,
    state: _TraversalState,
    source_index: ModuleSourceIndex,
    include_dirs: Sequence[Path],
    defines: Sequence[str],
    emit_callback: EmitCallback | None,
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
            emit_callback=emit_callback,
        )

    state.in_progress.remove(module_name)

    # Bottom-up emit: now that every child has been emitted (and its
    # signature is cached), it is safe to write this module's hpp.
    if emit_callback is not None and module_name not in state.emitted:
        emit_callback(module, state.signatures)
        state.emitted.add(module_name)
        state.emit_order.append(module_name)


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
                message=(
                    f"instance refers to unknown module '{module_name}'"
                    if owner
                    else f"top module '{module_name}' not found"
                ),
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
        module_index = build_module_index(ast)
        # Eagerly extract signatures and lower every module defined in this
        # source. Cost: lowering work for possibly-unreached siblings (cheap
        # compared to a second Pyverilog parse). Benefit: we can release the
        # AST right now, and we never re-parse this source.
        for sibling_name, module_def in module_index.items():
            if sibling_name not in state.signatures:
                state.signatures[sibling_name] = extract_signature(module_def)
            if sibling_name not in state.lowered_modules:
                state.lowered_modules[sibling_name] = lower_module(
                    module_def, source_path=str(source)
                )
        state.parsed_sources.add(source)
        state.source_parse_count += 1
        del ast, module_index
    return state.lowered_modules[module_name]


def _scan_module_names(text: str) -> list[str]:
    pattern = re.compile(r"(?m)^\s*module\s+([A-Za-z_][A-Za-z0-9_$]*)\b")
    return [match.group(1) for match in pattern.finditer(text)]


def _lower_design_pyslang(
    sources: Sequence[Path],
    top: str,
    *,
    include_dirs: Sequence[Path] = (),
    defines: Sequence[str] = (),
    emit_callback: EmitCallback | None = None,
) -> FlowArtifacts:
    """pyslang dispatch path for ``lower_design_top_down``.

    slang elaborates the entire design across all sources in one compile,
    so the per-source streaming concerns of the pyverilog flow do not
    apply here. We parse once, walk the elaborated instance tree in
    post-order DFS, and emit in the same callback-driven order so callers
    cannot tell the two backends apart.
    """
    from .lower_sv import extract_signature as sv_extract_signature
    from .lower_sv import lower_module as sv_lower_module
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

    # ``design.modules`` follows top-down discovery order to mirror the
    # pyverilog flow; the emit_callback above already received them in
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


def _pyslang_child_instances(instance) -> list:
    """Return the direct child instance symbols reachable from a parent."""
    from .lower_sv import _child_instances

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
