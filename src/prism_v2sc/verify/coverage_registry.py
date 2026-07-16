"""Validation and summary helpers for the RTL feature coverage registry."""

from __future__ import annotations

import json
from collections import Counter
from pathlib import Path


VALID_STATUSES = {
    "supported",
    "supported_with_warning",
    "modeled_by_provider",
    "rejected",
    "not_tested",
}


def validate_coverage_registry(path: Path, project_root: Path) -> dict[str, int]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict) or payload.get("version") != 1:
        raise ValueError("coverage registry must be a version 1 object")
    features = payload.get("features")
    if not isinstance(features, list) or not features:
        raise ValueError("coverage registry requires a non-empty features list")
    seen: set[str] = set()
    counts: Counter[str] = Counter()
    for index, feature in enumerate(features):
        if not isinstance(feature, dict):
            raise ValueError(f"features[{index}] must be an object")
        feature_id = feature.get("id")
        status = feature.get("status")
        evidence = feature.get("evidence")
        if not isinstance(feature_id, str) or not feature_id or feature_id in seen:
            raise ValueError(f"features[{index}] has an invalid or duplicate id")
        if status not in VALID_STATUSES:
            raise ValueError(f"feature '{feature_id}' has invalid status: {status}")
        if not isinstance(evidence, list) or not all(isinstance(item, str) for item in evidence):
            raise ValueError(f"feature '{feature_id}' evidence must be a string list")
        if status == "not_tested" and evidence:
            raise ValueError(f"not_tested feature '{feature_id}' cannot claim evidence")
        if status != "not_tested" and not evidence:
            raise ValueError(f"feature '{feature_id}' requires evidence")
        for item in evidence:
            if not (project_root / item).exists():
                raise ValueError(f"feature '{feature_id}' evidence does not exist: {item}")
        seen.add(feature_id)
        counts[str(status)] += 1
    return dict(sorted(counts.items()))
