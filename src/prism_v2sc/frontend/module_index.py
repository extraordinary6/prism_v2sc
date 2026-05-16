"""Module indexing for parsed Pyverilog ASTs."""

from __future__ import annotations

from dataclasses import dataclass

from pyverilog.vparser.ast import ModuleDef


@dataclass(frozen=True)
class ModuleIndexEntry:
    """Minimal module index metadata."""

    name: str
    source: str


def build_module_index(ast: object) -> dict[str, ModuleDef]:
    """Return a module-name to ModuleDef mapping from a Pyverilog AST."""
    definitions = getattr(getattr(ast, "description", None), "definitions", ())
    modules = [definition for definition in definitions if isinstance(definition, ModuleDef)]
    return {module.name: module for module in modules}
