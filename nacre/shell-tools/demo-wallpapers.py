#!/usr/bin/env python3
"""Validate and cache the offline, artist-licensed Welcome wallpaper collection."""

import hashlib
import json
import os
from pathlib import Path
import shutil
import tempfile
from PIL import Image

ASSETS = Path(__file__).with_name("demo-wallpapers")


def collection():
    manifest = json.loads((ASSETS / "manifest.json").read_text())
    if manifest.get("version") != 1 or len(manifest.get("wallpapers", [])) != 4:
        raise ValueError(
            "The bundled wallpaper manifest is incomplete. Reinstall the shell."
        )
    entries = manifest["wallpapers"]
    for item in entries:
        name = item["file"]
        if Path(name).name != name or Path(name).suffix not in (".jpg", ".png"):
            raise ValueError("Invalid bundled wallpaper filename")
        source = ASSETS / name
        if hashlib.sha256(source.read_bytes()).hexdigest() != item["sha256"]:
            raise ValueError(
                "Bundled wallpaper checksum failed: " + name + ". Reinstall the shell."
            )
        with Image.open(source) as image:
            if (
                list(image.size) != item["size"]
                or image.width < 3840
                or image.height < 2000
            ):
                raise ValueError(
                    "Bundled wallpaper resolution does not match its manifest"
                )
            image.verify()
        if (
            item["license"] not in ("CC-BY-4.0", "CC-BY-SA-4.0")
            or not item.get("artist")
            or not item.get("source")
        ):
            raise ValueError("Bundled wallpaper attribution is incomplete")
    return entries


def ensure(home):
    """Copy original bytes once by content hash, with no network or library writes.

    Immutable cached originals keep an active wallpaper valid across software
    upgrades. A missing/corrupt cache copy is repaired from the licensed bundle.
    Only the separate thumbnail owner resizes viewing previews.
    """
    entries = collection()
    identity = hashlib.sha256((ASSETS / "manifest.json").read_bytes()).hexdigest()[:16]
    folder = Path(home) / ".cache/nacre/demo-wallpapers" / identity
    folder.mkdir(parents=True, exist_ok=True)
    result = []
    for item in entries:
        source = ASSETS / item["file"]
        path = folder / item["file"]
        if (
            not path.is_file()
            or hashlib.sha256(path.read_bytes()).hexdigest() != item["sha256"]
        ):
            fd, name = tempfile.mkstemp(dir=folder, suffix=path.suffix)
            os.close(fd)
            try:
                shutil.copyfile(source, name)
                os.replace(name, path)
            finally:
                Path(name).unlink(missing_ok=True)
        result.append(dict(item, path=str(path)))
    return result


if __name__ == "__main__":
    print(json.dumps(ensure(Path.home())))
