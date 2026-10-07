#!/usr/bin/env python3
"""Provision a private Yazi trial from checksum-verified distribution packages."""

import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import urllib.request

HOME = Path.home()
DEST = HOME / ".local/share/siverteh-ai/yazi-runtime"


def install():
    if shutil.which("yazi") or (DEST / "usr/bin/yazi").is_file():
        return
    DEST.parent.mkdir(parents=True, exist_ok=True)
    cache = HOME / ".cache/siverteh-shell-packages"
    cache.mkdir(parents=True, exist_ok=True)
    records = []
    with tempfile.TemporaryDirectory(dir=DEST.parent) as directory:
        stage = Path(directory)
        for package in ["yazi", "oniguruma", "lua"]:
            output = subprocess.check_output(
                ["pacman", "-Sp", "--print-format", "%l %h", "extra/" + package],
                text=True,
            )
            url, checksum = next(
                line for line in output.splitlines() if "/" + package + "-" in line
            ).split()
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
            records.append({"name": package, "url": url, "sha256": checksum})
        env = dict(os.environ, LD_LIBRARY_PATH=str(stage / "usr/lib"))
        subprocess.run(
            [str(stage / "usr/bin/yazi"), "--version"],
            env=env,
            check=True,
            capture_output=True,
        )
        (stage / "manifest.json").write_text(json.dumps(records, indent=2) + "\n")
        shutil.copytree(stage, DEST)


if __name__ == "__main__":
    install()
