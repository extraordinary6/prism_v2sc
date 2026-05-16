"""Lower Pyverilog AST nodes into the Phase 1 structural IR."""

from __future__ import annotations

from pyverilog.vparser import ast as vast

from prism_v2sc.ir.expressions import render_expr
from prism_v2sc.ir.model import (
    ArgIR,
    ContinuousAssignIR,
    DiagnosticIR,
    DesignIR,
    GenerateForIR,
    InstanceIR,
    ModuleIR,
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
    modules = tuple(_lower_module(module) for module in module_index.values())
    diagnostics = tuple(diagnostic for module in modules for diagnostic in module.diagnostics)
    return DesignIR(top=top, modules=modules, diagnostics=diagnostics)


def _lower_module(module: vast.ModuleDef) -> ModuleIR:
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

    for item in module.items or ():
        if isinstance(item, vast.Decl):
            item_parameters, item_signals = _lower_decl(item, port_names)
            parameters.extend(item_parameters)
            signals.extend(item_signals)
        elif isinstance(item, vast.Assign):
            continuous_assigns.append(
                ContinuousAssignIR(left=render_expr(item.left), right=render_expr(item.right))
            )
        elif isinstance(item, vast.Always):
            processes.append(_lower_always(item))
            diagnostics.extend(_statement_diagnostics(module.name, item.statement))
        elif isinstance(item, vast.Initial):
            diagnostics.append(
                _diagnostic(
                    module.name,
                    "unsupported_initial",
                    "initial blocks are parsed but not emitted as SystemC behavior",
                    item,
                )
            )
            diagnostics.extend(_statement_diagnostics(module.name, item.statement))
            processes.append(
                ProcessIR(
                    kind="initial",
                    statements=_statement_summaries(item.statement),
                    structured_statements=_structured_statements(item.statement),
                )
            )
        elif isinstance(item, vast.InstanceList):
            instances.extend(_lower_instance_list(item))
        elif isinstance(item, vast.GenerateStatement):
            lowered_generate_fors, generate_diagnostics = _lower_generate_statement(module.name, item)
            generate_fors.extend(lowered_generate_fors)
            diagnostics.extend(generate_diagnostics)
        elif isinstance(item, vast.Pragma):
            diagnostics.append(
                _diagnostic(
                    module.name,
                    "unsupported_pragma",
                    "pragmas are ignored by the current lowering flow",
                    item,
                    severity="warning",
                )
            )

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
    )


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
        }
    if isinstance(statement, vast.NonblockingSubstitution):
        return {
            "type": "nonblocking_assign",
            "left": render_expr(statement.left),
            "right": render_expr(statement.right),
        }
    if isinstance(statement, vast.IfStatement):
        return {
            "type": "if",
            "cond": render_expr(statement.cond),
            "true": list(_structured_statements(statement.true_statement)),
            "false": list(_structured_statements(statement.false_statement)),
        }
    if isinstance(statement, vast.CaseStatement):
        return {
            "type": "unsupported",
            "node": "case",
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
        return [
            _diagnostic(
                module_name,
                "unsupported_case",
                "case statements are parsed but not emitted as executable SystemC logic",
                statement,
            )
        ]
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


def _lower_generate_statement(
    module_name: str,
    generate: vast.GenerateStatement,
) -> tuple[list[GenerateForIR], list[DiagnosticIR]]:
    generate_fors: list[GenerateForIR] = []
    diagnostics: list[DiagnosticIR] = []
    for item in generate.items:
        if isinstance(item, vast.ForStatement):
            lowered = _lower_generate_for(item)
            if lowered is not None:
                generate_fors.append(lowered)
            else:
                diagnostics.append(
                    _diagnostic(
                        module_name,
                        "unsupported_generate_for",
                        "generate-for must use a named block containing instance lists",
                        item,
                    )
                )
        else:
            diagnostics.append(
                _diagnostic(
                    module_name,
                    "unsupported_generate_item",
                    "only simple generate-for items are supported",
                    item,
                )
            )
    return generate_fors, diagnostics


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
