"""SystemC code generation.

Two entry points:

- :func:`generate_systemc_header` returns a single string containing every
  module concatenated in dependency order. Used by tests and the Phase 5
  metrics' ``ConversionArtifacts.header`` view.

- :func:`emit_systemc_files` writes one ``.hpp`` per module under
  ``out_dir`` mirroring the original RTL directory layout (each file's
  directory relative to ``out_dir`` matches its source's directory
  relative to ``source_root``). Each per-module file ``#include``s its
  instantiated children's headers, so users only need to include the top
  module's hpp.
"""

from __future__ import annotations

import ast
from dataclasses import asdict, dataclass, replace
from functools import lru_cache
import hashlib
import json
from pathlib import Path
import os
import re
from typing import Sequence

from prism_v2sc.ir.model import (
    ArgIR,
    ContinuousAssignIR,
    DesignIR,
    GenerateForIR,
    InstanceIR,
    ModuleIR,
    ModuleSignature,
    PortIR,
    ProcessIR,
    SignalIR,
    SubroutineIR,
    SubroutineParamIR,
    WidthIR,
)

from .expr import (
    ModuleContext,
    build_module_context,
    collect_sensitivity,
    const_eval,
    infer_signed,
    infer_width,
    is_array_element_expr,
    lvalue_base_name,
    render_lvalue,
    render_rvalue,
    sanitize_identifier,
    systemc_int_type,
)
from .instrumentation import (
    InstrumentationConfig,
    generate_dump_api,
    generate_instrumentation_declarations,
    generate_instrumentation_init,
    generate_sampling_processes,
)
from .writer import CodeWriter


@dataclass(frozen=True)
class GenerateBitBridge:
    """Scalar bridge for a generated instance bit-select port binding."""

    name: str
    method_name: str
    parent_name: str
    port_name: str
    direction: str
    count_expr: str


@dataclass(frozen=True)
class DirectBitBridge:
    """Scalar bridge for a direct instance bit-select port binding."""

    name: str
    method_name: str
    parent_name: str
    index_expr: str
    instance_name: str
    port_name: str
    direction: str
    vector: bool = False
    array_cell: bool = False


@dataclass(frozen=True)
class ExprPortBridge:
    """Bridge an input port connected to a non-net expression."""

    name: str
    method_name: str
    instance_name: str
    port_name: str
    port: PortIR
    expr: dict[str, object]


@dataclass(frozen=True)
class BridgeMethodSpec:
    """Generated bridge body plus the signals that schedule it."""

    name: str
    body: tuple[str, ...]
    sensitivity: tuple[str, ...]


@dataclass(frozen=True)
class UnconnectedPortSignal:
    """Dummy signal for an explicitly unconnected child port."""

    name: str
    instance_name: str
    port_name: str
    port: PortIR


@dataclass(frozen=True)
class ChildOutputAssembler:
    """One method per parent signal that gathers sliced child outputs.

    SystemC tracks writers per ``sc_signal``, not per bit.  Consequently,
    direct bit bridges and expression bridges targeting disjoint slices of
    one parent must still share a single writer process.
    """

    parent_name: str
    method_name: str
    direct_bridges: tuple[DirectBitBridge, ...]
    expr_bridges: tuple[ExprPortBridge, ...]
    shadow_slots: tuple[tuple[str, int, int], ...] = ()


@dataclass(frozen=True)
class ProcessSliceAssembler:
    """One method per parent signal whose bits are written by multiple
    procedural processes. Same single-writer problem as
    ``DirectOutputAssembler``: if N procedural blocks each do
    ``parent.read(); __next_parent[i] = expr; parent.write(__next_parent);``
    the resulting SystemC aborts at runtime with
    ``SC_ID_MORE_THAN_ONE_SIGNAL_DRIVER_``.

    The transformation pass redirects each per-process bit/part write to a
    dedicated ``__shadow_<parent>_<slot>`` signal. This assembler is the
    single writer to ``parent`` and reads all the shadows back.
    """

    parent_name: str
    method_name: str
    # Each slot: (shadow_signal_name, msb_index, lsb_index).
    # msb == lsb for a 1-bit shadow.
    slots: tuple[tuple[str, int, int], ...]


def _expr_output_parent(bridge: ExprPortBridge, ctx: ModuleContext) -> str | None:
    if bridge.port.direction != "output" or bridge.expr.get("kind") not in {"bitselect", "partselect"}:
        return None
    target = bridge.expr.get("target")
    if not isinstance(target, dict):
        return None
    if target.get("kind") == "identifier":
        name = str(target.get("name", ""))
        if bridge.expr.get("kind") == "bitselect" and name in ctx.array_signal_names:
            return None
        return _sanitize_identifier(name)
    if target.get("kind") != "bitselect":
        return None
    array_target = target.get("target")
    if not isinstance(array_target, dict) or array_target.get("kind") != "identifier":
        return None
    array_name = str(array_target.get("name", ""))
    array_index = target.get("index")
    index_value = const_eval(array_index, ctx) if isinstance(array_index, dict) else None
    if index_value is None or array_name not in ctx.array_signal_names:
        return None
    return f"{_sanitize_identifier(array_name)}[{index_value}]"


def _child_output_assemblers(
    direct_bit_bridges: list[DirectBitBridge],
    expr_port_bridges: list[ExprPortBridge],
    ctx: ModuleContext,
) -> list[ChildOutputAssembler]:
    grouped_direct: dict[str, list[DirectBitBridge]] = {}
    grouped_expr: dict[str, list[ExprPortBridge]] = {}
    order: list[str] = []
    for bridge in direct_bit_bridges:
        if bridge.direction not in {"output", "inout"}:
            continue
        if _is_array_subarray_name(bridge.parent_name, ctx):
            # An unpacked array element is already its own sc_signal. Its
            # child output must be bridged directly, not assembled as bits of
            # the outer array object.
            continue
        if bridge.parent_name not in grouped_direct and bridge.parent_name not in grouped_expr:
            order.append(bridge.parent_name)
        grouped_direct.setdefault(bridge.parent_name, []).append(bridge)
    for bridge in expr_port_bridges:
        parent = _expr_output_parent(bridge, ctx)
        if parent is None:
            continue
        if _is_array_subarray_name(parent, ctx):
            continue
        if parent not in grouped_direct and parent not in grouped_expr:
            order.append(parent)
        grouped_expr.setdefault(parent, []).append(bridge)
    return [
        ChildOutputAssembler(
            parent_name=parent,
            method_name=f"__bridge_assemble_{_sanitize_identifier(parent)}",
            direct_bridges=tuple(grouped_direct.get(parent, ())),
            expr_bridges=tuple(grouped_expr.get(parent, ())),
        )
        for parent in order
    ]


def _merge_child_and_slice_assemblers(
    child_assemblers: list[ChildOutputAssembler],
    slice_assemblers: list[ProcessSliceAssembler],
) -> tuple[list[ChildOutputAssembler], list[ProcessSliceAssembler]]:
    """Merge sliced local writers into a child-output assembler for a parent.

    A Verilog vector may legally have one child output driving a low slice and
    a continuous/procedural assignment driving a disjoint high slice. SystemC
    still requires one process to write the complete ``sc_signal``.
    """
    slices_by_parent: dict[str, list[ProcessSliceAssembler]] = {}
    for assembler in slice_assemblers:
        slices_by_parent.setdefault(assembler.parent_name, []).append(assembler)

    merged: list[ChildOutputAssembler] = []
    consumed: set[int] = set()
    for child in child_assemblers:
        matching = slices_by_parent.get(child.parent_name, ())
        shadow_slots: list[tuple[str, int, int]] = list(child.shadow_slots)
        for assembler in matching:
            shadow_slots.extend(assembler.slots)
            consumed.add(id(assembler))
        merged.append(replace(child, shadow_slots=tuple(shadow_slots)))
    remaining = [assembler for assembler in slice_assemblers if id(assembler) not in consumed]
    return merged, remaining


def _classify_lvalue_slot(
    lvalue: object,
    ctx: ModuleContext,
) -> tuple[str, int, int] | None:
    """Return ``(parent_name, msb, lsb)`` for a constant-indexed bit/part
    select lvalue. ``msb == lsb`` for a single bit. Returns ``None`` for
    whole-signal writes, dynamic indices, or non-identifier targets.
    """
    if not isinstance(lvalue, dict):
        return None
    kind = lvalue.get("kind")
    if kind == "bitselect":
        target = lvalue.get("target")
        if not isinstance(target, dict):
            return None
        idx = lvalue.get("index")
        value = const_eval(idx, ctx) if isinstance(idx, dict) else None
        if value is None:
            return None
        if target.get("kind") == "bitselect":
            array_target = target.get("target")
            if not isinstance(array_target, dict) or array_target.get("kind") != "identifier":
                return None
            array_name = str(array_target.get("name", ""))
            array_index = target.get("index")
            array_value = const_eval(array_index, ctx) if isinstance(array_index, dict) else None
            if array_value is None or array_name not in ctx.array_signal_names:
                return None
            return (f"{array_name}[{array_value}]", value, value)
        if target.get("kind") != "identifier" or str(target.get("name", "")) in ctx.array_signal_names:
            return None
        return (str(target.get("name", "")), value, value)
    if kind == "partselect":
        target = lvalue.get("target")
        if not isinstance(target, dict):
            return None
        msb_node = lvalue.get("msb")
        lsb_node = lvalue.get("lsb")
        msb = const_eval(msb_node, ctx) if isinstance(msb_node, dict) else None
        lsb = const_eval(lsb_node, ctx) if isinstance(lsb_node, dict) else None
        if msb is None or lsb is None:
            return None
        if target.get("kind") == "bitselect":
            array_target = target.get("target")
            if not isinstance(array_target, dict) or array_target.get("kind") != "identifier":
                return None
            array_name = str(array_target.get("name", ""))
            array_index = target.get("index")
            array_value = const_eval(array_index, ctx) if isinstance(array_index, dict) else None
            if array_value is None or array_name not in ctx.array_signal_names:
                return None
            return (f"{array_name}[{array_value}]", max(msb, lsb), min(msb, lsb))
        if target.get("kind") != "identifier" or str(target.get("name", "")) in ctx.array_signal_names:
            return None
        return (str(target.get("name", "")), max(msb, lsb), min(msb, lsb))
    return None


def _walk_process_assignments(statement: object, sink: list) -> None:
    """Yield every assignment dict reachable from ``statement``."""
    if not isinstance(statement, dict):
        return
    kind = statement.get("type")
    if kind in {"blocking_assign", "nonblocking_assign"}:
        sink.append(statement)
        return
    if kind == "block":
        for child in statement.get("statements", ()) or ():
            _walk_process_assignments(child, sink)
        return
    if kind == "if":
        for child in statement.get("true", ()) or ():
            _walk_process_assignments(child, sink)
        for child in statement.get("false", ()) or ():
            _walk_process_assignments(child, sink)
        return
    if kind == "case":
        for item in statement.get("items", ()) or ():
            for child in (item.get("statements", ()) if isinstance(item, dict) else ()) or ():
                _walk_process_assignments(child, sink)


def _cast_expr_to_slice_width(expr: object, width: int) -> object:
    """Preserve Verilog part-select assignment conversion after shadowing."""
    if width <= 1 or not isinstance(expr, dict):
        return expr
    return {
        "kind": "cast",
        "signed": False,
        "width": width,
        "operand": expr,
    }


def _aggregate_multi_writer_continuous_assigns(
    module: ModuleIR,
    ctx: ModuleContext | None = None,
    *,
    force_parents: frozenset[str] = frozenset(),
) -> tuple[ModuleIR, list[ProcessSliceAssembler]]:
    """Give sliced continuous assignments one SystemC writer per parent.

    Multiple Verilog continuous assignments may legally drive disjoint bits
    of one vector. Each generated ``assign_N`` SC_METHOD otherwise performs
    a read-modify-write on the whole ``sc_signal``, which SystemC treats as
    multiple drivers even when the Verilog slices do not overlap.
    """
    ctx = ctx or build_module_context(module)
    sites_per_parent: dict[str, list[tuple[int, int | None, tuple[str, int, int]]]] = {}
    has_whole_or_dynamic_write: set[str] = set()

    for index, assign in enumerate(module.continuous_assigns):
        left_expr = assign.left_expr
        if isinstance(left_expr, dict) and left_expr.get("kind") == "concat":
            for part_index, part in enumerate(left_expr.get("parts", ()) or ()):
                slot = _classify_lvalue_slot(part, ctx)
                if slot is not None:
                    parent = slot[0]
                    if not _is_array_subarray_name(parent, ctx):
                        sites_per_parent.setdefault(parent, []).append(
                            (index, part_index, slot)
                        )
                    continue
                if not isinstance(part, dict):
                    continue
                kind = part.get("kind")
                if kind == "identifier":
                    name = str(part.get("name", ""))
                    if name:
                        has_whole_or_dynamic_write.add(name)
                    continue
                target = part.get("target") if kind in {"bitselect", "partselect"} else None
                if isinstance(target, dict) and target.get("kind") == "identifier":
                    has_whole_or_dynamic_write.add(str(target.get("name", "")))
            continue
        slot = _classify_lvalue_slot(left_expr, ctx)
        if slot is not None:
            parent = slot[0]
            if _is_array_subarray_name(parent, ctx):
                continue
            sites_per_parent.setdefault(parent, []).append((index, None, slot))
            continue
        if not isinstance(left_expr, dict):
            continue
        kind = left_expr.get("kind")
        if kind == "identifier":
            name = str(left_expr.get("name", ""))
            if name:
                has_whole_or_dynamic_write.add(name)
            continue
        target = left_expr.get("target") if kind in {"bitselect", "partselect"} else None
        if isinstance(target, dict) and target.get("kind") == "identifier":
            has_whole_or_dynamic_write.add(str(target.get("name", "")))

    qualifying = {
        parent: sites
        for parent, sites in sites_per_parent.items()
        if (len(sites) > 1 or parent in force_parents)
        and parent not in has_whole_or_dynamic_write
    }
    if not qualifying:
        return module, []

    rewritten_assigns = list(module.continuous_assigns)
    extra_signals: list[SignalIR] = []
    extra_signal_names: set[str] = set()
    assemblers: list[ProcessSliceAssembler] = []

    for parent in sorted(qualifying):
        slot_map: dict[tuple[int, int], str] = {}
        for index, part_index, (_, msb, lsb) in qualifying[parent]:
            slot = (msb, lsb)
            shadow_name = slot_map.get(slot)
            if shadow_name is None:
                slot_id = f"{msb}" if msb == lsb else f"{msb}_{lsb}"
                shadow_name = f"__shadow_{_sanitize_identifier(parent)}_{slot_id}"
                slot_map[slot] = shadow_name
                if shadow_name not in extra_signal_names:
                    extra_signal_names.add(shadow_name)
                    slot_width = abs(msb - lsb) + 1
                    width_ir = None if slot_width == 1 else WidthIR(msb=str(slot_width - 1), lsb="0")
                    extra_signals.append(
                        SignalIR(name=shadow_name, kind="wire", width=width_ir, signed=False)
                    )
            if part_index is None:
                rewritten_assigns[index] = replace(
                    rewritten_assigns[index],
                    left=shadow_name,
                    left_expr={"kind": "identifier", "name": shadow_name},
                    right_expr=_cast_expr_to_slice_width(
                        rewritten_assigns[index].right_expr,
                        abs(msb - lsb) + 1,
                    ),
                )
            else:
                left_expr = rewritten_assigns[index].left_expr
                if not isinstance(left_expr, dict):
                    continue
                parts = list(left_expr.get("parts", ()) or ())
                parts[part_index] = {"kind": "identifier", "name": shadow_name}
                rewritten_assigns[index] = replace(
                    rewritten_assigns[index],
                    left_expr={**left_expr, "parts": parts},
                )
        assemblers.append(
            ProcessSliceAssembler(
                parent_name=parent,
                method_name=f"__assemble_{_sanitize_identifier(parent)}",
                slots=tuple(
                    (slot_map[(msb, lsb)], msb, lsb) for (msb, lsb) in sorted(slot_map)
                ),
            )
        )

    return (
        replace(
            module,
            signals=tuple(extra_signals) + module.signals,
            continuous_assigns=tuple(rewritten_assigns),
        ),
        assemblers,
    )


def _aggregate_multi_writer_processes(
    module: ModuleIR,
    ctx: ModuleContext | None = None,
    *,
    force_parents: frozenset[str] = frozenset(),
) -> tuple[ModuleIR, list[ProcessSliceAssembler]]:
    """Rewrite per-process bit/part writes so that each parent signal driven
    by multiple procedural processes has exactly one writer process.

    Without this pass, two ``always`` blocks each doing
    ``parent[i] <= expr`` codegen to two SC_METHODs that both do
    ``parent.write(__next_parent)`` — SystemC aborts at runtime with
    ``SC_ID_MORE_THAN_ONE_SIGNAL_DRIVER_``. The transformation redirects
    each per-process write to a private ``__shadow_<parent>_<slot>`` signal
    and emits one assembler that gathers all shadows into the parent.
    Aggregation only fires when every contributing write is a
    constant-indexed bit or part select; whole-signal writes or
    dynamic-index writes leave the original IR untouched (and remain a
    pre-existing real conflict for driver analysis to surface).
    """
    # Gather every assignment dict per process, classified by its lvalue.
    ctx = ctx or build_module_context(module)
    per_process: list[list[tuple[dict, tuple[str, int, int] | None]]] = []
    for process in module.processes:
        sink: list = []
        for statement in process.structured_statements:
            _walk_process_assignments(statement, sink)
        per_process.append(
            [(stmt, _classify_lvalue_slot(stmt.get("left_expr"), ctx)) for stmt in sink]
        )

    # Signals declared as unpacked arrays already render as per-cell
    # ``mem[i].write(...)``, so the parent multi-writer aggregation logic
    # below mustn't try to shadow-rewrite them — they're not vector
    # bit/part selects.
    # Group by parent identifier across processes.
    writers_per_parent: dict[str, dict[int, list[tuple[dict, tuple[str, int, int]]]]] = {}
    has_whole_write: set[str] = set()
    for process_idx, assignments in enumerate(per_process):
        for stmt, slot in assignments:
            left_expr = stmt.get("left_expr")
            if not isinstance(left_expr, dict):
                continue
            kind = left_expr.get("kind")
            if kind == "identifier":
                name = str(left_expr.get("name", ""))
                if name:
                    has_whole_write.add(name)
                continue
            if slot is None:
                # bit/part-select but with a non-constant index — leave as is.
                # The pre-existing driver-conflict analysis will surface any
                # true conflict via its own diagnostic codes.
                target = left_expr.get("target") if kind in {"bitselect", "partselect"} else None
                if isinstance(target, dict) and target.get("kind") == "identifier":
                    has_whole_write.add(str(target.get("name", "")))
                continue
            parent, msb, lsb = slot
            if _is_array_subarray_name(parent, ctx):
                # Array cells already route through their own sc_signal
                # per cell; no parent-level shadow rewrite needed.
                continue
            writers_per_parent.setdefault(parent, {}).setdefault(process_idx, []).append(
                (stmt, slot)
            )

    # Decide which parents qualify for aggregation: more than one writing
    # process AND no writer does a whole-signal or dynamic write.
    qualifying: dict[str, list[tuple[dict, tuple[str, int, int]]]] = {}
    for parent, by_proc in writers_per_parent.items():
        if len(by_proc) < 2 and parent not in force_parents:
            continue
        if parent in has_whole_write:
            continue
        flat: list[tuple[dict, tuple[str, int, int]]] = []
        for sites in by_proc.values():
            flat.extend(sites)
        qualifying[parent] = flat

    if not qualifying:
        return module, []

    # Apply the rewrite + collect shadow signals + assembler descriptors.
    extra_signals: list[SignalIR] = []
    extra_signal_names: set[str] = set()
    assemblers: list[ProcessSliceAssembler] = []
    for parent in sorted(qualifying):
        slot_map: dict[tuple[int, int], str] = {}
        sites = qualifying[parent]
        for stmt, (_, msb, lsb) in sites:
            if (msb, lsb) not in slot_map:
                slot_id = f"{msb}" if msb == lsb else f"{msb}_{lsb}"
                shadow_name = f"__shadow_{_sanitize_identifier(parent)}_{slot_id}"
                slot_map[(msb, lsb)] = shadow_name
                if shadow_name not in extra_signal_names:
                    extra_signal_names.add(shadow_name)
                    slot_width = abs(msb - lsb) + 1
                    width_ir: WidthIR | None
                    if slot_width == 1:
                        width_ir = None
                    else:
                        width_ir = WidthIR(msb=str(slot_width - 1), lsb="0")
                    extra_signals.append(
                        SignalIR(name=shadow_name, kind="reg", width=width_ir, signed=False)
                    )
            shadow_name = slot_map[(msb, lsb)]
            # Mutate the lvalue dict in place: replace the bit/part select
            # with a plain identifier pointing at the shadow signal.
            left_expr = stmt["left_expr"]
            left_expr.clear()
            left_expr["kind"] = "identifier"
            left_expr["name"] = shadow_name
            stmt["left"] = shadow_name
            stmt["right_expr"] = _cast_expr_to_slice_width(
                stmt.get("right_expr"),
                abs(msb - lsb) + 1,
            )
        assemblers.append(
            ProcessSliceAssembler(
                parent_name=parent,
                method_name=f"__assemble_{_sanitize_identifier(parent)}",
                slots=tuple(
                    (slot_map[(msb, lsb)], msb, lsb) for (msb, lsb) in sorted(slot_map)
                ),
            )
        )

    new_module = ModuleIR(
        name=module.name,
        parameters=module.parameters,
        ports=module.ports,
        type_aliases=module.type_aliases,
        signals=tuple(extra_signals) + module.signals,
        continuous_assigns=module.continuous_assigns,
        processes=module.processes,
        instances=module.instances,
        generate_fors=module.generate_fors,
        subroutines=module.subroutines,
        diagnostics=module.diagnostics,
        source_path=module.source_path,
    )
    return new_module, assemblers


def banner() -> str:
    """Return the banner used by generated SystemC files."""
    return "// Generated by prism_v2sc\n"


# ---------------------------------------------------------------------------
# Concatenated single-string view (for tests + Phase 5 metrics .header field)
# ---------------------------------------------------------------------------


def generate_systemc_header(
    design: DesignIR,
    instrumentation_config: InstrumentationConfig | None = None,
) -> str:
    """Generate every module as one concatenated SystemC header string.

    Equivalent to ``emit_systemc_files`` but returns the concatenated text
    instead of writing per-module files. The single-file include guard
    uses the top module name.
    """
    signatures = _signatures_from_design(design)
    writer = CodeWriter()
    guard = f"PRISM_V2SC_{_sanitize_identifier(design.top).upper()}_HPP"

    writer.line(banner().rstrip())
    writer.line("#pragma once")
    writer.line()
    writer.line("#include <array>")
    writer.line("#include <systemc>")
    writer.line("#include <string>")
    writer.line("#include <type_traits>")
    if instrumentation_config is not None and instrumentation_config.enabled:
        writer.line("#include <cstdint>")
        writer.line("#include <ostream>")
    writer.line()
    writer.line("using namespace sc_core;")
    writer.line("using namespace sc_dt;")
    writer.line()
    _emit_integer_type_aliases(writer)
    writer.line()
    writer.line(f"#ifndef {guard}")
    writer.line(f"#define {guard}")
    writer.line()

    modules = _dependency_order(list(design.modules))
    modules_by_name = {module.name: module for module in modules}
    for module in modules:
        _emit_module(
            writer,
            module,
            modules_by_name,
            signatures,
            include_children=False,
            instrumentation_config=instrumentation_config,
        )
        writer.line()

    writer.line(f"#endif  // {guard}")
    return writer.render()


# ---------------------------------------------------------------------------
# Per-module file emission with directory mirroring
# ---------------------------------------------------------------------------


def emit_systemc_files(
    design: DesignIR,
    out_dir: Path,
    source_root: Path,
    *,
    signatures: dict[str, ModuleSignature] | None = None,
    instrumentation_config: InstrumentationConfig | None = None,
    incremental: bool = False,
    reuse_existing_modules: frozenset[str] = frozenset(),
    compile_friendly: bool = False,
) -> list[Path]:
    """Write one ``.hpp`` per module under ``out_dir``, mirroring RTL layout.

    Each file ``#include``s the hpps of every child module it instantiates,
    using a path relative to its own directory. Returns the absolute paths
    of every written file, in emit (post-order) sequence.
    """
    sigs = dict(signatures) if signatures is not None else _signatures_from_design(design)
    modules_by_name = {module.name: module for module in design.modules}
    cache_path = out_dir / ".prism_codegen_cache.json"
    old_cache = _load_codegen_cache(cache_path) if incremental else {}
    old_modules = old_cache.get("modules", {}) if isinstance(old_cache.get("modules"), dict) else {}
    new_modules: dict[str, dict[str, object]] = {}
    rendered_count = 0
    reused_count = 0
    bootstrapped_count = 0

    if compile_friendly:
        _write_shared_runtime_header(
            out_dir / "prism_v2sc_runtime.hpp",
            instrumentation_config=instrumentation_config,
        )

    written: list[Path] = []
    for module in _dependency_order(list(design.modules)):
        path = _module_output_path(module, out_dir, source_root)
        fingerprint = _module_codegen_fingerprint(
            module,
            modules_by_name,
            sigs,
            instrumentation_config,
            compile_friendly=compile_friendly,
        )
        cached = old_modules.get(module.name, {}) if isinstance(old_modules, dict) else {}
        cached_artifacts = _cached_module_artifact_paths(cached, out_dir, path)
        cache_hit = (
            incremental
            and isinstance(cached, dict)
            and cached.get("fingerprint") == fingerprint
            and all(artifact.exists() for artifact in cached_artifacts)
        )
        bootstrap_hit = module.name in reuse_existing_modules and path.exists()
        artifact_paths = cached_artifacts if (cache_hit or bootstrap_hit) else [path]
        if cache_hit:
            reused_count += 1
        elif bootstrap_hit:
            bootstrapped_count += 1
        else:
            target, implementations = _render_module_artifacts(
                module,
                modules_by_name,
                sigs,
                out_dir,
                source_root,
                instrumentation_config=instrumentation_config,
                split_implementation=True,
                compile_friendly=compile_friendly,
            )
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(target, encoding="utf-8")
            artifact_paths = [path]
            for file_name, implementation in implementations:
                implementation_path = path.parent / file_name
                implementation_path.write_text(implementation, encoding="utf-8")
                artifact_paths.append(implementation_path)
            for stale_path in cached_artifacts:
                if stale_path not in artifact_paths and stale_path != path:
                    try:
                        stale_path.unlink()
                    except OSError:
                        pass
            rendered_count += 1
        recorded_fingerprint = fingerprint
        if bootstrap_hit and not cache_hit:
            previous_fingerprint = cached.get("fingerprint") if isinstance(cached, dict) else None
            recorded_fingerprint = (
                previous_fingerprint
                if isinstance(previous_fingerprint, str) and previous_fingerprint
                else f"trusted-existing:{_file_sha256(path)}"
            )
        new_modules[module.name] = {
            "fingerprint": recorded_fingerprint,
            "path": str(path.relative_to(out_dir)),
            "artifacts": [str(artifact.relative_to(out_dir)) for artifact in artifact_paths],
            "size_bytes": sum(artifact.stat().st_size for artifact in artifact_paths),
        }
        written.append(path)
    if incremental or reuse_existing_modules:
        _write_codegen_cache(
            cache_path,
            {
                "version": 2,
                "generator_fingerprint": _generator_fingerprint(),
                "compile_friendly": compile_friendly,
                "modules": new_modules,
                "last_run": {
                    "rendered": rendered_count,
                    "reused": reused_count,
                    "bootstrapped": bootstrapped_count,
                    "module_count": len(written),
                },
            },
        )
    return written


def _cached_module_artifact_paths(cached: object, out_dir: Path, header_path: Path) -> list[Path]:
    if not isinstance(cached, dict):
        return [header_path]
    artifacts = cached.get("artifacts")
    if isinstance(artifacts, list) and artifacts and all(isinstance(item, str) for item in artifacts):
        return [out_dir / item for item in artifacts]
    return [header_path]


def _load_codegen_cache(path: Path) -> dict[str, object]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError, OSError):
        return {}
    return payload if isinstance(payload, dict) and payload.get("version") in {1, 2} else {}


def _write_codegen_cache(path: Path, payload: dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    temporary.replace(path)


def _file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


@lru_cache(maxsize=1)
def _generator_fingerprint() -> str:
    digest = hashlib.sha256()
    for source in (
        Path(__file__),
        Path(__file__).with_name("expr.py"),
        Path(__file__).with_name("writer.py"),
        Path(__file__).with_name("instrumentation.py"),
    ):
        digest.update(source.name.encode("utf-8"))
        digest.update(source.read_bytes())
    return digest.hexdigest()


def _module_codegen_fingerprint(
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
    instrumentation_config: InstrumentationConfig | None,
    *,
    compile_friendly: bool = False,
) -> str:
    dependencies = _module_dependencies(module)
    dependency_signatures = {
        name: asdict(signatures[name])
        for name in dependencies
        if name in signatures
    }
    payload = {
        "generator": _generator_fingerprint(),
        "module": asdict(module),
        "dependency_signatures": dependency_signatures,
        "instrumentation": repr(instrumentation_config),
        "compile_friendly": compile_friendly,
    }
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def render_module_file(
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
    out_dir: Path,
    source_root: Path,
    *,
    instrumentation_config: InstrumentationConfig | None = None,
) -> str:
    """Render a single module's SystemC hpp text (no disk side effects)."""
    header, _implementations = _render_module_artifacts(
        module,
        modules_by_name,
        signatures,
        out_dir,
        source_root,
        instrumentation_config=instrumentation_config,
        split_implementation=False,
    )
    return header


def _render_module_artifacts(
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
    out_dir: Path,
    source_root: Path,
    *,
    instrumentation_config: InstrumentationConfig | None = None,
    split_implementation: bool,
    compile_friendly: bool = False,
) -> tuple[str, tuple[tuple[str, str], ...]]:
    writer = CodeWriter()
    guard = f"PRISM_V2SC_MOD_{_sanitize_identifier(module.name).upper()}_HPP"
    writer.line(banner().rstrip())
    writer.line("#pragma once")
    writer.line()
    if compile_friendly:
        runtime_path = os.path.relpath(
            out_dir / "prism_v2sc_runtime.hpp",
            start=_module_output_path(module, out_dir, source_root).parent,
        ).replace(os.sep, "/")
        writer.line(f'#include "{runtime_path}"')
    else:
        writer.line("#include <array>")
        writer.line("#include <systemc>")
        writer.line("#include <string>")
        writer.line("#include <type_traits>")
        if instrumentation_config is not None and instrumentation_config.enabled:
            writer.line("#include <cstdint>")
            writer.line("#include <ostream>")

    child_includes = _child_include_paths(module, modules_by_name, out_dir, source_root)
    if child_includes:
        writer.line()
        for include in child_includes:
            writer.line(f'#include "{include}"')

    writer.line()
    writer.line("using namespace sc_core;")
    writer.line("using namespace sc_dt;")
    writer.line()
    if not compile_friendly:
        _emit_integer_type_aliases(writer)
    writer.line()
    writer.line(f"#ifndef {guard}")
    writer.line(f"#define {guard}")
    writer.line()

    outlined_bodies = _emit_module(
        writer,
        module,
        modules_by_name,
        signatures,
        include_children=False,
        instrumentation_config=instrumentation_config,
        defer_outlined_definitions=split_implementation,
        compile_friendly=compile_friendly,
    )
    writer.line()
    writer.line(f"#endif  // {guard}")
    implementations = (
        _render_module_implementation_chunks(
            module,
            outlined_bodies,
            out_dir,
            source_root,
            implementation_chunk_bytes=64 * 1024 if compile_friendly else 256 * 1024,
        )
        if split_implementation and outlined_bodies
        else ()
    )
    return writer.render(), implementations


def _render_module_implementation_chunks(
    module: ModuleIR,
    methods: list[tuple[str, tuple[str, ...]]],
    out_dir: Path,
    source_root: Path,
    *,
    implementation_chunk_bytes: int = 256 * 1024,
) -> tuple[tuple[str, str], ...]:
    heavy_expression_line_bytes = 32 * 1024
    chunks: list[list[tuple[str, tuple[str, ...]]]] = []
    current: list[tuple[str, tuple[str, ...]]] = []
    current_size = 0
    for method in methods:
        method_size = sum(len(line) + 1 for line in method[1])
        has_heavy_expression = any(
            len(line) > heavy_expression_line_bytes for line in method[1]
        )
        if current and (
            current_size + method_size > implementation_chunk_bytes or has_heavy_expression
        ):
            chunks.append(current)
            current = []
            current_size = 0
        current.append(method)
        current_size += method_size
        if has_heavy_expression:
            chunks.append(current)
            current = []
            current_size = 0
    if current:
        chunks.append(current)

    header_name = _module_output_path(module, out_dir, source_root).name
    class_name = _sanitize_identifier(module.name)
    stem = Path(header_name).stem
    rendered: list[tuple[str, str]] = []
    for index, chunk in enumerate(chunks):
        writer = CodeWriter()
        writer.line(banner().rstrip())
        writer.line(f'#include "{header_name}"')
        writer.line()
        for method_name, body_lines in chunk:
            if method_name == "__prism_constructor__":
                for body_line in body_lines:
                    writer.line(body_line)
                writer.line()
                continue
            writer.line(f"void {class_name}::{method_name}() {{")
            writer.indent()
            for body_line in body_lines:
                writer.line(body_line)
            writer.dedent()
            writer.line("}")
            writer.line()
        rendered.append((f"{stem}__impl_{index:03d}.cpp", writer.render()))
    return tuple(rendered)


def module_output_path(module: ModuleIR, out_dir: Path, source_root: Path) -> Path:
    """Public helper: where a given module's hpp will be written."""
    return _module_output_path(module, out_dir, source_root)


def _module_output_path(module: ModuleIR, out_dir: Path, source_root: Path) -> Path:
    file_name = f"{_sanitize_identifier(module.name)}.hpp"
    source_path = module.source_path
    if not source_path:
        return out_dir / file_name
    source = Path(source_path)
    try:
        rel_parent = source.resolve().parent.relative_to(Path(source_root).resolve())
    except ValueError:
        # Source lives outside source_root (rare); fall back to flat layout.
        return out_dir / file_name
    return out_dir / rel_parent / file_name


def _child_include_paths(
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    out_dir: Path,
    source_root: Path,
) -> list[str]:
    """Return relative-include paths for every distinct child module."""
    self_path = _module_output_path(module, out_dir, source_root)
    self_dir = self_path.parent
    seen: set[str] = set()
    paths: list[str] = []
    for child_name in _dedupe(_module_dependencies(module)):
        child_module = modules_by_name.get(child_name)
        if child_module is None:
            continue
        if child_name in seen:
            continue
        seen.add(child_name)
        child_path = _module_output_path(child_module, out_dir, source_root)
        rel = os.path.relpath(child_path, start=self_dir).replace(os.sep, "/")
        paths.append(rel)
    return paths


def _signatures_from_design(design: DesignIR) -> dict[str, ModuleSignature]:
    """Derive signatures from a fully-lowered DesignIR (fallback path)."""
    signatures: dict[str, ModuleSignature] = {}
    for module in design.modules:
        signatures[module.name] = ModuleSignature(
            name=module.name,
            ports=module.ports,
            parameters=tuple(parameter for parameter in module.parameters if parameter.kind == "parameter"),
        )
    return signatures


# ---------------------------------------------------------------------------
# Module emission
# ---------------------------------------------------------------------------


def _emit_module(
    writer: CodeWriter,
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
    *,
    include_children: bool,
    instrumentation_config: InstrumentationConfig | None = None,
    defer_outlined_definitions: bool = False,
    compile_friendly: bool = False,
) -> list[tuple[str, tuple[str, ...]]]:
    if module.model.get("provider") == "memory":
        _emit_provider_memory_module(writer, module)
        return []
    class_name = _sanitize_identifier(module.name)
    # Rewrite sliced continuous/procedural writes that share a parent signal
    # so the generated SystemC has exactly one writer per signal. Must run
    # before ``build_module_context`` so the shadow signals enter the context.
    original_module = module
    base_ctx = build_module_context(module, compile_friendly=compile_friendly)
    preliminary_direct_bridges = _direct_bit_bridges(
        module,
        modules_by_name,
        signatures,
        parent_ctx=base_ctx,
    )
    preliminary_expr_bridges = _expr_port_bridges(
        module,
        modules_by_name,
        signatures,
        parent_ctx=base_ctx,
    )
    child_driven_parents = frozenset(
        assembler.parent_name
        for assembler in _child_output_assemblers(
            preliminary_direct_bridges,
            preliminary_expr_bridges,
            base_ctx,
        )
    )
    module, continuous_assemblers = _aggregate_multi_writer_continuous_assigns(
        module,
        base_ctx,
        force_parents=child_driven_parents,
    )
    module, process_assemblers = _aggregate_multi_writer_processes(
        module,
        base_ctx,
        force_parents=child_driven_parents,
    )
    slice_assemblers = continuous_assemblers + process_assemblers
    resolved_names = _resolved_signal_names(module, modules_by_name, signatures)
    if module is original_module:
        ctx = replace(base_ctx, resolved_names=frozenset(resolved_names))
    else:
        ctx = build_module_context(
            module,
            resolved_names=frozenset(resolved_names),
            compile_friendly=compile_friendly,
        )
    bit_bridges = _generate_bit_bridges(module, modules_by_name, signatures)
    direct_bit_bridges = _direct_bit_bridges(module, modules_by_name, signatures, parent_ctx=ctx)
    expr_port_bridges = _expr_port_bridges(module, modules_by_name, signatures, parent_ctx=ctx)
    bridge_methods = _bridge_method_specs(direct_bit_bridges, expr_port_bridges, ctx)
    if compile_friendly:
        bridge_methods = [
            replace(spec, body=tuple(_optimize_method_body_for_compile(spec.body)))
            for spec in bridge_methods
        ]
    child_output_assemblers = _child_output_assemblers(direct_bit_bridges, expr_port_bridges, ctx)
    child_output_assemblers, slice_assemblers = _merge_child_and_slice_assemblers(
        child_output_assemblers,
        slice_assemblers,
    )
    unconnected_port_signals = _unconnected_port_signals(module, modules_by_name, signatures)
    module_instrumentation = _module_instrumentation_config(module, instrumentation_config)
    module_needs_power_sample_strobe = _module_subtree_needs_power_sample_strobe(
        module,
        modules_by_name,
        instrumentation_config,
    )
    if any(parameter.kind == "parameter" for parameter in module.parameters):
        template_params = _template_parameter_list(module)
        writer.line(f"template <{template_params}>")
    writer.line(f"SC_MODULE({class_name}) {{")
    writer.indent()

    _emit_local_parameters(writer, module)

    for port in module.ports:
        dims = port.declared_unpacked_dims or port.unpacked_dims
        writer.line(f"{_port_type(port)} {_sanitize_identifier(port.name)}{_unpacked_suffix(dims)};")
    if module_needs_power_sample_strobe:
        writer.line("sc_in<bool> __power_sample_strobe;")
    if module.ports:
        writer.line()

    for signal in module.signals:
        writer.line(
            f"{_signal_type(signal, resolved=signal.name in resolved_names)} "
            f"{_sanitize_identifier(signal.name)}"
            f"{_unpacked_suffix(signal.declared_unpacked_dims or signal.unpacked_dims)};"
        )
    if module.signals:
        writer.line()

    for instance in module.instances:
        writer.line(f"{_instance_type(instance, modules_by_name, signatures)} {_sanitize_identifier(instance.name)};")
    for generate_for in module.generate_fors:
        for instance in generate_for.instances:
            writer.line(
                f"sc_vector<{_instance_type(instance, modules_by_name, signatures)}> "
                f"{_sanitize_identifier(generate_for.name)}_{_sanitize_identifier(instance.name)};"
            )
    for bridge in bit_bridges:
        if bridge.direction == "inout":
            writer.line(f"sc_vector<sc_signal_rv<1>> {bridge.name};")
        else:
            writer.line(f"sc_vector<sc_signal<bool>> {bridge.name};")
    for bridge in direct_bit_bridges:
        if bridge.direction == "inout":
            writer.line(f"sc_signal_rv<1> {bridge.name};")
        elif bridge.vector:
            writer.line(f"sc_signal<sc_uint<1>> {bridge.name};")
        else:
            writer.line(f"sc_signal<bool> {bridge.name};")
    for bridge in expr_port_bridges:
        writer.line(f"sc_signal<{_sc_type(bridge.port.width, bridge.port.signed)}> {bridge.name};")
    for dummy in unconnected_port_signals:
        if dummy.port.direction == "inout":
            writer.line(f"sc_signal_rv<{_width_expr(dummy.port.width)}> {dummy.name};")
        else:
            writer.line(f"sc_signal<{_sc_type(dummy.port.width, dummy.port.signed)}> {dummy.name};")
    if module.instances or module.generate_fors:
        writer.line()

    for declaration in generate_instrumentation_declarations(module_instrumentation):
        writer.line(declaration)
    if module_instrumentation.enabled:
        writer.line()

    methods = _method_specs(module, ctx)
    if compile_friendly:
        methods = [
            (method_name, _optimize_method_body_for_compile(body_lines))
            for method_name, body_lines in methods
        ]
    outline_methods = (
        not any(parameter.kind == "parameter" for parameter in module.parameters)
        and (
            compile_friendly
            or (
            len(module.continuous_assigns) > 256
            or len(direct_bit_bridges) + len(expr_port_bridges) > 256
            or len(bit_bridges) > 64
            or len(child_output_assemblers) > 64
            )
        )
    )
    outlined_method_bodies: list[tuple[str, tuple[str, ...]]] = []
    for subroutine in module.subroutines:
        _emit_subroutine(writer, subroutine, ctx)
    for method_name, body_lines in methods:
        if outline_methods:
            writer.line(f"void {method_name}();")
            outlined_method_bodies.append((method_name, tuple(body_lines)))
        else:
            writer.line(f"void {method_name}() {{")
            writer.indent()
            for body_line in body_lines:
                writer.line(body_line)
            writer.dedent()
            writer.line("}")
        writer.line()

    for bridge in bit_bridges:
        if outline_methods:
            writer.line(f"void {bridge.method_name}();")
            bridge_body = _generate_bit_bridge_body(bridge)
            if compile_friendly:
                bridge_body = _optimize_method_body_for_compile(bridge_body)
            outlined_method_bodies.append(
                (bridge.method_name, tuple(bridge_body))
            )
        else:
            _emit_bridge_method(writer, bridge)
        writer.line()
    for bridge_method in bridge_methods:
        if outline_methods:
            writer.line(f"void {bridge_method.name}();")
            outlined_method_bodies.append((bridge_method.name, bridge_method.body))
        else:
            _emit_bridge_method_spec(writer, bridge_method)
        writer.line()
    for assembler in child_output_assemblers:
        if outline_methods:
            writer.line(f"void {assembler.method_name}();")
            assembler_body = _generate_child_output_assembler_body(assembler, ctx)
            if compile_friendly:
                assembler_body = _optimize_method_body_for_compile(assembler_body)
            outlined_method_bodies.append(
                (assembler.method_name, tuple(assembler_body))
            )
        else:
            _emit_child_output_assembler(writer, assembler, ctx)
        writer.line()
    for assembler in slice_assemblers:
        _emit_process_slice_assembler(writer, assembler)
        writer.line()

    power_sampling_processes = generate_sampling_processes(module_instrumentation)
    for process in power_sampling_processes:
        writer.line(f"void {process.method_name}() {{")
        writer.indent()
        for body_line in process.body.splitlines():
            writer.line(body_line)
        writer.dedent()
        writer.line("}")
        writer.line()

    dump_api = generate_dump_api(
        module_instrumentation,
        child_dump_lines=_child_power_dump_lines(
            module,
            modules_by_name,
            instrumentation_config,
        ),
    )
    if dump_api:
        for body_line in dump_api.splitlines():
            writer.line(body_line)
        writer.line()

    constructor_args = (
        module,
        ctx,
        methods,
        bit_bridges,
        direct_bit_bridges,
        expr_port_bridges,
        bridge_methods,
        child_output_assemblers,
        unconnected_port_signals,
        slice_assemblers,
        modules_by_name,
        signatures,
        instrumentation_config,
        module_instrumentation,
        power_sampling_processes,
    )
    if outline_methods and defer_outlined_definitions:
        writer.line(f"SC_HAS_PROCESS({class_name});")
        writer.line(f"{class_name}(sc_module_name name);")
        constructor_writer = CodeWriter()
        _emit_constructor(constructor_writer, *constructor_args, out_of_class=True)
        outlined_method_bodies.append(
            ("__prism_constructor__", tuple(constructor_writer.render().splitlines()))
        )
    else:
        _emit_constructor(writer, *constructor_args)
    writer.dedent()
    writer.line("};")
    if outlined_method_bodies and not defer_outlined_definitions:
        writer.line()
        for method_name, body_lines in outlined_method_bodies:
            writer.line(f"inline void {class_name}::{method_name}() {{")
            writer.indent()
            for body_line in body_lines:
                writer.line(body_line)
            writer.dedent()
            writer.line("}")
            writer.line()
    return outlined_method_bodies


def _emit_provider_memory_module(writer: CodeWriter, module: ModuleIR) -> None:
    model = module.model
    if model.get("implementation") != "masked_registered_address":
        raise ValueError(f"unsupported memory provider implementation: {model.get('implementation')}")

    ports = {port.name: port for port in module.ports}
    clock = _sanitize_identifier(str(model["clock"]))
    enable = _sanitize_identifier(str(model["enable"]))
    write_enable = _sanitize_identifier(str(model["write_enable"]))
    byte_enable = _sanitize_identifier(str(model["byte_enable"]))
    address = _sanitize_identifier(str(model["address"]))
    write_data = _sanitize_identifier(str(model["write_data"]))
    read_data = _sanitize_identifier(str(model["read_data"]))
    depth = _cpp_expr(str(model["depth"]))
    lane_width = _cpp_expr(str(model["lane_width"]))
    data_port = ports[str(model["write_data"])]
    address_port = ports[str(model["address"])]
    data_type = _sc_type(data_port.width, data_port.signed)
    address_type = _sc_type(address_port.width, address_port.signed)
    data_width = _width_expr(data_port.width)
    class_name = _sanitize_identifier(module.name)

    if any(parameter.kind == "parameter" for parameter in module.parameters):
        writer.line(f"template <{_template_parameter_list(module)}>")
    writer.line(f"SC_MODULE({class_name}) {{")
    writer.indent()
    _emit_local_parameters(writer, module)
    for port in module.ports:
        dims = port.declared_unpacked_dims or port.unpacked_dims
        writer.line(f"{_port_type(port)} {_sanitize_identifier(port.name)}{_unpacked_suffix(dims)};")
    writer.line()
    writer.line(f"std::array<{data_type}, {depth}> __model_mem{{}};")
    writer.line(f"sc_signal<{address_type}> __model_read_addr;")
    writer.line()
    writer.line("void __model_clocked() {")
    writer.indent()
    writer.line(f"if ({enable}.read()) {{")
    writer.indent()
    writer.line(f"if ({write_enable}.read()) {{")
    writer.indent()
    writer.line(f"auto __next = __model_mem[{address}.read().to_uint()];")
    writer.line(f"for (int __bit = 0; __bit < {data_width}; ++__bit) {{")
    writer.indent()
    writer.line(f"if ({byte_enable}.read()[__bit / {lane_width}]) __next[__bit] = {write_data}.read()[__bit];")
    writer.dedent()
    writer.line("}")
    writer.line(f"__model_mem[{address}.read().to_uint()] = __next;")
    writer.dedent()
    writer.line("} else {")
    writer.indent()
    writer.line(f"__model_read_addr.write({address}.read());")
    writer.dedent()
    writer.line("}")
    writer.dedent()
    writer.line("}")
    writer.dedent()
    writer.line("}")
    writer.line()
    writer.line("void __model_read() {")
    writer.indent()
    writer.line(f"{read_data}.write(__model_mem[__model_read_addr.read().to_uint()]);")
    writer.dedent()
    writer.line("}")
    writer.line()
    writer.line(f"SC_CTOR({class_name}) {{")
    writer.indent()
    writer.line("SC_METHOD(__model_clocked);")
    writer.line(f"sensitive << {clock}.pos();")
    writer.line("SC_METHOD(__model_read);")
    writer.line("sensitive << __model_read_addr;")
    writer.dedent()
    writer.line("}")
    writer.dedent()
    writer.line("};")


def _module_instrumentation_config(
    module: ModuleIR,
    config: InstrumentationConfig | None,
) -> InstrumentationConfig:
    if config is None or not config.enabled or config.probe_plan is None:
        return InstrumentationConfig()
    probes = tuple(
        probe for probe in config.probe_plan.probes if probe.module_name == module.name
    )
    if not probes:
        return InstrumentationConfig()
    module_plan = replace(
        config.probe_plan,
        probes=probes,
        probe_count=len(probes),
        state_probe_count=sum(1 for probe in probes if probe.signal_class == "state"),
        comb_probe_count=sum(1 for probe in probes if probe.signal_class == "comb"),
        memory_probe_count=sum(1 for probe in probes if probe.signal_class == "memory_cell"),
        warnings=(),
        estimated_counter_count=len(probes) * 3,
        estimated_storage_bytes=len(probes) * 3 * 8,
    )
    return replace(config, enabled=True, probe_plan=module_plan)


def _needs_power_sample_strobe(config: InstrumentationConfig) -> bool:
    if not config.enabled or config.probe_plan is None:
        return False
    return any(probe.clock_domain is None for probe in config.probe_plan.probes)


def _module_subtree_has_instrumentation(
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    config: InstrumentationConfig | None,
    seen: frozenset[str] = frozenset(),
) -> bool:
    if config is None or not config.enabled or config.probe_plan is None:
        return False
    if module.name in seen:
        return False
    local = _module_instrumentation_config(module, config)
    if local.enabled:
        return True
    next_seen = seen | {module.name}
    for child_name in _module_dependencies(module):
        child = modules_by_name.get(child_name)
        if child is not None and _module_subtree_has_instrumentation(child, modules_by_name, config, next_seen):
            return True
    return False


def _module_subtree_needs_power_sample_strobe(
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    config: InstrumentationConfig | None,
    seen: frozenset[str] = frozenset(),
) -> bool:
    if config is None or not config.enabled or config.probe_plan is None:
        return False
    if module.name in seen:
        return False
    local = _module_instrumentation_config(module, config)
    if _needs_power_sample_strobe(local):
        return True
    next_seen = seen | {module.name}
    for child_name in _module_dependencies(module):
        child = modules_by_name.get(child_name)
        if child is not None and _module_subtree_needs_power_sample_strobe(child, modules_by_name, config, next_seen):
            return True
    return False


def _child_needs_power_sample_strobe(
    instance: InstanceIR,
    modules_by_name: dict[str, ModuleIR],
    config: InstrumentationConfig | None,
) -> bool:
    child = modules_by_name.get(instance.module)
    return child is not None and _module_subtree_needs_power_sample_strobe(child, modules_by_name, config)


def _child_has_power_dump_api(
    instance: InstanceIR,
    modules_by_name: dict[str, ModuleIR],
    config: InstrumentationConfig | None,
) -> bool:
    child = modules_by_name.get(instance.module)
    return child is not None and _module_subtree_has_instrumentation(child, modules_by_name, config)


def _child_power_dump_lines(
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    config: InstrumentationConfig | None,
) -> list[str]:
    if config is None or not config.enabled or config.probe_plan is None:
        return []

    lines: list[str] = []
    for instance in module.instances:
        if not _child_has_power_dump_api(instance, modules_by_name, config):
            continue
        member_name = _sanitize_identifier(instance.name)
        path_name = _cpp_string_literal("." + instance.name)
        lines.append(f"{member_name}.prism_power_dump(os, false, instance_path + {path_name});")

    for generate_for in module.generate_fors:
        vector_count = _generate_for_count_expr(generate_for)
        for instance in generate_for.instances:
            if not _child_has_power_dump_api(instance, modules_by_name, config):
                continue
            vector_name = f"{_sanitize_identifier(generate_for.name)}_{_sanitize_identifier(instance.name)}"
            path_prefix = _cpp_string_literal(f".{generate_for.name}.{instance.name}[")
            lines.append(f"for (int __power_child_i = 0; __power_child_i < {vector_count}; ++__power_child_i) {{")
            lines.append(
                f"    {vector_name}[__power_child_i].prism_power_dump("
                f"os, false, instance_path + {path_prefix} + std::to_string(__power_child_i) + \"]\");"
            )
            lines.append("}")

    return lines


def _emit_constructor(
    writer: CodeWriter,
    module: ModuleIR,
    ctx: ModuleContext,
    methods: list[tuple[str, list[str]]],
    bit_bridges: list[GenerateBitBridge],
    direct_bit_bridges: list[DirectBitBridge],
    expr_port_bridges: list[ExprPortBridge],
    bridge_methods: list[BridgeMethodSpec],
    child_output_assemblers: list[ChildOutputAssembler],
    unconnected_port_signals: list[UnconnectedPortSignal],
    process_assemblers: list[ProcessSliceAssembler],
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
    root_instrumentation_config: InstrumentationConfig | None,
    instrumentation_config: InstrumentationConfig,
    power_sampling_processes: list,
    *,
    out_of_class: bool = False,
) -> None:
    class_name = _sanitize_identifier(module.name)
    init_list = [f"{_sanitize_identifier(instance.name)}(\"{instance.name}\")" for instance in module.instances]
    for generate_for in module.generate_fors:
        for instance in generate_for.instances:
            vector_name = f"{_sanitize_identifier(generate_for.name)}_{_sanitize_identifier(instance.name)}"
            init_list.append(
                f"{vector_name}(\"{vector_name}\", {_generate_for_count_expr(generate_for)})"
            )
    for bridge in bit_bridges:
        init_list.append(f"{bridge.name}(\"{bridge.name}\", {bridge.count_expr})")
    constructor_name = (
        f"{class_name}::{class_name}(sc_module_name name)"
        if out_of_class
        else f"SC_CTOR({class_name})"
    )
    if init_list:
        writer.line(constructor_name)
        writer.indent()
        writer.line(": " + ", ".join(init_list))
        writer.dedent()
        writer.line("{")
    else:
        writer.line(f"{constructor_name} {{")
    writer.indent()

    for init_line in generate_instrumentation_init(instrumentation_config):
        writer.line(init_line)
    if instrumentation_config.enabled:
        writer.line()

    for method_name, _body_lines in methods:
        writer.line(f"SC_METHOD({method_name});")
        sensitivity = _method_sensitivity(module, method_name, ctx)
        sensitivity = _expand_sensitivity_list(sensitivity, ctx)
        if sensitivity:
            writer.line("sensitive" + "".join(f" << {name}" for name in sensitivity) + ";")
        else:
            writer.line("// No inferred sensitivity; method will need manual review.")
        writer.line()

    for instance in module.instances:
        instance_name = _sanitize_identifier(instance.name)
        _emit_instance_bindings(
            writer,
            instance_name,
            instance,
            modules_by_name,
            signatures,
            bind_power_sample_strobe=_child_needs_power_sample_strobe(
                instance,
                modules_by_name,
                root_instrumentation_config,
            ),
            direct_bridge_by_port={
                bridge.port_name: bridge.name
                for bridge in direct_bit_bridges
                if bridge.instance_name == instance.name
            },
            expr_bridge_by_port={
                bridge.port_name: bridge.name
                for bridge in expr_port_bridges
                if bridge.instance_name == instance.name
            },
            dummy_by_port={
                dummy.port_name: dummy.name
                for dummy in unconnected_port_signals
                if dummy.instance_name == instance.name
            },
        )

    for generate_for in module.generate_fors:
        loop_var = _sanitize_identifier(generate_for.var)
        vector_count = _generate_for_count_expr(generate_for)
        writer.line(f"for (int {loop_var} = 0; {loop_var} < {vector_count}; ++{loop_var}) {{")
        writer.indent()
        for instance in generate_for.instances:
            vector_name = f"{_sanitize_identifier(generate_for.name)}_{_sanitize_identifier(instance.name)}"
            _emit_instance_bindings(
                writer,
                f"{vector_name}[{loop_var}]",
                instance,
                modules_by_name,
                signatures,
                loop_var=loop_var,
                bind_power_sample_strobe=_child_needs_power_sample_strobe(
                    instance,
                    modules_by_name,
                    root_instrumentation_config,
                ),
                bit_bridge_by_port={
                    bridge.port_name: bridge.name
                    for bridge in bit_bridges
                    if bridge.name.startswith(
                        f"__bridge_{_sanitize_identifier(generate_for.name)}_"
                        f"{_sanitize_identifier(instance.name)}_"
                    )
                },
            )
        writer.dedent()
        writer.line("}")

    for bridge in bit_bridges:
        writer.line(f"SC_METHOD({bridge.method_name});")
        if bridge.direction == "input":
            writer.line(f"sensitive << {bridge.parent_name};")
        elif bridge.direction == "inout":
            writer.line(f"sensitive << {bridge.parent_name};")
            writer.line(f"for (int i = 0; i < {bridge.count_expr}; ++i) {{")
            writer.indent()
            writer.line(f"sensitive << {bridge.name}[i];")
            writer.dedent()
            writer.line("}")
        else:
            writer.line(f"for (int i = 0; i < {bridge.count_expr}; ++i) {{")
            writer.indent()
            writer.line(f"sensitive << {bridge.name}[i];")
            writer.dedent()
            writer.line("}")
        writer.line()

    for bridge_method in bridge_methods:
        if bridge_method.sensitivity:
            writer.line(f"SC_METHOD({bridge_method.name});")
            writer.line(
                "sensitive"
                + "".join(f" << {name}" for name in bridge_method.sensitivity)
                + ";"
            )
        else:
            writer.line(f"{bridge_method.name}();")
        writer.line()

    for assembler in child_output_assemblers:
        writer.line(f"SC_METHOD({assembler.method_name});")
        sensitivities = "".join(
            f" << {bridge.name}"
            for bridge in (*assembler.direct_bridges, *assembler.expr_bridges)
        )
        sensitivities += "".join(
            f" << {shadow}" for shadow, _msb, _lsb in assembler.shadow_slots
        )
        writer.line(f"sensitive{sensitivities};")
        writer.line()

    for assembler in process_assemblers:
        writer.line(f"SC_METHOD({assembler.method_name});")
        sensitivities = "".join(f" << {shadow}" for shadow, _msb, _lsb in assembler.slots)
        writer.line(f"sensitive{sensitivities};")
        writer.line()

    for process in power_sampling_processes:
        writer.line(f"SC_METHOD({process.method_name});")
        if process.clock_domain:
            writer.line(
                "sensitive << "
                f"{_sanitize_identifier(process.clock_domain)}.{_systemc_edge(process.clock_edge or 'posedge')}();"
            )
        else:
            writer.line("sensitive << __power_sample_strobe.pos();")
        writer.line("dont_initialize();")
        writer.line()

    writer.dedent()
    writer.line("}")


def _emit_instance_bindings(
    writer: CodeWriter,
    instance_ref: str,
    instance: InstanceIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
    loop_var: str | None = None,
    bit_bridge_by_port: dict[str, str] | None = None,
    direct_bridge_by_port: dict[str, str] | None = None,
    expr_bridge_by_port: dict[str, str] | None = None,
    dummy_by_port: dict[str, str] | None = None,
    bind_power_sample_strobe: bool = False,
) -> None:
    """Emit ``inst.<port>(<value>);`` lines, resolving positional via signature."""
    child_ports = _child_ports_lookup(instance.module, modules_by_name, signatures)
    resolved_ports = _resolve_instance_ports(instance, signatures)
    for port_name, value in resolved_ports:
        if not port_name:
            writer.line(f"// Positional port binding not emitted for {instance.name}: {value}")
            continue
        dummy_name = (dummy_by_port or {}).get(port_name)
        if dummy_name is not None:
            writer.line(f"{instance_ref}.{_sanitize_identifier(port_name)}({dummy_name});")
            continue
        expr_bridge_name = (expr_bridge_by_port or {}).get(port_name)
        if expr_bridge_name is not None:
            writer.line(f"{instance_ref}.{_sanitize_identifier(port_name)}({expr_bridge_name});")
            continue
        child_port = child_ports.get(port_name)
        if child_port is not None and child_port.unpacked_dims and _simple_instance_binding(value):
            _emit_array_port_binding(writer, instance_ref, port_name, value, child_port)
            continue
        direct_bridge_name = (direct_bridge_by_port or {}).get(port_name)
        if direct_bridge_name is not None:
            writer.line(f"{instance_ref}.{_sanitize_identifier(port_name)}({direct_bridge_name});")
            continue
        bridge_name = (bit_bridge_by_port or {}).get(port_name)
        if bridge_name is not None and loop_var is not None:
            writer.line(f"{instance_ref}.{_sanitize_identifier(port_name)}({bridge_name}[{loop_var}]);")
            continue
        writer.line(
            f"{instance_ref}.{_sanitize_identifier(port_name)}"
            f"({_cpp_binding_expr(value, loop_var=loop_var)});"
        )
    if bind_power_sample_strobe:
        writer.line(f"{instance_ref}.__power_sample_strobe(__power_sample_strobe);")


def _resolve_instance_ports(
    instance: InstanceIR,
    signatures: dict[str, ModuleSignature],
) -> list[tuple[str, str]]:
    return [(name, arg.value) for name, arg in _resolve_instance_arg_ports(instance, signatures)]


def _emit_array_port_binding(
    writer: CodeWriter,
    instance_ref: str,
    port_name: str,
    value: str,
    child_port: PortIR,
) -> None:
    base = _sanitize_identifier(value)
    port = _sanitize_identifier(port_name)
    dim_sizes = tuple(max(msb, lsb) - min(msb, lsb) + 1 for msb, lsb in child_port.unpacked_dims)
    for suffix in _array_index_suffixes(dim_sizes):
        writer.line(f"{instance_ref}.{port}{suffix}({base}{suffix});")


def _resolve_instance_arg_ports(
    instance: InstanceIR,
    signatures: dict[str, ModuleSignature],
) -> list[tuple[str, ArgIR]]:
    """Return [(port_name, arg_value), ...] for an instance.

    Named bindings keep their name as-is. Positional bindings (empty name)
    are resolved against the child's signature when available, recovering
    the port name from its position.
    """
    if not instance.ports:
        return []
    has_positional = any(not port.name for port in instance.ports)
    if not has_positional:
        return [(port.name, port) for port in instance.ports]

    signature = signatures.get(instance.module)
    if signature is None or not signature.ports:
        # No signature available: keep the placeholder behavior (empty name).
        return [(port.name, port) for port in instance.ports]

    resolved: list[tuple[str, ArgIR]] = []
    sig_ports = signature.ports
    for index, port in enumerate(instance.ports):
        if port.name:
            resolved.append((port.name, port))
            continue
        if index < len(sig_ports):
            resolved.append((sig_ports[index].name, port))
        else:
            resolved.append(("", port))
    return resolved


def _method_specs(module: ModuleIR, ctx: ModuleContext) -> list[tuple[str, list[str]]]:
    specs: list[tuple[str, list[str]]] = []
    assign_count = len(module.continuous_assigns)
    if assign_count > 256:
        start = 0
        body: list[str] = []
        body_size = 0
        for index, assign in enumerate(module.continuous_assigns):
            assign_body = ["{"]
            assign_body.extend(f"  {line}" for line in _emit_continuous_assign(assign, ctx))
            assign_body.append("}")
            assign_size = sum(len(line) + 1 for line in assign_body)
            if body and (index - start >= 64 or body_size + assign_size > 256 * 1024):
                specs.append((f"assign_group_{start}_{index - 1}", body))
                start = index
                body = []
                body_size = 0
            body.extend(assign_body)
            body_size += assign_size
        if body:
            specs.append((f"assign_group_{start}_{assign_count - 1}", body))
    else:
        for index, assign in enumerate(module.continuous_assigns):
            specs.append((f"assign_{index}", _emit_continuous_assign(assign, ctx)))

    comb_index = 0
    ff_index = 0
    for process in module.processes:
        if process.kind == "always_comb":
            specs.append((f"always_comb_{comb_index}", _emit_comb_process(process, ctx)))
            comb_index += 1
        elif process.kind == "always_ff":
            specs.append((f"always_ff_{ff_index}", _emit_ff_process(process, ctx)))
            ff_index += 1
    return specs


_STATIC_SIGNAL_READ_RE = re.compile(
    r"\b[A-Za-z_][A-Za-z0-9_]*(?:\[[0-9\s()+\-*/]+\])*\.read\(\)"
)


def _optimize_method_body_for_compile(lines: Sequence[str]) -> list[str]:
    """Hoist repeated stable signal reads into method-local temporaries.

    SystemC signal writes update after the method returns, so repeated reads
    of the same statically indexed signal observe one stable value throughout
    an invocation. Dynamic array indices are deliberately excluded because
    their index variables may be declared inside the method body.
    """
    counts: dict[str, int] = {}
    order: list[str] = []
    for line in lines:
        for match in _STATIC_SIGNAL_READ_RE.finditer(line):
            read = match.group(0)
            if read not in counts:
                counts[read] = 0
                order.append(read)
            counts[read] += 1
    repeated = [read for read in order if counts[read] >= 2]
    if not repeated:
        return list(lines)

    aliases = {read: f"__prism_read_{index}" for index, read in enumerate(repeated)}
    optimized = [f"const auto {aliases[read]} = {read};" for read in repeated]
    for line in lines:
        updated = line
        for read in repeated:
            updated = re.sub(
                rf"(?<![A-Za-z0-9_]){re.escape(read)}(?![A-Za-z0-9_])",
                aliases[read],
                updated,
            )
        optimized.append(updated)
    return optimized


def _emit_bridge_method(writer: CodeWriter, bridge: GenerateBitBridge) -> None:
    writer.line(f"void {bridge.method_name}() {{")
    writer.indent()
    for line in _generate_bit_bridge_body(bridge):
        writer.line(line)
    writer.dedent()
    writer.line("}")


def _generate_bit_bridge_body(bridge: GenerateBitBridge) -> list[str]:
    if bridge.direction == "input":
        return [
            f"for (int i = 0; i < {bridge.count_expr}; ++i) {{",
            f"    {bridge.name}[i].write({bridge.parent_name}.read()[i]);",
            "}",
        ]
    if bridge.direction == "inout":
        return [
            f"for (int i = 0; i < {bridge.count_expr}; ++i) {{",
            f"    {bridge.name}[i].write(sc_lv<1>({bridge.parent_name}.read()[i]));",
            "}",
            f"auto __tmp = {bridge.parent_name}.read();",
            f"for (int i = 0; i < {bridge.count_expr}; ++i) {{",
            f"    __tmp[i] = {bridge.name}[i].read()[0];",
            "}",
            f"{bridge.parent_name}.write(__tmp);",
        ]
    return [
        f"auto __tmp = {bridge.parent_name}.read();",
        f"for (int i = 0; i < {bridge.count_expr}; ++i) {{",
        f"    __tmp[i] = {bridge.name}[i].read();",
        "}",
        f"{bridge.parent_name}.write(__tmp);",
    ]


def _emit_direct_bridge_method(writer: CodeWriter, bridge: DirectBitBridge) -> None:
    _emit_bridge_method_spec(
        writer,
        BridgeMethodSpec(
            name=bridge.method_name,
            body=tuple(_direct_bridge_body(bridge)),
            sensitivity=(bridge.parent_name,),
        ),
    )


def _direct_bridge_body(bridge: DirectBitBridge) -> list[str]:
    if bridge.array_cell:
        target = f"{bridge.parent_name}[{bridge.index_expr}]"
        if bridge.direction == "input":
            return [f"{bridge.name}.write({target}.read());"]
        if bridge.direction == "inout":
            return [f"{bridge.name}.write(sc_lv<1>({target}.read()));"]
        return [f"{target}.write({bridge.name}.read());"]
    if bridge.direction == "input":
        value = f"{bridge.parent_name}.read()[{bridge.index_expr}]"
        if bridge.vector:
            value = f"sc_uint<1>({value})"
        return [f"{bridge.name}.write({value});"]
    elif bridge.direction == "inout":
        return [
            f"{bridge.name}.write(sc_lv<1>({bridge.parent_name}.read()[{bridge.index_expr}]));"
        ]
    value = f"{bridge.name}.read()[0]" if bridge.vector else f"{bridge.name}.read()"
    return [
        f"auto __tmp = {bridge.parent_name}.read();",
        f"__tmp[{bridge.index_expr}] = {value};",
        f"{bridge.parent_name}.write(__tmp);",
    ]


def _emit_child_output_assembler(
    writer: CodeWriter,
    assembler: ChildOutputAssembler,
    ctx: ModuleContext,
) -> None:
    writer.line(f"void {assembler.method_name}() {{")
    writer.indent()
    for line in _generate_child_output_assembler_body(assembler, ctx):
        writer.line(line)
    writer.dedent()
    writer.line("}")


def _generate_child_output_assembler_body(
    assembler: ChildOutputAssembler,
    ctx: ModuleContext,
) -> list[str]:
    lines = [f"auto __tmp = {assembler.parent_name}.read();"]
    for shadow, msb, lsb in assembler.shadow_slots:
        if msb == lsb:
            lines.append(f"__tmp[{msb}] = {shadow}.read();")
        else:
            lines.append(f"__tmp.range({msb}, {lsb}) = {shadow}.read();")
    for bridge in assembler.direct_bridges:
        if bridge.direction == "inout":
            lines.append(f"__tmp[{bridge.index_expr}] = {bridge.name}.read()[0];")
        else:
            value = f"{bridge.name}.read()[0]" if bridge.vector else f"{bridge.name}.read()"
            lines.append(f"__tmp[{bridge.index_expr}] = {value};")
    for bridge in assembler.expr_bridges:
        value = _cast_to_lvalue_type(f"{bridge.name}.read()", bridge.expr, ctx)
        if bridge.expr.get("kind") == "bitselect":
            index = render_rvalue(bridge.expr.get("index"), ctx)
            lines.append(f"__tmp[{index}] = {value};")
        else:
            msb = render_rvalue(bridge.expr.get("msb"), ctx)
            lsb = render_rvalue(bridge.expr.get("lsb"), ctx)
            lines.append(f"__tmp.range({msb}, {lsb}) = {value};")
    lines.append(f"{assembler.parent_name}.write(__tmp);")
    return lines


def _emit_expr_port_bridge_method(writer: CodeWriter, bridge: ExprPortBridge, ctx: ModuleContext) -> None:
    raw_sensitivity = (
        [bridge.name]
        if bridge.port.direction == "output"
        else collect_sensitivity(bridge.expr, ctx)
    )
    _emit_bridge_method_spec(
        writer,
        BridgeMethodSpec(
            name=bridge.method_name,
            body=tuple(_expr_port_bridge_body(bridge, ctx)),
            sensitivity=tuple(_expand_sensitivity_list(raw_sensitivity, ctx)),
        ),
    )


def _expr_port_bridge_body(bridge: ExprPortBridge, ctx: ModuleContext) -> list[str]:
    if bridge.port.direction == "output":
        value = _cast_to_lvalue_type(f"{bridge.name}.read()", bridge.expr, ctx)
        return [_emit_lvalue_write(bridge.expr, value, ctx)]
    value = _cast_to_port_type(render_rvalue(bridge.expr, ctx), bridge.port)
    return [f"{bridge.name}.write({value});"]


def _emit_bridge_method_spec(writer: CodeWriter, spec: BridgeMethodSpec) -> None:
    writer.line(f"void {spec.name}() {{")
    writer.indent()
    for line in spec.body:
        writer.line(line)
    writer.dedent()
    writer.line("}")


def _bridge_method_specs(
    direct_bit_bridges: list[DirectBitBridge],
    expr_port_bridges: list[ExprPortBridge],
    ctx: ModuleContext,
) -> list[BridgeMethodSpec]:
    specs: list[BridgeMethodSpec] = []
    for bridge in direct_bit_bridges:
        if bridge.direction not in {"input", "inout"} and not bridge.array_cell:
            continue
        specs.append(
            BridgeMethodSpec(
                name=bridge.method_name,
                body=tuple(_direct_bridge_body(bridge)),
                sensitivity=(
                    (bridge.name,)
                    if bridge.direction == "output"
                    else (_bridge_parent_signal_expr(bridge),)
                ),
            )
        )
    for bridge in expr_port_bridges:
        expr_parent = _expr_output_parent(bridge, ctx)
        if expr_parent is not None and not _is_array_subarray_name(expr_parent, ctx):
            continue
        raw_sensitivity = (
            [bridge.name]
            if bridge.port.direction == "output"
            else collect_sensitivity(bridge.expr, ctx)
        )
        specs.append(
            BridgeMethodSpec(
                name=bridge.method_name,
                body=tuple(_expr_port_bridge_body(bridge, ctx)),
                sensitivity=tuple(_expand_sensitivity_list(raw_sensitivity, ctx)),
            )
        )

    scheduled = [spec for spec in specs if spec.sensitivity]
    immediate = [spec for spec in specs if not spec.sensitivity]
    if len(scheduled) <= 256:
        return specs

    grouped: list[BridgeMethodSpec] = []
    for start in range(0, len(scheduled), 256):
        chunk = scheduled[start : start + 256]
        body: list[str] = []
        sensitivity: list[str] = []
        for spec in chunk:
            body.append("{")
            body.extend(f"  {line}" for line in spec.body)
            body.append("}")
            sensitivity.extend(spec.sensitivity)
        grouped.append(
            BridgeMethodSpec(
                name=f"__bridge_group_{start}_{start + len(chunk) - 1}",
                body=tuple(body),
                sensitivity=tuple(_dedupe_preserve(sensitivity)),
            )
        )
    return grouped + immediate


def _array_index_count(name: str) -> int:
    return name.count("[")


def _is_array_subarray_name(name: str, ctx: ModuleContext) -> bool:
    """Return whether ``name`` indexes an array but not a complete cell."""
    base = name.split("[", 1)[0]
    dimensions = ctx.array_dimensions.get(base, ())
    return bool(dimensions) and 0 < _array_index_count(name) < len(dimensions)


def _bridge_parent_signal_expr(bridge: DirectBitBridge) -> str:
    if bridge.array_cell:
        return f"{bridge.parent_name}[{bridge.index_expr}]"
    return bridge.parent_name


def _emit_process_slice_assembler(writer: CodeWriter, assembler: ProcessSliceAssembler) -> None:
    writer.line(f"void {assembler.method_name}() {{")
    writer.indent()
    writer.line(f"auto __tmp = {assembler.parent_name}.read();")
    for shadow, msb, lsb in assembler.slots:
        if msb == lsb:
            writer.line(f"__tmp[{msb}] = {shadow}.read();")
        else:
            writer.line(f"__tmp.range({msb}, {lsb}) = {shadow}.read();")
    writer.line(f"{assembler.parent_name}.write(__tmp);")
    writer.dedent()
    writer.line("}")


def _dependency_order(modules: list[ModuleIR]) -> list[ModuleIR]:
    by_name = {module.name: module for module in modules}
    visited: set[str] = set()
    ordered: list[ModuleIR] = []

    def visit(module: ModuleIR) -> None:
        if module.name in visited:
            return
        visited.add(module.name)
        for child in _module_dependencies(module):
            child_module = by_name.get(child)
            if child_module is not None:
                visit(child_module)
        ordered.append(module)

    for module in modules:
        visit(module)
    return ordered


def _module_dependencies(module: ModuleIR) -> list[str]:
    names = [instance.module for instance in module.instances]
    for generate_for in module.generate_fors:
        names.extend(instance.module for instance in generate_for.instances)
    return _dedupe(names)


def _generate_bit_bridges(
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
) -> list[GenerateBitBridge]:
    bridges: list[GenerateBitBridge] = []
    for generate_for in module.generate_fors:
        count_expr = _generate_for_count_expr(generate_for)
        for instance in generate_for.instances:
            child_ports = _child_ports_lookup(instance.module, modules_by_name, signatures)
            if not child_ports:
                continue
            for port in instance.ports:
                match = _bit_select_binding(port.value, generate_for.var)
                if match is None:
                    continue
                child_port = child_ports.get(port.name)
                if child_port is None or child_port.direction not in {"input", "output", "inout"}:
                    continue
                parent_name, _index = match
                base = (
                    f"{_sanitize_identifier(generate_for.name)}_"
                    f"{_sanitize_identifier(instance.name)}_"
                    f"{_sanitize_identifier(port.name)}"
                )
                bridges.append(
                    GenerateBitBridge(
                        name=f"__bridge_{base}",
                        method_name=f"__bridge_method_{base}",
                        parent_name=_sanitize_identifier(parent_name),
                        port_name=port.name,
                        direction=child_port.direction,
                        count_expr=count_expr,
                    )
                )
    return bridges


def _direct_bit_bridges(
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
    *,
    parent_ctx: ModuleContext | None = None,
) -> list[DirectBitBridge]:
    bridges: list[DirectBitBridge] = []
    parent_ctx = parent_ctx or build_module_context(module)
    for instance in module.instances:
        child_ports = _child_ports_lookup(instance.module, modules_by_name, signatures)
        if not child_ports:
            continue
        for port in instance.ports:
            if is_array_element_expr(port.value_expr, parent_ctx):
                # ``array[index]`` denotes a complete unpacked-array cell,
                # not a packed-vector bit. ExprPortBridge preserves the
                # cell's actual width and signedness.
                continue
            match = _constant_bit_select_binding(port.value)
            if match is None:
                continue
            child_port = child_ports.get(port.name)
            if child_port is None or child_port.direction not in {"input", "output", "inout"}:
                continue
            child_port = _specialize_child_port(instance, child_port, modules_by_name, signatures)
            parent_name, index_expr = match
            array_cell = _is_array_subarray_name(parent_name, parent_ctx)
            base = f"{_sanitize_identifier(instance.name)}_{_sanitize_identifier(port.name)}"
            bridges.append(
                DirectBitBridge(
                    name=f"__bridge_{base}",
                    method_name=f"__bridge_method_{base}",
                    parent_name=parent_name if (array_cell or "[" in parent_name) else _sanitize_identifier(parent_name),
                    index_expr=_sanitize_identifier(index_expr) if not index_expr.isdecimal() else index_expr,
                    instance_name=instance.name,
                    port_name=port.name,
                    direction=child_port.direction,
                    vector=child_port.width is not None,
                    array_cell=array_cell,
                )
            )
    return bridges


def _expr_port_bridges(
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
    *,
    parent_ctx: ModuleContext | None = None,
) -> list[ExprPortBridge]:
    bridges: list[ExprPortBridge] = []
    parent_ctx = parent_ctx or build_module_context(module)
    for instance in module.instances:
        child_ports = _child_ports_lookup(instance.module, modules_by_name, signatures)
        if not child_ports:
            continue
        for port_name, arg in _resolve_instance_arg_ports(instance, signatures):
            if not port_name or not arg.value:
                continue
            child_port = child_ports.get(port_name)
            if child_port is None or child_port.direction not in {"input", "output"}:
                continue
            child_port = _specialize_child_port(instance, child_port, modules_by_name, signatures)
            if not isinstance(arg.value_expr, dict):
                continue
            simple_binding = _simple_instance_binding(arg.value)
            if (
                simple_binding
                and not _port_binding_width_mismatch(arg.value_expr, child_port, parent_ctx)
                and not _port_binding_shape_mismatch(module, arg.value, child_port)
            ):
                continue
            if (
                _constant_bit_select_binding(arg.value) is not None
                and not is_array_element_expr(arg.value_expr, parent_ctx)
            ):
                continue
            if (
                child_port.direction == "output"
                and not simple_binding
                and not is_array_element_expr(arg.value_expr, parent_ctx)
                and arg.value_expr.get("kind") not in {"bitselect", "partselect"}
            ):
                continue
            base = f"{_sanitize_identifier(instance.name)}_{_sanitize_identifier(port_name)}"
            bridges.append(
                ExprPortBridge(
                    name=f"__bridge_{base}",
                    method_name=f"__bridge_method_{base}",
                    instance_name=instance.name,
                    port_name=port_name,
                    port=child_port,
                    expr=arg.value_expr,
                )
            )
    return bridges


def _port_binding_width_mismatch(
    expr: dict[str, object],
    port: PortIR,
    ctx: ModuleContext,
) -> bool:
    parent_width = max(1, infer_width(expr, ctx))
    child_width = _constant_integer_expr(_width_expr(port.width))
    return child_width is not None and parent_width != max(1, child_width)


def _port_binding_shape_mismatch(module: ModuleIR, parent_name: str, child_port: PortIR) -> bool:
    parent = next(
        (
            item
            for item in (*module.ports, *module.signals)
            if item.name == parent_name
        ),
        None,
    )
    if parent is None:
        return False
    return (parent.width is None) != (child_port.width is None)


def _unconnected_port_signals(
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
) -> list[UnconnectedPortSignal]:
    dummies: list[UnconnectedPortSignal] = []
    for instance in module.instances:
        child_ports = _child_ports_lookup(instance.module, modules_by_name, signatures)
        if not child_ports:
            continue
        for port_name, arg in _resolve_instance_arg_ports(instance, signatures):
            if not port_name or arg.value:
                continue
            child_port = child_ports.get(port_name)
            if child_port is None:
                continue
            child_port = _specialize_child_port(instance, child_port, modules_by_name, signatures)
            base = f"{_sanitize_identifier(instance.name)}_{_sanitize_identifier(port_name)}"
            dummies.append(
                UnconnectedPortSignal(
                    name=f"__unused_{base}",
                    instance_name=instance.name,
                    port_name=port_name,
                    port=child_port,
                )
            )
    return dummies


def _simple_instance_binding(expr: str) -> bool:
    return re.fullmatch(r"[A-Za-z_][A-Za-z0-9_$]*", expr or "") is not None


def _child_ports_lookup(
    module_name: str,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
) -> dict[str, PortIR]:
    child_module = modules_by_name.get(module_name)
    if child_module is not None:
        return {port.name: port for port in child_module.ports}
    signature = signatures.get(module_name)
    if signature is not None:
        return {port.name: port for port in signature.ports}
    return {}


def _specialize_child_port(
    instance: InstanceIR,
    port: PortIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
) -> PortIR:
    child = modules_by_name.get(instance.module)
    parameters = child.parameters if child is not None else signatures.get(instance.module, ModuleSignature(instance.module)).parameters
    values = {parameter.name: parameter.value for parameter in parameters}
    values.update({argument.name: argument.value for argument in instance.parameters})
    if not values:
        return port

    def substitute(text: str) -> str:
        result = text
        for name, value in values.items():
            result = re.sub(rf"\b{re.escape(name)}\b", f"({value})", result)
        return result

    width = port.width
    specialized_width = (
        WidthIR(msb=substitute(width.msb), lsb=substitute(width.lsb))
        if width is not None
        else None
    )
    specialized_dims = tuple(
        (substitute(str(left)), substitute(str(right)))
        for left, right in port.declared_unpacked_dims
    )
    return replace(
        port,
        width=specialized_width,
        declared_unpacked_dims=specialized_dims,
    )


def _resolved_signal_names(
    module: ModuleIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
) -> set[str]:
    """Return module-local names that must use SystemC resolved vectors.

    ``inout`` ports need resolved channels at their boundary. Internal nets
    also need them when they feed child ``inout`` ports or when the module
    drives them with a high-impedance branch such as ``assign bus = oe ? x :
    'z``.
    """
    resolved = {port.name for port in module.ports if port.direction == "inout"}
    internal_signal_names = {signal.name for signal in module.signals}

    for assign in module.continuous_assigns:
        if not _contains_xz_literal(assign.right_expr):
            continue
        base = lvalue_base_name(assign.left_expr) if assign.left_expr is not None else ""
        if not base:
            base = _binding_base_name(assign.left)
        if base in internal_signal_names or base in resolved:
            resolved.add(base)

    for instance in module.instances:
        _collect_inout_binding_names(instance, modules_by_name, signatures, resolved)
    for generate_for in module.generate_fors:
        for instance in generate_for.instances:
            _collect_inout_binding_names(instance, modules_by_name, signatures, resolved)
    return resolved


def _collect_inout_binding_names(
    instance: InstanceIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
    resolved: set[str],
) -> None:
    child_ports = _child_ports_lookup(instance.module, modules_by_name, signatures)
    if not child_ports:
        return
    for port_name, value in _resolve_instance_ports(instance, signatures):
        child_port = child_ports.get(port_name)
        if child_port is None or child_port.direction != "inout":
            continue
        base = _binding_base_name(value)
        if base:
            resolved.add(base)


def _binding_base_name(expr: str) -> str:
    match = re.match(r"\s*(?P<name>[A-Za-z_][A-Za-z0-9_$]*)", expr or "")
    return match.group("name") if match else ""


def _contains_xz_literal(expr: object) -> bool:
    if not isinstance(expr, dict):
        return False
    if expr.get("kind") == "intconst" and expr.get("has_xz"):
        return True
    for key in (
        "target",
        "operand",
        "value",
        "cond",
        "true",
        "false",
        "left",
        "right",
        "msb",
        "lsb",
        "index",
        "count",
    ):
        if _contains_xz_literal(expr.get(key)):
            return True
    for key in ("parts", "args", "elements"):
        children = expr.get(key)
        if isinstance(children, list) and any(_contains_xz_literal(child) for child in children):
            return True
    return False


def _method_sensitivity(module: ModuleIR, method_name: str, ctx: ModuleContext) -> list[str]:
    grouped_assign = re.fullmatch(r"assign_group_(?P<start>\d+)_(?P<end>\d+)", method_name)
    if grouped_assign is not None:
        start = int(grouped_assign.group("start"))
        end = int(grouped_assign.group("end"))
        sensitivity: list[str] = []
        for assign in module.continuous_assigns[start : end + 1]:
            if assign.right_expr is not None:
                sensitivity.extend(collect_sensitivity(assign.right_expr, ctx))
            else:
                sensitivity.extend(_identifiers(assign.right))
        return _dedupe_preserve(sensitivity)

    if method_name.startswith("assign_"):
        index = int(method_name.removeprefix("assign_"))
        assign = module.continuous_assigns[index]
        if assign.right_expr is not None:
            return collect_sensitivity(assign.right_expr, ctx)
        return _identifiers(assign.right)

    if method_name.startswith("always_comb_"):
        index = int(method_name.removeprefix("always_comb_"))
        comb_processes = [process for process in module.processes if process.kind == "always_comb"]
        process = comb_processes[index]
        explicit = [item.signal for item in process.sensitivity if item.edge in {"all", "level"} and item.signal]
        if explicit:
            return [_sanitize_identifier(name) for name in explicit if name != "*"]
        ordered: list[str] = []
        seen: set[str] = set()
        for statement in process.structured_statements:
            for name in _collect_statement_rhs_sensitivity(statement, ctx):
                if name not in seen:
                    seen.add(name)
                    ordered.append(name)
        if ordered:
            return ordered
        # Last-resort fall back to the legacy string scan
        legacy: list[str] = []
        for statement_str in process.statements:
            if "=" in statement_str:
                legacy.extend(_identifiers(statement_str.split("=", maxsplit=1)[1]))
        return _dedupe(legacy)

    if method_name.startswith("always_ff_"):
        index = int(method_name.removeprefix("always_ff_"))
        ff_processes = [process for process in module.processes if process.kind == "always_ff"]
        process = ff_processes[index]
        sensitivity: list[str] = []
        for item in process.sensitivity:
            if item.edge in {"posedge", "negedge"}:
                signal = _sanitize_identifier(item.signal)
                is_port = any(port.name == item.signal for port in module.ports)
                edge_method = _systemc_edge(item.edge) if is_port else f"{item.edge}_event"
                sensitivity.append(f"{signal}.{edge_method}()")
            elif item.signal and item.signal != "*":
                sensitivity.append(_sanitize_identifier(item.signal))
        return sensitivity

    return []


def _expand_sensitivity_list(names: list[str], ctx: ModuleContext) -> list[str]:
    expanded: list[str] = []
    for name in names:
        if "." in name or "[" in name:
            expanded.append(name)
            continue
        raw_name = name
        if raw_name not in ctx.array_dimensions:
            expanded.append(name)
            continue
        for suffix in _array_index_suffixes(ctx.array_dimensions[raw_name]):
            expanded.append(f"{_sanitize_identifier(raw_name)}{suffix}")
    return _dedupe_preserve(expanded)


def _array_index_suffixes(dim_sizes: tuple[int, ...]) -> list[str]:
    if not dim_sizes:
        return [""]
    suffixes: list[str] = []

    def walk(prefix: list[int], rest: tuple[int, ...]) -> None:
        if not rest:
            suffixes.append("".join(f"[{index}]" for index in prefix))
            return
        for index in range(rest[0]):
            walk(prefix + [index], rest[1:])

    walk([], tuple(max(0, size) for size in dim_sizes))
    return suffixes


def _collect_statement_rhs_sensitivity(statement: dict[str, object], ctx: ModuleContext) -> list[str]:
    kind = statement.get("type")
    names: list[str] = []
    if kind in {"blocking_assign", "nonblocking_assign"}:
        right_expr = statement.get("right_expr")
        if isinstance(right_expr, dict):
            names.extend(collect_sensitivity(right_expr, ctx))
        # bit-/part-select indices on LHS also need sensitivity
        left_expr = statement.get("left_expr")
        if isinstance(left_expr, dict):
            names.extend(_collect_lvalue_index_sensitivity(left_expr, ctx))
        return names
    if kind == "if":
        cond_expr = statement.get("cond_expr")
        if isinstance(cond_expr, dict):
            names.extend(collect_sensitivity(cond_expr, ctx))
        for child in _as_statement_list(statement.get("true")):
            names.extend(_collect_statement_rhs_sensitivity(child, ctx))
        for child in _as_statement_list(statement.get("false")):
            names.extend(_collect_statement_rhs_sensitivity(child, ctx))
        return names
    if kind == "case":
        expr_tree = statement.get("expr_tree")
        if isinstance(expr_tree, dict):
            names.extend(collect_sensitivity(expr_tree, ctx))
        for item in _as_case_items(statement.get("items")):
            for cond_expr in item.get("cond_exprs", []) or []:
                if isinstance(cond_expr, dict):
                    names.extend(collect_sensitivity(cond_expr, ctx))
            for child in _as_statement_list(item.get("statements")):
                names.extend(_collect_statement_rhs_sensitivity(child, ctx))
        return names
    if kind == "block":
        for child in _as_statement_list(statement.get("statements")):
            names.extend(_collect_statement_rhs_sensitivity(child, ctx))
    return names


def _collect_lvalue_index_sensitivity(expr: dict[str, object], ctx: ModuleContext) -> list[str]:
    kind = expr.get("kind")
    names: list[str] = []
    if kind == "bitselect":
        index = expr.get("index")
        if isinstance(index, dict):
            names.extend(collect_sensitivity(index, ctx))
        target = expr.get("target")
        if isinstance(target, dict):
            names.extend(_collect_lvalue_index_sensitivity(target, ctx))
    elif kind == "partselect":
        for key in ("msb", "lsb"):
            child = expr.get(key)
            if isinstance(child, dict):
                names.extend(collect_sensitivity(child, ctx))
        target = expr.get("target")
        if isinstance(target, dict):
            names.extend(_collect_lvalue_index_sensitivity(target, ctx))
    return names


def _emit_subroutine(writer: CodeWriter, subroutine: SubroutineIR, ctx: ModuleContext) -> None:
    """Emit a Verilog function as a const C++ class method.

    Verilog's implicit "return value via function-name variable" maps to a
    local C++ variable named after the function, written in the body and
    returned at the end. Parameter names and the implicit return variable
    are added to ``ctx.local_names`` so identifier rendering treats them as
    plain locals rather than ``sc_signal`` reads.
    """
    if subroutine.kind != "function":
        return

    return_type = _sc_type(subroutine.return_width, subroutine.return_signed)
    func_name = _sanitize_identifier(subroutine.name)
    formal_params = []
    local_names: set[str] = {subroutine.name}
    for param in subroutine.params:
        param_type = _sc_type(param.width, param.signed)
        param_name = _sanitize_identifier(param.name)
        formal_params.append(f"{param_type} {param_name}")
        local_names.add(param.name)

    for local in subroutine.local_signals:
        local_names.add(local.name)

    body_ctx = ctx.with_subroutine(subroutine)
    writer.line(f"{return_type} {func_name}({', '.join(formal_params)}) const {{")
    writer.indent()
    writer.line(f"{return_type} {func_name};")
    for local in subroutine.local_signals:
        writer.line(
            f"{_sc_type(local.width, local.signed)} {_sanitize_identifier(local.name)}"
            f"{_unpacked_suffix(local.declared_unpacked_dims or local.unpacked_dims)};"
        )
    for statement in subroutine.body_statements:
        for body_line in _emit_structured_statement(
            statement, indent_level=0, ctx=body_ctx, staged_names=frozenset()
        ):
            writer.line(body_line)
    writer.line(f"return {func_name};")
    writer.dedent()
    writer.line("}")
    writer.line()


def _emit_comb_process(process: ProcessIR, ctx: ModuleContext) -> list[str]:
    if not process.structured_statements:
        if process.statements:
            lines: list[str] = []
            for statement in process.statements:
                if "<=" in statement:
                    left, right = statement.split("<=", maxsplit=1)
                    lines.append(_emit_legacy_assignment(left.strip(), right.strip()))
                elif "=" in statement:
                    left, right = statement.split("=", maxsplit=1)
                    lines.append(_emit_legacy_assignment(left.strip(), right.strip()))
                else:
                    lines.append(f"// Unsupported statement: {statement}")
            return lines
        return ["// Empty process."]

    written_bases = _collect_written_base_names(process, ctx)
    if not written_bases:
        lines: list[str] = []
        for statement in process.structured_statements:
            lines.extend(_emit_structured_statement(statement, indent_level=0, ctx=ctx, staged_names=frozenset()))
        return lines

    staged_names = frozenset(written_bases)
    lines = []
    for base in written_bases:
        sanitized = _sanitize_identifier(base)
        lines.append(f"auto __next_{sanitized} = {sanitized}.read();")
    for statement in process.structured_statements:
        lines.extend(_emit_structured_statement(statement, indent_level=0, ctx=ctx, staged_names=staged_names))
    for base in written_bases:
        sanitized = _sanitize_identifier(base)
        lines.append(f"{sanitized}.write(__next_{sanitized});")
    return lines


def _emit_ff_process(process: ProcessIR, ctx: ModuleContext) -> list[str]:
    if not process.structured_statements:
        return ["// Empty process."]

    written_bases = _collect_written_base_names(process, ctx)
    if not written_bases:
        lines: list[str] = []
        for statement in process.structured_statements:
            lines.extend(_emit_structured_statement(statement, indent_level=0, ctx=ctx, staged_names=frozenset()))
        return lines

    staged_names = frozenset(written_bases)
    lines = []
    for base in written_bases:
        sanitized = _sanitize_identifier(base)
        lines.append(f"auto __next_{sanitized} = {sanitized}.read();")
    # Verilog nonblocking assignments evaluate their RHS from the pre-edge
    # state, while blocking temporaries in the same FF block take effect
    # immediately. LHS still schedules into __next_*; RHS reads only see
    # __next_* for names written by blocking assignments in this process.
    immediate_names = frozenset(
        _collect_written_base_names(process, ctx, assignment_kinds={"blocking_assign"})
    )
    for statement in process.structured_statements:
        lines.extend(
            _emit_structured_statement(
                statement,
                indent_level=0,
                ctx=ctx,
                staged_names=staged_names,
                rhs_staged_names=immediate_names,
            )
        )
    for base in written_bases:
        sanitized = _sanitize_identifier(base)
        lines.append(f"{sanitized}.write(__next_{sanitized});")
    return lines


def _emit_structured_statement(
    statement: dict[str, object],
    indent_level: int,
    *,
    ctx: ModuleContext,
    staged_names: frozenset[str],
    rhs_staged_names: frozenset[str] | None = None,
) -> list[str]:
    prefix = "  " * indent_level
    kind = statement.get("type")
    rhs_names = staged_names if rhs_staged_names is None else rhs_staged_names

    if kind in {"blocking_assign", "nonblocking_assign"}:
        return [prefix + _emit_tree_assignment(statement, ctx, staged_names, rhs_staged_names=rhs_names)]

    if kind == "return":
        value_expr = statement.get("value_expr")
        if value_expr is None:
            return [f"{prefix}return;"]
        value_cpp = render_rvalue(value_expr, ctx, staged_names=rhs_names)
        return [f"{prefix}return {value_cpp};"]

    if kind == "if":
        cond_text = _render_cond(statement, ctx, staged_names=rhs_names)
        lines = [f"{prefix}if ({cond_text}) {{"]
        for child in _as_statement_list(statement.get("true")):
            lines.extend(
                _emit_structured_statement(
                    child,
                    indent_level + 1,
                    ctx=ctx,
                    staged_names=staged_names,
                    rhs_staged_names=rhs_names,
                )
            )
        false_branch = _as_statement_list(statement.get("false"))
        if false_branch:
            lines.append(f"{prefix}}} else {{")
            for child in false_branch:
                lines.extend(
                    _emit_structured_statement(
                        child,
                        indent_level + 1,
                        ctx=ctx,
                        staged_names=staged_names,
                        rhs_staged_names=rhs_names,
                    )
                )
        lines.append(f"{prefix}}}")
        return lines

    if kind == "case":
        return _emit_case_statement(
            statement,
            indent_level,
            ctx=ctx,
            staged_names=staged_names,
            rhs_staged_names=rhs_names,
        )

    if kind == "block":
        # Unrolled for loops and other compound statements produce blocks
        lines = []
        for child in _as_statement_list(statement.get("statements")):
            lines.extend(
                _emit_structured_statement(
                    child,
                    indent_level,
                    ctx=ctx,
                    staged_names=staged_names,
                    rhs_staged_names=rhs_names,
                )
            )
        return lines

    if kind == "noop":
        # Empty statements and variable declarations (already handled by slang)
        return []

    node = statement.get("node", kind)
    return [f"{prefix}// Unsupported statement: {node}"]


def _emit_case_statement(
    statement: dict[str, object],
    indent_level: int,
    *,
    ctx: ModuleContext,
    staged_names: frozenset[str],
    rhs_staged_names: frozenset[str] | None = None,
) -> list[str]:
    rhs_names = staged_names if rhs_staged_names is None else rhs_staged_names
    case_kind = str(statement.get("case_kind", "case"))
    if case_kind in {"casez", "casex"}:
        return _emit_wildcard_case_statement(
            statement,
            indent_level,
            ctx=ctx,
            staged_names=staged_names,
            rhs_staged_names=rhs_names,
            case_kind=case_kind,
        )
    prefix = "  " * indent_level
    expr_tree = statement.get("expr_tree")
    if isinstance(expr_tree, dict):
        expr = render_rvalue(expr_tree, ctx, staged_names=rhs_names)
    else:
        expr = _cpp_rvalue(str(statement.get("expr", "")))
    lines = [f"{prefix}switch ({expr}) {{"]
    for item in _as_case_items(statement.get("items")):
        cond_exprs = item.get("cond_exprs")
        if isinstance(cond_exprs, list) and cond_exprs:
            for cond_expr in cond_exprs:
                if isinstance(cond_expr, dict):
                    lines.append(f"{prefix}case {_render_case_label(cond_expr, ctx, staged_names=rhs_names)}:")
                else:
                    lines.append(f"{prefix}case {cond_expr}:")
        else:
            conds = item.get("conds")
            if isinstance(conds, list) and conds:
                for cond in conds:
                    lines.append(f"{prefix}case {_cpp_expr(str(cond))}:")
            else:
                lines.append(f"{prefix}default:")
        for child in _as_statement_list(item.get("statements")):
            lines.extend(
                _emit_structured_statement(
                    child,
                    indent_level + 1,
                    ctx=ctx,
                    staged_names=staged_names,
                    rhs_staged_names=rhs_names,
                )
            )
        lines.append(f"{prefix}  break;")
    lines.append(f"{prefix}}}")
    return lines


def _render_case_label(
    expr: dict[str, object],
    ctx: ModuleContext,
    *,
    staged_names: frozenset[str],
) -> str:
    # Verilog case labels are matched by sized bit pattern. A signed literal
    # like 4'shF should therefore emit 15 here, not the arithmetic value -1.
    if expr.get("kind") == "intconst" and expr.get("signed"):
        value = expr.get("value")
        if isinstance(value, int):
            return str(value)
    return render_rvalue(expr, ctx, staged_names=staged_names)


_WILDCARD_CHARS_CASEZ = "zZ?"
_WILDCARD_CHARS_CASEX = "xXzZ?"
_BITS_PER_DIGIT = {2: 1, 8: 3, 16: 4}


def _pattern_mask_and_match(
    pattern: dict[str, object], case_kind: str, fallback_width: int
) -> tuple[int, int, int] | None:
    """Return ``(mask, match, width)`` for a wildcard-aware pattern literal.

    ``casez`` treats only ``z`` / ``Z`` / ``?`` as wildcards. ``casex`` also
    treats ``x`` / ``X`` as wildcards. For digits in any of the wildcard
    sets, the corresponding bit is cleared in ``mask`` and forced to 0 in
    ``match``. Returns ``None`` for non-intconst patterns (caller falls
    back to a strict equality compare).
    """
    if pattern.get("kind") != "intconst":
        return None
    digits = str(pattern.get("digits", ""))
    base = pattern.get("base")
    if not isinstance(base, int) or base not in _BITS_PER_DIGIT:
        return None
    wildcard_chars = _WILDCARD_CHARS_CASEX if case_kind == "casex" else _WILDCARD_CHARS_CASEZ
    bits_per_digit = _BITS_PER_DIGIT[base]
    full_mask_digit = (1 << bits_per_digit) - 1
    mask = 0
    match = 0
    for ch in digits:
        mask <<= bits_per_digit
        match <<= bits_per_digit
        if ch in wildcard_chars:
            continue
        mask |= full_mask_digit
        digit_val = int(ch, base)
        match |= digit_val
    width = pattern.get("width")
    if not isinstance(width, int) or width <= 0:
        width = max(fallback_width, len(digits) * bits_per_digit, 1)
    truncate = (1 << width) - 1
    return mask & truncate, match & truncate, width


def _emit_wildcard_case_statement(
    statement: dict[str, object],
    indent_level: int,
    *,
    ctx: ModuleContext,
    staged_names: frozenset[str],
    rhs_staged_names: frozenset[str] | None = None,
    case_kind: str,
) -> list[str]:
    """Lower ``casez`` / ``casex`` to an if / else-if / else chain.

    SystemC ``sc_uint`` provides bitwise ``&``, so each pattern becomes a
    ``(__sel & MASK) == MATCH`` test. Multiple patterns per item are OR'd
    together. The selector is read once into ``__sel`` so each test sees
    the same value even if the underlying signal is volatile in a
    multi-cycle simulation.
    """
    prefix = "  " * indent_level
    rhs_names = staged_names if rhs_staged_names is None else rhs_staged_names
    expr_tree = statement.get("expr_tree")
    if isinstance(expr_tree, dict):
        sel_text = render_rvalue(expr_tree, ctx, staged_names=rhs_names)
        sel_width = infer_width(expr_tree, ctx)
    else:
        sel_text = _cpp_rvalue(str(statement.get("expr", "")))
        sel_width = 1

    lines: list[str] = []
    lines.append(f"{prefix}{{")
    lines.append(f"{prefix}  auto __sel = {sel_text};")

    items = _as_case_items(statement.get("items"))
    first = True
    default_body: list[dict[str, object]] | None = None
    for item in items:
        cond_exprs = item.get("cond_exprs")
        if not (isinstance(cond_exprs, list) and cond_exprs):
            default_body = _as_statement_list(item.get("statements"))
            continue
        terms: list[str] = []
        for cond_expr in cond_exprs:
            if not isinstance(cond_expr, dict):
                continue
            spec = _pattern_mask_and_match(cond_expr, case_kind, sel_width)
            if spec is None:
                # Pattern isn't a sized literal we can mask — fall back to
                # an equality test (loses wildcard semantics, but only if
                # the user wrote a non-literal in the case label, which is
                # already unusual).
                terms.append(f"(__sel == {render_rvalue(cond_expr, ctx, staged_names=rhs_names)})")
                continue
            mask, match, _width = spec
            terms.append(f"((__sel & {hex(mask)}) == {hex(match)})")
        condition = " || ".join(terms) if terms else "false"
        keyword = "if" if first else "else if"
        lines.append(f"{prefix}  {keyword} ({condition}) {{")
        for child in _as_statement_list(item.get("statements")):
            lines.extend(
                _emit_structured_statement(
                    child,
                    indent_level + 2,
                    ctx=ctx,
                    staged_names=staged_names,
                    rhs_staged_names=rhs_names,
                )
            )
        lines.append(f"{prefix}  }}")
        first = False
    if default_body is not None:
        keyword = "" if first else "else "
        if first:
            # No labeled items at all — emit the default body unconditionally.
            for child in default_body:
                lines.extend(
                    _emit_structured_statement(
                        child,
                        indent_level + 1,
                        ctx=ctx,
                        staged_names=staged_names,
                        rhs_staged_names=rhs_names,
                    )
                )
        else:
            lines.append(f"{prefix}  {keyword}{{".rstrip())
            for child in default_body:
                lines.extend(
                    _emit_structured_statement(
                        child,
                        indent_level + 2,
                        ctx=ctx,
                        staged_names=staged_names,
                        rhs_staged_names=rhs_names,
                    )
                )
            lines.append(f"{prefix}  }}")
    lines.append(f"{prefix}}}")
    return lines


def _render_cond(statement: dict[str, object], ctx: ModuleContext, *, staged_names: frozenset[str] | None = None) -> str:
    cond_expr = statement.get("cond_expr")
    if isinstance(cond_expr, dict):
        return render_rvalue(cond_expr, ctx, staged_names=staged_names or frozenset())
    return _cpp_rvalue(str(statement.get("cond", "")))


def _emit_tree_assignment(
    statement: dict[str, object],
    ctx: ModuleContext,
    staged_names: frozenset[str],
    rhs_staged_names: frozenset[str] | None = None,
) -> str:
    left_expr = statement.get("left_expr")
    right_expr = statement.get("right_expr")
    rhs_names = staged_names if rhs_staged_names is None else rhs_staged_names
    if isinstance(right_expr, dict):
        rhs = render_rvalue(right_expr, ctx, staged_names=rhs_names)
    else:
        rhs = _cpp_rvalue(str(statement.get("right", "")))

    if isinstance(left_expr, dict):
        target = left_expr.get("target")
        if (
            left_expr.get("kind") in {"bitselect", "partselect"}
            and isinstance(target, dict)
            and is_array_element_expr(target, ctx)
        ):
            value = _cast_to_lvalue_type(rhs, left_expr, ctx)
            return _emit_lvalue_write(left_expr, value, ctx)
        # Array-cell write (``mem[idx] <= val``): each cell is its own
        # sc_signal, so emit ``mem[idx].write(val);`` directly. The
        # surrounding process doesn't stage these — SystemC's delta-cycle
        # semantics already give nonblocking behavior per cell.
        if is_array_element_expr(left_expr, ctx):
            value = _cast_for_signed_lvalue(rhs, left_expr, ctx)
            return f"{render_lvalue(left_expr, ctx)}.write({value});"
        base = lvalue_base_name(left_expr)
        if base in staged_names:
            lhs = render_lvalue(left_expr, ctx, staged_names=staged_names)
            return f"{lhs} = {_cast_for_signed_lvalue(rhs, left_expr, ctx)};"
        if base in ctx.local_names:
            lhs = render_lvalue(left_expr, ctx)
            return f"{lhs} = {_cast_for_signed_lvalue(rhs, left_expr, ctx)};"
        if left_expr.get("kind") == "identifier":
            value = _cast_for_signed_lvalue(rhs, left_expr, ctx)
            return f"{render_lvalue(left_expr, ctx)}.write({value});"
        return f"// unsupported lvalue without staging: {statement.get('left', '')}"

    return _emit_legacy_assignment(str(statement.get("left", "")), rhs, rhs_already_cpp=True)


def _emit_continuous_assign(assign: ContinuousAssignIR, ctx: ModuleContext) -> list[str]:
    if assign.left_expr is not None and assign.left_expr.get("kind") == "identifier":
        base = lvalue_base_name(assign.left_expr)
        if base in ctx.array_dimensions and assign.right_expr is not None:
            aggregate_lines = _emit_unpacked_array_assignment(base, assign.right_expr, ctx)
            if aggregate_lines is not None:
                return aggregate_lines
    if assign.right_expr is not None:
        rhs = render_rvalue(assign.right_expr, ctx)
    else:
        rhs = _cpp_rvalue(assign.right)
    if assign.left_expr is not None and assign.left_expr.get("kind") == "concat":
        return _emit_concat_lvalue_assignment(assign.left_expr, rhs, ctx)
    if assign.left_expr is not None and assign.left_expr.get("kind") == "identifier":
        base = lvalue_base_name(assign.left_expr)
        if base in ctx.resolved_names:
            width = max(1, ctx.signal_widths.get(base, 1))
            return [(
                f"{render_lvalue(assign.left_expr, ctx)}"
                f".write({_render_resolved_drive(assign.right_expr, ctx, width, fallback=rhs)});"
            )]
        value = _cast_for_signed_lvalue(rhs, assign.left_expr, ctx)
        return [f"{render_lvalue(assign.left_expr, ctx)}.write({value});"]
    if assign.left_expr is not None and assign.left_expr.get("kind") in {"bitselect", "partselect"}:
        value = _cast_to_lvalue_type(rhs, assign.left_expr, ctx)
        return [_emit_lvalue_write(assign.left_expr, value, ctx)]
    return [_emit_legacy_assignment(assign.left, rhs, rhs_already_cpp=True)]


def _emit_unpacked_array_assignment(
    base: str,
    expr: dict[str, object],
    ctx: ModuleContext,
) -> list[str] | None:
    """Expand a constant unpacked-array assignment into per-cell writes."""
    bounds = ctx.array_bounds.get(base)
    if not bounds:
        return None
    lines: list[str] = []
    sanitized = _sanitize_identifier(base)

    def children(node: dict[str, object]) -> list[dict[str, object]] | None:
        kind = node.get("kind")
        key = "elements" if kind == "assignment_pattern" else "parts" if kind == "concat" else ""
        values = node.get(key) if key else None
        if not isinstance(values, list) or not all(isinstance(value, dict) for value in values):
            return None
        return values

    def indices_for(bound: tuple[int, int]) -> list[int]:
        left, right = bound
        step = 1 if right >= left else -1
        return list(range(left, right + step, step))

    def walk(node: dict[str, object], depth: int, indices: tuple[int, ...]) -> bool:
        if depth == len(bounds):
            suffix = "".join(f"[{index}]" for index in indices)
            lines.append(f"{sanitized}{suffix}.write({render_rvalue(node, ctx)});")
            return True
        values = children(node)
        dimension_indices = indices_for(bounds[depth])
        if values is None or len(values) != len(dimension_indices):
            return False
        return all(
            walk(value, depth + 1, (*indices, index))
            for index, value in zip(dimension_indices, values)
        )

    return lines if walk(expr, 0, ()) else None


def _emit_concat_lvalue_assignment(
    left_expr: dict[str, object],
    rhs: str,
    ctx: ModuleContext,
) -> list[str]:
    parts = [part for part in left_expr.get("parts", []) if isinstance(part, dict)]
    if not parts:
        return ["// unsupported empty concat lvalue"]
    widths = [max(1, infer_width(part, ctx)) for part in parts]
    total_width = max(1, sum(widths))
    rhs_tmp = "__concat_rhs"
    lines = [f"auto {rhs_tmp} = {systemc_int_type(total_width)}({rhs});"]
    lsb = total_width
    for part, width in zip(parts, widths):
        lsb -= width
        if width == 1:
            slice_expr = f"{rhs_tmp}[{lsb}]"
        else:
            slice_expr = f"{rhs_tmp}.range({lsb + width - 1}, {lsb})"
        lines.append(_emit_lvalue_write(part, _cast_to_lvalue_type(slice_expr, part, ctx), ctx))
    return lines


def _emit_lvalue_write(left_expr: dict[str, object], value: str, ctx: ModuleContext) -> str:
    if is_array_element_expr(left_expr, ctx) or left_expr.get("kind") == "identifier":
        return f"{render_lvalue(left_expr, ctx)}.write({value});"
    if left_expr.get("kind") in {"bitselect", "partselect"}:
        target = left_expr.get("target")
        if isinstance(target, dict) and is_array_element_expr(target, ctx):
            element = render_lvalue(target, ctx)
            return (
                f"{{ auto __tmp_array = {element}.read(); "
                f"{render_lvalue(left_expr, ctx).replace(element, '__tmp_array')} = {value}; "
                f"{element}.write(__tmp_array); }}"
            )
        base = lvalue_base_name(left_expr)
        if base:
            sanitized = _sanitize_identifier(base)
            lhs_target = render_lvalue(left_expr, ctx, staged_names=frozenset({base}))
            return (
                f"{{ auto __tmp_{sanitized} = {sanitized}.read(); "
                f"{lhs_target.replace(f'__next_{sanitized}', f'__tmp_{sanitized}')} = {value}; "
                f"{sanitized}.write(__tmp_{sanitized}); }}"
            )
    return f"// unsupported concat lvalue part: {render_lvalue(left_expr, ctx)}"


def _cast_to_port_type(value: str, port: PortIR) -> str:
    width_expr = _width_expr(port.width)
    if port.width is None and not port.signed:
        return value
    return f"{_sc_type(port.width, port.signed)}({value})"


def _cast_to_lvalue_type(value: str, left_expr: dict[str, object], ctx: ModuleContext) -> str:
    width = max(1, infer_width(left_expr, ctx))
    signed = _lvalue_signed(left_expr, ctx)
    base = lvalue_base_name(left_expr)
    if width == 1 and not signed and base not in ctx.packed_vector_names:
        return value
    return f"{systemc_int_type(width, signed=signed)}({value})"


def _cast_for_signed_lvalue(value: str, left_expr: dict[str, object], ctx: ModuleContext) -> str:
    width = max(1, infer_width(left_expr, ctx))
    base = lvalue_base_name(left_expr)
    if not _lvalue_signed(left_expr, ctx):
        if width == 1 and base in ctx.packed_vector_names:
            return f"{systemc_int_type(1)}({value})"
        return value
    return f"{systemc_int_type(width, signed=True)}({value})"


def _lvalue_signed(left_expr: dict[str, object], ctx: ModuleContext) -> bool:
    base = lvalue_base_name(left_expr)
    if left_expr.get("kind") == "identifier" and base:
        return bool(ctx.signal_signedness.get(base, False))
    if is_array_element_expr(left_expr, ctx) and base:
        return bool(ctx.signal_signedness.get(base, False))
    return infer_signed(left_expr, ctx)


def _render_resolved_drive(
    expr: dict[str, object] | None,
    ctx: ModuleContext,
    width: int,
    *,
    fallback: str | None = None,
) -> str:
    width = max(1, width)
    if isinstance(expr, dict):
        kind = expr.get("kind")
        if kind == "cond":
            cond = render_rvalue(expr.get("cond"), ctx)
            true_branch = _render_resolved_drive(expr.get("true"), ctx, width)
            false_branch = _render_resolved_drive(expr.get("false"), ctx, width)
            return f"({cond} ? {true_branch} : {false_branch})"
        if kind == "intconst" and expr.get("has_xz"):
            return f"sc_lv<{width}>(\"{_xz_literal_bits(expr, width)}\")"
        if kind == "repeat":
            repeated = _repeat_xz_bits(expr, ctx, width)
            if repeated is not None:
                return f"sc_lv<{width}>(\"{repeated}\")"
        if kind == "concat":
            concat = _concat_xz_bits(expr, ctx, width)
            if concat is not None:
                return f"sc_lv<{width}>(\"{concat}\")"
    numeric = fallback if fallback is not None else render_rvalue(expr, ctx)
    return f"sc_lv<{width}>(sc_uint<{width}>({numeric}))"


def _repeat_xz_bits(expr: dict[str, object], ctx: ModuleContext, width: int) -> str | None:
    value = expr.get("value")
    if not isinstance(value, dict):
        return None
    count = const_eval(expr.get("count"), ctx) or 0
    if count <= 0:
        return None
    value_width = max(1, infer_width(value, ctx))
    if value.get("kind") == "intconst" and value.get("has_xz"):
        bits = _xz_literal_bits(value, value_width) * count
        return _fit_bit_string(bits, width)
    return None


def _concat_xz_bits(expr: dict[str, object], ctx: ModuleContext, width: int) -> str | None:
    parts = expr.get("parts")
    if not isinstance(parts, list) or not parts:
        return None
    rendered: list[str] = []
    for part in parts:
        if not isinstance(part, dict):
            return None
        part_width = max(1, infer_width(part, ctx))
        if part.get("kind") == "intconst" and part.get("has_xz"):
            rendered.append(_xz_literal_bits(part, part_width))
            continue
        if part.get("kind") == "repeat":
            repeated = _repeat_xz_bits(part, ctx, part_width)
            if repeated is None:
                return None
            rendered.append(repeated)
            continue
        return None
    return _fit_bit_string("".join(rendered), width)


def _xz_literal_bits(expr: dict[str, object], width: int) -> str:
    base = expr.get("base")
    digits = str(expr.get("digits", "") or "")
    if not isinstance(base, int) or base not in _BITS_PER_DIGIT or not digits:
        return "X" * max(1, width)
    bits_per_digit = _BITS_PER_DIGIT[base]
    pieces: list[str] = []
    for digit in digits:
        if digit in {"x", "X"}:
            pieces.append("X" * bits_per_digit)
        elif digit in {"z", "Z", "?"}:
            pieces.append("Z" * bits_per_digit)
        else:
            try:
                pieces.append(format(int(digit, base), f"0{bits_per_digit}b"))
            except ValueError:
                pieces.append("X" * bits_per_digit)
    return _fit_bit_string("".join(pieces), max(1, width))


def _fit_bit_string(bits: str, width: int) -> str:
    width = max(1, width)
    if len(bits) >= width:
        return bits[-width:]
    pad = "0"
    if bits and bits[0] in {"X", "Z"}:
        pad = bits[0]
    return pad * (width - len(bits)) + bits


def _collect_written_base_names(
    process: ProcessIR,
    ctx: ModuleContext | None = None,
    *,
    assignment_kinds: set[str] | None = None,
) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for statement in process.structured_statements:
        for base in _walk_lvalue_bases(statement, assignment_kinds=assignment_kinds):
            if not base or base in seen:
                continue
            if ctx is not None and base in ctx.array_signal_names:
                # Array-cell writes route through ``mem[i].write(...)``
                # directly; no whole-array staging needed.
                continue
            seen.add(base)
            ordered.append(base)
    return ordered


def _walk_lvalue_bases(
    statement: dict[str, object],
    *,
    assignment_kinds: set[str] | None = None,
) -> list[str]:
    kind = statement.get("type")
    if kind in {"blocking_assign", "nonblocking_assign"}:
        if assignment_kinds is not None and kind not in assignment_kinds:
            return []
        left_expr = statement.get("left_expr")
        if isinstance(left_expr, dict):
            base = lvalue_base_name(left_expr)
            if base:
                return [base]
        left_str = str(statement.get("left", "")).strip()
        match = re.match(r"^(?P<name>[A-Za-z_][A-Za-z0-9_$]*)", left_str)
        if match:
            return [match.group("name")]
        return []
    if kind == "if":
        names: list[str] = []
        for child in _as_statement_list(statement.get("true")):
            names.extend(_walk_lvalue_bases(child, assignment_kinds=assignment_kinds))
        for child in _as_statement_list(statement.get("false")):
            names.extend(_walk_lvalue_bases(child, assignment_kinds=assignment_kinds))
        return names
    if kind == "block":
        names = []
        for child in _as_statement_list(statement.get("statements")):
            names.extend(_walk_lvalue_bases(child, assignment_kinds=assignment_kinds))
        return names
    if kind == "case":
        names = []
        for item in _as_case_items(statement.get("items")):
            for child in _as_statement_list(item.get("statements")):
                names.extend(_walk_lvalue_bases(child, assignment_kinds=assignment_kinds))
        return names
    return []


def _as_statement_list(value: object) -> list[dict[str, object]]:
    if not isinstance(value, list):
        return []
    return [item for item in value if isinstance(item, dict)]


def _as_case_items(value: object) -> list[dict[str, object]]:
    if not isinstance(value, list):
        return []
    return [item for item in value if isinstance(item, dict)]


def _emit_legacy_assignment(left: str, right: str, *, rhs_already_cpp: bool = False) -> str:
    rendered_right = right if rhs_already_cpp else _cpp_rvalue(right)
    return f"{_cpp_lvalue(left)}.write({rendered_right});"


def _port_type(port: PortIR) -> str:
    dtype = _sc_type(port.width, port.signed)
    if port.direction == "input":
        return f"sc_in<{dtype}>"
    if port.direction == "output":
        return f"sc_out<{dtype}>"
    if port.direction == "inout":
        return f"sc_inout_rv<{_width_expr(port.width)}>"
    return f"sc_signal<{dtype}>"


def _signal_type(signal: SignalIR, *, resolved: bool = False) -> str:
    if resolved:
        return f"sc_signal_rv<{_width_expr(signal.width)}>"
    return f"sc_signal<{_sc_type(signal.width, signal.signed)}>"


def _unpacked_suffix(dims: tuple[tuple[int | str, int | str], ...]) -> str:
    rendered: list[str] = []
    for left, right in dims:
        if isinstance(left, int) and isinstance(right, int):
            size = str(abs(left - right) + 1)
        else:
            left_cpp = _cpp_expr(str(left))
            right_cpp = _cpp_expr(str(right))
            size = (
                f"((({left_cpp}) >= ({right_cpp})) ? "
                f"(({left_cpp}) - ({right_cpp}) + 1) : "
                f"(({right_cpp}) - ({left_cpp}) + 1))"
            )
        rendered.append(f"[{size}]")
    return "".join(rendered)


def _emit_integer_type_aliases(writer: CodeWriter) -> None:
    """Emit parameter-width integer aliases shared by generated headers."""
    writer.line("#ifndef PRISM_V2SC_INTEGER_TYPES")
    writer.line("#define PRISM_V2SC_INTEGER_TYPES")
    writer.line(
        "template <int Width> using prism_v2sc_uint_t = "
        "typename std::conditional<(Width <= 64), sc_uint<Width>, "
        "sc_biguint<Width>>::type;"
    )
    writer.line(
        "template <int Width> using prism_v2sc_int_t = "
        "typename std::conditional<(Width <= 64), sc_int<Width>, "
        "sc_bigint<Width>>::type;"
    )
    writer.line(
        "constexpr int prism_v2sc_clog2(int value) { "
        "int result = 0; for (int current = value - 1; current > 0; current >>= 1) ++result; "
        "return result; }"
    )
    writer.line("#endif")


def _write_shared_runtime_header(
    path: Path,
    *,
    instrumentation_config: InstrumentationConfig | None,
) -> None:
    """Write the common, PCH-friendly SystemC prelude once per output tree."""
    writer = CodeWriter()
    writer.line(banner().rstrip())
    writer.line("#pragma once")
    writer.line()
    writer.line("#include <array>")
    writer.line("#include <systemc>")
    writer.line("#include <string>")
    writer.line("#include <type_traits>")
    if instrumentation_config is not None and instrumentation_config.enabled:
        writer.line("#include <cstdint>")
        writer.line("#include <ostream>")
    writer.line()
    writer.line("using namespace sc_core;")
    writer.line("using namespace sc_dt;")
    writer.line()
    _emit_integer_type_aliases(writer)
    content = writer.render()
    try:
        if path.read_text(encoding="utf-8") == content:
            return
    except (FileNotFoundError, OSError):
        pass
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def _sc_type(width: WidthIR | None, signed: bool) -> str:
    width_expr = _width_expr(width)
    if width is None and not signed:
        return "bool"
    concrete_width = _constant_integer_expr(width_expr)
    if concrete_width is not None:
        return systemc_int_type(concrete_width, signed=signed)
    return f"prism_v2sc_{'int' if signed else 'uint'}_t<{width_expr}>"


def _template_parameter_list(module: ModuleIR) -> str:
    declared: set[str] = set()
    rendered: list[str] = []
    for parameter in module.parameters:
        if parameter.kind != "parameter":
            continue
        name = _sanitize_identifier(parameter.name)
        default = _safe_template_default(parameter.value, declared)
        rendered.append(f"int {name} = {default}")
        declared.add(name)
    return ", ".join(rendered)


def _emit_local_parameters(writer: CodeWriter, module: ModuleIR) -> None:
    declared = {
        _sanitize_identifier(parameter.name)
        for parameter in module.parameters
        if parameter.kind == "parameter"
    }
    emitted: set[str] = set()
    for parameter in module.parameters:
        if parameter.kind != "localparam":
            continue
        name = _sanitize_identifier(parameter.name)
        if name in emitted:
            continue
        default = _safe_template_default(parameter.value, declared | emitted)
        writer.line(f"static constexpr int {name} = {default};")
        emitted.add(name)
    if emitted:
        writer.line()


def _safe_template_default(value: str, declared: set[str]) -> str:
    constant_concat = _constant_concat_value(value) if "{" in value else None
    repeated_bit = re.fullmatch(
        r"\{\s*(?P<count>[A-Za-z_][A-Za-z0-9_$]*|\d+)\s*\{+\s*0b(?P<bit>[01])\s*\}+\s*\}",
        _convert_verilog_constants(value),
    )
    if constant_concat is not None:
        default = str(constant_concat)
    elif repeated_bit is not None:
        if repeated_bit.group("bit") == "0":
            default = "0"
        else:
            count = _sanitize_identifier(repeated_bit.group("count"))
            default = f"(({count} >= 31) ? -1 : ((1 << {count}) - 1))"
    else:
        default = _cpp_expr(value)
    if not default:
        return "1"

    def replace_slice(match: re.Match[str]) -> str:
        name = _sanitize_identifier(match.group("name"))
        msb = int(match.group("msb"))
        lsb = int(match.group("lsb"))
        width = abs(msb - lsb) + 1
        low = min(msb, lsb)
        mask = (1 << width) - 1
        return f"(({name} >> {low}) & {mask})"

    default = re.sub(
        r"(?P<name>[A-Za-z_][A-Za-z0-9_$]*)\s*\[\s*(?P<msb>\d+)\s*:\s*(?P<lsb>\d+)\s*\]",
        replace_slice,
        default,
    )
    identifiers = set(_identifiers(default))
    if identifiers - declared:
        return "1"
    return default


def _constant_concat_value(expr: str) -> int | None:
    """Evaluate constant Verilog concatenations and replications as bit patterns."""

    def enclosing_braces(value: str) -> bool:
        if not (value.startswith("{") and value.endswith("}")):
            return False
        depth = 0
        for index, char in enumerate(value):
            if char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0 and index != len(value) - 1:
                    return False
            if depth < 0:
                return False
        return depth == 0

    def split_top_level(value: str) -> list[str]:
        parts: list[str] = []
        depth = 0
        start = 0
        for index, char in enumerate(value):
            if char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
            elif char == "," and depth == 0:
                parts.append(value[start:index].strip())
                start = index + 1
        parts.append(value[start:].strip())
        return parts

    def parse(value: str) -> tuple[int, int] | None:
        value = value.strip()
        while value.startswith("(") and value.endswith(")"):
            depth = 0
            enclosed = True
            for index, char in enumerate(value):
                if char == "(":
                    depth += 1
                elif char == ")":
                    depth -= 1
                    if depth == 0 and index != len(value) - 1:
                        enclosed = False
                        break
            if not enclosed or depth != 0:
                break
            value = value[1:-1].strip()

        literal = re.fullmatch(
            r"(?P<width>\d+)\s*'\s*(?P<signed>s)?(?P<base>[bodhBODH])"
            r"(?P<digits>[0-9a-fA-F_xXzZ?]+)",
            value,
        )
        if literal is not None:
            width = int(literal.group("width"))
            digits = literal.group("digits").replace("_", "")
            if width <= 0 or width > 4096:
                return None
            if any(char in digits.lower() for char in "xz?"):
                integer = 0
            else:
                base = {"b": 2, "o": 8, "d": 10, "h": 16}[literal.group("base").lower()]
                integer = int(digits, base)
            return integer & ((1 << width) - 1), width

        unsized_bit = re.fullmatch(r"'(?P<bit>[01])", value)
        if unsized_bit is not None:
            return int(unsized_bit.group("bit")), 1

        if not enclosing_braces(value):
            return None
        body = value[1:-1].strip()
        parts = split_top_level(body)
        if len(parts) > 1:
            result = 0
            width = 0
            for part in parts:
                parsed = parse(part)
                if parsed is None:
                    return None
                part_value, part_width = parsed
                result = (result << part_width) | part_value
                width += part_width
                if width > 4096:
                    return None
            return result, width

        if "{" not in body or enclosing_braces(body):
            return parse(body)

        depth = 0
        repeat_open = None
        for index, char in enumerate(body):
            if char == "{":
                if depth == 0:
                    repeat_open = index
                    break
                depth += 1
        if repeat_open is None or not body.endswith("}"):
            return None
        count_expr = body[:repeat_open].strip()
        count = _constant_integer_expr(_cpp_expr(count_expr))
        repeated = parse(body[repeat_open:])
        if count is None or count < 0 or count > 4096 or repeated is None:
            return None
        repeated_value, repeated_width = repeated
        if repeated_width * count > 4096:
            return None
        result = 0
        for _ in range(count):
            result = (result << repeated_width) | repeated_value
        return result, repeated_width * count

    parsed = parse(expr)
    return None if parsed is None else parsed[0]


def _width_expr(width: WidthIR | None) -> str:
    if width is None:
        return "1"
    msb = _cpp_expr(width.msb)
    lsb = _cpp_expr(width.lsb)
    concrete_msb = _constant_integer_expr(msb)
    concrete_lsb = _constant_integer_expr(lsb)
    if concrete_msb is not None and concrete_lsb is not None:
        return str(abs(concrete_msb - concrete_lsb) + 1)
    return (
        f"((({msb}) >= ({lsb})) ? "
        f"(({msb}) - ({lsb}) + 1) : "
        f"(({lsb}) - ({msb}) + 1))"
    )


def _constant_integer_expr(expr: str) -> int | None:
    """Evaluate a name-free C++ integer expression without using eval()."""
    try:
        node = ast.parse(expr, mode="eval").body
    except (SyntaxError, ValueError):
        return None

    def evaluate(current: ast.AST) -> int:
        if isinstance(current, ast.Constant) and isinstance(current.value, int):
            return current.value
        if isinstance(current, ast.UnaryOp):
            operand = evaluate(current.operand)
            if isinstance(current.op, ast.UAdd):
                return operand
            if isinstance(current.op, ast.USub):
                return -operand
            if isinstance(current.op, ast.Invert):
                return ~operand
            raise ValueError
        if isinstance(current, ast.BinOp):
            left = evaluate(current.left)
            right = evaluate(current.right)
            if isinstance(current.op, ast.Add):
                return left + right
            if isinstance(current.op, ast.Sub):
                return left - right
            if isinstance(current.op, ast.Mult):
                return left * right
            if isinstance(current.op, ast.Div):
                if right == 0:
                    raise ValueError
                quotient = abs(left) // abs(right)
                return -quotient if (left < 0) != (right < 0) else quotient
            if isinstance(current.op, ast.Mod):
                if right == 0:
                    raise ValueError
                quotient = abs(left) // abs(right)
                quotient = -quotient if (left < 0) != (right < 0) else quotient
                return left - quotient * right
            if isinstance(current.op, ast.LShift):
                return left << right
            if isinstance(current.op, ast.RShift):
                return left >> right
            if isinstance(current.op, ast.BitAnd):
                return left & right
            if isinstance(current.op, ast.BitOr):
                return left | right
            if isinstance(current.op, ast.BitXor):
                return left ^ right
            raise ValueError
        raise ValueError

    try:
        return evaluate(node)
    except (TypeError, ValueError, ZeroDivisionError):
        return None


def _instance_type(
    instance: InstanceIR,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
) -> str:
    base = _sanitize_identifier(instance.module)
    if not instance.parameters:
        if _child_parameter_count(instance.module, modules_by_name, signatures) > 0:
            return f"{base}<>"
        return base
    child_module = modules_by_name.get(instance.module)
    signature = signatures.get(instance.module)
    formal_parameters = (
        tuple(parameter for parameter in child_module.parameters if parameter.kind == "parameter")
        if child_module is not None
        else signature.parameters if signature is not None else ()
    )
    named = {argument.name: argument.value for argument in instance.parameters if argument.name}
    if named and formal_parameters:
        last_override = max(
            index
            for index, parameter in enumerate(formal_parameters)
            if parameter.name in named
        )
        ordered_values = [
            named.get(parameter.name, parameter.value)
            for parameter in formal_parameters[: last_override + 1]
        ]
        args = ", ".join(_cpp_expr(value) for value in ordered_values)
    else:
        args = ", ".join(_cpp_expr(arg.value) for arg in instance.parameters)
    return f"{base}<{args}>"


def _child_parameter_count(
    module_name: str,
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
) -> int:
    child_module = modules_by_name.get(module_name)
    if child_module is not None:
        return sum(parameter.kind == "parameter" for parameter in child_module.parameters)
    signature = signatures.get(module_name)
    if signature is not None:
        return len(signature.parameters)
    return 0


def _generate_for_count_expr(generate_for: GenerateForIR) -> str:
    condition = _strip_outer_parens(generate_for.condition)
    match = re.fullmatch(
        rf"{re.escape(generate_for.var)}\s*<\s*(?P<limit>[A-Za-z_][A-Za-z0-9_]*|\d+)",
        condition,
    )
    if match and _is_zero_init(generate_for) and _is_increment_by_one(generate_for):
        return _cpp_expr(match.group("limit"))
    return f"/* unsupported generate count: {generate_for.condition} */ 0"


def _strip_outer_parens(expr: str) -> str:
    stripped = expr.strip()
    while stripped.startswith("(") and stripped.endswith(")"):
        depth = 0
        balanced_outer = True
        for index, char in enumerate(stripped):
            if char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
                if depth == 0 and index != len(stripped) - 1:
                    balanced_outer = False
                    break
        if not balanced_outer:
            break
        stripped = stripped[1:-1].strip()
    return stripped


def _is_zero_init(generate_for: GenerateForIR) -> bool:
    return re.fullmatch(rf"{re.escape(generate_for.var)}\s*=\s*0", generate_for.init) is not None


def _is_increment_by_one(generate_for: GenerateForIR) -> bool:
    return re.fullmatch(
        rf"{re.escape(generate_for.var)}\s*=\s*\({re.escape(generate_for.var)}\s*\+\s*1\)",
        generate_for.step,
    ) is not None


def _cpp_lvalue(expr: str) -> str:
    return _sanitize_identifier(expr)


def _cpp_rvalue(expr: str) -> str:
    rendered = _cpp_expr(expr)
    for name in sorted(_identifiers(expr), key=len, reverse=True):
        rendered = re.sub(rf"\b{re.escape(name)}\b", f"{_sanitize_identifier(name)}.read()", rendered)
    return rendered


def _cpp_expr(expr: str) -> str:
    rendered = _convert_verilog_constants(expr)
    previous = None
    while previous != rendered:
        previous = rendered
        rendered = re.sub(
            r"\{\s*([^,{}]+)\s*\}",
            lambda match: (
                match.group(0)
                if re.match(r"^[A-Za-z_][A-Za-z0-9_$]*\s*\(", match.group(1).strip())
                else f"({match.group(1)})"
            ),
            rendered,
        )
    return re.sub(r"\$clog2\s*\(", "prism_v2sc_clog2(", rendered)


def _cpp_string_literal(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _cpp_binding_expr(expr: str, loop_var: str | None = None) -> str:
    match = re.fullmatch(r"(?P<name>[A-Za-z_][A-Za-z0-9_$]*)\[(?P<index>[A-Za-z_][A-Za-z0-9_$]*|\d+)\]", expr)
    if match:
        name = _sanitize_identifier(match.group("name"))
        index = match.group("index")
        if loop_var is not None and index == loop_var:
            return f"{name}[{loop_var}]"
        return f"{name}[{_sanitize_identifier(index)}]" if not index.isdecimal() else f"{name}[{index}]"
    return _sanitize_identifier(expr)


def _bit_select_binding(expr: str, loop_var: str) -> tuple[str, str] | None:
    match = re.fullmatch(
        r"(?P<name>[A-Za-z_][A-Za-z0-9_$]*)\[(?P<index>[A-Za-z_][A-Za-z0-9_$]*|\d+)\]",
        expr,
    )
    if match is None or match.group("index") != loop_var:
        return None
    return match.group("name"), match.group("index")


def _constant_bit_select_binding(expr: str) -> tuple[str, str] | None:
    match = re.fullmatch(
        r"(?P<name>[A-Za-z_][A-Za-z0-9_$]*)\[(?P<index>[A-Za-z_][A-Za-z0-9_$]*|\d+)\]",
        expr,
    )
    if match is None:
        return None
    return match.group("name"), match.group("index")


def _convert_verilog_constants(expr: str) -> str:
    def replace_sized(match: re.Match[str]) -> str:
        base = match.group("base").lower()
        value = match.group("value").replace("_", "")
        if any(char in value.lower() for char in "xz?"):
            return "0"
        if base == "h":
            return f"0x{value}"
        if base == "b":
            return f"0b{value}"
        if base == "o":
            return f"0{value}"
        return value

    def replace_unsized(match: re.Match[str]) -> str:
        base = match.group("base").lower()
        value = match.group("value").replace("_", "")
        if any(char in value.lower() for char in "xz?"):
            return "0"
        if base == "h":
            return f"0x{value}"
        if base == "b":
            return f"0b{value}"
        if base == "o":
            return f"0{value}"
        return value

    rendered = re.sub(
        r"\b\d+'\s*(?P<base>[bodhBODH])(?P<value>[0-9a-fA-F_xXzZ?]+)",
        replace_sized,
        expr,
    )
    rendered = re.sub(
        r"'\s*(?P<base>[bodhBODH])(?P<value>[0-9a-fA-F_xXzZ?]+)",
        replace_unsized,
        rendered,
    )
    rendered = re.sub(
        r"(?<![A-Za-z0-9_$])0(?P<digits>[0-9][0-9_]*)(?![A-Za-z0-9_$])",
        lambda match: str(int(match.group("digits").replace("_", ""), 10)),
        rendered,
    )
    return rendered


def _systemc_edge(edge: str) -> str:
    if edge == "negedge":
        return "neg"
    return "pos"


def _identifiers(expr: str) -> list[str]:
    tokens = re.findall(r"\b[A-Za-z_][A-Za-z0-9_$]*\b", expr)
    return _dedupe(
        [
            token
            for token in tokens
            if token not in {
                "sc_uint",
                "sc_int",
                "sc_biguint",
                "sc_bigint",
                "prism_v2sc_clog2",
            }
        ]
    )


def _dedupe(items: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for item in items:
        clean = _sanitize_identifier(item)
        if clean not in seen:
            seen.add(clean)
            result.append(clean)
    return result


def _dedupe_preserve(items: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for item in items:
        if item not in seen:
            seen.add(item)
            result.append(item)
    return result


def _sanitize_identifier(name: str) -> str:
    cleaned = re.sub(r"\W", "_", name)
    if not cleaned:
        return "unnamed"
    if cleaned[0].isdigit():
        return f"_{cleaned}"
    return cleaned
