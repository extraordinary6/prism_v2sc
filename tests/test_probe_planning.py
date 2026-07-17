"""Tests for probe planning."""

from __future__ import annotations

from pathlib import Path

from prism_v2sc.analysis.probe_planning import (
    create_probe_plan,
    ProbePlanPolicy,
    export_probe_plan_json,
)

from _pyslang_helper import lower_via_pyslang


def test_probe_plan_state_registers(tmp_path: Path) -> None:
    """Test that state registers are probed by default."""
    rtl = tmp_path / "state_test.v"
    rtl.write_text(
        """
module state_test(
  input wire clk,
  input wire rst_n,
  input wire [7:0] data_in,
  output reg [7:0] q1,
  output reg [7:0] q2
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q1 <= 8'd0;
      q2 <= 8'd0;
    end else begin
      q1 <= data_in;
      q2 <= q1;
    end
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "state_test")

    # Create probe plan with default policy
    plan = create_probe_plan(design)

    # Should probe both state registers
    assert plan.state_probe_count >= 2

    # Check that q1 and q2 are in the plan
    probe_names = {probe.rtl_signal_name for probe in plan.probes}
    assert "q1" in probe_names
    assert "q2" in probe_names

    # Verify signal class
    for probe in plan.probes:
        if probe.rtl_signal_name in ("q1", "q2"):
            assert probe.signal_class == "state"
            assert probe.clock_domain == "clk"
            assert probe.clock_edge == "posedge"


def test_probe_plan_comb_suspects_only(tmp_path: Path) -> None:
    """Test that combinational signals are only probed if they are suspects."""
    rtl = tmp_path / "comb_test.v"
    rtl.write_text(
        """
module comb_test(
  input wire [7:0] a,
  input wire [7:0] b,
  output wire [7:0] simple,
  output wire [7:0] complex
);
  // Simple combinational logic - likely not a suspect
  assign simple = a & b;

  // Complex combinational logic - may be flagged as suspect
  assign complex = ((a + b) * (a - b)) + ((a & b) | (a ^ b));
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "comb_test")

    # Create probe plan with default policy (comb suspects only)
    plan = create_probe_plan(design)

    # Should have some comb probes if suspects detected
    # complex might be flagged as deep expression
    probe_names = {probe.rtl_signal_name for probe in plan.probes}

    # Check if complex is probed (it should be due to depth)
    # Note: This depends on the expression depth threshold
    if "complex" in probe_names:
        complex_probe = next(p for p in plan.probes if p.rtl_signal_name == "complex")
        assert complex_probe.signal_class == "comb"
        assert len(complex_probe.static_reason_codes) > 0


def test_probe_plan_filters_synthetic_signals(tmp_path: Path) -> None:
    """Test that synthetic signals are filtered out."""
    rtl = tmp_path / "simple.v"
    rtl.write_text(
        """
module simple(
  input wire clk,
  input wire [7:0] data_in,
  output reg [7:0] data_out
);
  always @(posedge clk) begin
    data_out <= data_in;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "simple")

    # Create probe plan
    plan = create_probe_plan(design)

    # Verify no synthetic signals in probes
    for probe in plan.probes:
        assert not probe.rtl_signal_name.startswith("__next_")
        assert not probe.rtl_signal_name.startswith("__shadow_")
        assert not probe.rtl_signal_name.startswith("__bridge_")


def test_probe_plan_all_signals_policy(tmp_path: Path) -> None:
    """Test probe plan with all-signals policy."""
    rtl = tmp_path / "mixed.v"
    rtl.write_text(
        """
module mixed(
  input wire clk,
  input wire [7:0] a,
  input wire [7:0] b,
  output reg [7:0] state_out,
  output wire [7:0] comb_out
);
  always @(posedge clk) begin
    state_out <= a;
  end

  assign comb_out = a + b;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "mixed")

    # Create probe plan that probes all signals (not just suspects)
    policy = ProbePlanPolicy(
        probe_all_state_registers=True,
        probe_comb_suspects_only=False  # Probe all comb signals
    )
    plan = create_probe_plan(design, policy)

    # Should probe both state and comb signals
    probe_names = {probe.rtl_signal_name for probe in plan.probes}
    assert "state_out" in probe_names
    assert "comb_out" in probe_names


def test_probe_plan_top_k_selection(tmp_path: Path) -> None:
    """Test top-K selection for combinational suspects."""
    rtl = tmp_path / "many_comb.v"
    rtl.write_text(
        """
module many_comb(
  input wire [7:0] a,
  input wire [7:0] b,
  input wire [7:0] c,
  output wire [7:0] out1,
  output wire [7:0] out2,
  output wire [7:0] out3
);
  assign out1 = a + b;
  assign out2 = b * c;
  assign out3 = a ^ c;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "many_comb")

    # Create probe plan with max 2 comb suspects
    policy = ProbePlanPolicy(
        probe_all_state_registers=True,
        probe_comb_suspects_only=True,
        max_comb_suspects=2
    )
    plan = create_probe_plan(design, policy)

    # Should have at most 2 comb probes
    comb_probes = [p for p in plan.probes if p.signal_class == "comb"]
    assert len(comb_probes) <= 2


def test_probe_plan_export_json(tmp_path: Path) -> None:
    """Test exporting probe plan to JSON."""
    rtl = tmp_path / "simple.v"
    rtl.write_text(
        """
module simple(
  input wire clk,
  input wire [7:0] data_in,
  output reg [7:0] data_out
);
  always @(posedge clk) begin
    data_out <= data_in;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "simple")

    # Create probe plan
    plan = create_probe_plan(design)

    # Export to JSON
    json_data = export_probe_plan_json(plan)

    # Verify structure
    assert "design_name" in json_data
    assert "top_module" in json_data
    assert "probe_count" in json_data
    assert "probes" in json_data
    assert isinstance(json_data["probes"], list)

    # Verify probe entries
    if json_data["probes"]:
        probe = json_data["probes"][0]
        assert "rtl_signal_name" in probe
        assert "signal_class" in probe
        assert "width" in probe


def test_probe_plan_with_power_suspects(tmp_path: Path) -> None:
    """Test that power suspects are included in probe plan."""
    rtl = tmp_path / "power_suspect.v"
    rtl.write_text(
        """
module power_suspect(
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

    design = lower_via_pyslang([rtl], "power_suspect")

    # Create probe plan
    plan = create_probe_plan(design)

    # Should probe wide_reg (it's both a state signal and a suspect)
    probe_names = {probe.rtl_signal_name for probe in plan.probes}
    assert "wide_reg" in probe_names

    # Check that it has reason codes
    wide_reg_probe = next(p for p in plan.probes if p.rtl_signal_name == "wide_reg")
    assert len(wide_reg_probe.static_reason_codes) > 0
    # Should have clock_gating_candidate and/or counter_activity_candidate
    reason_codes = set(wide_reg_probe.static_reason_codes)
    assert "clock_gating_candidate" in reason_codes or "counter_activity_candidate" in reason_codes


def test_probe_plan_resolves_parameterized_signal_width(tmp_path: Path) -> None:
    rtl = tmp_path / "parameterized_probe.sv"
    rtl.write_text(
        """
module parameterized_probe #(parameter DW = 78)(
  input logic clk,
  input logic [DW-1:0] d,
  output logic [DW-1:0] q
);
  always_ff @(posedge clk) q <= d;
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "parameterized_probe")
    plan = create_probe_plan(design)
    q_probe = next(probe for probe in plan.probes if probe.rtl_signal_name == "q")
    assert q_probe.width == 78
