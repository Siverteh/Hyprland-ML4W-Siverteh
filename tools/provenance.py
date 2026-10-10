#!/usr/bin/env python3
"""Inventory tracked artifacts without treating a rename or commit as proof of origin."""

import argparse
from collections import Counter
import hashlib
import json
import os
import re
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parent.parent
REGISTRY = Path("docs/nacre/current-tree-reviews.json")
DISPOSITIONS = {"independent", "third-party", "inherited", "non-implementation"}


def tracked_paths(root):
    try:
        result = subprocess.run(
            ["git", "ls-files", "-z"], cwd=root, check=True, capture_output=True
        )
    except subprocess.CalledProcessError as error:
        detail = error.stderr.decode(errors="replace").strip()
        raise RuntimeError(
            f"Cannot inventory Git index (exit {error.returncode}): {detail}"
        ) from error
    return sorted(set(result.stdout.decode().rstrip("\0").split("\0")) - {""})


def category(path):
    if path.startswith("docs/") or path.endswith(".md"):
        return "documentation"
    if "LICENSE" in path or "NOTICE" in path:
        return "license-notice"
    if "/tests/" in path:
        return "test-fixture"
    if path.startswith("nacre/shell-cli/"):
        return "palette-engine"
    if path.startswith("nacre/shell/"):
        return "shell-asset" if "/assets/" in path else "shell-source"
    if path.startswith("nacre/shell-tools/"):
        return "desktop-helper-data"
    if path.startswith("nacre/login/"):
        return "login-theme"
    if path.startswith(("hypr/", "uwsm/", "kitty/", "fastfetch/", "fish/")):
        return "desktop-config-helper"
    if path.startswith(("ai/", "brain/", "bin/")):
        return "ai-brain-workflow"
    return "packaging-maintenance"


def inventory(root, registry, paths):
    if registry.get("version") != 1:
        raise ValueError("Unsupported provenance registry version")
    path_set = set(paths)
    reviews = registry.get("reviews", {})
    if set(reviews) - path_set:
        raise ValueError("Review references an untracked or retired path")
    changes = {}
    for record in registry.get("change_records", []):
        if not (root / record["spec"]).is_file():
            raise ValueError("Missing change-record spec: " + record["spec"])
        for path in record["paths"]:
            if path in path_set:
                changes.setdefault(path, []).append(
                    {key: record[key] for key in ("area", "commit", "spec")}
                )
    result = []
    for path in sorted(path_set):
        artifact = root / path
        digest = (
            hashlib.sha256(
                os.readlink(artifact).encode()
                if artifact.is_symlink()
                else artifact.read_bytes()
            ).hexdigest()
            if artifact.is_file() or artifact.is_symlink()
            else None
        )
        review = reviews.get(path)
        state = "pending"
        if review is not None:
            if review.get("disposition") not in DISPOSITIONS:
                raise ValueError("Invalid disposition: " + path)
            if not review.get("evidence") or not review.get("sha256"):
                raise ValueError(
                    "A review needs evidence and an artifact hash: " + path
                )
            state = "reviewed" if review["sha256"] == digest else "stale"
        result.append(
            {
                "path": path,
                "category": category(path),
                "sha256": digest,
                "audit": state,
                "review": review,
                "recorded_changes": changes.get(path, []),
            }
        )
    return result


def completion_metadata(root, records, revision):
    """Require exact source reviews and anchor only registry metadata externally."""
    if not re.fullmatch(r"[0-9a-f]{40}", revision or ""):
        raise ValueError("Completion needs an immutable 40-character Git revision")
    unresolved = [
        item["path"]
        for item in records
        if item["path"] != str(REGISTRY)
        and (
            item["audit"] != "reviewed" or item["review"]["disposition"] == "inherited"
        )
    ]
    if unresolved:
        raise ValueError("Unfinished source reviews: " + ", ".join(unresolved))
    metadata = next((item for item in records if item["path"] == str(REGISTRY)), None)
    if metadata is None or metadata["review"] is not None:
        raise ValueError(
            "Registry metadata must be present without a circular self-review"
        )
    try:
        committed = subprocess.run(
            ["git", "show", revision + ":" + str(REGISTRY)],
            cwd=root,
            check=True,
            capture_output=True,
        ).stdout
    except subprocess.CalledProcessError as error:
        raise ValueError("Cannot read the immutable registry revision") from error
    current = (root / REGISTRY).read_bytes()
    if committed != current:
        raise ValueError("Registry differs from its immutable metadata revision")
    return {
        "revision": revision,
        "sha256": hashlib.sha256(current).hexdigest(),
        "disposition": "non-implementation",
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--json", action="store_true", help="Emit the complete inventory"
    )
    parser.add_argument("--check", action="store_true", help="Reject stale reviews")
    parser.add_argument(
        "--complete",
        action="store_true",
        help="Require all source reviews to be resolved",
    )
    parser.add_argument(
        "--metadata-revision",
        help="Immutable commit containing the exact registry bytes",
    )
    args = parser.parse_args()
    if args.complete and not args.metadata_revision:
        parser.error("--complete requires --metadata-revision")
    registry = json.loads((ROOT / REGISTRY).read_text())
    records = inventory(ROOT, registry, tracked_paths(ROOT))
    stale = [item["path"] for item in records if item["audit"] == "stale"]
    metadata = (
        completion_metadata(ROOT, records, args.metadata_revision)
        if args.complete
        else None
    )
    if args.json:
        result = {"version": 1, "files": records}
        if metadata is not None:
            result["metadata_audit"] = metadata
        print(json.dumps(result, indent=2))
    else:
        print(f"Tracked artifacts: {len(records)}")
        print(
            f"Artifacts with recorded rewrite changes: {sum(bool(r['recorded_changes']) for r in records)}"
        )
        print(
            "Final audit: "
            + ", ".join(
                f"{state}={count}"
                for state, count in sorted(Counter(r["audit"] for r in records).items())
            )
        )
        for group, count in sorted(Counter(r["category"] for r in records).items()):
            print(f"  {group}: {count}")
        print(
            "Recorded changes are evidence pointers, not independent-origin certification."
        )
    if metadata is not None and not args.json:
        print(
            "All source reviews resolved; registry metadata anchored at "
            + metadata["revision"]
        )
        print("Registry metadata SHA-256: " + metadata["sha256"])
    if args.check and stale:
        raise SystemExit("Stale provenance reviews: " + ", ".join(stale))


if __name__ == "__main__":
    main()
