"""Unit tests for synthesizable Verilog/SystemVerilog function lowering.

Covers Phase A first-round scope: ``function`` only. ``task`` lowering is
gated behind an unsupported diagnostic on both frontends until a follow-up
round adds it.
"""

from __future__ import annotations

import textwrap
from pathlib import Path

import pyverilog.vparser.parser as pyverilog_parser
import pytest

from prism_v2sc.codegen.systemc import generate_systemc_header
from prism_v2sc.frontend.lower import lower_design as lower_pyverilog
from prism_v2sc.ir.model import SubroutineIR


pyslang = pytest.importorskip("pyslang")


SIMPLE_FUNCTION_SRC = """
module simple_fn(input [7:0] q, output [7:0] r);
  function [7:0] add_one;
    input [7:0] a;
    begin
      add_one = a + 8'd1;
    end
  endfunction
  assign r = add_one(q);
endmodule
"""


SIMPLE_FUNCTION_SV_SRC = """
module simple_fn(input [7:0] q, output [7:0] r);
  function automatic [7:0] add_one(input [7:0] a);
    add_one = a + 8'd1;
  endfunction
  assign r = add_one(q);
endmodule
"""


def _design_via_pyverilog(src: str, top: str, tmp_path: Path):
    tmp_path.mkdir(parents=True, exist_ok=True)
    src_path = tmp_path / "src.v"
    src_path.write_text(textwrap.dedent(src))
    ast, _ = pyverilog_parser.parse([str(src_path)])
    return lower_pyverilog(ast, top)


def _design_via_pyslang(src: str, top: str, tmp_path: Path):
    from prism_v2sc.frontend.lower_sv import lower_design as lower_pyslang
    from prism_v2sc.frontend.pyslang_parser import parse_sources
    tmp_path.mkdir(parents=True, exist_ok=True)
    src_path = tmp_path / "src.sv"
    src_path.write_text(textwrap.dedent(src))
    compilation = parse_sources([src_path])
    return lower_pyslang(compilation, top)


def test_pyverilog_lowers_function_to_subroutine_ir(tmp_path: Path) -> None:
    design = _design_via_pyverilog(SIMPLE_FUNCTION_SRC, "simple_fn", tmp_path)
    module = design.modules[0]
    assert len(module.subroutines) == 1
    sub = module.subroutines[0]
    assert isinstance(sub, SubroutineIR)
    assert sub.name == "add_one"
    assert sub.kind == "function"
    assert sub.return_width is not None
    assert (sub.return_width.msb, sub.return_width.lsb) == ("7", "0")
    assert len(sub.params) == 1
    assert sub.params[0].name == "a"
    assert sub.params[0].direction == "input"
    assert len(sub.body_statements) == 1
    assert sub.body_statements[0]["type"] == "blocking_assign"


def test_pyslang_lowers_function_to_subroutine_ir(tmp_path: Path) -> None:
    design = _design_via_pyslang(SIMPLE_FUNCTION_SV_SRC, "simple_fn", tmp_path)
    module = design.modules[0]
    assert len(module.subroutines) == 1
    sub = module.subroutines[0]
    assert sub.name == "add_one"
    assert sub.kind == "function"
    assert (sub.return_width.msb, sub.return_width.lsb) == ("7", "0")
    assert sub.params[0].name == "a"
    assert sub.params[0].direction == "input"
    assert len(sub.body_statements) == 1


def test_function_call_lowered_to_funcall_node(tmp_path: Path) -> None:
    design = _design_via_pyverilog(SIMPLE_FUNCTION_SRC, "simple_fn", tmp_path)
    module = design.modules[0]
    assert len(module.continuous_assigns) == 1
    rhs = module.continuous_assigns[0].right_expr
    assert rhs is not None and rhs.get("kind") == "funcall"
    assert rhs["name"] == "add_one"
    assert rhs["args"][0] == {"kind": "identifier", "name": "q"}


def test_codegen_emits_function_method(tmp_path: Path) -> None:
    design = _design_via_pyverilog(SIMPLE_FUNCTION_SRC, "simple_fn", tmp_path)
    header = generate_systemc_header(design)
    assert "sc_uint<8> add_one(sc_uint<8> a) const" in header
    assert "sc_uint<8> add_one;" in header
    assert "return add_one;" in header
    assert "add_one(q.read())" in header


def test_both_frontends_emit_identical_function_systemc(tmp_path: Path) -> None:
    py_design = _design_via_pyverilog(SIMPLE_FUNCTION_SRC, "simple_fn", tmp_path / "py")
    sl_design = _design_via_pyslang(SIMPLE_FUNCTION_SV_SRC, "simple_fn", tmp_path / "sl")
    assert generate_systemc_header(py_design) == generate_systemc_header(sl_design)


PYVERILOG_TASK_SRC = """
module with_task;
  reg [7:0] r;
  task do_set;
    input [7:0] a;
    begin
      r = a;
    end
  endtask
endmodule
"""


PYSLANG_TASK_SRC = """
module with_task;
  logic [7:0] r;
  task automatic do_set(input [7:0] a);
    r = a;
  endtask
endmodule
"""


def test_pyverilog_task_emits_unsupported_diagnostic(tmp_path: Path) -> None:
    design = _design_via_pyverilog(PYVERILOG_TASK_SRC, "with_task", tmp_path)
    module = design.modules[0]
    assert module.subroutines == ()
    codes = {d.code for d in module.diagnostics}
    assert "unsupported_task_first_round" in codes


def test_pyslang_task_emits_unsupported_diagnostic(tmp_path: Path) -> None:
    design = _design_via_pyslang(PYSLANG_TASK_SRC, "with_task", tmp_path)
    module = design.modules[0]
    assert module.subroutines == ()
    codes = {d.code for d in module.diagnostics}
    assert "unsupported_task_first_round" in codes
