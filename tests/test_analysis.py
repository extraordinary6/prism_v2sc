"""Tests for dependency and sensitivity analysis."""

from __future__ import annotations

from pathlib import Path

from prism_v2sc.analysis.dependencies import analyze_dependencies, filter_synthetic_signals
from prism_v2sc.analysis.sensitivity import analyze_sensitivity
from prism_v2sc.analysis.expression_metrics import analyze_expression_metrics, compute_expression_metrics

from _pyslang_helper import lower_via_pyslang


def test_dependency_analysis_continuous_assign(tmp_path: Path) -> None:
    """Test dependency analysis on continuous assignments."""
    rtl = tmp_path / "deps_test.v"
    rtl.write_text(
        """
module deps_test(
  input wire [7:0] a,
  input wire [7:0] b,
  output wire [7:0] y,
  output wire [7:0] z
);
  wire [7:0] temp;

  assign temp = a + b;
  assign y = temp;
  assign z = a & b;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "deps_test")
    module = design.modules[0]

    graph = analyze_dependencies(module)

    # temp depends on a and b
    assert "a" in graph.dependencies.get("temp", set())
    assert "b" in graph.dependencies.get("temp", set())

    # y depends on temp
    assert "temp" in graph.dependencies.get("y", set())

    # z depends on a and b
    assert "a" in graph.dependencies.get("z", set())
    assert "b" in graph.dependencies.get("z", set())

    # a and b have fanout
    assert graph.fanout_count.get("a", 0) >= 2  # feeds temp and z
    assert graph.fanout_count.get("b", 0) >= 2  # feeds temp and z
    assert graph.fanout_count.get("temp", 0) >= 1  # feeds y


def test_dependency_analysis_procedural(tmp_path: Path) -> None:
    """Test dependency analysis on procedural blocks."""
    rtl = tmp_path / "proc_deps.v"
    rtl.write_text(
        """
module proc_deps(
  input wire clk,
  input wire [7:0] d,
  output reg [7:0] q
);
  always @(posedge clk) begin
    q <= d;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "proc_deps")
    module = design.modules[0]

    graph = analyze_dependencies(module)

    # q depends on d
    assert "d" in graph.dependencies.get("q", set())

    # d has fanout to q
    assert "q" in graph.dependents.get("d", set())


def test_sensitivity_analysis_clock_domain(tmp_path: Path) -> None:
    """Test clock domain extraction from sensitivity lists."""
    rtl = tmp_path / "clk_domain.v"
    rtl.write_text(
        """
module clk_domain(
  input wire clk,
  input wire rst_n,
  input wire [7:0] d,
  output reg [7:0] q1,
  output reg [7:0] q2
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      q1 <= 8'd0;
    else
      q1 <= d;
  end

  always @(posedge clk) begin
    q2 <= q1;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "clk_domain")
    module = design.modules[0]

    analysis = analyze_sensitivity(module)

    # q1 and q2 are state signals
    assert "q1" in analysis.state_signals
    assert "q2" in analysis.state_signals

    # Clock domain should be identified
    assert "clk" in analysis.clock_domains
    domain = analysis.clock_domains["clk"]
    assert domain.clock_signal == "clk"
    assert domain.edge == "posedge"


def test_sensitivity_analysis_comb_signals(tmp_path: Path) -> None:
    """Test combinational signal identification."""
    rtl = tmp_path / "comb_test.v"
    rtl.write_text(
        """
module comb_test(
  input wire [7:0] a,
  input wire [7:0] b,
  output reg [7:0] y
);
  always @(*) begin
    y = a + b;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "comb_test")
    module = design.modules[0]

    analysis = analyze_sensitivity(module)

    # y is a combinational signal
    assert "y" in analysis.comb_signals
    assert "y" not in analysis.state_signals


def test_expression_metrics_simple(tmp_path: Path) -> None:
    """Test expression metrics on simple expressions."""
    rtl = tmp_path / "expr_test.v"
    rtl.write_text(
        """
module expr_test(
  input wire [7:0] a,
  input wire [7:0] b,
  input wire sel,
  output wire [7:0] y
);
  assign y = sel ? a : b;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "expr_test")
    module = design.modules[0]

    metrics = analyze_expression_metrics(module)

    # y should have metrics
    assert "y" in metrics
    y_metrics = metrics["y"]

    # Should have detected the mux (ternary operator)
    assert y_metrics.mux_count >= 1
    assert y_metrics.max_expr_depth >= 1


def test_expression_metrics_complex(tmp_path: Path) -> None:
    """Test expression metrics on complex expressions."""
    rtl = tmp_path / "complex_expr.v"
    rtl.write_text(
        """
module complex_expr(
  input wire [7:0] a,
  input wire [7:0] b,
  input wire [7:0] c,
  output wire [7:0] y
);
  assign y = (a + b) * c;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "complex_expr")
    module = design.modules[0]

    metrics = analyze_expression_metrics(module)

    assert "y" in metrics
    y_metrics = metrics["y"]

    # Should have detected arithmetic operations
    assert y_metrics.has_arithmetic
    assert y_metrics.operator_count >= 2  # + and *
    assert y_metrics.max_expr_depth >= 2  # nested operations


def test_filter_synthetic_signals() -> None:
    """Test synthetic signal filtering."""
    signals = {
        "data",
        "clk",
        "__next_data",
        "__shadow_output",
        "temp",
    }

    filtered = filter_synthetic_signals(signals)

    assert "data" in filtered
    assert "clk" in filtered
    assert "temp" in filtered
    assert "__next_data" not in filtered
    assert "__shadow_output" not in filtered


def test_dependency_analysis_nested_if(tmp_path: Path) -> None:
    """Test dependency analysis with nested if statements."""
    rtl = tmp_path / "nested_if.v"
    rtl.write_text(
        """
module nested_if(
  input wire clk,
  input wire [7:0] a,
  input wire [7:0] b,
  input wire sel1,
  input wire sel2,
  output reg [7:0] y
);
  always @(posedge clk) begin
    if (sel1) begin
      if (sel2)
        y <= a;
      else
        y <= b;
    end else begin
      y <= 8'd0;
    end
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "nested_if")
    module = design.modules[0]

    graph = analyze_dependencies(module)

    # y depends on a and b (from the nested if)
    assert "a" in graph.dependencies.get("y", set())
    assert "b" in graph.dependencies.get("y", set())


def test_dependency_analysis_case(tmp_path: Path) -> None:
    """Test dependency analysis with case statements."""
    rtl = tmp_path / "case_test.v"
    rtl.write_text(
        """
module case_test(
  input wire clk,
  input wire [1:0] sel,
  input wire [7:0] a,
  input wire [7:0] b,
  input wire [7:0] c,
  output reg [7:0] y
);
  always @(posedge clk) begin
    case (sel)
      2'd0: y <= a;
      2'd1: y <= b;
      2'd2: y <= c;
      default: y <= 8'd0;
    endcase
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "case_test")
    module = design.modules[0]

    graph = analyze_dependencies(module)

    # y depends on a, b, and c (from case branches)
    assert "a" in graph.dependencies.get("y", set())
    assert "b" in graph.dependencies.get("y", set())
    assert "c" in graph.dependencies.get("y", set())
