"""Pyverilog parser integration."""

from __future__ import annotations

import contextlib
import io
from pathlib import Path

from pyverilog.vparser.parser import parse

def pyverilog_available() -> bool:
    """Return whether Pyverilog can be imported in the active environment."""
    try:
        import pyverilog  # noqa: F401
    except ImportError:
        return False
    return True


def parse_verilog(sources: list[Path]) -> object:
    """Parse Verilog sources and return the Pyverilog AST.

    Pyverilog emits parser-generation chatter to stdout/stderr on first use.
    The CLI needs stable output, so this integration captures that noise.
    """
    normalized_sources = [str(source) for source in sources]
    parser_output_dir = Path("build") / "pyverilog"
    parser_output_dir.mkdir(parents=True, exist_ok=True)
    stdout = io.StringIO()
    stderr = io.StringIO()
    with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
        ast, _directives = parse(
            normalized_sources,
            outputdir=str(parser_output_dir),
            debug=False,
        )
    return ast
