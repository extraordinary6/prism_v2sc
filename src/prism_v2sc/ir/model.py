"""Core IR model definitions."""

from __future__ import annotations

from dataclasses import asdict, dataclass, field
from typing import Any


@dataclass(frozen=True)
class SourceLocIR:
    """Source location in the original RTL."""

    file: str
    line: int
    column: int


@dataclass(frozen=True)
class WidthIR:
    """Verilog packed width range."""

    msb: str
    lsb: str


@dataclass(frozen=True)
class ParameterIR:
    """Module parameter or localparam."""

    name: str
    value: str
    kind: str = "parameter"


@dataclass(frozen=True)
class PortIR:
    """Module port metadata."""

    name: str
    direction: str
    kind: str = "wire"
    width: WidthIR | None = None
    signed: bool = False
    loc: SourceLocIR | None = None


@dataclass(frozen=True)
class SignalIR:
    """Internal signal declaration."""

    name: str
    kind: str
    width: WidthIR | None = None
    signed: bool = False
    # Outermost unpacked dimensions of the signal, outermost first. Each
    # entry is the (msb, lsb) of one Verilog unpacked range. For a plain
    # vector (``reg [7:0] x``) this is empty. For ``reg [7:0] mem [0:15]``
    # it is ``((0, 15),)``. Codegen treats signals with non-empty
    # ``unpacked_dims`` as ``sc_signal<inner> name[D0][D1]...;`` arrays.
    unpacked_dims: tuple[tuple[int, int], ...] = ()
    loc: SourceLocIR | None = None


@dataclass(frozen=True)
class EnumValueIR:
    """One flattened SystemVerilog enum member."""

    name: str
    value: int


@dataclass(frozen=True)
class PackedFieldIR:
    """One field inside a flattened packed struct / union alias."""

    name: str
    offset: int
    width: WidthIR | None = None
    signed: bool = False


@dataclass(frozen=True)
class TypeAliasIR:
    """SystemVerilog typedef metadata after elaborated type flattening."""

    name: str
    width: WidthIR | None = None
    signed: bool = False
    kind: str = "typedef"
    enum_values: tuple[EnumValueIR, ...] = field(default_factory=tuple)
    packed_fields: tuple[PackedFieldIR, ...] = field(default_factory=tuple)


@dataclass(frozen=True)
class ContinuousAssignIR:
    """Continuous assignment."""

    left: str
    right: str
    left_expr: dict[str, Any] | None = None
    right_expr: dict[str, Any] | None = None
    loc: SourceLocIR | None = None


@dataclass(frozen=True)
class SensitivityIR:
    """Process sensitivity item."""

    signal: str
    edge: str = "level"


@dataclass(frozen=True)
class ProcessIR:
    """Always/initial process summary."""

    kind: str
    sensitivity: tuple[SensitivityIR, ...] = field(default_factory=tuple)
    statements: tuple[str, ...] = field(default_factory=tuple)
    structured_statements: tuple[dict[str, Any], ...] = field(default_factory=tuple)
    loc: SourceLocIR | None = None


@dataclass(frozen=True)
class ArgIR:
    """Named module argument."""

    name: str
    value: str


@dataclass(frozen=True)
class InstanceIR:
    """Module instance summary."""

    module: str
    name: str
    parameters: tuple[ArgIR, ...] = field(default_factory=tuple)
    ports: tuple[ArgIR, ...] = field(default_factory=tuple)


@dataclass(frozen=True)
class GenerateForIR:
    """Simple generate-for block summary."""

    name: str
    var: str
    init: str
    condition: str
    step: str
    instances: tuple[InstanceIR, ...] = field(default_factory=tuple)


@dataclass(frozen=True)
class DiagnosticIR:
    """Unsupported or risky construct found while lowering a design."""

    severity: str
    module: str
    code: str
    message: str
    node: str = ""


@dataclass(frozen=True)
class SubroutineParamIR:
    """Formal parameter of a Verilog function or task."""

    name: str
    direction: str = "input"
    width: WidthIR | None = None
    signed: bool = False


@dataclass(frozen=True)
class SubroutineIR:
    """Synthesizable function or task definition."""

    name: str
    kind: str = "function"
    return_width: WidthIR | None = None
    return_signed: bool = False
    params: tuple[SubroutineParamIR, ...] = field(default_factory=tuple)
    body_statements: tuple[dict[str, Any], ...] = field(default_factory=tuple)


@dataclass(frozen=True)
class ModuleSignature:
    """Lightweight module signature used during streaming traversal.

    Carries only the port list and parameter list needed to bind instances
    (including positional bindings) without keeping the full lowered IR
    around.
    """

    name: str
    ports: tuple[PortIR, ...] = field(default_factory=tuple)
    parameters: tuple[ParameterIR, ...] = field(default_factory=tuple)


@dataclass(frozen=True)
class ModuleIR:
    """Module-level intermediate representation."""

    name: str
    parameters: tuple[ParameterIR, ...] = field(default_factory=tuple)
    ports: tuple[PortIR, ...] = field(default_factory=tuple)
    type_aliases: tuple[TypeAliasIR, ...] = field(default_factory=tuple)
    signals: tuple[SignalIR, ...] = field(default_factory=tuple)
    continuous_assigns: tuple[ContinuousAssignIR, ...] = field(default_factory=tuple)
    processes: tuple[ProcessIR, ...] = field(default_factory=tuple)
    instances: tuple[InstanceIR, ...] = field(default_factory=tuple)
    generate_fors: tuple[GenerateForIR, ...] = field(default_factory=tuple)
    subroutines: tuple[SubroutineIR, ...] = field(default_factory=tuple)
    diagnostics: tuple[DiagnosticIR, ...] = field(default_factory=tuple)
    source_path: str = ""


@dataclass(frozen=True)
class DesignIR:
    """Design-level IR containing all parsed modules."""

    top: str
    modules: tuple[ModuleIR, ...]
    diagnostics: tuple[DiagnosticIR, ...] = field(default_factory=tuple)

    def to_dict(self) -> dict[str, Any]:
        """Return a JSON-serializable dictionary."""
        return asdict(self)
