"""Shared pyslang lowering shim for unit tests.

Tests read ``lower_via_pyslang([rtl], top)`` to get a fully elaborated
``DesignIR`` from a list of RTL paths in one call.

The helper also surfaces slang's compilation-level diagnostics (e.g.
``UnknownModule``, ``Redefinition``) so tests can assert on them the same
way the flow path does — ``frontend.lower.lower_design`` itself only attaches
per-module diagnostics, but the production CLI funnels through
``lower_design_top_down`` which collects both. We mirror that here.
"""

from __future__ import annotations

from pathlib import Path
from typing import Sequence

from prism_v2sc.frontend.flow import _collect_slang_diagnostics
from prism_v2sc.frontend.lower import lower_design
from prism_v2sc.frontend.pyslang_parser import parse_sources
from prism_v2sc.ir.model import DesignIR


def lower_via_pyslang(sources: Sequence[Path], top: str) -> DesignIR:
    """Parse ``sources`` with pyslang and lower the elaborated design.

    Returns a ``DesignIR`` with slang's compilation-level diagnostics
    merged into ``design.diagnostics`` so tests get the same coverage they
    would through the CLI.
    """
    compilation = parse_sources(sources)
    design = lower_design(compilation, top)
    slang_diags = tuple(_collect_slang_diagnostics(compilation))
    if slang_diags:
        design = DesignIR(
            top=design.top,
            modules=design.modules,
            diagnostics=design.diagnostics + slang_diags,
        )
    return design
