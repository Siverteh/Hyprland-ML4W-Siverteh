#!/usr/bin/env python3
"""Provision only the reference shell's user-local dependencies and maintained CLI."""

import os, subprocess, urllib.request, hashlib, shutil
from pathlib import Path

HOME = Path.home()
ROOT = Path(__file__).resolve().parent
RUNTIME = HOME / ".local/share/siverteh-ai/shell-runtime"


def main():
    RUNTIME.mkdir(parents=True, exist_ok=True)
    cache = HOME / ".cache/siverteh-shell-packages"
    cache.mkdir(parents=True, exist_ok=True)
    for record in subprocess.check_output(
        [
            "pacman",
            "-Sp",
            "--print-format",
            "%l %h",
            "quickshell",
            "qt6-imageformats",
            "ddcutil",
            "cpptrace",
            "libdwarf",
            "wtype",
            "qt6-multimedia",
            "qt6-multimedia-ffmpeg",
            "papirus-icon-theme",
        ],
        text=True,
    ).splitlines():
        url, expected = record.split()
        package = cache / url.rsplit("/", 1)[-1]
        if not package.exists():
            urllib.request.urlretrieve(url, package)
        if hashlib.sha256(package.read_bytes()).hexdigest() != expected:
            raise RuntimeError("Package checksum mismatch: " + package.name)
        subprocess.run(["bsdtar", "-xf", str(package), "-C", str(RUNTIME)], check=True)
    # Native GTK apps use the user icon directory, outside the isolated Qt runtime.
    for name in (
        "Papirus",
        "Papirus-Dark",
        "Papirus-Light",
        "ePapirus",
        "ePapirus-Dark",
    ):
        source = RUNTIME / "usr/share/icons" / name
        if source.is_dir():
            shutil.copytree(
                source, HOME / ".local/share/icons" / name, dirs_exist_ok=True
            )
    venv = RUNTIME / "venv"
    if not (venv / "bin/python").exists():
        subprocess.run(["python3", "-m", "venv", str(venv)], check=True)
    subprocess.run(
        [str(venv / "bin/pip"), "install", str(ROOT.parent / "shell-cli")], check=True
    )


if __name__ == "__main__":
    main()
