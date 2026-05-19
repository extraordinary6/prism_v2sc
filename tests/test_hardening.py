from __future__ import annotations

import json
from pathlib import Path

from prism_v2sc.verify.harness import (
    MAX_CAPTURED_TOOL_OUTPUT_CHARS,
    ToolMeasurement,
    _truncate_text,
)

from _pyslang_helper import lower_via_pyslang


def test_x_z_literals_emit_approximation_warning(tmp_path: Path) -> None:
    rtl = tmp_path / "xz.v"
    rtl.write_text(
        """
module xz(input wire a, output reg [3:0] y);
  always @(*) begin
    if (a) begin
      y = 4'b10xz;
    end else begin
      y = 4'b????;
    end
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "xz")
    diagnostics = [diagnostic for diagnostic in design.diagnostics if diagnostic.code == "x_z_literal_approximated"]

    assert len(diagnostics) == 2
    assert all(diagnostic.severity == "warning" for diagnostic in diagnostics)
    assert "approximates those bits as zero" in diagnostics[0].message


def test_tool_output_truncation_marks_large_payloads() -> None:
    text = "x" * (MAX_CAPTURED_TOOL_OUTPUT_CHARS + 100)

    truncated, was_truncated = _truncate_text(text, MAX_CAPTURED_TOOL_OUTPUT_CHARS)

    assert was_truncated is True
    assert len(truncated) <= MAX_CAPTURED_TOOL_OUTPUT_CHARS
    assert "truncated 100 character(s)" in truncated


def test_tool_measurement_serializes_truncation_flags() -> None:
    measurement = ToolMeasurement(
        tool="verilator",
        available=True,
        stdout="short",
        stderr="short",
        stdout_truncated=True,
    )

    payload = json.loads(json.dumps(measurement.__dict__))

    assert payload["stdout_truncated"] is True
    assert payload["stderr_truncated"] is False
