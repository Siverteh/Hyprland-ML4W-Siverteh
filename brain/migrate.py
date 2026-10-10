"""Move private Brain namespaces with journaled moves and legacy aliases."""

import hashlib
import importlib.util
import json
import os
import shutil
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DIRECTORIES = (
    ("Documents/Siverteh-Brain", "Documents/Nacre-Brain"),
    (".local/state/siverteh-observatory", ".local/state/nacre/brain"),
    (".local/share/siverteh-ai/observatory", ".local/share/nacre/brain"),
    (
        ".local/share/siverteh-ai/observatory-browser",
        ".local/share/nacre/brain-browser",
    ),
    (".config/siverteh-ai/brain-sync.json", ".config/nacre/brain-sync.json"),
)
UNITS = {
    "siverteh-observatory-brain.service": (
        "nacre-brain.service",
        "a9b6ae47c5a8d872c358d86b3e937255a4ff17dd17ab71a28db8f8008a1af7fd",
    ),
    "siverteh-brain-sync.service": (
        "nacre-brain-sync.service",
        "faab8451427a98f54200eee51e0cbbdee5d649fdfd55a9edaa9a8f1dd10de22c",
    ),
    "siverteh-brain-sync.timer": (
        "nacre-brain-sync.timer",
        "0d8ecf151410671daf7b68b6fab756cf7f665712da656cffb1dfec0143e30950",
    ),
    "siverteh-brain-check.service": (
        "nacre-brain-check.service",
        "31d1db659b061d6ddb580e96f88c8d385e9b68d981bdd58b96bd7f65c2d9dda7",
    ),
    "siverteh-brain-check.timer": (
        "nacre-brain-check.timer",
        "85a35eb517e74f65c4c7539d33c35d3041a1cd2d4aded407d84a9b86436569dd",
    ),
}


def helper():
    spec = importlib.util.spec_from_file_location(
        "brain_namespace", ROOT / "tools/nacre_migration.py"
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def plan(home=None):
    home = Path.home() if home is None else Path(home)
    operations = helper().plan(home, DIRECTORIES, check_units=False)
    for old, (new, expected) in UNITS.items():
        path = home / ".config/systemd/user" / old
        if path.is_symlink() and path.resolve().name == new:
            continue
        if path.is_file() and hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            raise RuntimeError(f"Locally edited Brain service preserved: {path}")
    return operations


def apply(home=None):
    home = Path.home() if home is None else Path(home)
    plan(home)
    journal = helper().apply(home, DIRECTORIES, check_units=False)
    registration = home / ".config/obsidian/obsidian.json"
    if journal and registration.is_file():
        before = registration.read_bytes()
        data = json.loads(before)
        changed = False
        for vault in data.get("vaults", {}).values():
            if vault.get("path") == str(home / "Documents/Siverteh-Brain"):
                vault["path"] = str(home / "Documents/Nacre-Brain")
                changed = True
        if changed:
            saved = journal.parent / "obsidian-registration.json"
            shutil.copy2(registration, saved)
            body = (json.dumps(data, indent=2) + "\n").encode()
            fd, temporary = tempfile.mkstemp(dir=registration.parent)
            with os.fdopen(fd, "wb") as output:
                output.write(body)
            os.chmod(temporary, registration.stat().st_mode & 0o777)
            if registration.read_bytes() != before:
                Path(temporary).unlink()
                raise RuntimeError("Concurrent Obsidian registration edit preserved")
            os.replace(temporary, registration)
            record = json.loads(journal.read_text())
            record["registration"] = {
                "path": str(registration),
                "backup": str(saved),
                "after": hashlib.sha256(body).hexdigest(),
            }
            helper().atomic(journal, record)
    return journal


def aliases(home=None):
    home = Path.home() if home is None else Path(home)
    for old, (new, _) in UNITS.items():
        path = home / ".config/systemd/user" / old
        path.unlink(missing_ok=True)
        path.symlink_to(new)


def rollback(journal):
    journal = Path(journal)
    record = json.loads(journal.read_text())
    registration = record.get("registration")
    if registration and record.get("status") != "rolled-back":
        path = Path(registration["path"])
        if hashlib.sha256(path.read_bytes()).hexdigest() != registration["after"]:
            raise RuntimeError("Later Obsidian registration edit preserved")
        shutil.copy2(registration["backup"], path)
    helper().rollback(journal)
