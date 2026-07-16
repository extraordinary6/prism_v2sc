"""Source classification, explicit filtering, and module replacement."""

from __future__ import annotations

import fnmatch
from collections import Counter
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Sequence

from prism_v2sc.ir.model import DesignIR, DiagnosticIR, ModuleIR

from .manifest import ModelManifest, ModuleRule
from .providers import ModelProviderRegistry, builtin_provider_registry


@dataclass(frozen=True)
class SourceDecision:
    path: str
    category: str
    action: str
    reason: str = ""
    rule: str = ""


@dataclass(frozen=True)
class ModuleResolution:
    module: str
    provider: str
    status: str
    reason: str = ""
    details: dict[str, object] = field(default_factory=dict)


@dataclass(frozen=True)
class ModelResolutionReport:
    manifest_version: int
    manifest_path: str
    strict: bool
    available_providers: tuple[str, ...]
    sources: tuple[SourceDecision, ...] = ()
    modules: tuple[ModuleResolution, ...] = ()
    diagnostics: tuple[DiagnosticIR, ...] = ()

    def to_dict(self) -> dict[str, object]:
        return asdict(self)


def prepare_model_sources(
    sources: Sequence[Path],
    manifest: ModelManifest,
) -> tuple[tuple[Path, ...], tuple[SourceDecision, ...]]:
    """Classify every source and apply only explicit source rules."""
    kept: list[Path] = []
    decisions: list[SourceDecision] = []
    for source in sources:
        resolved = source.resolve()
        category = classify_source(resolved)
        matched = _matching_source_rule(resolved, manifest)
        action = matched.action if matched is not None else "include"
        reason = matched.reason if matched is not None else "automatic classification only"
        decisions.append(
            SourceDecision(
                path=str(resolved),
                category=category,
                action=action,
                reason=reason,
                rule=matched.glob if matched is not None else "",
            )
        )
        if action != "ignore":
            kept.append(resolved)
    return tuple(kept), tuple(decisions)


def resolve_design_models(
    design: DesignIR,
    manifest: ModelManifest,
    *,
    source_decisions: Sequence[SourceDecision] = (),
    registry: ModelProviderRegistry | None = None,
) -> tuple[DesignIR, ModelResolutionReport]:
    """Replace matched modules through registered providers."""
    providers = registry or builtin_provider_registry()
    original_module_diags = Counter(
        diagnostic for module in design.modules for diagnostic in module.diagnostics
    )
    global_diagnostics: list[DiagnosticIR] = []
    remaining = Counter(original_module_diags)
    for diagnostic in design.diagnostics:
        if remaining[diagnostic] > 0:
            remaining[diagnostic] -= 1
        else:
            global_diagnostics.append(diagnostic)

    resolutions: list[ModuleResolution] = []
    framework_diagnostics: list[DiagnosticIR] = []
    provider_diagnostics: list[DiagnosticIR] = []
    replacement_modules: list[ModuleIR] = []
    matched_rule_indices: set[int] = set()

    for module in design.modules:
        matches = [
            (index, rule)
            for index, rule in enumerate(manifest.module_rules)
            if fnmatch.fnmatchcase(module.name, rule.module)
            or fnmatch.fnmatchcase(module.name.split("__prism_p_", 1)[0], rule.module)
        ]
        if not matches:
            replacement_modules.append(module)
            continue
        if len(matches) > 1:
            diagnostic = DiagnosticIR(
                severity="error",
                module=module.name,
                code="model_multiple_rules",
                message=f"multiple model rules match module '{module.name}'",
                node=module.name,
            )
            framework_diagnostics.append(diagnostic)
            replacement_modules.append(module)
            resolutions.append(
                ModuleResolution(module=module.name, provider="", status="rejected")
            )
            continue

        index, rule = matches[0]
        matched_rule_indices.add(index)
        provider = providers.get(rule.provider)
        if provider is None:
            diagnostic = DiagnosticIR(
                severity="error",
                module=module.name,
                code="model_unknown_provider",
                message=(
                    f"unknown model provider '{rule.provider}'; available providers: "
                    + ", ".join(providers.names)
                ),
                node=rule.provider,
            )
            framework_diagnostics.append(diagnostic)
            replacement_modules.append(module)
            resolutions.append(
                ModuleResolution(
                    module=module.name,
                    provider=rule.provider,
                    status="rejected",
                    reason=rule.reason,
                )
            )
            continue

        result = provider.apply(module, rule, strict=manifest.strict)
        replacement_modules.append(result.module)
        provider_diagnostics.extend(result.module.diagnostics)
        resolutions.append(
            ModuleResolution(
                module=module.name,
                provider=rule.provider,
                status=result.status,
                reason=rule.reason,
                details=result.details,
            )
        )

    for index, rule in enumerate(manifest.module_rules):
        if index in matched_rule_indices:
            continue
        diagnostic = DiagnosticIR(
            severity="error" if manifest.strict else "warning",
            module=rule.module,
            code="model_rule_unmatched",
            message=f"model rule did not match any reachable module: {rule.module}",
            node=rule.provider,
        )
        framework_diagnostics.append(diagnostic)
        resolutions.append(
            ModuleResolution(
                module=rule.module,
                provider=rule.provider,
                status="unmatched",
                reason=rule.reason,
            )
        )

    modules = tuple(replacement_modules)
    diagnostics = (
        tuple(diagnostic for module in modules for diagnostic in module.diagnostics)
        + tuple(global_diagnostics)
        + tuple(framework_diagnostics)
    )
    resolved_design = DesignIR(top=design.top, modules=modules, diagnostics=diagnostics)
    report = ModelResolutionReport(
        manifest_version=manifest.version,
        manifest_path=manifest.path,
        strict=manifest.strict,
        available_providers=providers.names,
        sources=tuple(source_decisions),
        modules=tuple(resolutions),
        diagnostics=tuple(provider_diagnostics + framework_diagnostics),
    )
    return resolved_design, report


def _matching_source_rule(path: Path, manifest: ModelManifest):
    absolute = path.as_posix()
    for rule in manifest.source_rules:
        if fnmatch.fnmatchcase(absolute, rule.glob) or fnmatch.fnmatchcase(path.name, rule.glob):
            return rule
    return None


def classify_source(path: Path) -> str:
    """Conservatively classify a source without changing inclusion policy."""
    lowered_parts = {part.lower() for part in path.parts}
    lowered_name = path.name.lower()
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")[:131072].lower()
    except OSError:
        text = ""
    if lowered_parts & {"tb", "testbench", "uvm", "verification"}:
        return "verification_candidate"
    if any(token in lowered_name for token in ("sram", "ram_model", "memory_model", "rom_model")):
        return "memory_model_candidate"
    if "`celldefine" in text or "specify" in text or "primitive " in text:
        return "vendor_model_candidate"
    if "uvm_" in text or "program " in text:
        return "verification_candidate"
    return "design"
