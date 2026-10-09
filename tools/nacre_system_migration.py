#!/usr/bin/env python3
"""Rename the owned login/timezone integration, preserving its settings and backups."""

import argparse
import datetime as dt
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parent.parent
DIRECTORIES = (
    ("var/lib/siverteh-os", "var/lib/nacre"),
    ("var/lib/siverteh-login", "var/lib/nacre/login"),
    ("etc/siverteh-os", "etc/nacre"),
    ("usr/share/sddm/themes/siverteh", "usr/share/sddm/themes/nacre"),
)


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def apply(prefix=Path("/"), repo=ROOT, run_system=True):
    prefix, repo = Path(prefix), Path(repo)
    if run_system and (prefix != Path("/") or os.geteuid() != 0):
        raise PermissionError("Administrator authentication is required")
    migration = load("nacre_system_paths", repo / "tools/nacre_migration.py")
    migration.plan(prefix, DIRECTORIES, check_units=False)
    old_timer = "siverteh-timezone.timer"
    if run_system:
        subprocess.run(
            ["systemctl", "disable", "--now", old_timer],
            check=True,
            capture_output=True,
        )
        subprocess.run(
            ["systemctl", "stop", "siverteh-timezone.service"],
            check=True,
            capture_output=True,
        )
    manifest = migration.apply(
        prefix,
        DIRECTORIES,
        check_units=False,
        journal_root=prefix / "var/lib/nacre-name-migration",
    )
    timezone = load("nacre_system_timezone", repo / "nacre/shell-tools/timezone.py")
    current = prefix / "etc/nacre/timezone.json"
    automatic = (
        json.loads(current.read_text()).get("automatic", False)
        if current.exists()
        else False
    )
    stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    backup = prefix / "var/lib/nacre-name-migration" / stamp
    backup.mkdir(parents=True, exist_ok=True, mode=0o700)
    entries = []

    def capture(path):
        entry = {"path": str(path), "existed": path.exists() or path.is_symlink()}
        if path.is_symlink():
            entry["link"] = os.readlink(path)
        elif path.is_file():
            saved = backup / str(len(entries))
            shutil.copy2(path, saved)
            entry["backup"] = str(saved)
        entries.append(entry)
        (backup / "files.json").write_text(json.dumps(entries, indent=2))

    def write(relative, body, mode=0o644):
        target = prefix / relative
        capture(target)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.unlink(missing_ok=True) if target.is_symlink() else None
        temporary = target.with_name("." + target.name + ".nacre")
        temporary.write_text(body)
        temporary.chmod(mode)
        temporary.replace(target)

    def alias(old, new):
        source, target = prefix / old, prefix / new
        if not source.exists() or (
            source.is_symlink() and source.resolve() == target.resolve()
        ):
            return
        capture(source)
        source.unlink()
        source.symlink_to(target)

    try:
        for name in ["Main.qml", "Logo.qml", "theme.conf", "metadata.desktop"]:
            write(
                "usr/share/sddm/themes/nacre/" + name,
                (repo / "nacre/login" / name).read_text(),
            )
        old_config = prefix / "etc/sddm.conf.d/90-siverteh-theme.conf"
        if old_config.exists() and "Current=siverteh" in old_config.read_text():
            write(
                "etc/sddm.conf.d/90-nacre-theme.conf",
                old_config.read_text().replace("Current=siverteh", "Current=nacre"),
            )
            alias(
                "etc/sddm.conf.d/90-siverteh-theme.conf",
                "etc/sddm.conf.d/90-nacre-theme.conf",
            )
        write(
            "usr/local/libexec/nacre-timezone.py",
            (repo / "nacre/shell-tools/timezone.py").read_text(),
            0o755,
        )
        write(
            "usr/local/libexec/nacre-device-location.py",
            (repo / "nacre/shell-tools/device-location.py").read_text(),
            0o755,
        )
        for path, body, mode in [
            ("etc/systemd/system/nacre-timezone.service", timezone.SERVICE, 0o644),
            ("etc/systemd/system/nacre-timezone.timer", timezone.TIMER, 0o644),
            (
                "etc/NetworkManager/dispatcher.d/80-nacre-timezone",
                timezone.DISPATCH,
                0o755,
            ),
            (
                "etc/geoclue/conf.d/80-nacre-timezone.conf",
                timezone.GEO_PERMISSION,
                0o644,
            ),
            (
                "usr/share/applications/nacre-timezone.desktop",
                timezone.GEO_DESKTOP,
                0o644,
            ),
        ]:
            write(path, body, mode)
        for old, new in [
            (
                "usr/local/libexec/siverteh-timezone.py",
                "usr/local/libexec/nacre-timezone.py",
            ),
            (
                "usr/local/libexec/siverteh-device-location.py",
                "usr/local/libexec/nacre-device-location.py",
            ),
            (
                "etc/systemd/system/siverteh-timezone.service",
                "etc/systemd/system/nacre-timezone.service",
            ),
            (
                "etc/systemd/system/siverteh-timezone.timer",
                "etc/systemd/system/nacre-timezone.timer",
            ),
        ]:
            alias(old, new)
        # Avoid executing both NetworkManager hooks. Retain the previous file privately.
        old_dispatch = prefix / "etc/NetworkManager/dispatcher.d/80-siverteh-timezone"
        if old_dispatch.exists():
            capture(old_dispatch)
            old_dispatch.unlink()
        if run_system:
            subprocess.run(["systemctl", "daemon-reload"], check=True)
            if automatic:
                subprocess.run(
                    ["systemctl", "enable", "--now", "nacre-timezone.timer"],
                    check=True,
                    capture_output=True,
                )
        return {
            "directories": str(manifest) if manifest else None,
            "files": str(backup / "files.json"),
            "automatic": automatic,
        }
    except BaseException:
        for entry in reversed(entries):
            path = Path(entry["path"])
            path.unlink(missing_ok=True)
            if "link" in entry:
                path.symlink_to(entry["link"])
            elif "backup" in entry:
                shutil.copy2(entry["backup"], path)
        if manifest:
            migration.rollback(manifest)
        if run_system:
            subprocess.run(["systemctl", "daemon-reload"], check=True)
            if automatic:
                subprocess.run(
                    ["systemctl", "enable", "--now", old_timer],
                    check=True,
                    capture_output=True,
                )
        raise


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.parse_args()
    print(json.dumps(apply(), indent=2))
