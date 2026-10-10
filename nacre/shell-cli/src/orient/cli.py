"""Standalone, read-only Orient CLI. Publication belongs to the caller."""

import argparse
import json
from pathlib import Path
import sys
from . import ENGINE_ID
from .engine import from_image
from .extract import analyze, sample_color
from .palette import PERSONALITIES
from .export import export


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", action="version", version=ENGINE_ID)
    commands = parser.add_subparsers(dest="command", required=True)
    analysis = commands.add_parser("analyze")
    analysis.add_argument("image")
    sampling = commands.add_parser("sample")
    sampling.add_argument("image")
    sampling.add_argument("x", type=float)
    sampling.add_argument("y", type=float)
    palette = commands.add_parser("palette")
    palette.add_argument("image")
    palette.add_argument("--mode", choices=("dark", "light"), default="dark")
    palette.add_argument("--personality", choices=PERSONALITIES, default="natural")
    palette.add_argument("--background-from-wallpaper", action=argparse.BooleanOptionalAction, default=None)
    palette.add_argument("--accent")
    for role in ("primary", "secondary", "tertiary"):
        palette.add_argument("--" + role)
    palette.add_argument("--brightness", type=float, default=0.0)
    palette.add_argument("--saturation", type=float, default=1.0)
    palette.add_argument("--hour", type=int, default=12)
    exports = commands.add_parser("export")
    exports.add_argument("palette", type=Path)
    exports.add_argument("directory", type=Path)
    exports.add_argument("--templates", type=Path)
    args = parser.parse_args(argv)
    try:
        if args.command == "analyze":
            result = analyze(args.image)
        elif args.command == "sample":
            result = {"hex": sample_color(args.image, args.x, args.y)}
        elif args.command == "export":
            result = {"files": export(json.loads(args.palette.read_text()), args.directory, args.templates)}
        else:
            result = from_image(
                args.image,
                mode=args.mode,
                personality=args.personality,
                background_from_wallpaper=args.background_from_wallpaper,
                accent=args.accent,
                overrides={
                    role: getattr(args, role) for role in ("primary", "secondary", "tertiary") if getattr(args, role)
                },
                brightness=args.brightness,
                saturation=args.saturation,
                hour=args.hour,
            )
        print(json.dumps(result))
        return 0
    except (OSError, ValueError, KeyError) as error:
        print("orient: " + str(error), file=sys.stderr)
        return 1
