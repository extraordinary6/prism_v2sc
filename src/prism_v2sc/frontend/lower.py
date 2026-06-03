"""Lower a slang ``Compilation`` into the Phase 1 structural IR.

Companion of :mod:`prism_v2sc.frontend.pyslang_parser`. slang has already
elaborated the design before we walk it: parameter overrides have been
applied, generate-if has been folded, generate-for has been unrolled, and
port widths are concrete integers.

This is the **synthesizable** SystemVerilog lowering. Dynamic SV constructs
(classes, randomization, programs, runtime assertions/properties) are out
of scope; they surface as diagnostics rather than getting partially
lowered.

generate-for is fully unrolled by slang and therefore materialized as
concrete ``InstanceIR`` entries inside the parent module rather than as a
separate ``GenerateForIR``.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any

from prism_v2sc.analysis.drivers import analyze_process_drivers
from prism_v2sc.ir.model import (
    ArgIR,
    ContinuousAssignIR,
    DesignIR,
    DiagnosticIR,
    EnumValueIR,
    InstanceIR,
    ModuleIR,
    ModuleSignature,
    ParameterIR,
    PackedFieldIR,
    PortIR,
    ProcessIR,
    SensitivityIR,
    SignalIR,
    SubroutineIR,
    SubroutineParamIR,
    TypeAliasIR,
    WidthIR,
)


_SIZED_LITERAL = re.compile(
    r"^(?P<size>\d+)?\s*'\s*(?P<base>[bodhBODH])(?P<digits>[0-9a-fA-F_xXzZ?]+)$"
)
_UNSIZED_LITERAL = re.compile(
    r"^'\s*(?P<base>[bodhBODH])(?P<digits>[0-9a-fA-F_xXzZ?]+)$"
)
_BASE_MAP = {"b": 2, "o": 8, "d": 10, "h": 16}


# Per-iteration genvar substitutions for unrolled generate-for blocks.
# slang resolves each iteration's genvar to a distinct ParameterSymbol with a
# constant value; we push that ``{name: "<integer text>"}`` mapping onto this
# stack while walking the iteration so ``_render_expression`` /
# ``_lower_expression`` can replace ``NamedValue`` references to that genvar
# with its concrete value (e.g. ``a[i]`` -> ``a[0]`` in iteration 0). We key
# by name rather than ``id(symbol)`` because pybind11 returns a fresh Python
# wrapper for each ``expr.symbol`` access, so object identity is not stable.
_genvar_subst_stack: list[dict[str, str]] = []


def _lookup_genvar_subst(symbol: Any) -> str | None:
    """Return the integer text bound to ``symbol`` by an enclosing block, if any."""
    if symbol is None or not _genvar_subst_stack:
        return None
    name = getattr(symbol, "name", "")
    if not name:
        return None
    for frame in reversed(_genvar_subst_stack):
        if name in frame:
            return frame[name]
    return None


def _collect_genvar_substitutions(block: Any) -> dict[str, str]:
    """Build ``{parameter_name: integer_text}`` for an unrolled block.

    Each iteration of a slang generate-for owns a per-iteration
    ``ParameterSymbol`` whose ``value`` is the genvar's elaborated constant
    integer. We collect those so expressions referencing the genvar render
    its value instead of its name.
    """
    subst: dict[str, str] = {}
    for member in block:
        if type(member).__name__ == "ParameterSymbol":
            text = _constant_value_text(getattr(member, "value", None))
            if text:
                subst[member.name] = text
    return subst


# ---------------------------------------------------------------------------
# Top-level entry points
# ---------------------------------------------------------------------------


def lower_design(compilation: Any, top: str) -> DesignIR:
    """Lower every module reachable from ``top`` into a ``DesignIR``.

    Walks the elaborated instance tree once. Each unique definition name
    becomes one ``ModuleIR`` (the first elaborated body we encounter for
    that definition is the one we lower).
    """
    root = compilation.getRoot()
    top_instances = [ti for ti in root.topInstances if ti.definition.name == top]
    if not top_instances:
        known = ", ".join(sorted({ti.definition.name for ti in root.topInstances})) or "<none>"
        raise ValueError(f"top module '{top}' not found; top instances: {known}")

    source_manager = compilation.sourceManager
    lowered: dict[str, ModuleIR] = {}
    order: list[str] = []

    def _visit(instance: Any) -> None:
        name = instance.definition.name
        if name not in lowered:
            module = lower_module(instance, source_manager=source_manager)
            lowered[name] = module
            order.append(name)
        for child in _child_instances(instance):
            _visit(child)

    for ti in top_instances:
        _visit(ti)

    modules = tuple(lowered[name] for name in order)
    diagnostics = tuple(diagnostic for module in modules for diagnostic in module.diagnostics)
    return DesignIR(top=top, modules=modules, diagnostics=diagnostics)


def lower_module(instance: Any, *, source_manager: Any = None, source_path: str = "") -> ModuleIR:
    """Lower one elaborated ``InstanceSymbol`` into module IR.

    ``source_path`` overrides the path derived from the instance's syntax
    location; this is used by callers that already know which file the
    module came from.
    """
    name = instance.definition.name
    body = instance.body

    parameters: list[ParameterIR] = []
    ports: list[PortIR] = []
    type_aliases: list[TypeAliasIR] = []
    signals: list[SignalIR] = []
    continuous_assigns: list[ContinuousAssignIR] = []
    processes: list[ProcessIR] = []
    instances: list[InstanceIR] = []
    subroutines: list[SubroutineIR] = []
    diagnostics: list[DiagnosticIR] = []
    port_names: set[str] = set()

    for member in body:
        kind = type(member).__name__
        if kind == "ParameterSymbol":
            parameters.append(_lower_parameter(member))
        elif kind == "PortSymbol":
            port = _lower_port(member)
            ports.append(port)
            port_names.add(port.name)
        elif kind == "MultiPortSymbol":
            diagnostics.append(
                _diagnostic(name, "unsupported_multiport", "multi-ports are not supported", "PortSymbol")
            )
        elif kind == "InterfacePortSymbol":
            diagnostics.append(
                _diagnostic(name, "unsupported_interface_port", "SystemVerilog interfaces are not supported", "PortSymbol")
            )
        elif kind == "NetSymbol":
            if member.name not in port_names:
                signals.append(_lower_net(member))
        elif kind == "VariableSymbol":
            if member.name not in port_names:
                signals.append(_lower_variable(member))
        elif kind == "ContinuousAssignSymbol":
            continuous_assigns.append(_lower_continuous_assign(member))
        elif kind == "ProceduralBlockSymbol":
            process, process_diagnostics = _lower_procedural_block(member, name)
            processes.append(process)
            diagnostics.extend(process_diagnostics)
        elif kind == "InstanceSymbol":
            instances.append(_lower_instance(member))
        elif kind == "InstanceArraySymbol":
            instances.extend(_lower_instance_array(member))
        elif kind == "GenerateBlockSymbol":
            if getattr(member, "isUninstantiated", False):
                continue  # generate-if dead branch
            _walk_generate_block(
                member, name, signals, continuous_assigns, processes, instances,
                diagnostics, port_names, name_prefix=getattr(member, "name", "") or "",
            )
        elif kind == "GenerateBlockArraySymbol":
            array_name = getattr(member, "name", "") or ""
            for sub in member.entries:
                if getattr(sub, "isUninstantiated", False):
                    continue
                array_index = getattr(sub, "arrayIndex", 0)
                prefix = f"{array_name}_{array_index}" if array_name else f"_{array_index}"
                subst = _collect_genvar_substitutions(sub)
                _genvar_subst_stack.append(subst)
                try:
                    _walk_generate_block(
                        sub, name, signals, continuous_assigns, processes, instances,
                        diagnostics, port_names, name_prefix=prefix,
                    )
                finally:
                    _genvar_subst_stack.pop()
        elif kind == "SubroutineSymbol":
            subroutine, body_diagnostics = _lower_subroutine(member, name)
            if subroutine is not None:
                subroutines.append(subroutine)
            diagnostics.extend(body_diagnostics)
        elif kind == "WildcardImportSymbol":
            # Wildcard import (import pkg::*) - extract subroutines, typedefs, and parameters from package
            package_subroutines, package_aliases, package_params = _extract_from_package_import(member, name)
            subroutines.extend(package_subroutines)
            type_aliases.extend(package_aliases)
            parameters.extend(package_params)
        elif kind == "ExplicitImportSymbol":
            # Explicit import (import pkg::item) - extract specific items from package
            package_subroutines, package_aliases, package_params = _extract_from_explicit_import(member, name)
            subroutines.extend(package_subroutines)
            type_aliases.extend(package_aliases)
            parameters.extend(package_params)
        elif kind == "TypeAliasType":
            alias = _lower_type_alias(member)
            if alias is not None:
                type_aliases.append(alias)
        elif kind in {"ForwardingTypedefSymbol", "TypeParameterSymbol", "GenericClassDefSymbol", "ClassType",
                       "PropertySymbol", "SequenceSymbol", "AssertionPortSymbol",
                       "ClockingBlockSymbol", "ModportSymbol", "SpecifyBlockSymbol",
                       "EmptyMemberSymbol", "AttributeSymbol", "DefParamSymbol",
                       "DefinitionSymbol", "PackageSymbol", "ProgramSymbol"}:
            # Synthesizable typedefs and helpers slang already resolved are
            # consumed silently; non-synthesizable symbols emit a diagnostic.
            if kind in {"ClassType", "GenericClassDefSymbol", "ProgramSymbol",
                        "PropertySymbol", "SequenceSymbol", "AssertionPortSymbol"}:
                diagnostics.append(
                    _diagnostic(
                        name,
                        f"unsupported_{kind.lower()}",
                        f"non-synthesizable SystemVerilog construct '{kind}' is ignored",
                        kind,
                    )
                )

    src_path = source_path
    if not src_path and source_manager is not None:
        src_path = _resolve_source_path(instance, source_manager)

    # IR-level analyses operate purely on ProcessIR / ContinuousAssignIR
    # shape, so they're agnostic to how the IR was produced.
    diagnostics.extend(_xz_literal_diagnostics(name, processes, continuous_assigns))
    diagnostics.extend(_scheduler_approximation_diagnostics(name, processes))
    diagnostics.extend(analyze_process_drivers(name, tuple(processes)))

    return ModuleIR(
        name=name,
        parameters=tuple(parameters),
        ports=tuple(ports),
        type_aliases=tuple(type_aliases),
        signals=tuple(signals),
        continuous_assigns=tuple(continuous_assigns),
        processes=tuple(processes),
        instances=tuple(instances),
        generate_fors=(),  # slang has unrolled generate-for; entries are in `instances`.
        subroutines=tuple(subroutines),
        diagnostics=tuple(diagnostics),
        source_path=src_path,
    )


def extract_signature(instance: Any) -> ModuleSignature:
    """Build the lightweight port/parameter signature for an instance.

    Symmetric with :func:`prism_v2sc.frontend.lower.extract_signature` so
    the streaming flow can consume either frontend's output uniformly.
    """
    body = instance.body
    ports = []
    parameters = []
    for member in body:
        kind = type(member).__name__
        if kind == "PortSymbol":
            ports.append(_lower_port(member))
        elif kind == "ParameterSymbol":
            parameters.append(_lower_parameter(member))
    return ModuleSignature(
        name=instance.definition.name,
        ports=tuple(ports),
        parameters=tuple(parameters),
    )


# ---------------------------------------------------------------------------
# Symbol lowering
# ---------------------------------------------------------------------------


def _lower_parameter(parameter: Any) -> ParameterIR:
    kind = "localparam" if getattr(parameter, "isLocalParam", False) else "parameter"
    return ParameterIR(
        name=parameter.name,
        value=_parameter_initializer_text(parameter),
        kind=kind,
    )


def _lower_type_alias(symbol: Any) -> TypeAliasIR | None:
    """Lower a slang typedef / enum type into a compact IR record."""
    if type(symbol).__name__ != "TypeAliasType":
        return None

    target_type = getattr(symbol, "canonicalType", None) or getattr(symbol, "targetType", None) or getattr(symbol, "type", None)
    target_kind = type(target_type).__name__
    if bool(getattr(symbol, "isEnum", False)):
        alias_kind = "enum"
    elif target_kind == "PackedStructType":
        alias_kind = "packed_struct"
    elif target_kind == "PackedUnionType":
        alias_kind = "packed_union"
    else:
        alias_kind = "typedef"
    width = _width_from_type(target_type)
    signed = bool(getattr(target_type, "isSigned", False))
    enum_values: tuple[EnumValueIR, ...] = ()
    packed_fields: tuple[PackedFieldIR, ...] = ()
    if alias_kind == "enum":
        enum_values = _enum_values_from_type(symbol)
    elif alias_kind in {"packed_struct", "packed_union"}:
        packed_fields = _packed_fields_from_type(target_type)
    return TypeAliasIR(
        name=str(getattr(symbol, "name", "")),
        width=width,
        signed=signed,
        kind=alias_kind,
        enum_values=enum_values,
        packed_fields=packed_fields,
    )


def _packed_fields_from_type(slang_type: Any) -> tuple[PackedFieldIR, ...]:
    """Extract packed struct / union field layout from slang's symbols."""
    if slang_type is None:
        return ()
    syntax = getattr(slang_type, "syntax", None)
    fields: list[PackedFieldIR] = []
    seen: set[str] = set()
    for member_syntax in getattr(syntax, "members", ()) or ():
        for declarator in getattr(member_syntax, "declarators", ()) or ():
            name = _token_text(getattr(declarator, "name", ""))
            if not name or name in seen:
                continue
            field_symbol = _lookup_packed_field(slang_type, name)
            field_ir = _packed_field_ir(field_symbol)
            if field_ir is not None:
                fields.append(field_ir)
                seen.add(name)
    if fields:
        return tuple(fields)

    # Fallback for synthesized or syntax-less types: try the flattened member
    # iterator if the binding exposes one.
    for attr in ("members", "fields", "fieldSymbols"):
        for field_symbol in getattr(slang_type, attr, ()) or ():
            field_ir = _packed_field_ir(field_symbol)
            if field_ir is not None and field_ir.name not in seen:
                fields.append(field_ir)
                seen.add(field_ir.name)
    return tuple(fields)


def _lookup_packed_field(slang_type: Any, name: str) -> Any:
    for attr in ("lookupName", "find"):
        lookup = getattr(slang_type, attr, None)
        if not callable(lookup):
            continue
        try:
            return lookup(name)
        except Exception:
            continue
    return None


def _packed_field_ir(field_symbol: Any) -> PackedFieldIR | None:
    if field_symbol is None or type(field_symbol).__name__ != "FieldSymbol":
        return None
    field_type = getattr(field_symbol, "type", None)
    offset = _packed_field_offset(field_symbol)
    if offset is None:
        return None
    return PackedFieldIR(
        name=str(getattr(field_symbol, "name", "")),
        offset=offset,
        width=_width_from_type(field_type),
        signed=bool(getattr(field_type, "isSigned", False)),
    )


def _packed_field_offset(field_symbol: Any) -> int | None:
    offset = getattr(field_symbol, "bitOffset", None)
    if offset is None:
        return None
    try:
        return int(offset)
    except Exception:
        return None


def _bit_width_from_type(slang_type: Any) -> int:
    width = getattr(slang_type, "bitWidth", None)
    try:
        if width is not None:
            value = int(width)
            if value > 0:
                return value
    except Exception:
        pass
    width_ir = _width_from_type(slang_type)
    if width_ir is None:
        return 1
    msb = _parse_width_bound(width_ir.msb)
    lsb = _parse_width_bound(width_ir.lsb)
    if msb is None or lsb is None:
        return 1
    return abs(msb - lsb) + 1


def _parse_width_bound(text: str) -> int | None:
    try:
        return int(text)
    except Exception:
        return None


def _enum_values_from_type(symbol: Any) -> tuple[EnumValueIR, ...]:
    values: list[EnumValueIR] = []
    enum_type = getattr(symbol, "canonicalType", None) or symbol
    syntax = getattr(enum_type, "syntax", None)
    if syntax is not None:
        for enum_item in getattr(syntax, "members", ()) or ():
            if type(enum_item).__name__ != "DeclaratorSyntax":
                continue
            name = _token_text(getattr(enum_item, "name", ""))
            if not name:
                continue
            enum_symbol = _lookup_enum_value(enum_type, name)
            value = _enum_member_value(enum_symbol)
            if value is None:
                continue
            values.append(EnumValueIR(name=name, value=value))
    if values:
        return tuple(values)
    # Fallback to walking the flattened members in symbol order.
    parent = getattr(symbol, "parentScope", None)
    if parent is not None:
        current = getattr(parent, "firstMember", None)
        while current is not None:
            if type(current).__name__ == "EnumValueSymbol":
                value = _enum_member_value(current)
                if value is not None:
                    values.append(EnumValueIR(name=str(getattr(current, "name", "")), value=value))
            current = getattr(current, "nextSibling", None)
    return tuple(values)


def _token_text(token: Any) -> str:
    for attr in ("valueText", "value", "rawText"):
        value = getattr(token, attr, None)
        if callable(value):
            try:
                value = value()
            except Exception:
                value = None
        if value is not None:
            text = str(value).strip()
            if text:
                return text
    return str(token).strip()


def _lookup_enum_value(enum_type: Any, name: str) -> Any:
    if enum_type is None or not name:
        return None
    lookup = getattr(enum_type, "lookupName", None)
    if callable(lookup):
        try:
            return lookup(name)
        except Exception:
            return None
    return None


def _enum_member_value(symbol: Any) -> int | None:
    if symbol is None:
        return None
    value = getattr(symbol, "value", None)
    if value is None:
        return None
    int_value = getattr(value, "integer", None)
    if int_value is not None:
        try:
            return int(int_value.as_int())
        except Exception:
            pass
    if hasattr(value, "convertToInt"):
        try:
            converted = value.convertToInt()
            if hasattr(converted, "value"):
                return int(converted.value)
        except Exception:
            pass
    try:
        return int(value)
    except Exception:
        return None


def _enum_value_from_expr(expr: Any) -> int | None:
    if expr is None:
        return None
    if str(getattr(expr, "kind", "")).rsplit(".", 1)[-1] == "Conversion":
        expr = getattr(expr, "operand", None)
    value = getattr(expr, "constant", None)
    if value is not None:
        int_value = getattr(value, "integer", None)
        if int_value is not None:
            try:
                return int(int_value.as_int())
            except Exception:
                pass
        if hasattr(value, "convertToInt"):
            try:
                converted = value.convertToInt()
                if hasattr(converted, "value"):
                    return int(converted.value)
            except Exception:
                pass
    symbol = getattr(expr, "symbol", None)
    if symbol is not None:
        return _enum_member_value(symbol)
    try:
        return int(_constant_value_text(value))
    except Exception:
        return None


def _enum_intconst(symbol: Any, expr_type: Any = None) -> dict[str, Any] | None:
    if type(symbol).__name__ != "EnumValueSymbol":
        return None
    value = _enum_member_value(symbol)
    if value is None:
        return None
    enum_type = expr_type or getattr(symbol, "type", None)
    width = getattr(enum_type, "bitWidth", None)
    width_int = int(width) if isinstance(width, int) and width > 0 else None
    return {
        "kind": "intconst",
        "raw": f"{width_int}'d{value}" if width_int is not None else str(value),
        "value": value,
        "width": width_int,
        "base": 10,
        "has_xz": False,
        "digits": str(value),
    }


def _intconst_ir(value: int) -> dict[str, Any]:
    return {
        "kind": "intconst",
        "raw": str(value),
        "value": int(value),
        "width": None,
        "base": 10,
        "has_xz": False,
        "digits": str(value),
    }


def _parameter_initializer_text(parameter: Any) -> str:
    """Render a parameter's initializer using the original source text.

    slang's resolved ``ConstantValue`` strips leading zeros (``2'b00`` →
    ``2'b0``) and changes literal radixes, which would silently alter the
    width / bit patterns the codegen relies on. The initializer's
    ``syntax`` node, by contrast, points back at the user-written form.
    """
    initializer = getattr(parameter, "initializer", None)
    if initializer is not None:
        text = _render_expression(initializer)
        if text:
            return text
    value = getattr(parameter, "value", None)
    return _constant_value_text(value)


def _lower_port(port: Any) -> PortIR:
    direction = _port_direction_text(port.direction)
    internal_kind = _net_or_variable_kind(getattr(port, "internalSymbol", None))
    return PortIR(
        name=port.name,
        direction=direction,
        kind=internal_kind,
        width=_width_from_type(port.type),
        signed=bool(getattr(port.type, "isSigned", False)),
    )


def _lower_net(net: Any) -> SignalIR:
    return SignalIR(
        name=net.name,
        kind="wire",
        width=_width_from_type(net.type),
        signed=bool(getattr(net.type, "isSigned", False)),
    )


def _lower_variable(variable: Any) -> SignalIR:
    declared_reg = bool(getattr(variable.type, "isDeclaredReg", False))
    # Peel off any unpacked dimensions before classifying the cell type
    # and computing the per-cell packed width.
    cell_type, unpacked_dims = _peel_unpacked_dims(variable.type)
    if not declared_reg:
        declared_reg = bool(getattr(cell_type, "isDeclaredReg", False))
    kind = "reg" if declared_reg else _slang_type_kind(cell_type)
    return SignalIR(
        name=variable.name,
        kind=kind,
        width=_width_from_type(cell_type),
        signed=bool(getattr(cell_type, "isSigned", False)),
        unpacked_dims=unpacked_dims,
    )


def _peel_unpacked_dims(slang_type: Any) -> tuple[Any, tuple[tuple[int, int], ...]]:
    """Walk through ``FixedSizeUnpackedArrayType`` layers, returning the
    inner cell type and a tuple of ``(msb, lsb)`` dimension bounds outermost
    first. Non-array types fall through with an empty dim tuple.
    """
    dims: list[tuple[int, int]] = []
    current = slang_type
    while type(current).__name__ == "FixedSizeUnpackedArrayType":
        slang_range = getattr(current, "range", None)
        if slang_range is None:
            break
        msb = int(getattr(slang_range, "left", 0))
        lsb = int(getattr(slang_range, "right", 0))
        dims.append((msb, lsb))
        current = current.elementType
    return current, tuple(dims)


def _lower_continuous_assign(assign: Any) -> ContinuousAssignIR:
    expr = assign.assignment
    left = expr.left
    right = expr.right
    return ContinuousAssignIR(
        left=_render_expression(left),
        right=_render_expression(right),
        left_expr=_lower_expression(left),
        right_expr=_lower_expression(right),
    )


def _lower_procedural_block(block: Any, module_name: str) -> tuple[ProcessIR, list[DiagnosticIR]]:
    kind_name = str(block.procedureKind).rsplit(".", 1)[-1]
    sensitivity, statement = _split_timing(block.body)

    if kind_name in {"AlwaysComb", "AlwaysLatch"}:
        process_kind = "always_comb"
    elif kind_name == "AlwaysFF":
        process_kind = "always_ff"
    elif kind_name == "Initial":
        process_kind = "initial"
    else:  # Plain `always`
        process_kind = (
            "always_ff" if any(item.edge in {"posedge", "negedge"} for item in sensitivity) else "always_comb"
        )

    diagnostics: list[DiagnosticIR] = []
    structured = tuple(_lower_statement(child, module_name, diagnostics) for child in _flatten_statements(statement))
    summaries = tuple(_statement_summary(child) for child in _flatten_statements(statement))

    if process_kind == "initial":
        diagnostics.append(
            _diagnostic(
                module_name,
                "unsupported_initial",
                "initial blocks are parsed but not emitted as SystemC behavior",
                "Initial",
            )
        )

    return (
        ProcessIR(
            kind=process_kind,
            sensitivity=tuple(sensitivity),
            statements=summaries,
            structured_statements=structured,
        ),
        diagnostics,
    )


def _split_timing(statement: Any) -> tuple[list[SensitivityIR], Any]:
    """Strip the leading TimedStatement to extract sensitivity + inner stmt."""
    kind = getattr(statement, "kind", None)
    if kind is not None and "Timed" in str(kind):
        timing = statement.timing
        sensitivity = _lower_timing(timing)
        return sensitivity, statement.stmt
    return [], statement


def _lower_timing(timing: Any) -> list[SensitivityIR]:
    kind_name = str(getattr(timing, "kind", "")).rsplit(".", 1)[-1]
    items: list[SensitivityIR] = []
    if kind_name == "EventList":
        for event in timing.events:
            items.extend(_lower_timing(event))
    elif kind_name == "SignalEvent":
        edge = _edge_text(getattr(timing, "edge", None))
        items.append(SensitivityIR(signal=_render_expression(timing.expr), edge=edge))
    elif kind_name == "ImplicitEvent":
        items.append(SensitivityIR(signal="", edge="all"))
    return items


def _flatten_statements(statement: Any) -> tuple[Any, ...]:
    kind = getattr(statement, "kind", None)
    if kind is not None and str(kind).endswith("Block"):
        body = getattr(statement, "body", None)
        if body is None:
            return ()
        # A Block's `body` is itself a Statement (often List or a single
        # inner statement). Unwrap one level if it is a List.
        body_kind = str(getattr(body, "kind", ""))
        if body_kind.endswith("List"):
            return tuple(body.list)
        return (body,)
    if statement is None:
        return ()
    return (statement,)


def _lower_statement(statement: Any, module_name: str, diagnostics: list[DiagnosticIR]) -> dict[str, Any]:
    kind_name = str(getattr(statement, "kind", "")).rsplit(".", 1)[-1]
    if kind_name == "ExpressionStatement":
        return _lower_expression_statement(statement.expr)
    if kind_name == "Conditional":
        return _lower_conditional_statement(statement, module_name, diagnostics)
    if kind_name == "Case":
        return _lower_case_statement(statement, module_name, diagnostics)
    if kind_name == "ForLoop":
        return _lower_for_loop_statement(statement, module_name, diagnostics)
    if kind_name == "Return":
        return _lower_return_statement(statement)
    if kind_name == "Block":
        children = [_lower_statement(child, module_name, diagnostics) for child in _flatten_statements(statement)]
        if len(children) == 1:
            return children[0]
        return {"type": "block", "statements": children}
    if kind_name in {"Empty", "VariableDeclaration"}:
        return {"type": "noop", "node": kind_name}
    diagnostics.append(
        _diagnostic(
            module_name,
            f"unsupported_{kind_name.lower()}",
            f"procedural statement '{kind_name}' is not supported by the current SystemC emitter",
            kind_name,
        )
    )
    return {"type": "unsupported", "node": kind_name}


def _lower_expression_statement(expr: Any) -> dict[str, Any]:
    kind_name = str(getattr(expr, "kind", "")).rsplit(".", 1)[-1]
    if kind_name == "Assignment":
        op_type = "nonblocking_assign" if getattr(expr, "isNonBlocking", False) else "blocking_assign"
        return {
            "type": op_type,
            "left": _render_expression(expr.left),
            "right": _render_expression(expr.right),
            "left_expr": _lower_expression(expr.left),
            "right_expr": _lower_expression(expr.right),
        }
    return {"type": "unsupported", "node": kind_name}


def _lower_return_statement(statement: Any) -> dict[str, Any]:
    """Lower a return statement from a function body."""
    expr = getattr(statement, "expr", None)
    if expr is None:
        # return with no value (void function)
        return {"type": "return", "value": None, "value_expr": None}
    return {
        "type": "return",
        "value": _render_expression(expr),
        "value_expr": _lower_expression(expr),
    }


def _lower_conditional_statement(statement: Any, module_name: str, diagnostics: list[DiagnosticIR]) -> dict[str, Any]:
    conditions = statement.conditions
    cond_expr = conditions[0].expr if conditions else None
    cond_text = _render_expression(cond_expr) if cond_expr is not None else ""
    cond_dict = _lower_expression(cond_expr) if cond_expr is not None else {"kind": "raw", "text": ""}
    true_stmts = [_lower_statement(child, module_name, diagnostics) for child in _flatten_statements(statement.ifTrue)]
    false_stmts: list[dict[str, Any]] = []
    if getattr(statement, "ifFalse", None) is not None:
        false_stmts = [_lower_statement(child, module_name, diagnostics) for child in _flatten_statements(statement.ifFalse)]
    return {
        "type": "if",
        "cond": cond_text,
        "cond_expr": cond_dict,
        "true": true_stmts,
        "false": false_stmts,
    }


def _lower_case_statement(statement: Any, module_name: str, diagnostics: list[DiagnosticIR]) -> dict[str, Any]:
    items: list[dict[str, Any]] = []
    default_stmts: list[dict[str, Any]] = []
    for item in statement.items:
        groups = getattr(item, "expressions", None)
        if groups is None:
            default_stmts = [_lower_statement(s, module_name, diagnostics) for s in _flatten_statements(item.stmt)]
            continue
        cond_texts = [_render_expression(g) for g in groups]
        cond_exprs = [_lower_expression(g) for g in groups]
        item_stmts = [_lower_statement(s, module_name, diagnostics) for s in _flatten_statements(item.stmt)]
        items.append({"conds": cond_texts, "cond_exprs": cond_exprs, "statements": item_stmts})
    default_stmt = getattr(statement, "defaultCase", None)
    if default_stmt is not None and not default_stmts:
        default_stmts = [_lower_statement(s, module_name, diagnostics) for s in _flatten_statements(default_stmt)]
    if default_stmts:
        items.append({"conds": [], "cond_exprs": [], "statements": default_stmts})
    condition_name = str(getattr(statement, "condition", "")).rsplit(".", 1)[-1]
    # slang's CaseStatementCondition: Normal, WildcardJustZ, WildcardXOrZ, Inside.
    if condition_name == "WildcardJustZ":
        case_kind = "casez"
    elif condition_name == "WildcardXOrZ":
        case_kind = "casex"
    else:
        case_kind = "case"
    return {
        "type": "case",
        "case_kind": case_kind,
        "expr": _render_expression(statement.expr),
        "expr_tree": _lower_expression(statement.expr),
        "items": items,
    }


def _lower_for_loop_statement(statement: Any, module_name: str, diagnostics: list[DiagnosticIR]) -> dict[str, Any]:
    """Lower a slang ``ForLoopStatement`` into an unrolled block.

    slang gives us constant-resolved bounds for synthesizable loops, so we
    unroll them into sequential statements. The loop structure is:
    - initializers: list of Assignment expressions (e.g., i = 0)
    - stopExpr: BinaryOp condition (e.g., i < WIDTH)
    - steps: list of Assignment expressions (e.g., i = i + 1)
    - body: BlockStatement with the loop body

    We evaluate the loop bounds at lowering time and emit an unrolled block.
    If bounds are not constant or the loop is unbounded, emit a diagnostic.
    """
    # Extract loop variable and bounds
    if not statement.initializers or not statement.steps:
        diagnostics.append(
            _diagnostic(
                module_name,
                "unsupported_for_loop_structure",
                "for loop must have exactly one initializer and one step",
                "ForLoop",
            )
        )
        return {"type": "unsupported", "node": "ForLoop"}

    init_expr = statement.initializers[0]
    step_expr = statement.steps[0]
    stop_expr = statement.stopExpr

    # Try to extract constant bounds
    # init: i = <start>
    # stop: i < <end> or i <= <end>
    # step: i = i + <stride> or i = i - <stride>
    try:
        # Get loop variable name
        loop_var = _render_expression(init_expr.left)

        # Get start value
        start_val = _try_eval_const_expr(init_expr.right)
        if start_val is None:
            raise ValueError("non-constant start")

        # Get stop condition
        stop_kind = str(stop_expr.kind).rsplit(".", 1)[-1]
        if stop_kind not in {"BinaryOp"}:
            raise ValueError("non-constant stop")

        stop_op_text = str(stop_expr.op).rsplit(".", 1)[-1]
        stop_left = _render_expression(stop_expr.left)
        stop_right = _render_expression(stop_expr.right)

        # Determine which side is the loop variable
        if stop_left == loop_var:
            end_val = _try_eval_const_expr(stop_expr.right)
            if end_val is None:
                raise ValueError("non-constant end")
            # i < end or i <= end
            if stop_op_text == "LessThan":
                end_val = end_val  # exclusive
            elif stop_op_text == "LessThanEqual":
                end_val = end_val + 1  # inclusive -> exclusive
            else:
                raise ValueError(f"unsupported stop operator {stop_op_text}")
        elif stop_right == loop_var:
            end_val = _try_eval_const_expr(stop_expr.left)
            if end_val is None:
                raise ValueError("non-constant end")
            # end > i or end >= i
            if stop_op_text == "GreaterThan":
                end_val = end_val  # exclusive
            elif stop_op_text == "GreaterThanEqual":
                end_val = end_val + 1  # inclusive -> exclusive
            else:
                raise ValueError(f"unsupported stop operator {stop_op_text}")
        else:
            raise ValueError("loop variable not in stop condition")

        # Get stride (assume i = i + 1 or i = i - 1 for now)
        step_right_kind = str(step_expr.right.kind).rsplit(".", 1)[-1]
        if step_right_kind == "BinaryOp":
            step_op = str(step_expr.right.op).rsplit(".", 1)[-1]
            if step_op == "Add":
                stride_val = _try_eval_const_expr(step_expr.right.right)
                if stride_val is None:
                    raise ValueError("non-constant stride")
            elif step_op == "Subtract":
                stride_val = -_try_eval_const_expr(step_expr.right.right)
                if stride_val is None:
                    raise ValueError("non-constant stride")
            else:
                raise ValueError(f"unsupported step operator {step_op}")
        else:
            raise ValueError("unsupported step expression")

        # Unroll the loop
        unrolled_stmts: list[dict[str, Any]] = []
        iteration_count = 0
        max_iterations = 10000  # safety limit

        # Create a genvar substitution for this loop variable
        current_val = start_val
        while (stride_val > 0 and current_val < end_val) or (stride_val < 0 and current_val > end_val):
            if iteration_count >= max_iterations:
                raise ValueError(f"loop exceeds {max_iterations} iterations")

            # Push loop variable substitution
            _genvar_subst_stack.append({loop_var: str(current_val)})
            try:
                # Lower the body with the substituted loop variable
                body_stmts = [_lower_statement(s, module_name, diagnostics) for s in _flatten_statements(statement.body)]
                unrolled_stmts.extend(body_stmts)
            finally:
                _genvar_subst_stack.pop()

            current_val += stride_val
            iteration_count += 1

        if len(unrolled_stmts) == 1:
            return unrolled_stmts[0]
        return {"type": "block", "statements": unrolled_stmts}

    except (ValueError, AttributeError, TypeError) as e:
        diagnostics.append(
            _diagnostic(
                module_name,
                "unsupported_for_loop_bounds",
                f"for loop bounds must be constant at elaboration time: {e}",
                "ForLoop",
            )
        )
        return {"type": "unsupported", "node": "ForLoop"}


def _try_eval_const_expr(expr: Any) -> int | None:
    """Try to evaluate a slang expression to a constant integer.

    Returns None if the expression is not a compile-time constant.
    """
    # First check if the expression itself has a constant attribute
    if hasattr(expr, "constant"):
        const_val = expr.constant
        if const_val is not None:
            # pyslang ConstantValue: convertToInt().value gives SVInt, then int() gives Python int
            if hasattr(const_val, "convertToInt"):
                try:
                    converted = const_val.convertToInt()
                    if hasattr(converted, "value"):
                        return int(converted.value)
                except:
                    pass
            # Older pyslang versions might have .integer attribute
            if hasattr(const_val, "integer"):
                return const_val.integer.as_int()
            # Plain int (shouldn't happen with pyslang but keep for safety)
            if isinstance(const_val, int):
                return const_val

    kind = str(expr.kind).rsplit(".", 1)[-1]
    if kind == "NamedValue":
        # Could be a parameter; check the symbol's value
        symbol = getattr(expr, "symbol", None)
        if symbol:
            sym_val = getattr(symbol, "value", None)
            if sym_val is not None:
                if hasattr(sym_val, "convertToInt"):
                    try:
                        converted = sym_val.convertToInt()
                        if hasattr(converted, "value"):
                            return int(converted.value)
                    except:
                        pass
                if hasattr(sym_val, "integer"):
                    return sym_val.integer.as_int()
                if isinstance(sym_val, int):
                    return sym_val
    elif kind == "Conversion":
        # Type conversion wrapping a constant
        operand = getattr(expr, "operand", None)
        if operand:
            return _try_eval_const_expr(operand)
    return None


def _statement_summary(statement: Any) -> str:
    kind_name = str(getattr(statement, "kind", "")).rsplit(".", 1)[-1]
    if kind_name == "ExpressionStatement":
        expr = statement.expr
        if str(getattr(expr, "kind", "")).endswith("Assignment"):
            op = "<=" if getattr(expr, "isNonBlocking", False) else "="
            return f"{_render_expression(expr.left)} {op} {_render_expression(expr.right)}"
    if kind_name == "Conditional":
        conds = statement.conditions
        if conds:
            return f"if {_render_expression(conds[0].expr)}"
    return kind_name


def _extract_from_package_import(
    import_symbol: Any, module_name: str
) -> tuple[list[SubroutineIR], list[TypeAliasIR], list[ParameterIR]]:
    """Extract subroutines, type aliases, and parameters from a wildcard package import.

    slang resolves `import pkg::*` by linking to the package symbol, and we
    extract all synthesizable functions, typedefs, and parameters from that package.
    """
    subroutines: list[SubroutineIR] = []
    type_aliases: list[TypeAliasIR] = []
    pkg_parameters: list[ParameterIR] = []

    # Get the package symbol via the import
    package = getattr(import_symbol, "package", None)
    if package is None:
        return subroutines, type_aliases, pkg_parameters

    # Walk the package members and extract subroutines, type aliases, and parameters
    for pkg_member in package:
        kind = type(pkg_member).__name__
        if kind == "SubroutineSymbol":
            subroutine, _ = _lower_subroutine(pkg_member, module_name)
            if subroutine is not None:
                subroutines.append(subroutine)
        elif kind == "TypeAliasType":
            alias = _lower_type_alias(pkg_member)
            if alias is not None:
                type_aliases.append(alias)
        elif kind == "ParameterSymbol":
            pkg_parameters.append(_lower_parameter(pkg_member))

    return subroutines, type_aliases, pkg_parameters


def _extract_from_explicit_import(
    import_symbol: Any, module_name: str
) -> tuple[list[SubroutineIR], list[TypeAliasIR], list[ParameterIR]]:
    """Extract a specific item from an explicit package import.

    slang resolves `import pkg::item` by directly linking to the imported
    symbol. We check if it's a function, typedef, or parameter and lower it accordingly.
    """
    subroutines: list[SubroutineIR] = []
    type_aliases: list[TypeAliasIR] = []
    pkg_parameters: list[ParameterIR] = []

    # Get the imported symbol
    imported = getattr(import_symbol, "importedSymbol", None)
    if imported is None:
        return subroutines, type_aliases, pkg_parameters

    kind = type(imported).__name__
    if kind == "SubroutineSymbol":
        subroutine, _ = _lower_subroutine(imported, module_name)
        if subroutine is not None:
            subroutines.append(subroutine)
    elif kind == "TypeAliasType":
        alias = _lower_type_alias(imported)
        if alias is not None:
            type_aliases.append(alias)
    elif kind == "ParameterSymbol":
        pkg_parameters.append(_lower_parameter(imported))

    return subroutines, type_aliases, pkg_parameters


def _lower_subroutine(symbol: Any, module_name: str) -> tuple[SubroutineIR | None, list[DiagnosticIR]]:
    """Lower a slang ``SubroutineSymbol`` into ``SubroutineIR``.

    First-round scope is function-only; task subroutines emit a diagnostic
    and are not materialized in the IR.
    """
    kind_text = str(getattr(symbol, "subroutineKind", "")).rsplit(".", 1)[-1]
    if kind_text != "Function":
        return None, [
            _diagnostic(
                module_name,
                "unsupported_task_first_round",
                "SystemVerilog tasks are not lowered yet (first round supports functions only)",
                "SubroutineSymbol",
            )
        ]

    params: list[SubroutineParamIR] = []
    for arg in getattr(symbol, "arguments", ()) or ():
        params.append(
            SubroutineParamIR(
                name=str(arg.name),
                direction=_arg_direction_text(getattr(arg, "direction", None)),
                width=_width_from_type(getattr(arg, "type", None)),
                signed=bool(getattr(getattr(arg, "type", None), "isSigned", False)),
            )
        )

    body_diagnostics: list[DiagnosticIR] = []
    body_statements = tuple(
        _lower_statement(child, module_name, body_diagnostics)
        for child in _flatten_statements(getattr(symbol, "body", None))
    )

    return_type = getattr(symbol, "returnType", None)
    return_width = _width_from_type(return_type)
    return_signed = bool(getattr(return_type, "isSigned", False))

    return (
        SubroutineIR(
            name=str(symbol.name),
            kind="function",
            return_width=return_width,
            return_signed=return_signed,
            params=tuple(params),
            body_statements=body_statements,
        ),
        body_diagnostics,
    )


def _arg_direction_text(direction: Any) -> str:
    text = str(direction).rsplit(".", 1)[-1]
    return {"In": "input", "Out": "output", "InOut": "inout", "Ref": "ref", "ConstRef": "ref"}.get(text, "input")


# ---------------------------------------------------------------------------
# Instance lowering
# ---------------------------------------------------------------------------


def _lower_instance(instance: Any, *, name_prefix: str = "") -> InstanceIR:
    parameters = tuple(
        ArgIR(name=parameter.name, value=_constant_value_text(getattr(parameter, "value", None)))
        for parameter in _instance_parameter_overrides(instance)
    )
    ports: list[ArgIR] = []
    for connection in instance.portConnections:
        port = connection.port
        port_name = getattr(port, "name", "")
        value = _render_port_connection(connection)
        ports.append(ArgIR(name=port_name, value=value))
    instance_name = f"{name_prefix}_{instance.name}" if name_prefix else instance.name
    return InstanceIR(
        module=instance.definition.name,
        name=instance_name,
        parameters=parameters,
        ports=tuple(ports),
    )


def _lower_instance_array(array_symbol: Any, *, name_prefix: str = "") -> list[InstanceIR]:
    flattened: list[InstanceIR] = []
    for element in array_symbol.elements:
        if type(element).__name__ == "InstanceArraySymbol":
            flattened.extend(_lower_instance_array(element, name_prefix=name_prefix))
        elif type(element).__name__ == "InstanceSymbol":
            flattened.append(_lower_instance(element, name_prefix=name_prefix))
    return flattened


def _instance_parameter_overrides(instance: Any) -> list[Any]:
    overrides: list[Any] = []
    for member in instance.body:
        if type(member).__name__ == "ParameterSymbol" and getattr(member, "isOverridden", False):
            overrides.append(member)
    return overrides


def _render_port_connection(connection: Any) -> str:
    """Render the external expression for a port connection.

    slang represents output-port connections internally as an
    ``Assignment(left=external_lvalue, right=EmptyArgument)``. For our IR
    we only care about the external expression, so unwrap the lvalue side
    when the direction is output/inout.
    """
    expr = getattr(connection, "expression", None)
    if expr is None:
        return ""
    if str(getattr(expr, "kind", "")).endswith("Assignment"):
        return _render_expression(expr.left)
    return _render_expression(expr)


def _walk_generate_block(
    block: Any,
    module_name: str,
    signals: list[SignalIR],
    continuous_assigns: list[ContinuousAssignIR],
    processes: list[ProcessIR],
    instances: list[InstanceIR],
    diagnostics: list[DiagnosticIR],
    port_names: set[str],
    *,
    name_prefix: str = "",
) -> None:
    """Flatten an elaborated generate block back into the parent module's lists.

    slang has already chosen the active branch (generate-if) and unrolled the
    iterations (generate-for). For Phase A we materialize the contents
    directly into the parent module: each unrolled instance becomes a plain
    ``InstanceIR`` whose name is prefixed with the enclosing generate-block
    label (e.g. ``g_0_u``) so unrolled iterations don't collide on C++
    identifiers.
    """
    for member in block:
        kind = type(member).__name__
        if kind == "NetSymbol" and member.name not in port_names:
            signals.append(_lower_net(member))
        elif kind == "VariableSymbol" and member.name not in port_names:
            signals.append(_lower_variable(member))
        elif kind == "ContinuousAssignSymbol":
            continuous_assigns.append(_lower_continuous_assign(member))
        elif kind == "ProceduralBlockSymbol":
            process, process_diagnostics = _lower_procedural_block(member, module_name)
            processes.append(process)
            diagnostics.extend(process_diagnostics)
        elif kind == "InstanceSymbol":
            instances.append(_lower_instance(member, name_prefix=name_prefix))
        elif kind == "InstanceArraySymbol":
            instances.extend(_lower_instance_array(member, name_prefix=name_prefix))
        elif kind == "GenerateBlockSymbol":
            if getattr(member, "isUninstantiated", False):
                continue  # generate-if dead branch
            inner_name = getattr(member, "name", "") or ""
            inner_prefix = f"{name_prefix}_{inner_name}" if name_prefix and inner_name else (name_prefix or inner_name)
            _walk_generate_block(
                member, module_name, signals, continuous_assigns, processes, instances,
                diagnostics, port_names, name_prefix=inner_prefix,
            )
        elif kind == "GenerateBlockArraySymbol":
            array_name = getattr(member, "name", "") or ""
            for sub in member.entries:
                if getattr(sub, "isUninstantiated", False):
                    continue
                array_index = getattr(sub, "arrayIndex", 0)
                segment = f"{array_name}_{array_index}" if array_name else f"_{array_index}"
                inner_prefix = f"{name_prefix}_{segment}" if name_prefix else segment
                subst = _collect_genvar_substitutions(sub)
                _genvar_subst_stack.append(subst)
                try:
                    _walk_generate_block(
                        sub, module_name, signals, continuous_assigns, processes, instances,
                        diagnostics, port_names, name_prefix=inner_prefix,
                    )
                finally:
                    _genvar_subst_stack.pop()


def _child_instances(instance: Any) -> list[Any]:
    """Return the direct child instance symbols reachable from a parent."""
    children: list[Any] = []
    for member in instance.body:
        kind = type(member).__name__
        if kind == "InstanceSymbol":
            children.append(member)
        elif kind == "InstanceArraySymbol":
            children.extend(_collect_array_instances(member))
        elif kind == "GenerateBlockSymbol":
            children.extend(_collect_generate_instances(member))
        elif kind == "GenerateBlockArraySymbol":
            for entry in member.entries:
                if not getattr(entry, "isUninstantiated", False):
                    children.extend(_collect_generate_instances(entry))
    return children


def _collect_array_instances(array_symbol: Any) -> list[Any]:
    found: list[Any] = []
    for element in array_symbol.elements:
        if type(element).__name__ == "InstanceArraySymbol":
            found.extend(_collect_array_instances(element))
        elif type(element).__name__ == "InstanceSymbol":
            found.append(element)
    return found


def _collect_generate_instances(block: Any) -> list[Any]:
    found: list[Any] = []
    for member in block:
        kind = type(member).__name__
        if kind == "InstanceSymbol":
            found.append(member)
        elif kind == "InstanceArraySymbol":
            found.extend(_collect_array_instances(member))
        elif kind == "GenerateBlockSymbol":
            found.extend(_collect_generate_instances(member))
        elif kind == "GenerateBlockArraySymbol":
            for entry in member.entries:
                if not getattr(entry, "isUninstantiated", False):
                    found.extend(_collect_generate_instances(entry))
    return found


# ---------------------------------------------------------------------------
# Expression rendering and lowering
# ---------------------------------------------------------------------------


_BINARY_OP_TEXT = {
    "Add": "+", "Subtract": "-", "Multiply": "*", "Divide": "/", "Mod": "%",
    "Power": "**",
    "BinaryAnd": "&", "BinaryOr": "|", "BinaryXor": "^", "BinaryXnor": "^~",
    "Equality": "==", "Inequality": "!=", "CaseEquality": "===", "CaseInequality": "!==",
    "WildcardEquality": "==?", "WildcardInequality": "!=?",
    "LessThan": "<", "LessThanEqual": "<=", "GreaterThan": ">", "GreaterThanEqual": ">=",
    "LogicalAnd": "&&", "LogicalOr": "||", "LogicalImplication": "->", "LogicalEquivalence": "<->",
    "LogicalShiftLeft": "<<", "LogicalShiftRight": ">>",
    "ArithmeticShiftLeft": "<<<", "ArithmeticShiftRight": ">>>",
}

_UNARY_OP_TEXT = {
    "Plus": "+", "Minus": "-", "BitwiseNot": "~", "LogicalNot": "!",
    "BitwiseAnd": "&", "BitwiseNand": "~&", "BitwiseOr": "|", "BitwiseNor": "~|",
    "BitwiseXor": "^", "BitwiseXnor": "^~",
}


def _render_expression(expr: Any) -> str:
    """Render a slang Expression back to a Verilog-like source string.

    For unrecognized shapes, fall back to the syntax node's text — slang
    keeps the original syntax pointer alongside the elaborated expression,
    so this round-trips the user-written form.
    """
    if expr is None:
        return ""
    kind_name = str(getattr(expr, "kind", "")).rsplit(".", 1)[-1]
    if kind_name == "NamedValue":
        symbol = getattr(expr, "symbol", None)
        subst = _lookup_genvar_subst(symbol)
        if subst is not None:
            return subst
        enum_const = _enum_intconst(symbol, getattr(expr, "type", None))
        if enum_const is not None:
            return str(enum_const["raw"])
        return getattr(symbol, "name", "")
    if kind_name == "IntegerLiteral":
        return _format_integer_literal(expr)
    if kind_name == "BinaryOp":
        op = _BINARY_OP_TEXT.get(_binary_operator_name(expr), "?")
        return f"({_render_expression(expr.left)} {op} {_render_expression(expr.right)})"
    if kind_name == "UnaryOp":
        op = _UNARY_OP_TEXT.get(_unary_operator_name(expr), "?")
        return f"({op}{_render_expression(expr.operand)})"
    if kind_name == "ConditionalOp":
        cond = expr.conditions[0].expr if expr.conditions else None
        return f"({_render_expression(cond)} ? {_render_expression(expr.left)} : {_render_expression(expr.right)})"
    if kind_name == "Concatenation":
        parts = ", ".join(_render_expression(op) for op in expr.operands)
        return "{" + parts + "}"
    if kind_name == "Replication":
        return "{" + f"{_render_expression(expr.count)}{{{_render_expression(expr.concat)}}}" + "}"
    if kind_name == "ElementSelect":
        return f"{_render_expression(expr.value)}[{_render_expression(expr.selector)}]"
    if kind_name == "RangeSelect":
        return f"{_render_expression(expr.value)}[{_render_expression(expr.left)}:{_render_expression(expr.right)}]"
    if kind_name == "MemberAccess":
        member = getattr(expr, "member", None)
        return f"{_render_expression(getattr(expr, 'value', None))}.{getattr(member, 'name', '')}"
    if kind_name == "Assignment":
        op = "<=" if getattr(expr, "isNonBlocking", False) else "="
        return f"{_render_expression(expr.left)} {op} {_render_expression(expr.right)}"
    if kind_name == "Conversion":
        return _render_expression(expr.operand)
    if kind_name == "Call":
        callee = getattr(expr, "subroutineName", "") or ""
        args = ", ".join(_render_expression(arg) for arg in getattr(expr, "arguments", ()) or ())
        if getattr(expr, "isSystemCall", False):
            return f"${callee.lstrip('$')}({args})"
        return f"{callee}({args})"
    syntax = getattr(expr, "syntax", None)
    if syntax is not None:
        return str(syntax).strip()
    return ""


def _lower_expression(expr: Any) -> dict[str, Any]:
    """Lower a slang Expression into the same dict shape ``lower_expr`` uses."""
    if expr is None:
        return {"kind": "raw", "text": ""}
    kind_name = str(getattr(expr, "kind", "")).rsplit(".", 1)[-1]
    if kind_name == "NamedValue":
        symbol = getattr(expr, "symbol", None)
        subst = _lookup_genvar_subst(symbol)
        if subst is not None:
            try:
                int_value = int(subst)
            except ValueError:
                return {"kind": "identifier", "name": subst}
            return {
                "kind": "intconst",
                "raw": subst,
                "value": int_value,
                "width": None,
                "base": 10,
                "has_xz": False,
                "digits": subst,
            }
        enum_const = _enum_intconst(symbol, getattr(expr, "type", None))
        if enum_const is not None:
            return enum_const
        return {"kind": "identifier", "name": getattr(symbol, "name", "")}
    if kind_name == "IntegerLiteral":
        return _lower_integer_literal(expr)
    if kind_name == "BinaryOp":
        op = _BINARY_OP_TEXT.get(_binary_operator_name(expr), "?")
        return {
            "kind": "binop",
            "op": op,
            "left": _lower_expression(expr.left),
            "right": _lower_expression(expr.right),
        }
    if kind_name == "UnaryOp":
        op = _UNARY_OP_TEXT.get(_unary_operator_name(expr), "?")
        return {"kind": "unop", "op": op, "operand": _lower_expression(expr.operand)}
    if kind_name == "ConditionalOp":
        cond = expr.conditions[0].expr if expr.conditions else None
        return {
            "kind": "cond",
            "cond": _lower_expression(cond),
            "true": _lower_expression(expr.left),
            "false": _lower_expression(expr.right),
        }
    if kind_name == "Concatenation":
        return {"kind": "concat", "parts": [_lower_expression(op) for op in expr.operands]}
    if kind_name == "Replication":
        return {
            "kind": "repeat",
            "count": _lower_expression(expr.count),
            "value": _lower_expression(expr.concat),
        }
    if kind_name == "ElementSelect":
        return {
            "kind": "bitselect",
            "target": _lower_expression(expr.value),
            "index": _lower_expression(expr.selector),
        }
    if kind_name == "RangeSelect":
        return {
            "kind": "partselect",
            "target": _lower_expression(expr.value),
            "msb": _lower_expression(expr.left),
            "lsb": _lower_expression(expr.right),
        }
    if kind_name == "MemberAccess":
        lowered = _lower_packed_member_access(expr)
        if lowered is not None:
            return lowered
    if kind_name == "Conversion":
        return _lower_expression(expr.operand)
    if kind_name == "Assignment":
        return _lower_expression(expr.right)
    if kind_name == "Call":
        callee = getattr(expr, "subroutineName", "") or ""
        args = [_lower_expression(arg) for arg in getattr(expr, "arguments", ()) or ()]
        if getattr(expr, "isSystemCall", False):
            return {"kind": "syscall", "name": callee.lstrip("$"), "args": args}
        return {"kind": "funcall", "name": callee, "args": args}
    syntax = getattr(expr, "syntax", None)
    return {"kind": "raw", "text": str(syntax).strip() if syntax is not None else ""}


def _lower_packed_member_access(expr: Any) -> dict[str, Any] | None:
    member = getattr(expr, "member", None)
    if type(member).__name__ != "FieldSymbol":
        return None
    base_expr, offset = _packed_access_base_and_offset(getattr(expr, "value", None))
    if offset is None:
        return None
    field_width = _bit_width_from_type(getattr(member, "type", None))
    member_offset = _packed_field_offset(member)
    if member_offset is None:
        return None
    offset += member_offset
    if field_width <= 1:
        return {
            "kind": "bitselect",
            "target": base_expr,
            "index": _intconst_ir(offset),
        }
    return {
        "kind": "partselect",
        "target": base_expr,
        "msb": _intconst_ir(offset + field_width - 1),
        "lsb": _intconst_ir(offset),
    }


def _packed_access_base_and_offset(expr: Any) -> tuple[dict[str, Any], int] | tuple[None, None]:
    node = expr
    offset = 0
    while node is not None and str(getattr(node, "kind", "")).rsplit(".", 1)[-1] == "Conversion":
        node = getattr(node, "operand", None)
    while node is not None and str(getattr(node, "kind", "")).rsplit(".", 1)[-1] == "MemberAccess":
        member = getattr(node, "member", None)
        if type(member).__name__ != "FieldSymbol":
            return None, None
        member_offset = _packed_field_offset(member)
        if member_offset is None:
            return None, None
        offset += member_offset
        node = getattr(node, "value", None)
        while node is not None and str(getattr(node, "kind", "")).rsplit(".", 1)[-1] == "Conversion":
            node = getattr(node, "operand", None)
    if node is None:
        return None, None
    return _lower_expression(node), offset


def _binary_operator_name(expr: Any) -> str:
    op = getattr(expr, "op", None)
    return str(op).rsplit(".", 1)[-1] if op is not None else ""


def _unary_operator_name(expr: Any) -> str:
    op = getattr(expr, "op", None)
    return str(op).rsplit(".", 1)[-1] if op is not None else ""


def _format_integer_literal(literal: Any) -> str:
    """Reproduce the original Verilog literal text when slang records it.

    Falls back to a sized hex form derived from the SVInt value if no
    syntax pointer is available (slang sometimes synthesizes literals
    during elaboration, e.g., parameter defaults).
    """
    syntax = getattr(literal, "syntax", None)
    if syntax is not None:
        text = str(syntax).strip()
        if text:
            return text
    value = getattr(literal, "value", None)
    return str(value) if value is not None else "0"


def _digits_to_int(digits: str, base: int) -> int:
    """Parse a Verilog literal digit string into a Python int.

    X/Z/? are substituted with 0 — consistent with the converter's
    documented "X/Z approximated as zero" policy. Empty input is 0.
    """
    cleaned = re.sub(r"[xXzZ?]", "0", digits)
    if not cleaned:
        return 0
    try:
        return int(cleaned, base)
    except ValueError:
        return 0


def _lower_integer_literal(literal: Any) -> dict[str, Any]:
    syntax = getattr(literal, "syntax", None)
    text = str(syntax).strip() if syntax is not None else ""
    sized = _SIZED_LITERAL.match(text)
    unsized = _UNSIZED_LITERAL.match(text)
    width = None
    base = 10
    digits = text
    has_xz = False
    if sized:
        width = int(sized.group("size")) if sized.group("size") else None
        base = _BASE_MAP[sized.group("base").lower()]
        digits = sized.group("digits").replace("_", "")
        has_xz = bool(re.search(r"[xXzZ?]", digits))
    elif unsized:
        base = _BASE_MAP[unsized.group("base").lower()]
        digits = unsized.group("digits").replace("_", "")
        has_xz = bool(re.search(r"[xXzZ?]", digits))
    else:
        digits = text.replace("_", "")
    value = getattr(literal, "value", None)
    if value is not None:
        bit_width = getattr(value, "bitWidth", None)
        if bit_width is not None and width is None:
            width = int(bit_width)
    int_value = _digits_to_int(digits, base)
    return {
        "kind": "intconst",
        "raw": text,
        "value": int_value,
        "width": width,
        "base": base,
        "has_xz": has_xz,
        "digits": digits,
    }


# ---------------------------------------------------------------------------
# Small helpers
# ---------------------------------------------------------------------------


def _port_direction_text(direction: Any) -> str:
    text = str(direction).rsplit(".", 1)[-1].lower()
    return {"in": "input", "out": "output", "inout": "inout", "ref": "ref"}.get(text, text or "unknown")


def _edge_text(edge: Any) -> str:
    text = str(edge).rsplit(".", 1)[-1]
    return {"PosEdge": "posedge", "NegEdge": "negedge", "BothEdges": "edge", "None_": "level"}.get(text, "level")


def _net_or_variable_kind(internal_symbol: Any) -> str:
    if internal_symbol is None:
        return "wire"
    kind = type(internal_symbol).__name__
    if kind == "VariableSymbol":
        declared_reg = bool(getattr(getattr(internal_symbol, "type", None), "isDeclaredReg", False))
        return "reg" if declared_reg else "logic"
    return "wire"


def _slang_type_kind(slang_type: Any) -> str:
    name = (getattr(slang_type, "name", "") or "").lower()
    if "reg" in name:
        return "reg"
    if "logic" in name:
        return "logic"
    if "int" in name:
        return "integer"
    return "wire"


def _width_from_type(slang_type: Any) -> WidthIR | None:
    if slang_type is None:
        return None
    if not getattr(slang_type, "isIntegral", False):
        return None
    if not getattr(slang_type, "isPackedArray", False):
        if int(getattr(slang_type, "bitWidth", 1) or 1) == 1:
            return None
    fixed_range = None
    if getattr(slang_type, "hasFixedRange", False):
        fixed_range = getattr(slang_type, "fixedRange", None)
        get_range = getattr(slang_type, "getBitVectorRange", None)
        if fixed_range is None and callable(get_range):
            fixed_range = get_range()
    elif hasattr(slang_type, "range"):
        try:
            fixed_range = slang_type.range
        except Exception:
            fixed_range = None
    if fixed_range is None:
        # Fall back to width-1 down to 0.
        width = int(getattr(slang_type, "bitWidth", 1))
        return WidthIR(msb=str(width - 1), lsb="0")
    return WidthIR(msb=str(fixed_range.upper), lsb=str(fixed_range.lower))


def _constant_value_text(value: Any) -> str:
    if value is None:
        return ""
    return str(value).strip()


def _resolve_source_path(instance: Any, source_manager: Any) -> str:
    syntax = getattr(instance.definition, "syntax", None)
    location = getattr(syntax, "sourceRange", None)
    try:
        if location is not None:
            start = location.start
            if hasattr(source_manager, "getFullPath"):
                return str(source_manager.getFullPath(start.buffer))
    except Exception:
        return ""
    return ""


def _diagnostic(module: str, code: str, message: str, node: str, severity: str = "error") -> DiagnosticIR:
    return DiagnosticIR(severity=severity, module=module, code=code, message=message, node=node)


# ---------------------------------------------------------------------------
# IR-level diagnostics
# ---------------------------------------------------------------------------


def _xz_literal_diagnostics(
    module_name: str,
    processes: list[ProcessIR],
    continuous_assigns: list[ContinuousAssignIR],
) -> list[DiagnosticIR]:
    diagnostics: list[DiagnosticIR] = []
    seen: set[str] = set()
    for assign in continuous_assigns:
        for expr in (assign.left, assign.right):
            _append_xz_literal_diagnostic(module_name, expr, diagnostics, seen)
    for process in processes:
        for statement in process.structured_statements:
            _scan_statement_for_xz_literals(module_name, statement, diagnostics, seen)
    return diagnostics


def _scan_statement_for_xz_literals(
    module_name: str,
    statement: dict[str, object],
    diagnostics: list[DiagnosticIR],
    seen: set[str],
) -> None:
    kind = statement.get("type")
    if kind in {"blocking_assign", "nonblocking_assign"}:
        _append_xz_literal_diagnostic(module_name, str(statement.get("left", "")), diagnostics, seen)
        _append_xz_literal_diagnostic(module_name, str(statement.get("right", "")), diagnostics, seen)
        return
    if kind == "if":
        _append_xz_literal_diagnostic(module_name, str(statement.get("cond", "")), diagnostics, seen)
        for child in _as_statement_list(statement.get("true")):
            _scan_statement_for_xz_literals(module_name, child, diagnostics, seen)
        for child in _as_statement_list(statement.get("false")):
            _scan_statement_for_xz_literals(module_name, child, diagnostics, seen)
        return
    if kind == "case":
        _append_xz_literal_diagnostic(module_name, str(statement.get("expr", "")), diagnostics, seen)
        for item in _as_case_items(statement.get("items")):
            conds = item.get("conds")
            if isinstance(conds, list):
                for cond in conds:
                    _append_xz_literal_diagnostic(module_name, str(cond), diagnostics, seen)
            for child in _as_statement_list(item.get("statements")):
                _scan_statement_for_xz_literals(module_name, child, diagnostics, seen)


def _append_xz_literal_diagnostic(
    module_name: str,
    expr: str,
    diagnostics: list[DiagnosticIR],
    seen: set[str],
) -> None:
    for literal in _xz_literals(expr):
        key = f"{module_name}:{literal}"
        if key in seen:
            continue
        seen.add(key)
        diagnostics.append(
            DiagnosticIR(
                severity="warning",
                module=module_name,
                code="x_z_literal_approximated",
                message=(
                    f"literal '{literal}' contains X/Z/? bits; generated C++ currently "
                    "approximates those bits as zero"
                ),
                node="IntConst",
            )
        )


def _xz_literals(expr: str) -> list[str]:
    pattern = re.compile(r"\b(?:\d+)?'\s*[bodhBODH][0-9a-fA-F_xXzZ?]+")
    return [match.group(0) for match in pattern.finditer(expr) if re.search(r"[xXzZ?]", match.group(0))]


def _scheduler_approximation_diagnostics(module_name: str, processes: list[ProcessIR]) -> list[DiagnosticIR]:
    procedural = [process for process in processes if process.kind in {"always_comb", "always_ff", "initial"}]
    if len(procedural) <= 1:
        return []
    return [
        DiagnosticIR(
            severity="warning",
            module=module_name,
            code="event_scheduler_approximated",
            message=(
                "module contains multiple procedural blocks; generated SystemC uses "
                "SC_METHOD scheduling and may differ from full Verilog event ordering"
            ),
            node="Always",
        )
    ]


def _as_statement_list(value: object) -> list[dict[str, object]]:
    if not isinstance(value, list):
        return []
    return [item for item in value if isinstance(item, dict)]


def _as_case_items(value: object) -> list[dict[str, object]]:
    if not isinstance(value, list):
        return []
    return [item for item in value if isinstance(item, dict)]
