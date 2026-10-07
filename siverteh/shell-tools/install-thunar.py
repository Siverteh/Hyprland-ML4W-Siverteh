#!/usr/bin/env python3
"""Provision a private Thunar file manager from checksum-verified distribution packages."""

import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import urllib.request

HOME = Path.home()
DEST = HOME / ".local/share/siverteh-ai/thunar-runtime"


def provision():
    DEST.parent.mkdir(parents=True, exist_ok=True)
    cache = HOME / ".cache/siverteh-shell-packages"
    cache.mkdir(parents=True, exist_ok=True)
    packages = ["thunar", "xfconf", "exo", "libxfce4ui", "libgtop"]
    output = subprocess.check_output(
        [
            "pacman",
            "-Sp",
            "--print-format",
            "%n %l %h",
            *["extra/" + p for p in packages],
        ],
        text=True,
    )
    records = [
        dict(zip(("name", "url", "sha256"), line.split()))
        for line in output.splitlines()
        if line.split()[0] in packages
    ]
    if len(records) != len(packages):
        raise RuntimeError("Missing Thunar runtime package metadata")
    manifest = DEST / "manifest.json"
    if (
        (DEST / "usr/bin/thunar").is_file()
        and manifest.exists()
        and json.loads(manifest.read_text()) == records
    ):
        return
    with tempfile.TemporaryDirectory(dir=DEST.parent) as directory:
        stage = Path(directory)
        for record in records:
            package, url, checksum = record["name"], record["url"], record["sha256"]
            archive = cache / url.rsplit("/", 1)[-1]
            if not archive.exists():
                with (
                    urllib.request.urlopen(url, timeout=30) as source,
                    archive.open("wb") as destination,
                ):
                    shutil.copyfileobj(source, destination)
            if hashlib.sha256(archive.read_bytes()).hexdigest() != checksum:
                raise ValueError("Package checksum mismatch: " + package)
            subprocess.run(
                ["bsdtar", "-xf", str(archive), "-C", str(stage)], check=True
            )
        env = dict(os.environ, LD_LIBRARY_PATH=str(stage / "usr/lib"))
        subprocess.run(
            [str(stage / "usr/bin/thunar"), "--version"],
            env=env,
            check=True,
            capture_output=True,
        )
        (stage / "manifest.json").write_text(json.dumps(records, indent=2) + "\n")
        if DEST.exists():
            old = DEST.with_name("thunar-runtime.previous")
            if old.exists():
                shutil.rmtree(old)
            DEST.rename(old)
            try:
                shutil.copytree(stage, DEST)
            except Exception:
                shutil.rmtree(DEST, ignore_errors=True)
                old.rename(DEST)
                raise
            shutil.rmtree(old)
        else:
            shutil.copytree(stage, DEST)


def install():
    provision()
    flags = subprocess.check_output(
        ["pkg-config", "--cflags", "--libs", "gtk+-3.0"], text=True
    ).split()
    output = DEST / "siverteh-thunar-theme.so"
    candidate = output.with_suffix(".tmp.so")
    subprocess.run(
        [
            "cc",
            "-shared",
            "-fPIC",
            "-Wall",
            "-Wextra",
            "-Werror",
            "-o",
            str(candidate),
            str(Path(__file__).with_name("thunar-theme.c")),
            *flags,
        ],
        check=True,
    )
    candidate.replace(output)
    launcher = HOME / ".local/share/applications/siverteh-thunar.desktop"
    launcher.parent.mkdir(parents=True, exist_ok=True)
    launcher.write_text(
        "[Desktop Entry]\nType=Application\nName=Thunar Files\n"
        "Comment=Browse files with Siverteh colors\nIcon=system-file-manager\n"
        "Exec=" + str(HOME / ".local/bin/siverteh-os-shell") + " thunar %U\n"
        "Terminal=false\nDBusActivatable=false\nMimeType=inode/directory;\nCategories=System;FileManager;\n"
    )

    marker = HOME / ".local/state/siverteh-os/thunar-default.json"
    if not marker.exists():
        before = subprocess.check_output(
            ["xdg-mime", "query", "default", "inode/directory"], text=True
        ).strip()
        subprocess.run(
            ["xdg-mime", "default", "siverteh-thunar.desktop", "inode/directory"],
            check=True,
        )
        marker.parent.mkdir(parents=True, exist_ok=True)
        marker.write_text(
            json.dumps({"before": before, "applied": "siverteh-thunar.desktop"}) + "\n"
        )
        marker.chmod(0o600)


if __name__ == "__main__":
    install()
