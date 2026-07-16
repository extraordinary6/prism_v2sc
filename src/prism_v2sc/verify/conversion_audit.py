"""Machine-readable audit summary for one conversion run."""

from __future__ import annotations

from collections import Counter
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Sequence

from prism_v2sc.ir.model import DesignIR, DiagnosticIR
from prism_v2sc.models.resolver import ModelResolutionReport
from prism_v2sc.models.resolver import classify_source


@dataclass(frozen=True)
class ConversionAudit:
    version: int
    top: str
    sources: tuple[str, ...]
    source_count: int
    reachable_module_count: int
    generated_module_count: int
    provider_module_count: int
    ignored_source_count: int
    diagnostic_counts: dict[str, int]
    diagnostic_code_counts: dict[str, int]
    source_category_counts: dict[str, int]
    modules: tuple[dict[str, str], ...]
    policy_path: str
    policy_failure_count: int
    status: str
    limitations: tuple[str, ...]

    def to_dict(self) -> dict[str, object]:
        return asdict(self)


def build_conversion_audit(
    design: DesignIR,
    sources: Sequence[Path],
    *,
    emitted_files: Sequence[Path],
    model_report: ModelResolutionReport | None,
    policy_path: str,
    policy_failures: Sequence[DiagnosticIR],
) -> ConversionAudit:
    severities = Counter(diagnostic.severity for diagnostic in design.diagnostics)
    codes = Counter(diagnostic.code for diagnostic in design.diagnostics)
    source_categories = Counter(classify_source(path.resolve()) for path in sources)
    provider_count = 0
    ignored_count = 0
    if model_report is not None:
        provider_count = sum(item.status == "applied" for item in model_report.modules)
        ignored_count = sum(item.action == "ignore" for item in model_report.sources)
    provider_modules = {
        item.module: item.provider
        for item in model_report.modules
        if item.status == "applied"
    } if model_report is not None else {}
    modules = tuple(
        {
            "name": module.name,
            "source": module.source_path,
            "status": "provider_backed" if module.name in provider_modules else "generated",
            "provider": provider_modules.get(module.name, ""),
        }
        for module in design.modules
    )
    limitations = (
        "approximate SystemC scheduling; not a formal equivalence proof",
        "two-state datapath semantics outside resolved inout handling",
        "verification-only constructs are outside the synthesizable design view",
    )
    return ConversionAudit(
        version=1,
        top=design.top,
        sources=tuple(str(path.resolve()) for path in sources),
        source_count=len(sources),
        reachable_module_count=len(design.modules),
        generated_module_count=len(emitted_files),
        provider_module_count=provider_count,
        ignored_source_count=ignored_count,
        diagnostic_counts=dict(sorted(severities.items())),
        diagnostic_code_counts=dict(sorted(codes.items())),
        source_category_counts=dict(sorted(source_categories.items())),
        modules=modules,
        policy_path=policy_path,
        policy_failure_count=len(policy_failures),
        status="failed" if policy_failures else "passed",
        limitations=limitations,
    )
