#!/usr/bin/env python3
"""Validate system desktop dependencies and provision the isolated palette engine."""

import subprocess
from pathlib import Path

HOME = Path.home()
ROOT = Path(__file__).resolve().parent
RUNTIME = HOME / ".local/share/siverteh-ai/shell-runtime"
PACKAGES = (
    "quickshell",
    "qt6-imageformats",
    "qt6-multimedia",
    "qt6-multimedia-ffmpeg",
    "ddcutil",
    "cpptrace",
    "libdwarf",
    "wtype",
    "papirus-icon-theme",
)


def main():
    result = subprocess.run(["pacman", "-Q", *PACKAGES], capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(
            "Install desktop dependencies with pacman first:\n" + result.stderr
        )
    venv = RUNTIME / "venv"
    if not (venv / "bin/python").exists():
        subprocess.run(["/usr/bin/python3", "-m", "venv", str(venv)], check=True)
    subprocess.run(
        [str(venv / "bin/pip"), "install", str(ROOT.parent / "shell-cli")], check=True
    )


if __name__ == "__main__":
    main()
