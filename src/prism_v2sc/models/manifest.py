"""Declarative manifest for external RTL simulation models."""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


@dataclass(frozen=True)
class SourceRule:
    """Explicit source-file action, matched with shell-style glob syntax."""

    glob: str
    action: str = "ignore"
    reason: str = ""


@dataclass(frozen=True)
class ModuleRule:
    """Select a module and route it through a named provider."""

    module: str
    provider: str
    config: dict[str, Any] = field(default_factory=dict)
    reason: str = ""


@dataclass(frozen=True)
class ModelManifest:
    """Versioned model policy consumed by the conversion flow."""

    version: int = 1
    strict: bool = True
    source_rules: tuple[SourceRule, ...] = ()
    module_rules: tuple[ModuleRule, ...] = ()
    path: str = ""


def load_model_manifest(path: Path) -> ModelManifest:
    """Load a JSON or TOML model manifest with strict schema validation."""
    resolved = path.resolve()
    if not resolved.is_file():
        raise FileNotFoundError(f"model manifest not found: {path}")
    suffix = resolved.suffix.lower()
    if suffix == ".json":
        payload = json.loads(resolved.read_text(encoding="utf-8"))
    elif suffix in {".toml", ".tml"}:
        import tomllib

        with resolved.open("rb") as handle:
            payload = tomllib.load(handle)
    else:
        raise ValueError("model manifest must use .json or .toml")
    if not isinstance(payload, dict):
        raise ValueError("model manifest root must be an object/table")

    version = payload.get("version", 1)
    if version != 1:
        raise ValueError(f"unsupported model manifest version: {version}")
    strict = payload.get("strict", True)
    if not isinstance(strict, bool):
        raise ValueError("model manifest 'strict' must be boolean")

    source_rules: list[SourceRule] = []
    for index, item in enumerate(payload.get("source_rules", ()) or ()):
        if not isinstance(item, dict) or not isinstance(item.get("glob"), str):
            raise ValueError(f"source_rules[{index}] requires string 'glob'")
        action = item.get("action", "ignore")
        if action not in {"ignore", "include"}:
            raise ValueError(f"source_rules[{index}] has unsupported action: {action}")
        source_rules.append(
            SourceRule(
                glob=item["glob"],
                action=action,
                reason=str(item.get("reason", "")),
            )
        )

    module_rules: list[ModuleRule] = []
    for index, item in enumerate(payload.get("module_rules", ()) or ()):
        if not isinstance(item, dict):
            raise ValueError(f"module_rules[{index}] must be an object/table")
        module = item.get("module")
        provider = item.get("provider")
        config = item.get("config", {})
        if not isinstance(module, str) or not module:
            raise ValueError(f"module_rules[{index}] requires string 'module'")
        if not isinstance(provider, str) or not provider:
            raise ValueError(f"module_rules[{index}] requires string 'provider'")
        if not isinstance(config, dict):
            raise ValueError(f"module_rules[{index}].config must be an object/table")
        module_rules.append(
            ModuleRule(
                module=module,
                provider=provider,
                config=dict(config),
                reason=str(item.get("reason", "")),
            )
        )

    return ModelManifest(
        version=1,
        strict=strict,
        source_rules=tuple(source_rules),
        module_rules=tuple(module_rules),
        path=str(resolved),
    )
