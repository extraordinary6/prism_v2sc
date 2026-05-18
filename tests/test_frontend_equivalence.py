"""Cross-frontend equivalence tests.

Phase A exit criterion of the pyslang migration: for every equivalence
fixture, running the converter under ``--frontend pyverilog`` and
``--frontend pyslang`` produces functionally-equivalent SystemC. We check
this two ways:

1. **SystemC text identity** for fixtures with no parameter-driven width
   expressions. These should be byte-identical between the two frontends.
2. **SystemC presence + non-empty output** for fixtures with macro/param
   widths. The fully-elaborated pyslang output collapses an expression
   like ``(((WIDTH-1))-(0)+1)`` to a concrete integer; both forms compile
   to the same C++ type but the text differs. Equivalence is verified at
   the SystemC build / simulation level by the equivalence harness, not
   here.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from prism_v2sc.frontend.preprocess import collect_sources
from prism_v2sc.verify.harness import convert_with_metrics

FIXTURE_DIR = Path(__file__).parent / "equivalence" / "fixtures"

# Fixtures we expect to round-trip byte-identical SystemC between the two
# frontends. These are designs whose port widths are literal integers
# (e.g. ``[7:0]``) rather than parameter or macro expressions.
BYTE_IDENTICAL_FIXTURES = (
    ("mux2", ("mux2.v",), None),
    ("adder", ("adder.v",), None),
    ("byteswap", ("byteswap.v",), None),
    ("counter", ("counter.v",), None),
    ("fsm_handshake", ("fsm_handshake.v",), None),
    ("shift_register", ("shift_register.v",), None),
    ("alu", ("alu.v",), None),
    ("pipeline8", ("pipeline8.v",), None),
    ("function_alu", ("function_alu.v",), None),
)

# Fixtures where the two frontends produce equivalent but textually
# different SystemC (slang collapses width expressions to integers).
WIDTH_EXPR_FIXTURES = (
    ("top_datapath", None, "multi_file/sources.f"),
)


pyslang = pytest.importorskip("pyslang")


def _convert(top: str, sources: tuple[Path, ...], filelist: Path | None, out_dir: Path, frontend: str) -> dict[str, str]:
    """Convert via the named frontend; return ``{relpath: text}`` for emitted files."""
    if filelist is not None:
        source_set = collect_sources((), [filelist])
        src_list = source_set.sources
        include_dirs = source_set.include_dirs
        defines = source_set.defines
    else:
        src_list = tuple(sources)
        include_dirs = ()
        defines = ()
    artifacts = convert_with_metrics(
        src_list,
        top,
        include_dirs=include_dirs,
        defines=defines,
        out_dir=out_dir,
        frontend=frontend,
    )
    emitted: dict[str, str] = {}
    for path in artifacts.emitted_files:
        emitted[path.relative_to(out_dir).as_posix()] = path.read_text(encoding="utf-8")
    return emitted


@pytest.mark.parametrize("top,sources,filelist", BYTE_IDENTICAL_FIXTURES)
def test_systemc_byte_identical(top: str, sources: tuple[str, ...] | None, filelist: str | None, tmp_path: Path) -> None:
    """The two frontends must emit byte-identical SystemC for these fixtures."""
    source_paths = tuple(FIXTURE_DIR / src for src in sources) if sources else ()
    filelist_path = FIXTURE_DIR / filelist if filelist else None
    py_out = _convert(top, source_paths, filelist_path, tmp_path / "py", frontend="pyverilog")
    sl_out = _convert(top, source_paths, filelist_path, tmp_path / "sl", frontend="pyslang")
    assert set(py_out) == set(sl_out), (
        f"emitted file sets differ: pyverilog={sorted(py_out)} pyslang={sorted(sl_out)}"
    )
    for rel, py_text in py_out.items():
        assert py_text == sl_out[rel], f"SystemC text differs for {rel}"


@pytest.mark.parametrize("top,sources,filelist", WIDTH_EXPR_FIXTURES)
def test_systemc_equivalent_widths(top: str, sources: tuple[str, ...] | None, filelist: str | None, tmp_path: Path) -> None:
    """The two frontends emit the same set of files for these fixtures.

    Text differs only in width-expression form (``sc_uint<N>`` vs the
    pyverilog ``sc_uint<((N-1)-0+1)>`` shape). Both compile to the same
    C++ type; we verify this at the equivalence-harness level rather than
    by text diff.
    """
    source_paths = tuple(FIXTURE_DIR / src for src in sources) if sources else ()
    filelist_path = FIXTURE_DIR / filelist if filelist else None
    py_out = _convert(top, source_paths, filelist_path, tmp_path / "py", frontend="pyverilog")
    sl_out = _convert(top, source_paths, filelist_path, tmp_path / "sl", frontend="pyslang")
    assert set(py_out) == set(sl_out), (
        f"emitted file sets differ: pyverilog={sorted(py_out)} pyslang={sorted(sl_out)}"
    )
    for rel, sl_text in sl_out.items():
        assert sl_text.strip(), f"pyslang emitted empty SystemC for {rel}"


def test_ir_has_same_module_set(tmp_path: Path) -> None:
    """Across all fixtures, both frontends produce IR with the same module names."""
    inputs = [
        ("mux2", (FIXTURE_DIR / "mux2.v",), None),
        ("counter", (FIXTURE_DIR / "counter.v",), None),
        ("alu", (FIXTURE_DIR / "alu.v",), None),
        ("top_datapath", (), FIXTURE_DIR / "multi_file" / "sources.f"),
    ]
    for top, sources, filelist in inputs:
        if filelist is not None:
            source_set = collect_sources((), [filelist])
            src_list = source_set.sources
            include_dirs = source_set.include_dirs
            defines = source_set.defines
        else:
            src_list = sources
            include_dirs = ()
            defines = ()
        py = convert_with_metrics(src_list, top, include_dirs=include_dirs, defines=defines, frontend="pyverilog")
        sl = convert_with_metrics(src_list, top, include_dirs=include_dirs, defines=defines, frontend="pyslang")
        py_names = {m.name for m in py.design.modules}
        sl_names = {m.name for m in sl.design.modules}
        assert py_names == sl_names, f"module sets differ for {top}: py={py_names} sl={sl_names}"
