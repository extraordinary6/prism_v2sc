"""External simulation-model classification and replacement framework."""

from .manifest import ModelManifest, ModuleRule, SourceRule, load_model_manifest
from .providers import ModelProviderRegistry, builtin_provider_registry
from .resolver import ModelResolutionReport, prepare_model_sources, resolve_design_models

__all__ = [
    "ModelManifest",
    "ModelProviderRegistry",
    "ModelResolutionReport",
    "ModuleRule",
    "SourceRule",
    "builtin_provider_registry",
    "load_model_manifest",
    "prepare_model_sources",
    "resolve_design_models",
]
