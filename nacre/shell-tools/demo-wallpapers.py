#!/usr/bin/env python3
"""Original procedural mother-of-pearl artwork; generated images are CC0-1.0."""

import hashlib
import json
import math
import os
from pathlib import Path
import tempfile
from PIL import Image, ImageDraw

SCENES = (
    ("opal-tide", "Opal Tide", (18, 38, 64), (60, 154, 174), (242, 155, 76)),
    ("rose-current", "Rose Current", (55, 19, 42), (190, 83, 118), (74, 210, 193)),
    ("amber-fold", "Amber Fold", (48, 29, 18), (195, 132, 63), (89, 149, 230)),
    ("violet-lagoon", "Violet Lagoon", (30, 24, 58), (134, 98, 191), (240, 170, 70)),
)
VERSION = 1


def render(scene, size=(3840, 2160)):
    """Draw layered, off-center curved sheets and a contrasting inset pearl.

    Geometry is authored here, not traced or sampled from external artwork.
    The restrained background uses an analytic light field. Four large sheets
    carry the dominant family; the inset is deliberately a different minority
    family so Pop has a meaningful detail to choose.
    """
    _, _, dark, body, detail = scene
    width, height = 960, 540
    pixels = []
    for y in range(height):
        for x in range(width):
            glow = math.exp(
                -(((x / width - 0.66) / 0.66) ** 2 + ((y / height - 0.45) / 0.72) ** 2)
            )
            ripple = 0.02 * math.sin(x / 53 + y / 80)
            amount = 0.11 + 0.18 * glow + ripple
            pixels.append(
                tuple(round(a * (1 - amount) + b * amount) for a, b in zip(dark, body))
            )
    image = Image.new("RGB", (width, height))
    image.putdata(pixels)
    draw = ImageDraw.Draw(image)
    # Sweeping sheets leave asymmetrical dark breathing room, with fine growth edges.
    for index in range(8):
        inset = index * 24
        bounds = (
            -155 + inset,
            -295 + inset * 1.5,
            870 - inset * 0.6,
            660 - inset * 0.9,
        )
        lift = 0.10 + index * 0.055
        color = tuple(round(v * (1 - lift) + 242 * lift) for v in body)
        draw.ellipse(bounds, fill=color)
        edge = tuple(min(255, v + 18) for v in color)
        draw.arc(bounds, 190, 350, fill=edge, width=2)
    # A dark lip around a contrasting pool: readable at thumbnail and desktop scale.
    draw.ellipse((584, 264, 824, 504), fill=dark)
    for inset in range(88):
        mix = inset / 88
        color = tuple(round(v * (1 - 0.22 * mix) + 248 * 0.22 * mix) for v in detail)
        draw.ellipse((602 + inset, 282 + inset, 806 - inset, 486 - inset), fill=color)
    return image.resize(size, Image.Resampling.LANCZOS)


def ensure(home):
    """Versioned atomic cache; never touch a user's private library."""
    home = Path(home)
    identity = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()[:16]
    folder = home / ".cache/nacre/demo-wallpapers" / identity
    folder.mkdir(parents=True, exist_ok=True)
    entries = []
    for scene in SCENES:
        path = folder / (scene[0] + ".png")
        if not path.exists():
            fd, name = tempfile.mkstemp(dir=folder, suffix=".png")
            os.close(fd)
            try:
                render(scene).save(name, optimize=True)
                os.replace(name, path)
            finally:
                Path(name).unlink(missing_ok=True)
        entries.append({"path": str(path), "name": scene[1], "license": "CC0-1.0"})
    return entries


if __name__ == "__main__":
    print(json.dumps(ensure(Path.home())))
