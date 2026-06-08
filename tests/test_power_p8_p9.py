from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

import pytest

from prism_v2sc.analysis.dependencies import analyze_dependencies
from prism_v2sc.analysis.expression_metrics import analyze_expression_metrics
from prism_v2sc.analysis.probe_planning import ProbePlanPolicy, create_probe_plan
from prism_v2sc.analysis.sensitivity import analyze_sensitivity
from prism_v2sc.cli import main
from prism_v2sc.codegen.instrumentation import InstrumentationConfig
from prism_v2sc.codegen.systemc import generate_systemc_header
from prism_v2sc.power.runner import WorkloadMetadata, create_power_profile_json, parse_power_dump
from prism_v2sc.power.scoring import (
    export_saif_like,
    generate_power_report,
    generate_workload_comparison_report,
    select_deep_profile_targets,
)

from _pyslang_helper import lower_via_pyslang


def test_systemc_codegen_integrates_power_instrumentation(tmp_path: Path) -> None:
    rtl = tmp_path / "simple.v"
    rtl.write_text(
        """
module simple(input wire clk, input wire [7:0] d, output reg [7:0] q);
  always @(posedge clk) q <= d;
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "simple")
    plan = create_probe_plan(design)
    config = InstrumentationConfig(enabled=True, probe_plan=plan)

    assert "prism_power_dump" not in generate_systemc_header(design)

    header = generate_systemc_header(design, config)
    assert "uint8_t __power_prev_q;" in header
    assert "void prism_power_dump(std::ostream& os) const" in header
    assert "SC_METHOD(__power_sample_clk_0);" in header
    assert "sensitive << clk.pos();" in header
    assert "dont_initialize();" in header
    assert "__builtin_popcountll(toggled_bits)" in header


def test_power_instrument_cli_writes_manifest_and_headers(tmp_path: Path) -> None:
    rtl = tmp_path / "simple.v"
    rtl.write_text(
        """
module simple(input wire clk, input wire [7:0] d, output reg [7:0] q);
  always @(posedge clk) q <= d;
endmodule
""",
        encoding="utf-8",
    )
    out_dir = tmp_path / "instrumented"
    manifest_path = tmp_path / "probe_manifest.json"

    assert (
        main(
            [
                "--top",
                "simple",
                "--out",
                str(out_dir),
                "--power-instrument",
                str(manifest_path),
                str(rtl),
            ]
        )
        == 0
    )

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    assert manifest["probe_count"] >= 1
    assert manifest["estimated_counter_count"] >= 3
    assert "instrumentation" in manifest
    assert (out_dir / "simple.hpp").is_file()
    assert "prism_power_dump" in (out_dir / "simple.hpp").read_text(encoding="utf-8")


def test_parse_deep_dump_records_bit_counts_and_memory_summary(tmp_path: Path) -> None:
    dump = tmp_path / "dump.csv"
    dump.write_text(
        """# Power Profile Data
signal,sample_count,change_count,toggle_count,module,width,signal_class,high_cycle_count,bit_toggle_counts
mem[0],10,2,5,top,8,memory_cell,20,0;1;0;1;0;1;0;2
mem[1],10,1,3,top,8,memory_cell,10,0;0;0;1;0;1;0;1
q,10,4,9,top,8,state,30,1;1;1;1;1;1;1;2
""",
        encoding="utf-8",
    )

    profile = parse_power_dump(dump)

    assert profile["probes"][0]["bit_toggle_counts"] == [0, 1, 0, 1, 0, 1, 0, 2]
    assert profile["probes"][0]["high_cycle_count"] == 20
    assert profile["memory_summary"] == [
        {
            "module": "top",
            "memory": "mem",
            "cell_count": 2,
            "sample_count": 20,
            "change_count": 3,
            "toggle_count": 8,
        }
    ]


def test_profile_json_records_vector_hash(tmp_path: Path) -> None:
    dump = tmp_path / "dump.csv"
    dump.write_text(
        """signal,sample_count,change_count,toggle_count
q,10,4,9
""",
        encoding="utf-8",
    )
    vector_file = tmp_path / "vectors.txt"
    vector_file.write_text("0 1\n1 0\n", encoding="utf-8")
    output = tmp_path / "profile.json"

    create_power_profile_json(
        dump,
        WorkloadMetadata(
            name="vectors",
            cycle_count=10,
            top_module="top",
            sources=["top.v"],
            vector_file=str(vector_file),
            seed=123,
            reset_cycles=2,
        ),
        output,
    )

    profile = json.loads(output.read_text(encoding="utf-8"))
    assert profile["workload"]["seed"] == 123
    assert profile["workload"]["reset_cycles"] == 2
    assert profile["workload"]["vector_file_sha256"] == hashlib.sha256(
        vector_file.read_bytes()
    ).hexdigest()


def test_deep_targets_workload_comparison_and_saif_export(tmp_path: Path) -> None:
    static_path = tmp_path / "power_static.json"
    static_path.write_text(
        json.dumps(
            {
                "version": "1.0",
                "design": {"top_module": "top"},
                "suspects": [
                    {
                        "module": "top",
                        "signal": "q",
                        "reason_code": "clock_gating_candidate",
                        "message": "wide reg",
                        "recommendation": "gate",
                    }
                ],
            }
        ),
        encoding="utf-8",
    )
    profile_a = tmp_path / "profile_a.json"
    profile_a.write_text(
        json.dumps(
            {
                "version": "1.0",
                "workload": {"name": "a", "total_cycles": 100, "top_module": "top"},
                "probes": [
                    {
                        "module": "top",
                        "signal": "q",
                        "width": 8,
                        "signal_class": "state",
                        "sample_count": 100,
                        "change_count": 20,
                        "toggle_count": 80,
                        "high_cycle_count": 240,
                        "bit_toggle_counts": [0, 0, 0, 0, 4, 8, 16, 52],
                    },
                    {
                        "module": "top",
                        "signal": "r",
                        "width": 8,
                        "signal_class": "state",
                        "sample_count": 100,
                        "change_count": 2,
                        "toggle_count": 4,
                    },
                ],
            }
        ),
        encoding="utf-8",
    )
    profile_b = tmp_path / "profile_b.json"
    profile_b.write_text(
        json.dumps(
            {
                "version": "1.0",
                "workload": {"name": "b", "total_cycles": 100, "top_module": "top"},
                "probes": [
                    {
                        "module": "top",
                        "signal": "q",
                        "width": 8,
                        "signal_class": "state",
                        "sample_count": 100,
                        "change_count": 10,
                        "toggle_count": 30,
                    },
                        {
                            "module": "top",
                            "signal": "r",
                            "width": 8,
                            "signal_class": "state",
                            "sample_count": 100,
                            "change_count": 2,
                            "toggle_count": 5,
                        },
                ],
            }
        ),
        encoding="utf-8",
    )

    report = generate_power_report(static_path, profile_a, tmp_path / "report.json")
    q_hotspot = next(item for item in report["hotspots"] if item["signal"] == "q")
    assert "bit_level_utilization" in q_hotspot["dimensions"]
    assert q_hotspot["metrics"]["bit_utilization"]["inactive_msb_count"] == 0
    assert "No absolute watts" in report["summary"]["limitations"][0]

    deep_targets = select_deep_profile_targets(
        json.loads(static_path.read_text(encoding="utf-8")),
        json.loads(profile_a.read_text(encoding="utf-8")),
        top_k=1,
    )
    assert deep_targets[0]["signal"] == "q"

    comparison = generate_workload_comparison_report([profile_a, profile_b], static_path, top_k=1)
    assert comparison["workloads"][0]["name"] == "a"
    assert {"module": "top", "signal": "q"} in comparison["stable_hotspots"] or comparison[
        "workload_specific_outliers"
    ]

    saif_text = export_saif_like(profile_a, tmp_path / "profile.saif")
    assert "(NET q (TC 80) (T1 240) (T0 560))" in saif_text


def test_probe_plan_guardrails_and_memory_cell_policy(tmp_path: Path) -> None:
    rtl = tmp_path / "mem_top.v"
    rtl.write_text(
        """
module mem_top(
  input wire clk,
  input wire we,
  input wire [1:0] addr,
  input wire [7:0] din,
  output reg [7:0] dout
);
  reg [7:0] mem [0:3];
  always @(posedge clk) begin
    if (we) mem[addr] <= din;
    dout <= mem[addr];
  end
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "mem_top")

    default_plan = create_probe_plan(design)
    assert default_plan.memory_probe_count == 0

    policy = ProbePlanPolicy(
        probe_memory_cells=True,
        max_memory_cells=2,
        warning_probe_count=1,
    )
    memory_plan = create_probe_plan(design, policy)
    assert memory_plan.memory_probe_count == 2
    assert memory_plan.warnings
    assert memory_plan.estimated_storage_bytes == memory_plan.estimated_counter_count * 8

    with pytest.raises(ValueError, match="exceeding limit"):
        create_probe_plan(
            design,
            ProbePlanPolicy(probe_memory_cells=True, max_total_probes=1),
        )


def test_concat_lhs_analysis_tracks_each_target(tmp_path: Path) -> None:
    rtl = tmp_path / "concat_lhs.v"
    rtl.write_text(
        """
module concat_lhs(input wire clk, input wire [7:0] d, output reg [3:0] hi, output reg [3:0] lo);
  always @(posedge clk) begin
    {hi, lo} <= d;
  end
endmodule
""",
        encoding="utf-8",
    )

    design = lower_via_pyslang([rtl], "concat_lhs")
    module = design.modules[0]

    graph = analyze_dependencies(module)
    assert "d" in graph.dependencies["hi"]
    assert "d" in graph.dependencies["lo"]

    sensitivity = analyze_sensitivity(module)
    assert {"hi", "lo"}.issubset(sensitivity.state_signals)

    metrics = analyze_expression_metrics(module)
    assert {"hi", "lo"}.issubset(metrics)


def test_linux_systemc_profile_collection_smoke(tmp_path: Path) -> None:
    if sys.platform != "linux":
        pytest.skip("Linux SystemC smoke is exercised by the Linux CI workflow")
    if shutil.which("g++") is None:
        pytest.skip("g++ is not available")
    if not Path("/usr/include/systemc").exists():
        pytest.skip("SystemC headers are not available")

    rtl = tmp_path / "simple.v"
    rtl.write_text(
        """
module simple(input wire clk, input wire [7:0] d, output reg [7:0] q);
  always @(posedge clk) q <= d;
endmodule
""",
        encoding="utf-8",
    )
    out_dir = tmp_path / "systemc"
    design = lower_via_pyslang([rtl], "simple")
    plan = create_probe_plan(design)
    header = generate_systemc_header(design, InstrumentationConfig(enabled=True, probe_plan=plan))
    (out_dir).mkdir()
    (out_dir / "simple.hpp").write_text(header, encoding="utf-8")
    runner = tmp_path / "runner.cpp"
    runner.write_text(
        """
#include "simple.hpp"
#include <fstream>

int sc_main(int argc, char** argv) {
  sc_clock clk("clk", 1, SC_NS);
  sc_signal<sc_uint<8>> d;
  sc_signal<sc_uint<8>> q;
  simple dut("dut");
  dut.clk(clk);
  dut.d(d);
  dut.q(q);
  for (int i = 0; i < 8; ++i) {
    d.write(i);
    sc_start(1, SC_NS);
  }
  std::ofstream out(argv[1]);
  dut.prism_power_dump(out);
  return 0;
}
""",
        encoding="utf-8",
    )
    exe = tmp_path / "runner"
    subprocess.run(
        [
            "g++",
            "-std=c++17",
            "-I",
            str(out_dir),
            str(runner),
            "-lsystemc",
            "-pthread",
            "-o",
            str(exe),
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    dump = tmp_path / "dump.csv"
    subprocess.run([str(exe), str(dump)], check=True, capture_output=True, text=True)

    profile = parse_power_dump(dump)
    assert profile["probes"]
    assert profile["probes"][0]["sample_count"] > 0


def test_linux_power_instrumentation_preserves_systemc_trace(tmp_path: Path) -> None:
    if sys.platform != "linux":
        pytest.skip("Linux SystemC instrumentation guard is exercised by CI")
    if shutil.which("g++") is None:
        pytest.skip("g++ is not available")
    if not Path("/usr/include/systemc").exists():
        pytest.skip("SystemC headers are not available")

    rtl = tmp_path / "simple.v"
    rtl.write_text(
        """
module simple(input wire clk, input wire [7:0] d, output reg [7:0] q);
  always @(posedge clk) q <= d;
endmodule
""",
        encoding="utf-8",
    )
    design = lower_via_pyslang([rtl], "simple")
    plan = create_probe_plan(design)
    plain_dir = tmp_path / "plain"
    inst_dir = tmp_path / "instrumented"
    plain_dir.mkdir()
    inst_dir.mkdir()
    (plain_dir / "simple.hpp").write_text(generate_systemc_header(design), encoding="utf-8")
    (inst_dir / "simple.hpp").write_text(
        generate_systemc_header(design, InstrumentationConfig(enabled=True, probe_plan=plan)),
        encoding="utf-8",
    )

    def build_and_run(include_dir: Path, name: str, dump_power: bool = False) -> list[str]:
        runner = tmp_path / f"{name}.cpp"
        dump_line = ""
        if dump_power:
            dump_line = """
  std::ofstream power_out("power.csv");
  dut.prism_power_dump(power_out);
"""
        runner.write_text(
            f"""
#include "simple.hpp"
#include <fstream>
#include <iostream>

int sc_main(int argc, char** argv) {{
  (void)argc; (void)argv;
  sc_clock clk("clk", 1, SC_NS);
  sc_signal<sc_uint<8>> d;
  sc_signal<sc_uint<8>> q;
  simple dut("dut");
  dut.clk(clk);
  dut.d(d);
  dut.q(q);
  for (int i = 0; i < 16; ++i) {{
    d.write((i * 17) & 0xff);
    sc_start(1, SC_NS);
    std::cout << q.read().to_uint() << "\\n";
  }}
{dump_line}
  return 0;
}}
""",
            encoding="utf-8",
        )
        exe = tmp_path / name
        subprocess.run(
            [
                "g++",
                "-std=c++17",
                "-I",
                str(include_dir),
                str(runner),
                "-lsystemc",
                "-pthread",
                "-o",
                str(exe),
            ],
            check=True,
            capture_output=True,
            text=True,
        )
        result = subprocess.run([str(exe)], check=True, capture_output=True, text=True, cwd=tmp_path)
        return [line for line in result.stdout.splitlines() if line.strip().isdigit()]

    assert build_and_run(plain_dir, "plain_runner") == build_and_run(
        inst_dir,
        "instrumented_runner",
        dump_power=True,
    )
