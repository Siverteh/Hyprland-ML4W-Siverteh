#!/usr/bin/env python3
"""Move owned desktop paths to Nacre, preserving data and legacy callers."""

import argparse
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import shutil

DIRECTORIES = (
    (".local/state/siverteh-os", ".local/state/nacre"),
    (".local/state/siverteh_shell", ".local/state/nacre"),
    (".local/state/siverteh-native-shell", ".local/state/nacre/shell"),
    (".local/state/siverteh-os-shell", ".local/state/nacre/supervisor"),
    (".config/siverteh-shell", ".config/nacre"),
    (".config/siverteh_shell", ".config/nacre"),
    (".local/share/siverteh-os", ".local/share/nacre"),
    (".local/share/siverteh_shell", ".local/share/nacre"),
    (".local/share/siverteh-ai/siverteh-shell", ".local/share/nacre/shell"),
    (".local/share/siverteh-ai/shell-runtime", ".local/share/nacre/palette-runtime"),
    (".local/share/siverteh-ai/thunar-style", ".local/share/nacre/thunar-style"),
    (".local/share/siverteh-ai/branding", ".local/share/nacre/branding"),
    (".cache/siverteh_shell", ".cache/nacre"),
)
UNITS = {
    "siverteh-os-shell.service": (
        "nacre-shell.service",
        "22c937eb6b735637c9e42024794bc1a7a6c9cef37a220d00277919f9a855f458",
    ),
    "siverteh-session-watch.service": (
        "nacre-session-watch.service",
        "9efbc7c6e584d00563719f38d674afbaf2796b1bf4af583a8d07e3086ded72fa",
    ),
    "siverteh-manual-power.service": (
        "nacre-power-key.service",
        "22daef16d5b21169fe9152ad585da5f4b81764778197a28122bc71315b6bf921",
    ),
}


def exists(path):
    return path.exists() or path.is_symlink()


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def compatible(source, target):
    if not exists(target):
        return
    if source.is_symlink() or target.is_symlink():
        if not (
            source.is_symlink()
            and target.is_symlink()
            and os.readlink(source) == os.readlink(target)
        ):
            raise RuntimeError(f"Conflicting migration destination preserved: {target}")
    elif source.is_dir() and target.is_dir():
        for child in source.iterdir():
            compatible(child, target / child.name)
    elif source.is_file() and target.is_file() and digest(source) == digest(target):
        return
    else:
        raise RuntimeError(f"Conflicting migration destination preserved: {target}")


def plan(home=None, directories=None, check_units=True):
    home = Path.home() if home is None else Path(home)
    operations = []
    projected = {}
    for old, new in DIRECTORIES if directories is None else directories:
        source, target = home / old, home / new
        if not exists(source):
            continue
        if source.is_symlink() and source.resolve() == target.resolve():
            continue
        compatible(source, target)
        nodes = [source]
        if source.is_dir() and not source.is_symlink():
            nodes.extend(source.rglob("*"))
        for node in nodes:
            destination = target / node.relative_to(source)
            previous = projected.get(destination)
            if previous is not None:
                compatible(node, previous)
            projected[destination] = node
        operations.append((old, new))
    # Validate every legacy service before any directory is moved.
    for old, (new, expected) in UNITS.items() if check_units else []:
        path = home / ".config/systemd/user" / old
        if path.is_symlink() and path.resolve().name == new:
            continue
        if path.is_file() and digest(path) != expected:
            raise RuntimeError(f"Locally edited service preserved: {path}")
    return operations


def atomic(path, body):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name("." + path.name + ".next")
    temporary.write_text(json.dumps(body, indent=2) + "\n")
    temporary.chmod(0o600)
    os.replace(temporary, path)


def apply(home=None, directories=None, check_units=True, journal_root=None):
    home = Path.home() if home is None else Path(home)
    proposed = plan(home, directories, check_units)
    if not proposed:
        return None
    stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    # Outside either namespace so the journal never moves underneath the transaction.
    backup = (
        Path(journal_root)
        if journal_root is not None
        else home / ".local/state/nacre-name-migration"
    ) / stamp
    backup.mkdir(parents=True, mode=0o700)
    record = {"home": str(home), "status": "moving", "operations": []}
    manifest = backup / "manifest.json"

    def log(operation):
        record["operations"].append(operation)
        atomic(manifest, record)

    def move(source, target):
        target.parent.mkdir(parents=True, exist_ok=True)
        source.rename(target)
        log({"kind": "move", "source": str(source), "target": str(target)})

    def merge(source, target):
        target.mkdir(parents=True, exist_ok=True)
        for child in sorted(source.iterdir()):
            destination = target / child.name
            if not exists(destination):
                move(child, destination)
            elif child.is_dir() and not child.is_symlink() and destination.is_dir():
                merge(child, destination)
            # Identical duplicate files remain in the original tree below.

    atomic(manifest, record)
    try:
        for old, new in proposed:
            source, target = home / old, home / new
            if not exists(target):
                move(source, target)
            else:
                merge(source, target)
                saved = backup / "originals" / old
                move(source, saved)
            source.symlink_to(target)
            log({"kind": "alias", "source": str(source), "target": str(target)})
        record["status"] = "complete"
        atomic(manifest, record)
        return manifest
    except BaseException:
        rollback(manifest)
        raise


def rollback(manifest):
    manifest = Path(manifest)
    record = json.loads(manifest.read_text())
    if record["status"] == "rolled-back":
        return
    for operation in reversed(record["operations"]):
        source, target = Path(operation["source"]), Path(operation["target"])
        if operation["kind"] == "alias":
            if not source.is_symlink() or source.resolve() != target.resolve():
                raise RuntimeError(f"Later edit preserved: {source}")
            source.unlink()
        else:
            if exists(source):
                # Recursive merge left empty original directory scaffolding.
                if source.is_dir() and not source.is_symlink():
                    try:
                        source.rmdir()
                    except OSError as error:
                        raise RuntimeError(f"Later edit preserved: {source}") from error
                else:
                    raise RuntimeError(f"Later edit preserved: {source}")
            source.parent.mkdir(parents=True, exist_ok=True)
            target.rename(source)
    record["status"] = "rolled-back"
    atomic(manifest, record)


def install_service_aliases(home=None):
    """Retire old unit identities only after the new power inhibitor has a lease."""
    import subprocess
    import time

    home = Path.home() if home is None else Path(home)
    folder = home / ".config/systemd/user"
    old_power = folder / "siverteh-manual-power.service"
    if old_power.is_file() and not old_power.is_symlink():
        for _ in range(25):
            result = subprocess.run(
                ["systemd-inhibit", "--list", "--json=short"],
                capture_output=True,
                text=True,
            )
            try:
                leases = json.loads(result.stdout)
            except ValueError:
                leases = []
            if any(
                row.get("who") == "Nacre-desktop"
                and "handle-power-key" in row.get("what", "")
                and row.get("mode") == "block"
                for row in leases
            ):
                break
            time.sleep(0.2)
        else:
            raise RuntimeError(
                "New power-key inhibitor not ready; original lease preserved"
            )
    for old, (new, expected) in UNITS.items():
        source, target = folder / old, folder / new
        if source.is_symlink() and source.resolve() == target.resolve():
            continue
        if not source.exists():
            continue
        if not target.is_file():
            raise RuntimeError(
                f"New unit missing; original service preserved: {target}"
            )
        if digest(source) != expected:
            raise RuntimeError(f"Locally edited service preserved: {source}")
        backup = home / ".local/state/nacre/migration-units" / old
        backup.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        if not backup.exists():
            shutil.copy2(source, backup)
        subprocess.run(
            ["systemctl", "--user", "disable", "--now", old],
            check=True,
            capture_output=True,
        )
        source.unlink()
        source.symlink_to(target.name)
    subprocess.run(["systemctl", "--user", "daemon-reload"], check=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "action", choices=["plan", "apply", "rollback"], default="plan", nargs="?"
    )
    parser.add_argument("manifest", type=Path, nargs="?")
    args = parser.parse_args()
    if args.action == "plan":
        for old, new in plan():
            print(f"Move {old} -> {new}; keep old path as an alias")
    elif args.action == "apply":
        print(apply())
    else:
        if args.manifest is None:
            parser.error("rollback needs its private manifest")
        rollback(args.manifest)
