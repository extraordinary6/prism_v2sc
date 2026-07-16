import importlib.util
import sys
from pathlib import Path


PATH = Path(__file__).resolve().parents[1] / "verification/cases/consistency/dma_e203_consistency.py"
SPEC = importlib.util.spec_from_file_location("dma_e203_consistency", PATH)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


def test_dma_trace_normalization_ignores_simulator_banners_and_hex_padding() -> None:
    rtl = ["VCS banner", "7 1 00000080 0 11223344 1 0 00000000 0 0"]
    systemc = ["SystemC banner", "7 1 000000080 0 011223344 1 0 000000000 0 0"]
    assert MODULE.normalize_trace(rtl) == MODULE.normalize_trace(systemc)


def test_dma_behavior_analysis_flags_protocol_and_address_risks() -> None:
    trace = [
        (0, 1, 0x3C, 1, 0, 0, 0, 0, 0, 0),
        (1, 1, 0x3C, 1, 0, 0, 0, 0, 0, 0),
        (2, 1, 0x40, 1, 0, 0, 0, 0, 0, 0),
        (3, 1, 0x80, 0, 1, 0, 0, 0, 0, 0),
        (4, 1, 0x44, 1, 0, 0, 0, 0, 1, 0),
    ]
    codes = {item["code"] for item in MODULE.analyze_rtl_behavior(trace)}
    assert {"rtl_icb_command_reaccepted", "rtl_dma_prebase_access", "rtl_dma_unpaired_final_read"} <= codes
