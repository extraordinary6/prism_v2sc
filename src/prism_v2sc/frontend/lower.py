"""Lower Pyverilog AST nodes into the Phase 1 structural IR."""

from __future__ import annotations

import re
from dataclasses import dataclass

from pyverilog.vparser import ast as vast

from prism_v2sc.analysis.drivers import analyze_process_drivers
from prism_v2sc.ir.expressions import lower_expr, render_expr
from prism_v2sc.ir.model import (
    ArgIR,
    ContinuousAssignIR,
    DiagnosticIR,
    DesignIR,
    GenerateForIR,
    InstanceIR,
    ModuleIR,
    ModuleSignature,
    ParameterIR,
    PortIR,
    ProcessIR,
    SensitivityIR,
    SignalIR,
)
from prism_v2sc.ir.widths import extract_width

from .module_index import build_module_index


def lower_design(ast: object, top: str) -> DesignIR:
    """Lower all modules in a Pyverilog AST into Phase 1 IR."""
    module_index = build_module_index(ast)
    if top not in module_index:
        known = ", ".join(sorted(module_index)) or "<none>"
        raise ValueError(f"top module '{top}' not found; known modules: {known}")

    module_order = list(module_index)
    lowered_by_name = {name: lower_module(module_index[name]) for name in module_order}
    reachable_names, missing_refs = _reachable_modules(top, lowered_by_name)

    modules: list[ModuleIR] = []
    for name in module_order:
        if name not in reachable_names:
            continue
        module = lowered_by_name[name]
        missing_targets = sorted({target for owner, target in missing_refs if owner == module.name})
        if missing_targets:
            diagnostics = list(module.diagnostics)
            for missing_target in missing_targets:
                diagnostics.append(
                    DiagnosticIR(
                        severity="error",
                        module=module.name,
                        code="unresolved_instance_module",
                        message=f"instance refers to unknown module '{missing_target}'",
                        node="Instance",
                    )
                )
            module = ModuleIR(
                name=module.name,
                parameters=module.parameters,
                ports=module.ports,
                signals=module.signals,
                continuous_assigns=module.continuous_assigns,
                processes=module.processes,
                instances=module.instances,
                generate_fors=module.generate_fors,
                diagnostics=tuple(diagnostics),
                source_path=module.source_path,
            )
        modules.append(module)

    modules_tuple = tuple(modules)
    diagnostics = tuple(diagnostic for module in modules_tuple for diagnostic in module.diagnostics)
    return DesignIR(top=top, modules=modules_tuple, diagnostics=diagnostics)


def _reachable_modules(
    top: str,
    modules_by_name: dict[str, ModuleIR],
) -> tuple[set[str], set[tuple[str, str]]]:
    reachable: set[str] = set()
    missing_refs: set[tuple[str, str]] = set()
    pending = [top]

    while pending:
        module_name = pending.pop()
        if module_name in reachable:
            continue
        reachable.add(module_name)
        module = modules_by_name.get(module_name)
        if module is None:
            continue
        for child in _instantiated_modules(module):
            if child in modules_by_name:
                pending.append(child)
            else:
                missing_refs.add((module_name, child))
    return reachable, missing_refs


def instantiated_modules(module: ModuleIR) -> list[str]:
    """Return module names instantiated directly by a lowered module."""
    child_modules = [instance.module for instance in module.instances]
    for generate_for in module.generate_fors:
        child_modules.extend(instance.module for instance in generate_for.instances)
    return child_modules


def _instantiated_modules(module: ModuleIR) -> list[str]:
    return instantiated_modules(module)


def lower_module(module: vast.ModuleDef, *, source_path: str = "") -> ModuleIR:
    """Lower one Pyverilog module definition into module IR."""
    parameters: list[ParameterIR] = []
    ports: list[PortIR] = []
    signals: list[SignalIR] = []
    continuous_assigns: list[ContinuousAssignIR] = []
    processes: list[ProcessIR] = []
    instances: list[InstanceIR] = []
    generate_fors: list[GenerateForIR] = []
    diagnostics: list[DiagnosticIR] = []
    port_names: set[str] = set()

    parameters.extend(_extract_paramlist(module.paramlist))
    for port in getattr(module.portlist, "ports", ()) or ():
        lowered = _lower_port(port)
        if lowered is not None:
            ports.append(lowered)
            port_names.add(lowered.name)

    accumulator = _LoweringAccumulator(
        module_name=module.name,
        parameters=parameters,
        signals=signals,
        continuous_assigns=continuous_assigns,
        processes=processes,
        instances=instances,
        generate_fors=generate_fors,
        diagnostics=diagnostics,
        port_names=port_names,
    )

    for item in module.items or ():
        _process_module_item(item, accumulator)

    diagnostics.extend(_xz_literal_diagnostics(module.name, processes, continuous_assigns))
    diagnostics.extend(_scheduler_approximation_diagnostics(module.name, processes))
    diagnostics.extend(analyze_process_drivers(module.name, tuple(processes)))

    return ModuleIR(
        name=module.name,
        parameters=tuple(parameters),
        ports=tuple(ports),
        signals=tuple(signals),
        continuous_assigns=tuple(continuous_assigns),
        processes=tuple(processes),
        instances=tuple(instances),
        generate_fors=tuple(generate_fors),
        diagnostics=tuple(diagnostics),
        source_path=source_path,
    )


def extract_signature(module: vast.ModuleDef) -> ModuleSignature:
    """Extract a lightweight port/parameter signature without lowering the body.

    This is the cheap-to-keep summary that the streaming flow caches so that
    parent modules can resolve positional / bit-bridge bindings against child
    port lists after the child AST has been released.
    """
    parameters = _extract_paramlist(module.paramlist)
    ports: list[PortIR] = []
    for port in getattr(module.portlist, "ports", ()) or ():
        lowered = _lower_port(port)
        if lowered is not None:
            ports.append(lowered)
    return ModuleSignature(
        name=module.name,
        ports=tuple(ports),
        parameters=tuple(parameters),
    )


@dataclass
class _LoweringAccumulator:
    """Mutable accumulator for module item lowering (including nested generates)."""

    module_name: str
    parameters: list[ParameterIR]
    signals: list[SignalIR]
    continuous_assigns: list[ContinuousAssignIR]
    processes: list[ProcessIR]
    instances: list[InstanceIR]
    generate_fors: list[GenerateForIR]
    diagnostics: list[DiagnosticIR]
    port_names: set[str]


def _process_module_item(item: object, acc: _LoweringAccumulator) -> None:
    if isinstance(item, vast.Decl):
        item_parameters, item_signals = _lower_decl(item, acc.port_names)
        acc.parameters.extend(item_parameters)
        acc.signals.extend(item_signals)
        return
    if isinstance(item, vast.Assign):
        acc.continuous_assigns.append(
            ContinuousAssignIR(
                left=render_expr(item.left),
                right=render_expr(item.right),
                left_expr=lower_expr(item.left),
                right_expr=lower_expr(item.right),
            )
        )
        return
    if isinstance(item, vast.Always):
        acc.processes.append(_lower_always(item))
        acc.diagnostics.extend(_statement_diagnostics(acc.module_name, item.statement))
        return
    if isinstance(item, vast.Initial):
        acc.diagnostics.append(
            _diagnostic(
                acc.module_name,
                "unsupported_initial",
                "initial blocks are parsed but not emitted as SystemC behavior",
                item,
            )
        )
        acc.diagnostics.extend(_statement_diagnostics(acc.module_name, item.statement))
        acc.processes.append(
            ProcessIR(
                kind="initial",
                statements=_statement_summaries(item.statement),
                structured_statements=_structured_statements(item.statement),
            )
        )
        return
    if isinstance(item, vast.InstanceList):
        acc.instances.extend(_lower_instance_list(item))
        return
    if isinstance(item, vast.GenerateStatement):
        _process_generate_statement(item, acc)
        return
    if isinstance(item, vast.Pragma):
        acc.diagnostics.append(
            _diagnostic(
                acc.module_name,
                "unsupported_pragma",
                "pragmas are ignored by the current lowering flow",
                item,
                severity="warning",
            )
        )
        return


def _process_generate_statement(generate: vast.GenerateStatement, acc: _LoweringAccumulator) -> None:
    for item in generate.items:
        _process_generate_item(item, acc)


def _process_generate_item(item: object, acc: _LoweringAccumulator) -> None:
    if isinstance(item, vast.ForStatement):
        lowered = _lower_generate_for(item)
        if lowered is not None:
            acc.generate_fors.append(lowered)
        else:
            acc.diagnostics.append(
                _diagnostic(
                    acc.module_name,
                    "unsupported_generate_for",
                    "generate-for must use a named block containing instance lists",
                    item,
                )
            )
        return
    if isinstance(item, vast.IfStatement):
        parameter_values = _parameter_value_map(acc.parameters)
        cond_value = _const_eval_expr(item.cond, parameter_values)
        if cond_value is None:
            acc.diagnostics.append(
                _diagnostic(
                    acc.module_name,
                    "unsupported_generate_if_condition",
                    "generate-if condition could not be evaluated from parameter values",
                    item,
                )
            )
            return
        chosen = item.true_statement if cond_value else item.false_statement
        _process_generate_branch(chosen, acc)
        return
    if isinstance(item, vast.Block):
        for child in item.statements:
            _process_generate_item(child, acc)
        return
    if isinstance(item, (vast.Decl, vast.Assign, vast.Always, vast.Initial, vast.InstanceList, vast.GenerateStatement, vast.Pragma)):
        _process_module_item(item, acc)
        return
    acc.diagnostics.append(
        _diagnostic(
            acc.module_name,
            "unsupported_generate_item",
            "only simple generate-for, generate-if, and block items are supported",
            item,
        )
    )


def _process_generate_branch(node: object | None, acc: _LoweringAccumulator) -> None:
    if node is None:
        return
    if isinstance(node, vast.Block):
        for child in node.statements:
            _process_generate_item(child, acc)
    else:
        _process_generate_item(node, acc)


def _parameter_value_map(parameters: list[ParameterIR]) -> dict[str, int]:
    values: dict[str, int] = {}
    for parameter in parameters:
        text = (parameter.value or "").strip()
        parsed = _parse_simple_constant(text)
        if parsed is not None:
            values[parameter.name] = parsed
    return values


def _parse_simple_constant(text: str) -> int | None:
    cleaned = text.strip().replace("_", "")
    if not cleaned:
        return None
    sized = re.match(r"^(?P<size>\d+)?\s*'\s*(?P<base>[bodhBODH])(?P<value>[0-9a-fA-F]+)$", cleaned)
    unsized = re.match(r"^'\s*(?P<base>[bodhBODH])(?P<value>[0-9a-fA-F]+)$", cleaned)
    bases = {"b": 2, "o": 8, "d": 10, "h": 16}
    if sized:
        try:
            return int(sized.group("value"), bases[sized.group("base").lower()])
        except ValueError:
            return None
    if unsized:
        try:
            return int(unsized.group("value"), bases[unsized.group("base").lower()])
        except ValueError:
            return None
    try:
        return int(cleaned)
    except ValueError:
        return None


def _const_eval_expr(node: object | None, parameter_values: dict[str, int]) -> int | None:
    """Static evaluation for generate-if conditions."""
    if node is None:
        return None
    cls_name = node.__class__.__name__
    if cls_name == "IntConst":
        return _parse_simple_constant(str(getattr(node, "value", "")))
    if cls_name == "Identifier":
        return parameter_values.get(str(getattr(node, "name", "")))
    if cls_name in {"Lvalue", "Rvalue"}:
        children = node.children() if hasattr(node, "children") else ()
        return _const_eval_expr(children[0], parameter_values) if children else None
    if cls_name in {"Plus", "Minus", "Times", "Divide", "Mod", "Sll", "Srl", "And", "Or", "Xor",
                    "Eq", "NotEq", "LessThan", "GreaterThan", "LessEq", "GreaterEq", "Land", "Lor"}:
        children = node.children() if hasattr(node, "children") else ()
        if len(children) < 2:
            return None
        left = _const_eval_expr(children[0], parameter_values)
        right = _const_eval_expr(children[1], parameter_values)
        if left is None or right is None:
            return None
        try:
            if cls_name == "Plus":
                return left + right
            if cls_name == "Minus":
                return left - right
            if cls_name == "Times":
                return left * right
            if cls_name == "Divide":
                return left // right if right else None
            if cls_name == "Mod":
                return left % right if right else None
            if cls_name == "Sll":
                return left << right
            if cls_name == "Srl":
                return left >> right
            if cls_name == "And":
                return left & right
            if cls_name == "Or":
                return left | right
            if cls_name == "Xor":
                return left ^ right
            if cls_name == "Eq":
                return int(left == right)
            if cls_name == "NotEq":
                return int(left != right)
            if cls_name == "LessThan":
                return int(left < right)
            if cls_name == "GreaterThan":
                return int(left > right)
            if cls_name == "LessEq":
                return int(left <= right)
            if cls_name == "GreaterEq":
                return int(left >= right)
            if cls_name == "Land":
                return int(bool(left) and bool(right))
            if cls_name == "Lor":
                return int(bool(left) or bool(right))
        except Exception:
            return None
    if cls_name in {"Uminus", "Uplus", "Ulnot", "Unot"}:
        children = node.children() if hasattr(node, "children") else ()
        if not children:
            return None
        operand = _const_eval_expr(children[0], parameter_values)
        if operand is None:
            return None
        if cls_name == "Uminus":
            return -operand
        if cls_name == "Uplus":
            return operand
        if cls_name == "Ulnot":
            return int(not operand)
        if cls_name == "Unot":
            return ~operand
    return None


def _extract_paramlist(paramlist: vast.Paramlist | None) -> list[ParameterIR]:
    if paramlist is None:
        return []
    parameters: list[ParameterIR] = []
    for decl in getattr(paramlist, "params", ()) or ():
        if isinstance(decl, vast.Decl):
            decl_parameters, _signals = _lower_decl(decl, set())
            parameters.extend(decl_parameters)
    return parameters


def _lower_port(port: object) -> PortIR | None:
    if isinstance(port, vast.Ioport):
        first = port.first
        second = port.second
        direction = _direction_of(first)
        kind = _kind_of(second) if second is not None else "wire"
        return PortIR(
            name=first.name,
            direction=direction,
            kind=kind,
            width=extract_width(getattr(first, "width", None)),
            signed=bool(getattr(first, "signed", False)),
        )
    if isinstance(port, vast.Port):
        return PortIR(name=port.name, direction="unknown")
    return None


def _lower_decl(decl: vast.Decl, port_names: set[str]) -> tuple[list[ParameterIR], list[SignalIR]]:
    parameters: list[ParameterIR] = []
    signals: list[SignalIR] = []
    for item in decl.list:
        if isinstance(item, (vast.Parameter, vast.Localparam)):
            parameters.append(
                ParameterIR(
                    name=item.name,
                    value=render_expr(getattr(item, "value", None)),
                    kind="localparam" if isinstance(item, vast.Localparam) else "parameter",
                )
            )
        elif isinstance(item, (vast.Wire, vast.Reg, vast.Integer, vast.Genvar)):
            if isinstance(item, vast.Genvar):
                continue
            if item.name not in port_names:
                signals.append(
                    SignalIR(
                        name=item.name,
                        kind=_kind_of(item),
                        width=extract_width(getattr(item, "width", None)),
                        signed=bool(getattr(item, "signed", False)),
                    )
                )
    return parameters, signals


def _lower_always(always: vast.Always) -> ProcessIR:
    sensitivity = tuple(_lower_sensitivity(always.sens_list))
    kind = "always_comb"
    if any(item.edge in {"posedge", "negedge"} for item in sensitivity):
        kind = "always_ff"
    return ProcessIR(
        kind=kind,
        sensitivity=sensitivity,
        statements=_statement_summaries(always.statement),
        structured_statements=_structured_statements(always.statement),
    )


def _lower_sensitivity(sens_list: vast.SensList | None) -> list[SensitivityIR]:
    if sens_list is None:
        return []
    lowered: list[SensitivityIR] = []
    for item in sens_list.list:
        lowered.append(SensitivityIR(signal=render_expr(item.sig), edge=item.type))
    return lowered


def _statement_summaries(statement: object | None) -> tuple[str, ...]:
    if statement is None:
        return ()
    if isinstance(statement, vast.Block):
        return tuple(_statement_summary(child) for child in statement.statements)
    return (_statement_summary(statement),)


def _statement_summary(statement: object) -> str:
    if isinstance(statement, vast.BlockingSubstitution):
        return f"{render_expr(statement.left)} = {render_expr(statement.right)}"
    if isinstance(statement, vast.NonblockingSubstitution):
        return f"{render_expr(statement.left)} <= {render_expr(statement.right)}"
    if isinstance(statement, vast.IfStatement):
        return f"if {render_expr(statement.cond)}"
    return statement.__class__.__name__


def _structured_statements(statement: object | None) -> tuple[dict[str, object], ...]:
    if statement is None:
        return ()
    if isinstance(statement, vast.Block):
        return tuple(_structured_statement(child) for child in statement.statements)
    return (_structured_statement(statement),)


def _structured_statement(statement: object) -> dict[str, object]:
    if isinstance(statement, vast.BlockingSubstitution):
        return {
            "type": "blocking_assign",
            "left": render_expr(statement.left),
            "right": render_expr(statement.right),
            "left_expr": lower_expr(statement.left),
            "right_expr": lower_expr(statement.right),
        }
    if isinstance(statement, vast.NonblockingSubstitution):
        return {
            "type": "nonblocking_assign",
            "left": render_expr(statement.left),
            "right": render_expr(statement.right),
            "left_expr": lower_expr(statement.left),
            "right_expr": lower_expr(statement.right),
        }
    if isinstance(statement, vast.IfStatement):
        return {
            "type": "if",
            "cond": render_expr(statement.cond),
            "cond_expr": lower_expr(statement.cond),
            "true": list(_structured_statements(statement.true_statement)),
            "false": list(_structured_statements(statement.false_statement)),
        }
    if isinstance(statement, vast.CaseStatement):
        return {
            "type": "case",
            "expr": render_expr(statement.comp),
            "expr_tree": lower_expr(statement.comp),
            "items": [
                {
                    "conds": [] if item.cond is None else [render_expr(cond) for cond in item.cond],
                    "cond_exprs": [] if item.cond is None else [lower_expr(cond) for cond in item.cond],
                    "statements": list(_structured_statements(item.statement)),
                }
                for item in statement.caselist
            ],
        }
    return {
        "type": "unsupported",
        "node": statement.__class__.__name__,
    }


def _statement_diagnostics(module_name: str, statement: object | None) -> list[DiagnosticIR]:
    if statement is None:
        return []
    if isinstance(statement, vast.Block):
        diagnostics: list[DiagnosticIR] = []
        for child in statement.statements:
            diagnostics.extend(_statement_diagnostics(module_name, child))
        return diagnostics
    if isinstance(statement, vast.IfStatement):
        diagnostics = _statement_diagnostics(module_name, statement.true_statement)
        diagnostics.extend(_statement_diagnostics(module_name, statement.false_statement))
        return diagnostics
    if isinstance(statement, vast.CaseStatement):
        diagnostics: list[DiagnosticIR] = []
        for item in statement.caselist:
            diagnostics.extend(_statement_diagnostics(module_name, item.statement))
        return diagnostics
    if isinstance(statement, vast.ForStatement):
        return [
            _diagnostic(
                module_name,
                "unsupported_procedural_for",
                "procedural for-loops are not supported in always/initial blocks",
                statement,
            )
        ]
    if isinstance(statement, (vast.BlockingSubstitution, vast.NonblockingSubstitution)):
        return []
    return [
        _diagnostic(
            module_name,
            f"unsupported_{statement.__class__.__name__.lower()}",
            "statement is not supported by the current SystemC emitter",
            statement,
        )
    ]


def _lower_instance_list(instance_list: vast.InstanceList) -> list[InstanceIR]:
    instances: list[InstanceIR] = []
    for instance in instance_list.instances:
        parameters = tuple(
            ArgIR(name=arg.paramname or "", value=render_expr(arg.argname))
            for arg in getattr(instance, "parameterlist", ()) or ()
        )
        ports = tuple(
            ArgIR(name=arg.portname or "", value=render_expr(arg.argname))
            for arg in getattr(instance, "portlist", ()) or ()
        )
        instances.append(
            InstanceIR(module=instance.module, name=instance.name, parameters=parameters, ports=ports)
        )
    return instances


def _lower_generate_for(statement: vast.ForStatement) -> GenerateForIR | None:
    body = statement.statement
    if not isinstance(body, vast.Block):
        return None
    instances: list[InstanceIR] = []
    for item in body.statements:
        if isinstance(item, vast.InstanceList):
            instances.extend(_lower_instance_list(item))
    init_left = render_expr(statement.pre.left) if hasattr(statement.pre, "left") else ""
    var = init_left
    return GenerateForIR(
        name=body.scope or "genblk",
        var=var,
        init=f"{render_expr(statement.pre.left)} = {render_expr(statement.pre.right)}",
        condition=render_expr(statement.cond),
        step=f"{render_expr(statement.post.left)} = {render_expr(statement.post.right)}",
        instances=tuple(instances),
    )


def _direction_of(node: object) -> str:
    if isinstance(node, vast.Input):
        return "input"
    if isinstance(node, vast.Output):
        return "output"
    if isinstance(node, vast.Inout):
        return "inout"
    return "unknown"


def _kind_of(node: object | None) -> str:
    if node is None:
        return "wire"
    name = node.__class__.__name__.lower()
    if name == "reg":
        return "reg"
    if name == "wire":
        return "wire"
    if name == "integer":
        return "integer"
    if name == "genvar":
        return "genvar"
    return name


def _diagnostic(
    module: str,
    code: str,
    message: str,
    node: object,
    severity: str = "error",
) -> DiagnosticIR:
    return DiagnosticIR(
        severity=severity,
        module=module,
        code=code,
        message=message,
        node=node.__class__.__name__,
    )


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
