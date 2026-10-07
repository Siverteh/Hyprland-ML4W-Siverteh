#!/usr/bin/env python3
"""Provision only native KDE platform integration for the existing Dolphin binary."""

import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import urllib.request

HOME = Path.home()
RUNTIME = HOME / ".local/share/siverteh-ai/file-manager-runtime"
SYSTEM_PLUGIN = Path("/usr/lib/qt6/plugins/platformthemes/KDEPlasmaPlatformTheme6.so")


def qt_version():
    return subprocess.check_output(
        ["/usr/lib/qt6/bin/qtpaths", "--qt-version"], text=True
    ).strip()


def compatible():
    if SYSTEM_PLUGIN.is_file():
        return True
    try:
        data = json.loads((RUNTIME / "manifest.json").read_text())
        return (
            data["qt"].split(".")[:2] == qt_version().split(".")[:2]
            and (
                RUNTIME
                / "usr/lib/qt6/plugins/platformthemes/KDEPlasmaPlatformTheme6.so"
            ).is_file()
        )
    except (OSError, ValueError, KeyError, subprocess.SubprocessError):
        return False


def provision():
    if compatible():
        return
    RUNTIME.parent.mkdir(parents=True, exist_ok=True)
    cache = HOME / ".cache/siverteh-shell-packages"
    cache.mkdir(parents=True, exist_ok=True)
    records = []
    with tempfile.TemporaryDirectory(dir=RUNTIME.parent) as folder:
        stage = Path(folder)
        for name in ["plasma-integration", "kstatusnotifieritem"]:
            output = subprocess.check_output(
                ["pacman", "-Sp", "--print-format", "%l %h", "extra/" + name], text=True
            )
            url, digest = next(
                line for line in output.splitlines() if "/" + name + "-" in line
            ).split()
            if not url.startswith("https://"):
                raise ValueError("Expected a secure distribution package URL")
            archive = cache / url.rsplit("/", 1)[-1]
            if not archive.exists():
                with (
                    urllib.request.urlopen(url, timeout=30) as source,
                    archive.open("wb") as destination,
                ):
                    shutil.copyfileobj(source, destination)
            if hashlib.sha256(archive.read_bytes()).hexdigest() != digest:
                raise ValueError("Package checksum mismatch: " + name)
            subprocess.run(
                ["bsdtar", "-xf", str(archive), "-C", str(stage)], check=True
            )
            records.append({"package": name, "url": url, "sha256": digest})
        plugin = stage / "usr/lib/qt6/plugins/platformthemes/KDEPlasmaPlatformTheme6.so"
        output = subprocess.check_output(
            ["ldd", str(plugin)],
            env=dict(os.environ, LD_LIBRARY_PATH=str(stage / "usr/lib")),
            text=True,
        )
        if "not found" in output:
            raise RuntimeError(
                "Native file-manager integration has unresolved libraries"
            )
        (stage / "manifest.json").write_text(
            json.dumps({"qt": qt_version(), "packages": records}, indent=2) + "\n"
        )
        old = RUNTIME.with_name(RUNTIME.name + ".previous")
        if old.exists():
            shutil.rmtree(old)
        if RUNTIME.exists():
            RUNTIME.rename(old)
        try:
            shutil.copytree(stage, RUNTIME)
        except Exception:
            if RUNTIME.exists():
                shutil.rmtree(RUNTIME)
            if old.exists():
                old.rename(RUNTIME)
            raise


if __name__ == "__main__":
    provision()
