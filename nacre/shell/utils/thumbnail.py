#!/usr/bin/env python3
"""Generate the reference shell's cache without shell interpolation or invalid sizes."""

import hashlib, subprocess, sys
from pathlib import Path

source = Path(sys.argv[1])
width = int(sys.argv[2])
height = int(sys.argv[3])
directory = Path(sys.argv[4])
if not str(sys.argv[1]) or not source.is_file():
    sys.exit(0)
if width <= 0 or height <= 0:
    print(source)
    sys.exit(0)
directory.mkdir(parents=True, exist_ok=True)
target = directory / (
    hashlib.sha1(source.read_bytes()).hexdigest() + f"@{width}x{height}-exact.png"
)
if not target.exists():
    print("start", flush=True)
    subprocess.run(
        [
            "magick",
            str(source),
            "-resize",
            f"{width}x{height}^",
            "-background",
            "none",
            "-gravity",
            "center",
            "-extent",
            f"{width}x{height}",
            str(target),
        ],
        check=True,
        capture_output=True,
    )
print(target)
