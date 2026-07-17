from __future__ import annotations

import json
from pathlib import Path

from prism_v2sc.cli import main
from prism_v2sc.ir.model import DesignIR, ModuleIR, ParameterIR, PortIR
from prism_v2sc.models.manifest import ModelManifest, ModuleRule, SourceRule, load_model_manifest
from prism_v2sc.models.providers import MemoryProvider
from prism_v2sc.models.resolver import prepare_model_sources, resolve_design_models


def test_model_manifest_and_source_filter_are_explicit(tmp_path: Path) -> None:
    design = tmp_path / "rtl" / "core.sv"
    testbench = tmp_path / "tb" / "tb_core.sv"
    design.parent.mkdir()
    testbench.parent.mkdir()
    design.write_text("module core; endmodule\n", encoding="utf-8")
    testbench.write_text("module tb_core; initial begin end endmodule\n", encoding="utf-8")
    manifest_path = tmp_path / "models.json"
    manifest_path.write_text(
        json.dumps(
            {
                "version": 1,
                "strict": True,
                "source_rules": [
                    {"glob": "*/tb/*", "action": "ignore", "reason": "testbench"}
                ],
            }
        ),
        encoding="utf-8",
    )

    manifest = load_model_manifest(manifest_path)
    kept, decisions = prepare_model_sources((design, testbench), manifest)

    assert kept == (design.resolve(),)
    by_name = {Path(item.path).name: item for item in decisions}
    assert by_name["core.sv"].action == "include"
    assert by_name["core.sv"].category == "design"
    assert by_name["tb_core.sv"].action == "ignore"
    assert by_name["tb_core.sv"].category == "verification_candidate"


def test_strict_blackbox_requires_explicit_allow() -> None:
    module = ModuleIR(
        name="hard_macro",
        ports=(PortIR(name="a", direction="input"), PortIR(name="y", direction="output")),
    )
    design = DesignIR(top="hard_macro", modules=(module,))
    manifest = ModelManifest(
        strict=True,
        module_rules=(ModuleRule(module="hard_macro", provider="blackbox"),),
    )

    resolved, report = resolve_design_models(design, manifest)

    assert report.modules[0].status == "rejected"
    assert resolved.diagnostics[0].severity == "error"
    assert resolved.diagnostics[0].code == "model_blackbox_not_allowed"


def test_parameterized_depth_requires_masked_memory_contract() -> None:
    module = ModuleIR(
        name="param_mem",
        parameters=(ParameterIR(name="DP", value="16"),),
        ports=tuple(
            PortIR(name=name, direction="output" if name == "dout" else "input")
            for name in ("clk", "en", "we", "addr", "din", "dout")
        ),
    )
    rule = ModuleRule(
        module="param_mem",
        provider="memory",
        config={
            "clock": "clk",
            "enable": "en",
            "write_enable": "we",
            "address": "addr",
            "write_data": "din",
            "read_data": "dout",
            "depth": "DP",
        },
    )

    result = MemoryProvider().apply(module, rule, strict=True)

    assert result.status == "rejected"
    assert result.module.diagnostics[0].code == "model_memory_parameter_depth_requires_masked_contract"


def test_cli_memory_provider_emits_canonical_model_and_report(tmp_path: Path, capsys) -> None:
    rtl = tmp_path / "memory_top.sv"
    rtl.write_text(
        """
module sim_sram(
  input  logic       clk,
  input  logic       en,
  input  logic       we,
  input  logic [3:0] addr,
  input  logic [7:0] wdata,
  output logic [7:0] rdata
);
  logic [7:0] storage [0:15];
  always_ff @(posedge clk) begin
    if (en) begin
      rdata <= storage[addr];
      if (we) storage[addr] <= wdata;
    end
  end
endmodule

module memory_top(
  input logic clk, en, we,
  input logic [3:0] addr,
  input logic [7:0] wdata,
  output logic [7:0] rdata
);
  sim_sram u_mem(.*);
endmodule
""",
        encoding="utf-8",
    )
    manifest = tmp_path / "models.json"
    manifest.write_text(
        json.dumps(
            {
                "version": 1,
                "strict": True,
                "module_rules": [
                    {
                        "module": "sim_sram",
                        "provider": "memory",
                        "reason": "replace simulation memory",
                        "config": {
                            "clock": "clk",
                            "enable": "en",
                            "write_enable": "we",
                            "address": "addr",
                            "write_data": "wdata",
                            "read_data": "rdata",
                            "depth": 16,
                            "read_latency": 1,
                            "write_mode": "read_first",
                        },
                    }
                ],
            }
        ),
        encoding="utf-8",
    )
    out_dir = tmp_path / "out"

    assert main(
        [
            "--top",
            "memory_top",
            "--model-manifest",
            str(manifest),
            "--out",
            str(out_dir),
            str(rtl),
        ]
    ) == 0

    output = capsys.readouterr().out
    assert "wrote model resolution report" in output
    report = json.loads((out_dir / "model_report.json").read_text(encoding="utf-8"))
    assert report["modules"][0]["module"] == "sim_sram"
    assert report["modules"][0]["provider"] == "memory"
    assert report["modules"][0]["status"] == "applied"

    header = (out_dir / "sim_sram.hpp").read_text(encoding="utf-8")
    assert "sc_signal<sc_uint<8>> __model_mem[16];" in header
    assert "SC_METHOD(always_ff_0);" in header
    assert "sensitive << clk.pos();" in header
    assert "__model_mem[addr.read()].write(wdata.read());" in header
    assert "rdata.write(__next_rdata);" in header


def test_cli_model_audit_writes_classification_without_rules(tmp_path: Path) -> None:
    rtl = tmp_path / "core.sv"
    rtl.write_text("module core(input logic a, output logic y); assign y=a; endmodule\n", encoding="utf-8")
    out_dir = tmp_path / "out"

    assert main(["--top", "core", "--model-audit", "--out", str(out_dir), str(rtl)]) == 0
    report = json.loads((out_dir / "model_report.json").read_text(encoding="utf-8"))
    assert report["sources"][0]["category"] == "design"
    assert report["sources"][0]["action"] == "include"


def test_masked_parameterized_memory_provider_emits_compact_model(tmp_path: Path) -> None:
    rtl = tmp_path / "masked_ram.sv"
    rtl.write_text(
        """
module masked_ram #(parameter DP=16, DW=32, MW=4, AW=4)(
  input logic clk, cs, we,
  input logic [AW-1:0] addr,
  input logic [DW-1:0] din,
  input logic [MW-1:0] wem,
  output logic [DW-1:0] dout
);
  localparam WBITS = DW / MW;
endmodule
""",
        encoding="utf-8",
    )
    manifest = tmp_path / "models.json"
    manifest.write_text(
        json.dumps(
            {
                "version": 1,
                "module_rules": [
                    {
                        "module": "masked_ram",
                        "provider": "memory",
                        "config": {
                            "clock": "clk",
                            "enable": "cs",
                            "write_enable": "we",
                            "byte_enable": "wem",
                            "lane_width": "WBITS",
                            "address": "addr",
                            "write_data": "din",
                            "read_data": "dout",
                            "depth": "DP",
                            "read_latency": 1,
                            "read_address_register": True,
                            "write_mode": "no_change",
                        },
                    }
                ],
            }
        ),
        encoding="utf-8",
    )
    out_dir = tmp_path / "out"

    assert main(["--top", "masked_ram", "--model-manifest", str(manifest), "--out", str(out_dir), str(rtl)]) == 0
    header = (out_dir / "masked_ram.hpp").read_text(encoding="utf-8")
    assert "std::array<" in header
    assert "__model_mem[" in header
    assert "__bit / WBITS" in header
    assert "sensitive << __model_read_addr;" in header
    assert "mem_r[0]" not in header


def _write_power_memory_case(tmp_path: Path) -> tuple[Path, Path]:
    rtl = tmp_path / "memory_top.sv"
    rtl.write_text(
        """
module sim_sram(input logic clk, en, we, input logic [1:0] addr,
                input logic [7:0] wdata, output logic [7:0] rdata);
endmodule
module memory_top(input logic clk, en, we, input logic [1:0] addr,
                  input logic [7:0] wdata, output logic [7:0] rdata);
  sim_sram u_mem(.*);
endmodule
""",
        encoding="utf-8",
    )
    manifest = tmp_path / "models.json"
    manifest.write_text(json.dumps({
        "version": 1,
        "module_rules": [{
            "module": "sim_sram", "provider": "memory",
            "config": {
                "clock": "clk", "enable": "en", "write_enable": "we",
                "address": "addr", "write_data": "wdata", "read_data": "rdata",
                "depth": 4, "read_latency": 1, "write_mode": "read_first"
            }
        }]
    }), encoding="utf-8")
    return rtl, manifest


def test_model_manifest_applies_to_power_static(tmp_path: Path) -> None:
    rtl, manifest = _write_power_memory_case(tmp_path)
    out = tmp_path / "out"
    static = tmp_path / "power_static.json"
    assert main([
        "--top", "memory_top", "--model-manifest", str(manifest),
        "--power-static", "--power-static-output", str(static),
        "--out", str(out), str(rtl),
    ]) == 0
    report = json.loads((out / "model_report.json").read_text(encoding="utf-8"))
    assert report["modules"][0]["provider"] == "memory"
    assert report["modules"][0]["status"] == "applied"
    assert json.loads(static.read_text(encoding="utf-8"))["design"]["top_module"] == "memory_top"


def test_model_manifest_applies_to_power_instrumentation(tmp_path: Path) -> None:
    rtl, manifest = _write_power_memory_case(tmp_path)
    out = tmp_path / "instrumented"
    probes = tmp_path / "probes.json"
    assert main([
        "--top", "memory_top", "--model-manifest", str(manifest),
        "--power-instrument", str(probes), "--power-memory-cells",
        "--out", str(out), str(rtl),
    ]) == 0
    probe_manifest = json.loads(probes.read_text(encoding="utf-8"))
    assert probe_manifest["memory_probe_count"] == 4
    assert probe_manifest["model_providers"][0] == {
        "module": "sim_sram", "provider": "memory", "status": "applied"
    }
    assert (out / "model_report.json").is_file()
    header = (out / "sim_sram.hpp").read_text(encoding="utf-8")
    assert "__model_mem[4]" in header
    assert "prism_power_dump" in header
