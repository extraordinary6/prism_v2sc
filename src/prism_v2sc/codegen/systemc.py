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

from dataclasses import dataclass, replace
from pathlib import Path
import os
import re

from prism_v2sc.ir.model import (
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
    infer_width,
    lvalue_base_name,
    render_lvalue,
    render_rvalue,
    sanitize_identifier,
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


@dataclass(frozen=True)
class DirectOutputAssembler:
    """One method per parent signal that gathers every output bit-bridge
    targeting it. Multiple output ``DirectBitBridge`` instances pointing at
    the same parent must share a single writer process — sc_signal allows
    only one driver, so emitting per-bridge methods would abort at runtime
    with ``SC_ID_MORE_THAN_ONE_SIGNAL_DRIVER_``.
    """

    parent_name: str
    method_name: str
    bridges: tuple[DirectBitBridge, ...]


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


def _direct_output_assemblers(
    direct_bit_bridges: list[DirectBitBridge],
) -> list[DirectOutputAssembler]:
    grouped: dict[str, list[DirectBitBridge]] = {}
    order: list[str] = []
    for bridge in direct_bit_bridges:
        if bridge.direction not in {"output", "inout"}:
            continue
        if bridge.parent_name not in grouped:
            grouped[bridge.parent_name] = []
            order.append(bridge.parent_name)
        grouped[bridge.parent_name].append(bridge)
    return [
        DirectOutputAssembler(
            parent_name=parent,
            method_name=f"__bridge_assemble_{parent}",
            bridges=tuple(grouped[parent]),
        )
        for parent in order
    ]


def _classify_lvalue_slot(lvalue: object) -> tuple[str, int, int] | None:
    """Return ``(parent_name, msb, lsb)`` for a constant-indexed bit/part
    select lvalue. ``msb == lsb`` for a single bit. Returns ``None`` for
    whole-signal writes, dynamic indices, or non-identifier targets.
    """
    if not isinstance(lvalue, dict):
        return None
    kind = lvalue.get("kind")
    if kind == "bitselect":
        target = lvalue.get("target")
        if not isinstance(target, dict) or target.get("kind") != "identifier":
            return None
        idx = lvalue.get("index")
        if not isinstance(idx, dict) or idx.get("kind") != "intconst":
            return None
        value = idx.get("value")
        if not isinstance(value, int):
            return None
        return (str(target.get("name", "")), value, value)
    if kind == "partselect":
        target = lvalue.get("target")
        if not isinstance(target, dict) or target.get("kind") != "identifier":
            return None
        msb_node = lvalue.get("msb")
        lsb_node = lvalue.get("lsb")
        if not isinstance(msb_node, dict) or msb_node.get("kind") != "intconst":
            return None
        if not isinstance(lsb_node, dict) or lsb_node.get("kind") != "intconst":
            return None
        msb = msb_node.get("value")
        lsb = lsb_node.get("value")
        if not isinstance(msb, int) or not isinstance(lsb, int):
            return None
        return (str(target.get("name", "")), msb, lsb)
    return None


def _walk_process_assignments(statement: object, sink: list) -> None:
    """Yield every assignment dict reachable from ``statement``."""
    if not isinstance(statement, dict):
        return
    kind = statement.get("type")
    if kind in {"blocking_assign", "nonblocking_assign"}:
        sink.append(statement)
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


def _aggregate_multi_writer_processes(
    module: ModuleIR,
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
    per_process: list[list[tuple[dict, tuple[str, int, int] | None]]] = []
    for process in module.processes:
        sink: list = []
        for statement in process.structured_statements:
            _walk_process_assignments(statement, sink)
        per_process.append([(stmt, _classify_lvalue_slot(stmt.get("left_expr"))) for stmt in sink])

    # Signals declared as unpacked arrays already render as per-cell
    # ``mem[i].write(...)``, so the parent multi-writer aggregation logic
    # below mustn't try to shadow-rewrite them — they're not vector
    # bit/part selects.
    array_signal_names = {signal.name for signal in module.signals if signal.unpacked_dims}

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
            if parent in array_signal_names:
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
        if len(by_proc) < 2:
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
                shadow_name = f"__shadow_{parent}_{slot_id}"
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
        assemblers.append(
            ProcessSliceAssembler(
                parent_name=parent,
                method_name=f"__assemble_{parent}",
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
    writer.line("#include <systemc>")
    writer.line("#include <string>")
    if instrumentation_config is not None and instrumentation_config.enabled:
        writer.line("#include <cstdint>")
        writer.line("#include <ostream>")
    writer.line()
    writer.line("using namespace sc_core;")
    writer.line("using namespace sc_dt;")
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
) -> list[Path]:
    """Write one ``.hpp`` per module under ``out_dir``, mirroring RTL layout.

    Each file ``#include``s the hpps of every child module it instantiates,
    using a path relative to its own directory. Returns the absolute paths
    of every written file, in emit (post-order) sequence.
    """
    sigs = dict(signatures) if signatures is not None else _signatures_from_design(design)
    modules_by_name = {module.name: module for module in design.modules}

    written: list[Path] = []
    for module in _dependency_order(list(design.modules)):
        target = render_module_file(
            module,
            modules_by_name,
            sigs,
            out_dir,
            source_root,
            instrumentation_config=instrumentation_config,
        )
        path = _module_output_path(module, out_dir, source_root)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(target, encoding="utf-8")
        written.append(path)
    return written


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
    writer = CodeWriter()
    guard = f"PRISM_V2SC_MOD_{_sanitize_identifier(module.name).upper()}_HPP"
    writer.line(banner().rstrip())
    writer.line("#pragma once")
    writer.line()
    writer.line("#include <systemc>")
    writer.line("#include <string>")
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
    writer.line(f"#ifndef {guard}")
    writer.line(f"#define {guard}")
    writer.line()

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
            parameters=module.parameters,
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
) -> None:
    class_name = _sanitize_identifier(module.name)
    # Rewrite per-process bit/part writes that share a parent signal so the
    # generated SystemC has exactly one writer per signal. Must run before
    # ``build_module_context`` so the new shadow signals end up in
    # ``ctx.signal_widths``.
    module, process_assemblers = _aggregate_multi_writer_processes(module)
    resolved_names = _resolved_signal_names(module, modules_by_name, signatures)
    ctx = build_module_context(module, resolved_names=frozenset(resolved_names))
    bit_bridges = _generate_bit_bridges(module, modules_by_name, signatures)
    direct_bit_bridges = _direct_bit_bridges(module, modules_by_name, signatures)
    module_instrumentation = _module_instrumentation_config(module, instrumentation_config)
    module_needs_power_sample_strobe = _module_subtree_needs_power_sample_strobe(
        module,
        modules_by_name,
        instrumentation_config,
    )
    if module.parameters:
        template_params = ", ".join(
            f"int {_sanitize_identifier(parameter.name)} = {_cpp_expr(parameter.value)}"
            for parameter in module.parameters
        )
        writer.line(f"template <{template_params}>")
    writer.line(f"SC_MODULE({class_name}) {{")
    writer.indent()

    for port in module.ports:
        writer.line(f"{_port_type(port)} {_sanitize_identifier(port.name)};")
    if module_needs_power_sample_strobe:
        writer.line("sc_in<bool> __power_sample_strobe;")
    if module.ports:
        writer.line()

    for signal in module.signals:
        suffix = "".join(
            f"[{max(msb, lsb) - min(msb, lsb) + 1}]" for msb, lsb in signal.unpacked_dims
        )
        writer.line(
            f"{_signal_type(signal, resolved=signal.name in resolved_names)} "
            f"{_sanitize_identifier(signal.name)}{suffix};"
        )
    if module.signals:
        writer.line()

    for instance in module.instances:
        writer.line(f"{_instance_type(instance)} {_sanitize_identifier(instance.name)};")
    for generate_for in module.generate_fors:
        for instance in generate_for.instances:
            writer.line(
                f"sc_vector<{_instance_type(instance)}> "
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
        else:
            writer.line(f"sc_signal<bool> {bridge.name};")
    if module.instances or module.generate_fors:
        writer.line()

    for declaration in generate_instrumentation_declarations(module_instrumentation):
        writer.line(declaration)
    if module_instrumentation.enabled:
        writer.line()

    methods = _method_specs(module, ctx)
    for subroutine in module.subroutines:
        _emit_subroutine(writer, subroutine, ctx)
    for method_name, body_lines in methods:
        writer.line(f"void {method_name}() {{")
        writer.indent()
        for body_line in body_lines:
            writer.line(body_line)
        writer.dedent()
        writer.line("}")
        writer.line()

    for bridge in bit_bridges:
        _emit_bridge_method(writer, bridge)
        writer.line()
    for bridge in direct_bit_bridges:
        if bridge.direction in {"input", "inout"}:
            _emit_direct_bridge_method(writer, bridge)
            writer.line()
    for assembler in _direct_output_assemblers(direct_bit_bridges):
        _emit_direct_output_assembler(writer, assembler)
        writer.line()
    for assembler in process_assemblers:
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

    _emit_constructor(
        writer,
        module,
        ctx,
        methods,
        bit_bridges,
        direct_bit_bridges,
        process_assemblers,
        modules_by_name,
        signatures,
        instrumentation_config,
        module_instrumentation,
        power_sampling_processes,
    )
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
    process_assemblers: list[ProcessSliceAssembler],
    modules_by_name: dict[str, ModuleIR],
    signatures: dict[str, ModuleSignature],
    root_instrumentation_config: InstrumentationConfig | None,
    instrumentation_config: InstrumentationConfig,
    power_sampling_processes: list,
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
    if init_list:
        writer.line(f"SC_CTOR({class_name})")
        writer.indent()
        writer.line(": " + ", ".join(init_list))
        writer.dedent()
        writer.line("{")
    else:
        writer.line(f"SC_CTOR({class_name}) {{")
    writer.indent()

    for init_line in generate_instrumentation_init(instrumentation_config):
        writer.line(init_line)
    if instrumentation_config.enabled:
        writer.line()

    for method_name, _body_lines in methods:
        writer.line(f"SC_METHOD({method_name});")
        sensitivity = _method_sensitivity(module, method_name, ctx)
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

    for bridge in direct_bit_bridges:
        if bridge.direction not in {"input", "inout"}:
            continue
        writer.line(f"SC_METHOD({bridge.method_name});")
        writer.line(f"sensitive << {bridge.parent_name};")
        writer.line()

    for assembler in _direct_output_assemblers(direct_bit_bridges):
        writer.line(f"SC_METHOD({assembler.method_name});")
        sensitivities = "".join(f" << {bridge.name}" for bridge in assembler.bridges)
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
    signatures: dict[str, ModuleSignature],
    loop_var: str | None = None,
    bit_bridge_by_port: dict[str, str] | None = None,
    direct_bridge_by_port: dict[str, str] | None = None,
    bind_power_sample_strobe: bool = False,
) -> None:
    """Emit ``inst.<port>(<value>);`` lines, resolving positional via signature."""
    resolved_ports = _resolve_instance_ports(instance, signatures)
    for port_name, value in resolved_ports:
        if not port_name:
            writer.line(f"// Positional port binding not emitted for {instance.name}: {value}")
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
    """Return [(port_name, arg_value), ...] for an instance.

    Named bindings keep their name as-is. Positional bindings (empty name)
    are resolved against the child's signature when available, recovering
    the port name from its position.
    """
    if not instance.ports:
        return []
    has_positional = any(not port.name for port in instance.ports)
    if not has_positional:
        return [(port.name, port.value) for port in instance.ports]

    signature = signatures.get(instance.module)
    if signature is None or not signature.ports:
        # No signature available: keep the placeholder behavior (empty name).
        return [(port.name, port.value) for port in instance.ports]

    resolved: list[tuple[str, str]] = []
    sig_ports = signature.ports
    for index, port in enumerate(instance.ports):
        if port.name:
            resolved.append((port.name, port.value))
            continue
        if index < len(sig_ports):
            resolved.append((sig_ports[index].name, port.value))
        else:
            resolved.append(("", port.value))
    return resolved


def _method_specs(module: ModuleIR, ctx: ModuleContext) -> list[tuple[str, list[str]]]:
    specs: list[tuple[str, list[str]]] = []
    for index, assign in enumerate(module.continuous_assigns):
        specs.append((f"assign_{index}", [_emit_continuous_assign(assign, ctx)]))

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


def _emit_bridge_method(writer: CodeWriter, bridge: GenerateBitBridge) -> None:
    writer.line(f"void {bridge.method_name}() {{")
    writer.indent()
    if bridge.direction == "input":
        writer.line(f"for (int i = 0; i < {bridge.count_expr}; ++i) {{")
        writer.indent()
        writer.line(f"{bridge.name}[i].write({bridge.parent_name}.read()[i]);")
        writer.dedent()
        writer.line("}")
    elif bridge.direction == "inout":
        writer.line(f"for (int i = 0; i < {bridge.count_expr}; ++i) {{")
        writer.indent()
        writer.line(f"{bridge.name}[i].write(sc_lv<1>({bridge.parent_name}.read()[i]));")
        writer.dedent()
        writer.line("}")
        writer.line(f"auto __tmp = {bridge.parent_name}.read();")
        writer.line(f"for (int i = 0; i < {bridge.count_expr}; ++i) {{")
        writer.indent()
        writer.line(f"__tmp[i] = {bridge.name}[i].read()[0];")
        writer.dedent()
        writer.line("}")
        writer.line(f"{bridge.parent_name}.write(__tmp);")
    else:
        writer.line(f"auto __tmp = {bridge.parent_name}.read();")
        writer.line(f"for (int i = 0; i < {bridge.count_expr}; ++i) {{")
        writer.indent()
        writer.line(f"__tmp[i] = {bridge.name}[i].read();")
        writer.dedent()
        writer.line("}")
        writer.line(f"{bridge.parent_name}.write(__tmp);")
    writer.dedent()
    writer.line("}")


def _emit_direct_bridge_method(writer: CodeWriter, bridge: DirectBitBridge) -> None:
    writer.line(f"void {bridge.method_name}() {{")
    writer.indent()
    if bridge.direction == "input":
        writer.line(f"{bridge.name}.write({bridge.parent_name}.read()[{bridge.index_expr}]);")
    elif bridge.direction == "inout":
        writer.line(
            f"{bridge.name}.write(sc_lv<1>({bridge.parent_name}.read()[{bridge.index_expr}]));"
        )
    else:
        writer.line(f"auto __tmp = {bridge.parent_name}.read();")
        writer.line(f"__tmp[{bridge.index_expr}] = {bridge.name}.read();")
        writer.line(f"{bridge.parent_name}.write(__tmp);")
    writer.dedent()
    writer.line("}")


def _emit_direct_output_assembler(writer: CodeWriter, assembler: DirectOutputAssembler) -> None:
    writer.line(f"void {assembler.method_name}() {{")
    writer.indent()
    writer.line(f"auto __tmp = {assembler.parent_name}.read();")
    for bridge in assembler.bridges:
        if bridge.direction == "inout":
            writer.line(f"__tmp[{bridge.index_expr}] = {bridge.name}.read()[0];")
        else:
            writer.line(f"__tmp[{bridge.index_expr}] = {bridge.name}.read();")
    writer.line(f"{assembler.parent_name}.write(__tmp);")
    writer.dedent()
    writer.line("}")


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
) -> list[DirectBitBridge]:
    bridges: list[DirectBitBridge] = []
    for instance in module.instances:
        child_ports = _child_ports_lookup(instance.module, modules_by_name, signatures)
        if not child_ports:
            continue
        for port in instance.ports:
            match = _constant_bit_select_binding(port.value)
            if match is None:
                continue
            child_port = child_ports.get(port.name)
            if child_port is None or child_port.direction not in {"input", "output", "inout"}:
                continue
            parent_name, index_expr = match
            base = f"{_sanitize_identifier(instance.name)}_{_sanitize_identifier(port.name)}"
            bridges.append(
                DirectBitBridge(
                    name=f"__bridge_{base}",
                    method_name=f"__bridge_method_{base}",
                    parent_name=_sanitize_identifier(parent_name),
                    index_expr=_sanitize_identifier(index_expr) if not index_expr.isdecimal() else index_expr,
                    instance_name=instance.name,
                    port_name=port.name,
                    direction=child_port.direction,
                )
            )
    return bridges


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
    for key in ("parts", "args"):
        children = expr.get(key)
        if isinstance(children, list) and any(_contains_xz_literal(child) for child in children):
            return True
    return False


def _method_sensitivity(module: ModuleIR, method_name: str, ctx: ModuleContext) -> list[str]:
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
        return [
            f"{_sanitize_identifier(item.signal)}.{_systemc_edge(item.edge)}()"
            for item in process.sensitivity
            if item.edge in {"posedge", "negedge"}
        ]

    return []


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

    body_ctx = ctx.with_locals(frozenset(local_names))
    writer.line(f"{return_type} {func_name}({', '.join(formal_params)}) const {{")
    writer.indent()
    writer.line(f"{return_type} {func_name};")
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
    for statement in process.structured_statements:
        lines.extend(_emit_structured_statement(statement, indent_level=0, ctx=ctx, staged_names=staged_names))
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
) -> list[str]:
    prefix = "  " * indent_level
    kind = statement.get("type")

    if kind in {"blocking_assign", "nonblocking_assign"}:
        return [prefix + _emit_tree_assignment(statement, ctx, staged_names)]

    if kind == "return":
        value_expr = statement.get("value_expr")
        if value_expr is None:
            return [f"{prefix}return;"]
        value_cpp = render_rvalue(value_expr, ctx, staged_names=staged_names)
        return [f"{prefix}return {value_cpp};"]

    if kind == "if":
        cond_text = _render_cond(statement, ctx, staged_names=staged_names)
        lines = [f"{prefix}if ({cond_text}) {{"]
        for child in _as_statement_list(statement.get("true")):
            lines.extend(_emit_structured_statement(child, indent_level + 1, ctx=ctx, staged_names=staged_names))
        false_branch = _as_statement_list(statement.get("false"))
        if false_branch:
            lines.append(f"{prefix}}} else {{")
            for child in false_branch:
                lines.extend(_emit_structured_statement(child, indent_level + 1, ctx=ctx, staged_names=staged_names))
        lines.append(f"{prefix}}}")
        return lines

    if kind == "case":
        return _emit_case_statement(statement, indent_level, ctx=ctx, staged_names=staged_names)

    if kind == "block":
        # Unrolled for loops and other compound statements produce blocks
        lines = []
        for child in _as_statement_list(statement.get("statements")):
            lines.extend(_emit_structured_statement(child, indent_level, ctx=ctx, staged_names=staged_names))
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
) -> list[str]:
    case_kind = str(statement.get("case_kind", "case"))
    if case_kind in {"casez", "casex"}:
        return _emit_wildcard_case_statement(
            statement, indent_level, ctx=ctx, staged_names=staged_names, case_kind=case_kind
        )
    prefix = "  " * indent_level
    expr_tree = statement.get("expr_tree")
    if isinstance(expr_tree, dict):
        expr = render_rvalue(expr_tree, ctx, staged_names=staged_names)
    else:
        expr = _cpp_rvalue(str(statement.get("expr", "")))
    lines = [f"{prefix}switch ({expr}) {{"]
    for item in _as_case_items(statement.get("items")):
        cond_exprs = item.get("cond_exprs")
        if isinstance(cond_exprs, list) and cond_exprs:
            for cond_expr in cond_exprs:
                if isinstance(cond_expr, dict):
                    lines.append(f"{prefix}case {_render_case_label(cond_expr, ctx, staged_names=staged_names)}:")
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
            lines.extend(_emit_structured_statement(child, indent_level + 1, ctx=ctx, staged_names=staged_names))
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
    expr_tree = statement.get("expr_tree")
    if isinstance(expr_tree, dict):
        sel_text = render_rvalue(expr_tree, ctx, staged_names=staged_names)
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
                terms.append(f"(__sel == {render_rvalue(cond_expr, ctx, staged_names=staged_names)})")
                continue
            mask, match, _width = spec
            terms.append(f"((__sel & {hex(mask)}) == {hex(match)})")
        condition = " || ".join(terms) if terms else "false"
        keyword = "if" if first else "else if"
        lines.append(f"{prefix}  {keyword} ({condition}) {{")
        for child in _as_statement_list(item.get("statements")):
            lines.extend(_emit_structured_statement(child, indent_level + 2, ctx=ctx, staged_names=staged_names))
        lines.append(f"{prefix}  }}")
        first = False
    if default_body is not None:
        keyword = "" if first else "else "
        if first:
            # No labeled items at all — emit the default body unconditionally.
            for child in default_body:
                lines.extend(_emit_structured_statement(child, indent_level + 1, ctx=ctx, staged_names=staged_names))
        else:
            lines.append(f"{prefix}  {keyword}{{".rstrip())
            for child in default_body:
                lines.extend(_emit_structured_statement(child, indent_level + 2, ctx=ctx, staged_names=staged_names))
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
) -> str:
    left_expr = statement.get("left_expr")
    right_expr = statement.get("right_expr")
    if isinstance(right_expr, dict):
        rhs = render_rvalue(right_expr, ctx, staged_names=staged_names)
    else:
        rhs = _cpp_rvalue(str(statement.get("right", "")))

    if isinstance(left_expr, dict):
        # Array-cell write (``mem[idx] <= val``): each cell is its own
        # sc_signal, so emit ``mem[idx].write(val);`` directly. The
        # surrounding process doesn't stage these — SystemC's delta-cycle
        # semantics already give nonblocking behavior per cell.
        if left_expr.get("kind") == "bitselect":
            target = left_expr.get("target")
            if (
                isinstance(target, dict)
                and target.get("kind") == "identifier"
                and str(target.get("name", "")) in ctx.array_signal_names
            ):
                target_name = sanitize_identifier(str(target["name"]))
                idx = render_rvalue(left_expr.get("index"), ctx, staged_names=staged_names)
                return f"{target_name}[{idx}].write({rhs});"
        base = lvalue_base_name(left_expr)
        if base in staged_names:
            lhs = render_lvalue(left_expr, ctx, staged_names=staged_names)
            return f"{lhs} = {rhs};"
        if base in ctx.local_names:
            lhs = render_lvalue(left_expr, ctx)
            return f"{lhs} = {rhs};"
        if left_expr.get("kind") == "identifier":
            return f"{render_lvalue(left_expr, ctx)}.write({rhs});"
        return f"// unsupported lvalue without staging: {statement.get('left', '')}"

    return _emit_legacy_assignment(str(statement.get("left", "")), rhs, rhs_already_cpp=True)


def _emit_continuous_assign(assign: ContinuousAssignIR, ctx: ModuleContext) -> str:
    if assign.right_expr is not None:
        rhs = render_rvalue(assign.right_expr, ctx)
    else:
        rhs = _cpp_rvalue(assign.right)
    if assign.left_expr is not None and assign.left_expr.get("kind") == "identifier":
        base = lvalue_base_name(assign.left_expr)
        if base in ctx.resolved_names:
            width = max(1, ctx.signal_widths.get(base, 1))
            return (
                f"{render_lvalue(assign.left_expr, ctx)}"
                f".write({_render_resolved_drive(assign.right_expr, ctx, width, fallback=rhs)});"
            )
        return f"{render_lvalue(assign.left_expr, ctx)}.write({rhs});"
    if assign.left_expr is not None and assign.left_expr.get("kind") in {"bitselect", "partselect"}:
        base = lvalue_base_name(assign.left_expr)
        if base:
            sanitized = _sanitize_identifier(base)
            lhs_target = render_lvalue(assign.left_expr, ctx, staged_names=frozenset({base}))
            return (
                f"{{ auto __tmp_{sanitized} = {sanitized}.read(); "
                f"{lhs_target.replace(f'__next_{sanitized}', f'__tmp_{sanitized}')} = {rhs}; "
                f"{sanitized}.write(__tmp_{sanitized}); }}"
            )
    return _emit_legacy_assignment(assign.left, rhs, rhs_already_cpp=True)


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


def _collect_written_base_names(process: ProcessIR, ctx: ModuleContext | None = None) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for statement in process.structured_statements:
        for base in _walk_lvalue_bases(statement):
            if not base or base in seen:
                continue
            if ctx is not None and base in ctx.array_signal_names:
                # Array-cell writes route through ``mem[i].write(...)``
                # directly; no whole-array staging needed.
                continue
            seen.add(base)
            ordered.append(base)
    return ordered


def _walk_lvalue_bases(statement: dict[str, object]) -> list[str]:
    kind = statement.get("type")
    if kind in {"blocking_assign", "nonblocking_assign"}:
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
            names.extend(_walk_lvalue_bases(child))
        for child in _as_statement_list(statement.get("false")):
            names.extend(_walk_lvalue_bases(child))
        return names
    if kind == "case":
        names = []
        for item in _as_case_items(statement.get("items")):
            for child in _as_statement_list(item.get("statements")):
                names.extend(_walk_lvalue_bases(child))
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


def _sc_type(width: WidthIR | None, signed: bool) -> str:
    width_expr = _width_expr(width)
    if width_expr == "1" and not signed:
        return "bool"
    return f"sc_{'int' if signed else 'uint'}<{width_expr}>"


def _width_expr(width: WidthIR | None) -> str:
    if width is None:
        return "1"
    msb = _cpp_expr(width.msb)
    lsb = _cpp_expr(width.lsb)
    if msb.isdecimal() and lsb.isdecimal():
        return str(abs(int(msb) - int(lsb)) + 1)
    return f"(({msb}) - ({lsb}) + 1)"


def _instance_type(instance: InstanceIR) -> str:
    base = _sanitize_identifier(instance.module)
    if not instance.parameters:
        return base
    args = ", ".join(_cpp_expr(arg.value) for arg in instance.parameters)
    return f"{base}<{args}>"


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
    return _convert_verilog_constants(expr)


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
    return rendered


def _systemc_edge(edge: str) -> str:
    if edge == "negedge":
        return "neg"
    return "pos"


def _identifiers(expr: str) -> list[str]:
    tokens = re.findall(r"\b[A-Za-z_][A-Za-z0-9_$]*\b", expr)
    return _dedupe([token for token in tokens if token not in {"sc_uint", "sc_int"}])


def _dedupe(items: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for item in items:
        clean = _sanitize_identifier(item)
        if clean not in seen:
            seen.add(clean)
            result.append(clean)
    return result


def _sanitize_identifier(name: str) -> str:
    cleaned = re.sub(r"\W", "_", name)
    if not cleaned:
        return "unnamed"
    if cleaned[0].isdigit():
        return f"_{cleaned}"
    return cleaned
