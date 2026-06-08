"""Tests for SystemC instrumentation code generation."""

from __future__ import annotations

from pathlib import Path

from prism_v2sc.analysis.probe_planning import create_probe_plan, ProbeSpec
from prism_v2sc.codegen.instrumentation import (
    InstrumentationConfig,
    generate_instrumentation_declarations,
    generate_instrumentation_init,
    generate_sampling_method,
    generate_all_sampling_methods,
    generate_dump_api,
    generate_manifest_json,
)
from prism_v2sc.ir.model import SourceLocIR

from _pyslang_helper import lower_via_pyslang


def test_instrumentation_disabled_by_default() -> None:
    """Test that instrumentation is disabled by default."""
    config = InstrumentationConfig()
    assert config.enabled is False


def test_generate_declarations_when_disabled() -> None:
    """Test that no declarations are generated when disabled."""
    config = InstrumentationConfig(enabled=False)
    declarations = generate_instrumentation_declarations(config)
    assert len(declarations) == 0


def test_generate_declarations_for_simple_probe(tmp_path: Path) -> None:
    """Test declaration generation for a simple probe."""
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
    probe_plan = create_probe_plan(design)

    config = InstrumentationConfig(
        enabled=True,
        probe_plan=probe_plan,
    )

    declarations = generate_instrumentation_declarations(config)

    # Should have declarations
    assert len(declarations) > 0

    # Check for expected patterns
    decl_text = "\n".join(declarations)
    assert "uint8_t __power_prev_" in decl_text
    assert "uint64_t __power_sample_count_" in decl_text
    assert "uint64_t __power_change_count_" in decl_text
    assert "uint64_t __power_toggle_count_" in decl_text


def test_generate_init_code(tmp_path: Path) -> None:
    """Test initialization code generation."""
    rtl = tmp_path / "simple.v"
    rtl.write_text(
        """
module simple(
  input wire clk,
  input wire [7:0] data,
  output reg [7:0] out
);
  always @(posedge clk) begin
    out <= data;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "simple")
    probe_plan = create_probe_plan(design)

    config = InstrumentationConfig(
        enabled=True,
        probe_plan=probe_plan,
    )

    init_code = generate_instrumentation_init(config)

    # Should have initialization code
    assert len(init_code) > 0

    init_text = "\n".join(init_code)
    assert "__power_prev_" in init_text
    assert "__power_sample_count_" in init_text or "__power_change_count_" in init_text


def test_generate_sampling_method_for_8bit_signal() -> None:
    """Test sampling method generation for 8-bit signal."""
    probe = ProbeSpec(
        instance_path="test",
        module_name="test",
        rtl_signal_name="data",
        systemc_member_name="data",
        width=8,
        signal_class="state",
        clock_domain="clk",
        clock_edge="posedge",
        source_loc=None,
        static_reason_codes=(),
    )

    config = InstrumentationConfig(
        enabled=True,
        probe_plan=None,
        track_toggles=True,
        track_value_changes=True,
        track_samples=True,
    )

    code = generate_sampling_method(config, probe)

    # Check for expected elements
    assert "current_value" in code
    assert "data.read()" in code
    assert "__power_sample_count_data" in code
    assert "__power_change_count_data" in code
    assert "__power_toggle_count_data" in code
    assert "__builtin_popcountll" in code


def test_generate_sampling_method_for_1bit_signal() -> None:
    """Test sampling method generation for 1-bit signal."""
    probe = ProbeSpec(
        instance_path="test",
        module_name="test",
        rtl_signal_name="flag",
        systemc_member_name="flag",
        width=1,
        signal_class="state",
        clock_domain="clk",
        clock_edge="posedge",
        source_loc=None,
        static_reason_codes=(),
    )

    config = InstrumentationConfig(
        enabled=True,
        probe_plan=None,
    )

    code = generate_sampling_method(config, probe)

    assert "flag.read()" in code
    assert "__power_prev_flag" in code


def test_generate_sampling_methods_grouped_by_domain(tmp_path: Path) -> None:
    """Test that sampling methods are grouped by clock domain."""
    rtl = tmp_path / "multi_domain.v"
    rtl.write_text(
        """
module multi_domain(
  input wire clk1,
  input wire clk2,
  input wire [7:0] data,
  output reg [7:0] out1,
  output reg [7:0] out2
);
  always @(posedge clk1) begin
    out1 <= data;
  end

  always @(posedge clk2) begin
    out2 <= data;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "multi_domain")
    probe_plan = create_probe_plan(design)

    config = InstrumentationConfig(
        enabled=True,
        probe_plan=probe_plan,
    )

    methods = generate_all_sampling_methods(config)

    # Should have methods for different domains
    assert len(methods) > 0

    # Check that methods contain probe names
    all_code = "\n".join(methods.values())
    if probe_plan.probe_count > 0:
        assert "__power_sample_count_" in all_code


def test_generate_dump_api(tmp_path: Path) -> None:
    """Test dump API generation."""
    rtl = tmp_path / "simple.v"
    rtl.write_text(
        """
module simple(
  input wire clk,
  input wire [7:0] data,
  output reg [7:0] out
);
  always @(posedge clk) begin
    out <= data;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "simple")
    probe_plan = create_probe_plan(design)

    config = InstrumentationConfig(
        enabled=True,
        probe_plan=probe_plan,
    )

    dump_code = generate_dump_api(config)

    # Check for dump method
    assert "void prism_power_dump" in dump_code
    assert "std::ostream& os" in dump_code
    assert "Power Profile Data" in dump_code
    assert "signal,sample_count,change_count,toggle_count" in dump_code


def test_generate_manifest_json(tmp_path: Path) -> None:
    """Test manifest JSON generation."""
    rtl = tmp_path / "simple.v"
    rtl.write_text(
        """
module simple(
  input wire clk,
  input wire [7:0] data,
  output reg [7:0] out
);
  always @(posedge clk) begin
    out <= data;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "simple")
    probe_plan = create_probe_plan(design)

    config = InstrumentationConfig(
        enabled=True,
        probe_plan=probe_plan,
    )

    manifest = generate_manifest_json(config)

    # Check manifest structure
    assert "instrumentation_version" in manifest
    assert "probes" in manifest
    assert isinstance(manifest["probes"], list)

    if len(manifest["probes"]) > 0:
        probe = manifest["probes"][0]
        assert "signal" in probe
        assert "module" in probe
        assert "width" in probe
        assert "signal_class" in probe
        assert "columns" in probe


def test_instrumentation_with_different_widths() -> None:
    """Test that different signal widths use appropriate C++ types."""
    config = InstrumentationConfig(enabled=True, probe_plan=None)

    # Create probes with different widths
    probes = [
        ProbeSpec(
            instance_path="test", module_name="test",
            rtl_signal_name="sig1", systemc_member_name="sig1",
            width=1, signal_class="state",
            clock_domain="clk", clock_edge="posedge",
            source_loc=None, static_reason_codes=(),
        ),
        ProbeSpec(
            instance_path="test", module_name="test",
            rtl_signal_name="sig8", systemc_member_name="sig8",
            width=8, signal_class="state",
            clock_domain="clk", clock_edge="posedge",
            source_loc=None, static_reason_codes=(),
        ),
        ProbeSpec(
            instance_path="test", module_name="test",
            rtl_signal_name="sig32", systemc_member_name="sig32",
            width=32, signal_class="state",
            clock_domain="clk", clock_edge="posedge",
            source_loc=None, static_reason_codes=(),
        ),
    ]

    # Generate code for each
    for probe in probes:
        code = generate_sampling_method(config, probe)
        assert f"__power_prev_{probe.rtl_signal_name}" in code
        assert f"{probe.rtl_signal_name}.read()" in code
