"""Lower a slang ``Compilation`` into the Phase 1 structural IR.

Companion of :mod:`prism_v2sc.frontend.pyslang_parser`. slang has already
elaborated the design before we walk it: parameter overrides have been
applied, generate-if has been folded, generate-for has been unrolled, and
port widths are concrete integers.

This is the **synthesizable** SystemVerilog lowering. Dynamic SV constructs
(classes, randomization, programs, runtime assertions/properties) are out
of scope; they surface as diagnostics rather than getting partially
lowered.

The output ``ModuleIR`` shape is identical to what the pyverilog frontend
produces; differences are limited to width values (slang returns resolved
integers; pyverilog returns the original Verilog text) and to
generate-for, which slang has already unrolled and which we therefore
materialize as concrete ``InstanceIR`` entries inside the parent module
rather than as a separate ``GenerateForIR``.
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
    InstanceIR,
    ModuleIR,
    ModuleSignature,
    ParameterIR,
    PortIR,
    ProcessIR,
    SensitivityIR,
    SignalIR,
    SubroutineIR,
    SubroutineParamIR,
    WidthIR,
)

from .lower import (
    _scheduler_approximation_diagnostics,
    _xz_literal_diagnostics,
)


_SIZED_LITERAL = re.compile(
    r"^(?P<size>\d+)?\s*'\s*(?P<base>[bodhBODH])(?P<digits>[0-9a-fA-F_xXzZ?]+)$"
)
_UNSIZED_LITERAL = re.compile(
    r"^'\s*(?P<base>[bodhBODH])(?P<digits>[0-9a-fA-F_xXzZ?]+)$"
)
_BASE_MAP = {"b": 2, "o": 8, "d": 10, "h": 16}


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
            _walk_generate_block(member, name, signals, continuous_assigns, processes, instances, diagnostics, port_names)
        elif kind == "GenerateBlockArraySymbol":
            for sub in member.entries:
                if not getattr(sub, "isUninstantiated", False):
                    _walk_generate_block(sub, name, signals, continuous_assigns, processes, instances, diagnostics, port_names)
        elif kind == "SubroutineSymbol":
            subroutine, body_diagnostics = _lower_subroutine(member, name)
            if subroutine is not None:
                subroutines.append(subroutine)
            diagnostics.extend(body_diagnostics)
        elif kind in {"TypeAliasType", "TransparentMemberSymbol", "ForwardingTypedefSymbol",
                       "TypeParameterSymbol", "GenericClassDefSymbol", "ClassType",
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

    # Re-use the IR-level analyses from the pyverilog path. They operate
    # purely on ProcessIR / ContinuousAssignIR shape, so they're agnostic
    # to which frontend produced the IR.
    diagnostics.extend(_xz_literal_diagnostics(name, processes, continuous_assigns))
    diagnostics.extend(_scheduler_approximation_diagnostics(name, processes))
    diagnostics.extend(analyze_process_drivers(name, tuple(processes)))

    return ModuleIR(
        name=name,
        parameters=tuple(parameters),
        ports=tuple(ports),
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
    kind = "reg" if declared_reg else _slang_type_kind(variable.type)
    return SignalIR(
        name=variable.name,
        kind=kind,
        width=_width_from_type(variable.type),
        signed=bool(getattr(variable.type, "isSigned", False)),
    )


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
    return {
        "type": "case",
        "expr": _render_expression(statement.expr),
        "expr_tree": _lower_expression(statement.expr),
        "items": items,
    }


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


def _lower_subroutine(symbol: Any, module_name: str) -> tuple[SubroutineIR | None, list[DiagnosticIR]]:
    """Lower a slang ``SubroutineSymbol`` into ``SubroutineIR``.

    First-round scope is function-only; task subroutines emit a diagnostic
    and are not materialized in the IR (mirroring the pyverilog path).
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


def _lower_instance(instance: Any) -> InstanceIR:
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
    return InstanceIR(
        module=instance.definition.name,
        name=instance.name,
        parameters=parameters,
        ports=tuple(ports),
    )


def _lower_instance_array(array_symbol: Any) -> list[InstanceIR]:
    flattened: list[InstanceIR] = []
    for element in array_symbol.elements:
        if type(element).__name__ == "InstanceArraySymbol":
            flattened.extend(_lower_instance_array(element))
        elif type(element).__name__ == "InstanceSymbol":
            flattened.append(_lower_instance(element))
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
) -> None:
    """Flatten an elaborated generate block back into the parent module's lists.

    slang has already chosen the active branch (generate-if) and unrolled the
    iterations (generate-for). For Phase A we materialize the contents
    directly into the parent module: each unrolled instance becomes a plain
    ``InstanceIR``; declared signals become parent-level ``SignalIR``.
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
            instances.append(_lower_instance(member))
        elif kind == "InstanceArraySymbol":
            instances.extend(_lower_instance_array(member))
        elif kind == "GenerateBlockSymbol":
            _walk_generate_block(member, module_name, signals, continuous_assigns, processes, instances, diagnostics, port_names)
        elif kind == "GenerateBlockArraySymbol":
            for sub in member.entries:
                if not getattr(sub, "isUninstantiated", False):
                    _walk_generate_block(sub, module_name, signals, continuous_assigns, processes, instances, diagnostics, port_names)


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
        return getattr(expr.symbol, "name", "")
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
        return {"kind": "identifier", "name": getattr(expr.symbol, "name", "")}
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
    int_value = 0
    if value is not None:
        bit_width = getattr(value, "bitWidth", None)
        if bit_width is not None and width is None:
            width = int(bit_width)
        try:
            int_value = int(str(value))
        except (TypeError, ValueError):
            int_value = 0
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
        fixed_range = slang_type.getBitVectorRange()
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
