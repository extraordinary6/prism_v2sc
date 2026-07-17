"""Built-in model providers and provider registry."""

from __future__ import annotations

from dataclasses import dataclass, replace
from typing import Protocol

from prism_v2sc.ir.model import (
    DiagnosticIR,
    ModuleIR,
    ProcessIR,
    SensitivityIR,
    SignalIR,
)

from .manifest import ModuleRule


@dataclass(frozen=True)
class ProviderResult:
    module: ModuleIR
    status: str
    details: dict[str, object]


class ModelProvider(Protocol):
    name: str

    def apply(self, module: ModuleIR, rule: ModuleRule, *, strict: bool) -> ProviderResult:
        """Return a canonical replacement module and audit metadata."""


class ModelProviderRegistry:
    """Explicit registry; downstream packages can install custom providers."""

    def __init__(self) -> None:
        self._providers: dict[str, ModelProvider] = {}

    def register(self, provider: ModelProvider) -> None:
        if provider.name in self._providers:
            raise ValueError(f"model provider already registered: {provider.name}")
        self._providers[provider.name] = provider

    def get(self, name: str) -> ModelProvider | None:
        return self._providers.get(name)

    @property
    def names(self) -> tuple[str, ...]:
        return tuple(sorted(self._providers))


class BlackboxProvider:
    name = "blackbox"

    def apply(self, module: ModuleIR, rule: ModuleRule, *, strict: bool) -> ProviderResult:
        allowed = bool(rule.config.get("allow", False))
        severity = "warning" if allowed or not strict else "error"
        diagnostic = DiagnosticIR(
            severity=severity,
            module=module.name,
            code="model_blackbox_applied" if severity == "warning" else "model_blackbox_not_allowed",
            message=(
                f"module '{module.name}' is emitted as an interface-only blackbox; "
                "functional outputs are not modeled"
            ),
            node="blackbox",
        )
        replacement = replace(
            module,
            signals=(),
            continuous_assigns=(),
            processes=(),
            instances=(),
            generate_fors=(),
            subroutines=(),
            diagnostics=(diagnostic,),
        )
        return ProviderResult(
            module=replacement,
            status="applied" if severity == "warning" else "rejected",
            details={"allow": allowed, "functional": False},
        )


class MemoryProvider:
    """Canonical synchronous single-port memory provider.

    Supported contract: one clock, one enable, one write enable, one address,
    one write-data input, one read-data output, one-cycle synchronous read.
    """

    name = "memory"

    def apply(self, module: ModuleIR, rule: ModuleRule, *, strict: bool) -> ProviderResult:
        config = rule.config
        diagnostics: list[DiagnosticIR] = []

        def required_name(key: str) -> str:
            value = config.get(key)
            if not isinstance(value, str) or not value:
                diagnostics.append(
                    DiagnosticIR(
                        severity="error",
                        module=module.name,
                        code="model_memory_missing_port_role",
                        message=f"memory provider requires config.{key}",
                        node=key,
                    )
                )
                return ""
            return value

        clock = required_name("clock")
        enable = required_name("enable")
        write_enable = required_name("write_enable")
        address = required_name("address")
        write_data = required_name("write_data")
        read_data = required_name("read_data")
        depth = config.get("depth")
        read_latency = config.get("read_latency", 1)
        write_mode = config.get("write_mode", "read_first")
        byte_enable = config.get("byte_enable")
        lane_width = config.get("lane_width", 8)
        read_address_register = bool(config.get("read_address_register", False))

        parameter_names = {parameter.name for parameter in module.parameters}
        depth_is_parameter = isinstance(depth, str) and depth in parameter_names
        lane_width_is_parameter = isinstance(lane_width, str) and lane_width in parameter_names
        if not depth_is_parameter and (not isinstance(depth, int) or depth <= 0):
            diagnostics.append(
                DiagnosticIR(
                    severity="error",
                    module=module.name,
                    code="model_memory_invalid_depth",
                    message=(
                        "memory provider requires positive integer config.depth or "
                        "the name of a module parameter"
                    ),
                    node="depth",
                )
            )
        if read_latency != 1:
            diagnostics.append(
                DiagnosticIR(
                    severity="error",
                    module=module.name,
                    code="model_memory_unsupported_read_latency",
                    message="memory provider currently supports read_latency=1 only",
                    node="read_latency",
                )
            )
        if write_mode not in {"read_first", "write_first", "no_change"}:
            diagnostics.append(
                DiagnosticIR(
                    severity="error",
                    module=module.name,
                    code="model_memory_unsupported_write_mode",
                    message=f"unsupported memory write_mode: {write_mode}",
                    node="write_mode",
                )
            )
        if byte_enable is not None and (not isinstance(byte_enable, str) or not byte_enable):
            diagnostics.append(
                DiagnosticIR(
                    severity="error",
                    module=module.name,
                    code="model_memory_invalid_byte_enable",
                    message="config.byte_enable must be a non-empty port name",
                    node="byte_enable",
                )
            )
        if byte_enable is not None and not (
            (isinstance(lane_width, int) and lane_width > 0) or lane_width_is_parameter
        ):
            diagnostics.append(
                DiagnosticIR(
                    severity="error",
                    module=module.name,
                    code="model_memory_invalid_lane_width",
                    message=(
                        "byte-enabled memory requires positive integer config.lane_width "
                        "or the name of a module parameter/localparam"
                    ),
                    node="lane_width",
                )
            )
        if depth_is_parameter and byte_enable is None and not read_address_register:
            diagnostics.append(
                DiagnosticIR(
                    severity="error",
                    module=module.name,
                    code="model_memory_parameter_depth_requires_masked_contract",
                    message=(
                        "parameterized memory depth currently requires the "
                        "masked registered-address provider contract"
                    ),
                    node="depth",
                )
            )

        ports = {port.name: port for port in module.ports}
        for role, name in (
            ("clock", clock),
            ("enable", enable),
            ("write_enable", write_enable),
            ("address", address),
            ("write_data", write_data),
            ("read_data", read_data),
            ("byte_enable", byte_enable),
        ):
            if name and name not in ports:
                diagnostics.append(
                    DiagnosticIR(
                        severity="error",
                        module=module.name,
                        code="model_memory_port_not_found",
                        message=f"memory {role} port '{name}' does not exist",
                        node=name,
                    )
                )

        if diagnostics:
            replacement = replace(module, diagnostics=tuple(diagnostics))
            return ProviderResult(
                module=replacement,
                status="rejected",
                details={"provider": self.name},
            )

        memory_name = "__model_mem"
        if byte_enable is not None or read_address_register:
            if not read_address_register:
                diagnostics.append(
                    DiagnosticIR(
                        severity="error",
                        module=module.name,
                        code="model_memory_byte_enable_requires_read_address_register",
                        message=(
                            "byte-enabled memory currently requires "
                            "config.read_address_register=true"
                        ),
                        node="read_address_register",
                    )
                )
            if write_mode != "no_change":
                diagnostics.append(
                    DiagnosticIR(
                        severity="error",
                        module=module.name,
                        code="model_memory_masked_write_mode_unsupported",
                        message="byte-enabled registered-address memory requires write_mode=no_change",
                        node="write_mode",
                    )
                )
            if diagnostics:
                replacement = replace(module, diagnostics=tuple(diagnostics))
                return ProviderResult(module=replacement, status="rejected", details={"provider": self.name})
            diagnostic = DiagnosticIR(
                severity="warning",
                module=module.name,
                code="model_memory_applied",
                message=(
                    f"module '{module.name}' replaced by canonical masked synchronous memory "
                    f"model depth={depth}, lane_width={lane_width}, registered read address"
                ),
                node="memory",
            )
            replacement = replace(
                module,
                signals=(),
                continuous_assigns=(),
                processes=(),
                instances=(),
                generate_fors=(),
                subroutines=(),
                diagnostics=(diagnostic,),
                model={
                    "provider": "memory",
                    "implementation": "masked_registered_address",
                    "clock": clock,
                    "enable": enable,
                    "write_enable": write_enable,
                    "byte_enable": byte_enable,
                    "address": address,
                    "write_data": write_data,
                    "read_data": read_data,
                    "depth": depth,
                    "lane_width": lane_width,
                },
            )
            return ProviderResult(
                module=replacement,
                status="applied",
                details={
                    "depth": depth,
                    "read_latency": 1,
                    "write_mode": write_mode,
                    "byte_enable": byte_enable,
                    "lane_width": lane_width,
                    "read_address_register": True,
                    "storage": memory_name,
                },
            )

        index_expr = {"kind": "identifier", "name": address}
        memory_expr = {
            "kind": "bitselect",
            "target": {"kind": "identifier", "name": memory_name},
            "index": index_expr,
        }
        write_stmt = _assignment(memory_expr, {"kind": "identifier", "name": write_data})
        read_rhs: dict[str, object] = memory_expr
        if write_mode == "write_first":
            read_rhs = {
                "kind": "cond",
                "cond": {"kind": "identifier", "name": write_enable},
                "true": {"kind": "identifier", "name": write_data},
                "false": memory_expr,
            }
        read_stmt = _assignment({"kind": "identifier", "name": read_data}, read_rhs)

        enabled_body: list[dict[str, object]] = []
        if write_mode == "no_change":
            enabled_body.append(
                {
                    "type": "if",
                    "cond": f"!{write_enable}",
                    "cond_expr": {
                        "kind": "unop",
                        "op": "!",
                        "operand": {"kind": "identifier", "name": write_enable},
                    },
                    "true": [read_stmt],
                    "false": [],
                }
            )
        else:
            enabled_body.append(read_stmt)
        enabled_body.append(
            {
                "type": "if",
                "cond": write_enable,
                "cond_expr": {"kind": "identifier", "name": write_enable},
                "true": [write_stmt],
                "false": [],
            }
        )
        process_stmt = {
            "type": "if",
            "cond": enable,
            "cond_expr": {"kind": "identifier", "name": enable},
            "true": enabled_body,
            "false": [],
        }
        data_port = ports[write_data]
        process = ProcessIR(
            kind="always_ff",
            sensitivity=(SensitivityIR(signal=clock, edge="posedge"),),
            statements=(f"canonical memory model: {write_mode}",),
            structured_statements=(process_stmt,),
        )
        diagnostic = DiagnosticIR(
            severity="warning",
            module=module.name,
            code="model_memory_applied",
            message=(
                f"module '{module.name}' replaced by canonical synchronous memory "
                f"model depth={depth}, read_latency=1, write_mode={write_mode}"
            ),
            node="memory",
        )
        replacement = replace(
            module,
            signals=(
                SignalIR(
                    name=memory_name,
                    kind="reg",
                    width=data_port.width,
                    signed=data_port.signed,
                    unpacked_dims=((0, depth - 1),),
                    declared_unpacked_dims=((0, depth - 1),),
                ),
            ),
            continuous_assigns=(),
            processes=(process,),
            instances=(),
            generate_fors=(),
            subroutines=(),
            diagnostics=(diagnostic,),
        )
        return ProviderResult(
            module=replacement,
            status="applied",
            details={
                "depth": depth,
                "read_latency": 1,
                "write_mode": write_mode,
                "storage": memory_name,
            },
        )


def _assignment(left: dict[str, object], right: dict[str, object]) -> dict[str, object]:
    return {
        "type": "nonblocking_assign",
        "left": "",
        "right": "",
        "left_expr": left,
        "right_expr": right,
    }


def builtin_provider_registry() -> ModelProviderRegistry:
    registry = ModelProviderRegistry()
    registry.register(BlackboxProvider())
    registry.register(MemoryProvider())
    return registry
