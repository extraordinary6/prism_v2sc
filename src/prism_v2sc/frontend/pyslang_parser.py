"""pyslang frontend integration.

slang elaborates the design — it resolves parameter overrides, unrolls
generate blocks, computes packed port widths, and resolves typedefs/packages.
``parse_sources`` returns a fully elaborated ``pyslang.ast.Compilation`` that
the lowerer in :mod:`prism_v2sc.frontend.lower_sv` walks to produce
``ModuleIR``.

Only synthesizable SystemVerilog is in scope. Dynamic SV constructs
(classes, randomization, programs) are not supported and surface as
diagnostics during lowering. Verification-only assertions, properties, and
sequences are ignored by the synthesizable design view.
"""

from __future__ import annotations

import shlex
from pathlib import Path
from typing import Sequence


def pyslang_available() -> bool:
    """Return whether pyslang can be imported in the active environment."""
    try:
        import pyslang  # noqa: F401
    except ImportError:
        return False
    return True


def parse_sources(
    sources: Sequence[Path],
    *,
    include_dirs: Sequence[Path] = (),
    defines: Sequence[str] = (),
):
    """Parse Verilog/SystemVerilog sources and return a slang ``Compilation``.

    slang's ``Driver`` is used so include directives and ``-D`` macros are
    applied through the same code path the standalone ``slang`` CLI uses.
    The returned compilation is fully elaborated: parameter overrides have
    been resolved, generate-if has been folded, and generate-for has been
    unrolled.
    """
    import pyslang as ps

    driver = ps.driver.Driver()
    driver.addStandardArgs()

    argv: list[str] = ["prism-v2sc"]
    for include_dir in include_dirs:
        argv.append(f"+incdir+{Path(include_dir).as_posix()}")
    for define in defines:
        argv.append(f"-D{define}")
    for source in sources:
        argv.append(Path(source).as_posix())

    joined = " ".join(shlex.quote(arg) for arg in argv)
    if not driver.parseCommandLine(joined):
        raise RuntimeError(f"pyslang failed to parse command line: {joined}")
    if not driver.processOptions():
        raise RuntimeError("pyslang failed to process options")
    if not driver.parseAllSources():
        # Don't abort: surface as diagnostics on the resulting Compilation so
        # downstream lowering can still report what it managed to elaborate.
        pass
    return driver.createCompilation()
