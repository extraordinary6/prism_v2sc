import importlib.util
import sys
from pathlib import Path


_MODULE_PATH = (
    Path(__file__).resolve().parents[1]
    / "verification/cases/consistency/generated_semantic_consistency.py"
)
_SPEC = importlib.util.spec_from_file_location("generated_semantic_consistency", _MODULE_PATH)
assert _SPEC is not None and _SPEC.loader is not None
_MODULE = importlib.util.module_from_spec(_SPEC)
sys.modules[_SPEC.name] = _MODULE
_SPEC.loader.exec_module(_MODULE)
generate_cases = _MODULE.generate_cases
render_case = _MODULE.render_case


def test_generated_semantic_cases_are_deterministic_and_valid() -> None:
    left = generate_cases(1234, 8)
    right = generate_cases(1234, 8)
    assert left == right
    assert len({case.name for case in left}) == 8
    assert all(case.width in {4, 8, 16, 32} for case in left)
    rendered = render_case(left[0])
    assert f"module {left[0].name}" in rendered
    assert "always @(posedge clk or negedge rst_n)" in rendered
