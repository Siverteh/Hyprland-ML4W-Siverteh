#!/usr/bin/env python3
"""Regenerate fixed desktop palettes with the maintained, pinned CLI runtime."""

import json
from pathlib import Path
from types import SimpleNamespace
from siverteh_shell.utils.material.generator import gen_scheme, hex_to_hct
from materialyoucolor.hct import Hct

SOFT = [
    ("amethyst", "Amethyst", "8b6bd1"),
    ("ocean", "Ocean", "2785b6"),
    ("forest", "Forest", "4c8861"),
    ("rose", "Rose", "b95879"),
    ("ember", "Ember", "bb713d"),
    ("slate", "Slate", "73808c"),
    ("soft-red", "Blush Red", "e54a54"),
    ("soft-orange", "Apricot", "ef8a47"),
    ("soft-gold", "Honey", "c59628"),
    ("soft-yellow", "Butter Yellow", "dac343"),
    ("soft-lime", "Pear", "9eaf38"),
    ("soft-green", "Sage", "6b9b67"),
    ("soft-teal", "Sea Glass", "409e91"),
    ("soft-cyan", "Glacier", "32a8c3"),
    ("soft-blue", "Cornflower", "4e78db"),
    ("soft-indigo", "Periwinkle", "6964c8"),
    ("soft-purple", "Lilac", "a05acb"),
    ("soft-pink", "Candy Pink", "de5caa"),
]
VIVID = [
    ("super-red", "Super Red", "ff3030"),
    ("flame-orange", "Flame Orange", "ff791f"),
    ("solar-gold", "Solar Gold", "ffb800"),
    ("electric-yellow", "Electric Yellow", "f5ed00"),
    ("acid-lime", "Acid Lime", "b5ed14"),
    ("emerald", "Emerald", "11d96c"),
    ("deep-teal", "Deep Teal", "00b99d"),
    ("electric-cyan", "Electric Cyan", "00d6f5"),
    ("cobalt-blue", "Cobalt Blue", "4275ff"),
    ("royal-indigo", "Royal Indigo", "7155ff"),
    ("vivid-purple", "Violet", "b147ff"),
    ("hot-pink", "Hot Pink", "ff38b8"),
]


def luminance(value):
    def linear(part):
        return part / 12.92 if part <= 0.04045 else ((part + 0.055) / 1.055) ** 2.4

    rgb = [linear(int(value[i : i + 2], 16) / 255) for i in (0, 2, 4)]
    return sum(a * b for a, b in zip(rgb, (0.2126, 0.7152, 0.0722)))


def contrast(a, b):
    low, high = sorted([luminance(a), luminance(b)])
    return (high + 0.05) / (low + 0.05)


def hct_hex(hue, chroma, tone):
    return format(Hct.from_hct(hue, chroma, tone).to_int() & 0xFFFFFF, "06x")


def build():
    presets = []
    for group, choices in [("soft", SOFT), ("vivid", VIVID)]:
        for ident, name, seed in choices:
            modes = {}
            for mode in ["dark", "light"]:
                variant = (
                    "neutral"
                    if ident == "slate"
                    else "vibrant"
                    if group == "vivid"
                    else "tonalspot"
                )
                source = hex_to_hct(seed)
                colors = gen_scheme(
                    SimpleNamespace(mode=mode, variant=variant, flavour="default"),
                    source,
                )
                if group == "vivid":
                    # Keep saturated seed colors, instead of Material's default pastel
                    # dark accents. Raise luminance only enough for header contrast.
                    if mode == "dark":
                        primary = seed
                        tone = source.tone
                        while (
                            contrast(primary, colors["surfaceContainer"]) < 4.5
                            and tone < 90
                        ):
                            tone += 1
                            primary = hct_hex(source.hue, source.chroma, tone)
                    else:
                        primary = hct_hex(source.hue, source.chroma, 40)
                    foreground = max(
                        ["000000", "ffffff"], key=lambda c: contrast(c, primary)
                    )
                    colors.update(
                        primary=primary, onPrimary=foreground, surfaceTint=primary
                    )
                modes[mode] = colors
            presets.append(
                dict(id=ident, name=name, seed="#" + seed, group=group, modes=modes)
            )
    return presets


if __name__ == "__main__":
    Path(__file__).with_name("palette-presets.json").write_text(
        json.dumps(build(), indent=2) + "\n"
    )
