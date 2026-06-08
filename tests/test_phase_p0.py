"""Tests for Phase P0 - JSON schemas and CLI."""

from __future__ import annotations

import json
from pathlib import Path

from prism_v2sc.power.schemas import (
    POWER_STATIC_SCHEMA,
    POWER_PROFILE_SCHEMA,
    POWER_REPORT_SCHEMA,
    export_power_static_json,
)
from prism_v2sc.power.cli import run_power_static
from prism_v2sc.analysis.power_static import PowerSuspect
from prism_v2sc.ir.model import SourceLocIR

from _pyslang_helper import lower_via_pyslang


def test_power_static_schema_structure() -> None:
    """Test that power_static.json schema is well-formed."""
    assert "type" in POWER_STATIC_SCHEMA
    assert POWER_STATIC_SCHEMA["type"] == "object"
    assert "required" in POWER_STATIC_SCHEMA
    assert "version" in POWER_STATIC_SCHEMA["required"]
    assert "suspects" in POWER_STATIC_SCHEMA["required"]


def test_power_profile_schema_structure() -> None:
    """Test that power_profile.json schema is well-formed."""
    assert "type" in POWER_PROFILE_SCHEMA
    assert POWER_PROFILE_SCHEMA["type"] == "object"
    assert "required" in POWER_PROFILE_SCHEMA
    assert "version" in POWER_PROFILE_SCHEMA["required"]
    assert "probes" in POWER_PROFILE_SCHEMA["required"]


def test_power_report_schema_structure() -> None:
    """Test that power_report.json schema is well-formed."""
    assert "type" in POWER_REPORT_SCHEMA
    assert POWER_REPORT_SCHEMA["type"] == "object"
    assert "required" in POWER_REPORT_SCHEMA
    assert "version" in POWER_REPORT_SCHEMA["required"]
    assert "hotspots" in POWER_REPORT_SCHEMA["required"]


def test_export_power_static_json() -> None:
    """Test exporting static analysis to JSON."""
    suspects = [
        PowerSuspect(
            module="test_module",
            signal="test_signal",
            reason_code="clock_gating_candidate",
            message="Test message",
            recommendation="Test recommendation",
            severity="info",
            loc=SourceLocIR(file="test.v", line=10, column=5),
            width=32,
            metrics={"fanout": 10},
        )
    ]

    result = export_power_static_json(suspects, "test_top")

    # Check structure
    assert "version" in result
    assert result["version"] == "1.0"
    assert "design" in result
    assert result["design"]["top_module"] == "test_top"
    assert "suspects" in result
    assert len(result["suspects"]) == 1

    suspect = result["suspects"][0]
    assert suspect["module"] == "test_module"
    assert suspect["signal"] == "test_signal"
    assert suspect["reason_code"] == "clock_gating_candidate"
    assert suspect["message"] == "Test message"
    assert suspect["recommendation"] == "Test recommendation"
    assert suspect["severity"] == "info"
    assert suspect["width"] == 32
    assert suspect["source_loc"]["file"] == "test.v"
    assert suspect["source_loc"]["line"] == 10
    assert suspect["metrics"]["fanout"] == 10


def test_run_power_static_e2e(tmp_path: Path) -> None:
    """Test end-to-end power static analysis via CLI."""
    rtl = tmp_path / "test.v"
    rtl.write_text(
        """
module test(
  input wire clk,
  input wire rst_n,
  output reg [63:0] wide_reg
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      wide_reg <= 64'd0;
    else
      wide_reg <= wide_reg + 64'd1;
  end
endmodule
""",
        encoding="utf-8",
    )

    output_file = tmp_path / "power_static.json"

    # Run static analysis
    result = run_power_static([rtl], "test", output_file)

    # Check result structure
    assert "version" in result
    assert "design" in result
    assert "suspects" in result

    # Check output file was created
    assert output_file.exists()

    # Verify it's valid JSON
    with open(output_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
        assert data["version"] == "1.0"
        assert data["design"]["top_module"] == "test"


def test_power_static_json_is_valid_json(tmp_path: Path) -> None:
    """Test that exported power_static.json is valid JSON."""
    suspects = [
        PowerSuspect(
            module="m1",
            signal="s1",
            reason_code="clock_gating_candidate",
            message="msg",
            recommendation="rec",
            severity="info",
        )
    ]

    result = export_power_static_json(suspects, "top")

    # Should be JSON serializable
    json_str = json.dumps(result)
    parsed = json.loads(json_str)

    assert parsed["version"] == "1.0"
    assert len(parsed["suspects"]) == 1


def test_suspect_with_no_source_location() -> None:
    """Test exporting suspect without source location."""
    suspects = [
        PowerSuspect(
            module="m1",
            signal="s1",
            reason_code="high_fanout_candidate",
            message="High fanout",
            recommendation="Buffer",
            severity="info",
            loc=None,  # No source location
            width=8,
        )
    ]

    result = export_power_static_json(suspects, "top")

    suspect = result["suspects"][0]
    assert suspect["source_loc"] is None
    assert suspect["width"] == 8


def test_all_reason_codes_in_schema() -> None:
    """Test that schema includes all reason codes."""
    reason_codes = POWER_STATIC_SCHEMA["properties"]["suspects"]["items"]["properties"]["reason_code"]["enum"]

    expected_codes = [
        "clock_gating_candidate",
        "counter_activity_candidate",
        "wide_mux_candidate",
        "high_fanout_candidate",
        "glitch_risk_structural",
        "width_reduction_candidate",
    ]

    for code in expected_codes:
        assert code in reason_codes


def test_p0_examples_generate_valid_output(tmp_path: Path) -> None:
    """Test that P0 example modules generate valid power_static.json."""
    # Test all three P0 examples
    examples = [
        ("wide_reg_no_enable.v", """
module wide_reg_no_enable(
  input wire clk,
  input wire rst_n,
  input wire [63:0] data_in,
  output reg [63:0] data_out
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      data_out <= 64'd0;
    else
      data_out <= data_in;
  end
endmodule
"""),
        ("counter_with_enable.v", """
module counter_with_enable(
  input wire clk,
  input wire rst_n,
  input wire enable,
  output reg [15:0] count
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      count <= 16'd0;
    else if (enable)
      count <= count + 16'd1;
  end
endmodule
"""),
        ("wide_mux_reg.v", """
module wide_mux_reg(
  input wire clk,
  input wire [1:0] sel,
  input wire [31:0] data_a,
  input wire [31:0] data_b,
  input wire [31:0] data_c,
  input wire [31:0] data_d,
  output reg [31:0] result
);
  always @(posedge clk) begin
    case (sel)
      2'd0: result <= data_a;
      2'd1: result <= data_b;
      2'd2: result <= data_c;
      2'd3: result <= data_d;
    endcase
  end
endmodule
"""),
    ]

    for filename, content in examples:
        rtl = tmp_path / filename
        rtl.write_text(content, encoding="utf-8")

        output_file = tmp_path / f"{filename}.json"
        result = run_power_static([rtl], filename.replace(".v", ""), output_file)

        # Should generate valid output
        assert output_file.exists()
        assert result["version"] == "1.0"
        assert len(result["suspects"]) > 0
