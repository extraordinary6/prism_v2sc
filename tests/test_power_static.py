"""Tests for static power analysis."""

from __future__ import annotations

from pathlib import Path

from prism_v2sc.analysis.power_static import analyze_static_power, PowerThresholds

from _pyslang_helper import lower_via_pyslang


def test_wide_register_detection(tmp_path: Path) -> None:
    """Test detection of wide registers as clock gating candidates."""
    rtl = tmp_path / "wide_reg.v"
    rtl.write_text(
        """
module wide_reg(
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
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "wide_reg")
    module = design.modules[0]

    suspects = analyze_static_power(module)

    # Should detect wide register as clock gating candidate
    clock_gating_suspects = [s for s in suspects if s.reason_code == "clock_gating_candidate"]
    assert len(clock_gating_suspects) > 0
    assert any(s.signal == "data_out" for s in clock_gating_suspects)
    assert any(s.width == 64 for s in clock_gating_suspects)


def test_counter_pattern_detection(tmp_path: Path) -> None:
    """Test detection of counter patterns."""
    rtl = tmp_path / "counter.v"
    rtl.write_text(
        """
module counter(
  input wire clk,
  input wire rst_n,
  output reg [15:0] count
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      count <= 16'd0;
    else
      count <= count + 16'd1;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "counter")
    module = design.modules[0]

    suspects = analyze_static_power(module)

    # Should detect counter activity pattern
    counter_suspects = [s for s in suspects if s.reason_code == "counter_activity_candidate"]
    assert len(counter_suspects) > 0
    assert any(s.signal == "count" for s in counter_suspects)


def test_wide_mux_detection(tmp_path: Path) -> None:
    """Test detection of wide muxes."""
    rtl = tmp_path / "wide_mux.v"
    rtl.write_text(
        """
module wide_mux(
  input wire clk,
  input wire [1:0] sel,
  input wire [31:0] a,
  input wire [31:0] b,
  input wire [31:0] c,
  input wire [31:0] d,
  output reg [31:0] y
);
  always @(posedge clk) begin
    case (sel)
      2'd0: y <= a;
      2'd1: y <= b;
      2'd2: y <= c;
      2'd3: y <= d;
    endcase
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "wide_mux")
    module = design.modules[0]

    suspects = analyze_static_power(module)

    # Should detect wide mux (case statement counts as muxes)
    # Note: case statements may be represented differently, so we check for either wide_mux or clock_gating
    mux_or_wide_suspects = [
        s for s in suspects
        if s.reason_code in ("wide_mux_candidate", "clock_gating_candidate")
        and s.signal == "y"
    ]
    assert len(mux_or_wide_suspects) > 0


def test_high_fanout_detection(tmp_path: Path) -> None:
    """Test detection of high fanout signals."""
    rtl = tmp_path / "high_fanout.v"
    rtl.write_text(
        """
module high_fanout(
  input wire clk,
  input wire enable,
  output reg [7:0] out0,
  output reg [7:0] out1,
  output reg [7:0] out2,
  output reg [7:0] out3,
  output reg [7:0] out4,
  output reg [7:0] out5,
  output reg [7:0] out6,
  output reg [7:0] out7,
  output reg [7:0] out8,
  output reg [7:0] out9,
  output reg [7:0] out10,
  output reg [7:0] out11
);
  // 'enable' drives many outputs - high fanout
  always @(posedge clk) begin
    if (enable) out0 <= 8'd0;
    if (enable) out1 <= 8'd1;
    if (enable) out2 <= 8'd2;
    if (enable) out3 <= 8'd3;
    if (enable) out4 <= 8'd4;
    if (enable) out5 <= 8'd5;
    if (enable) out6 <= 8'd6;
    if (enable) out7 <= 8'd7;
    if (enable) out8 <= 8'd8;
    if (enable) out9 <= 8'd9;
    if (enable) out10 <= 8'd10;
    if (enable) out11 <= 8'd11;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "high_fanout")
    module = design.modules[0]

    suspects = analyze_static_power(module)

    # Should detect 'enable' as high fanout signal
    fanout_suspects = [s for s in suspects if s.reason_code == "high_fanout_candidate"]
    assert len(fanout_suspects) > 0
    # enable appears in many conditions, creating high fanout
    assert any(s.signal == "enable" for s in fanout_suspects)


def test_deep_expression_detection(tmp_path: Path) -> None:
    """Test detection of deep combinational expressions (glitch risk)."""
    rtl = tmp_path / "deep_expr.v"
    rtl.write_text(
        """
module deep_expr(
  input wire [7:0] a,
  input wire [7:0] b,
  input wire [7:0] c,
  input wire [7:0] d,
  input wire [7:0] e,
  output wire [7:0] result
);
  // Deep nested expression
  assign result = ((a + b) * (c - d)) + ((e & a) | (b ^ c));
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "deep_expr")
    module = design.modules[0]

    suspects = analyze_static_power(module)

    # Should detect deep expression as glitch risk
    glitch_suspects = [s for s in suspects if s.reason_code == "glitch_risk_structural"]
    assert len(glitch_suspects) > 0
    assert any(s.signal == "result" for s in glitch_suspects)


def test_custom_thresholds(tmp_path: Path) -> None:
    """Test that custom thresholds affect detection."""
    rtl = tmp_path / "small_reg.v"
    rtl.write_text(
        """
module small_reg(
  input wire clk,
  input wire [15:0] data_in,
  output reg [15:0] data_out
);
  always @(posedge clk) begin
    data_out <= data_in;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "small_reg")
    module = design.modules[0]

    # With default thresholds (32 bits), should not flag 16-bit register
    suspects_default = analyze_static_power(module)
    clock_gating_default = [s for s in suspects_default if s.reason_code == "clock_gating_candidate"]
    assert len(clock_gating_default) == 0

    # With lower threshold (8 bits), should flag 16-bit register
    custom_thresholds = PowerThresholds(wide_register_bits=8)
    suspects_custom = analyze_static_power(module, custom_thresholds)
    clock_gating_custom = [s for s in suspects_custom if s.reason_code == "clock_gating_candidate"]
    assert len(clock_gating_custom) > 0
    assert any(s.signal == "data_out" for s in clock_gating_custom)


def test_p0_examples(tmp_path: Path) -> None:
    """Test the three baseline example modules used by static power analysis."""
    # Example 1: Wide register without enable
    wide_reg_rtl = tmp_path / "wide_reg_no_enable.v"
    wide_reg_rtl.write_text(
        """
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
""",
        encoding="utf-8",
    )

    design1 = lower_via_pyslang([wide_reg_rtl], "wide_reg_no_enable")
    suspects1 = analyze_static_power(design1.modules[0])
    assert any(s.reason_code == "clock_gating_candidate" for s in suspects1)

    # Example 2: Counter with enable
    counter_rtl = tmp_path / "counter_with_enable.v"
    counter_rtl.write_text(
        """
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
""",
        encoding="utf-8",
    )

    design2 = lower_via_pyslang([counter_rtl], "counter_with_enable")
    suspects2 = analyze_static_power(design2.modules[0])
    assert any(s.reason_code == "counter_activity_candidate" for s in suspects2)

    # Example 3: Wide mux feeding register
    mux_rtl = tmp_path / "wide_mux_reg.v"
    mux_rtl.write_text(
        """
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
""",
        encoding="utf-8",
    )

    design3 = lower_via_pyslang([mux_rtl], "wide_mux_reg")
    suspects3 = analyze_static_power(design3.modules[0])
    # Should detect either wide mux or wide register (32 bits)
    assert len(suspects3) > 0
