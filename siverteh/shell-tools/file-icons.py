#!/usr/bin/env python3
"""Small user icon overlay; Papirus supplies the artwork and app/MIME fallbacks."""

import colorsys
from pathlib import Path


def family(color):
    rgb = [int(color.lstrip("#")[i : i + 2], 16) / 255 for i in (0, 2, 4)]
    hue, saturation, _ = colorsys.rgb_to_hsv(*rgb)
    hue *= 360
    if saturation < 0.16:
        return "grey"
    if saturation < 0.36 and 20 <= hue < 70:
        return "brown"
    for end, name in [
        (20, "red"),
        (45, "orange"),
        (70, "yellow"),
        (165, "green"),
        (190, "teal"),
        (207, "cyan"),
        (252, "blue"),
        (278, "indigo"),
        (307, "violet"),
        (342, "pink"),
        (360, "red"),
    ]:
        if hue < end:
            return name
    return "red"


def theme(home, primary, mode):
    home = Path(home)
    bases = [home / ".local/share/icons", Path("/usr/share/icons")]
    fallback = "Papirus-Dark" if mode == "dark" else "Papirus"
    if not any((base / fallback / "index.theme").is_file() for base in bases):
        return ""
    # Prefer the updated system artwork over legacy user copies.
    source = next(
        (
            base / "Papirus"
            for base in reversed(bases)
            if (base / "Papirus/index.theme").is_file()
        ),
        None,
    )
    if source is None:
        return fallback
    color = family(primary)
    name = "Siverteh-Papirus-v2-" + color + "-" + mode
    target = bases[0] / name
    if (target / "index.theme").exists():
        return name
    directories = []
    prefix = "folder-" + color
    for size in [32, 48, 64]:
        folder = source / f"{size}x{size}/places"
        if not (folder / (prefix + ".svg")).exists():
            continue
        relative = f"{size}x{size}/places"
        destination = target / relative
        destination.mkdir(parents=True, exist_ok=True)
        for icon in folder.glob(prefix + "*.svg"):
            if icon.stem != prefix and not icon.stem.startswith(prefix + "-"):
                continue
            alias = destination / ("folder" + icon.name[len(prefix) :])
            if not alias.exists():
                alias.symlink_to(icon.resolve())
        # KDE asks for the MIME name, while GTK usually asks for folder.
        for alias_name, source_name in {
            "inode-directory.svg": "folder.svg",
            "user-desktop.svg": "folder-desktop.svg",
            "desktop.svg": "folder-desktop.svg",
        }.items():
            source_icon = destination / source_name
            alias_icon = destination / alias_name
            if source_icon.exists() and not alias_icon.exists():
                alias_icon.symlink_to(source_icon.resolve())
        directories.append((relative, size))
    if not directories:
        return fallback
    content = (
        "[Icon Theme]\nName=Siverteh Files\nComment=Palette-matched Papirus folders\n"
        f"Inherits={fallback},Papirus,Adwaita,hicolor\nDirectories="
        + ",".join(d for d, _ in directories)
        + "\n"
    )
    for directory, size in directories:
        content += f"\n[{directory}]\nSize={size}\nContext=Places\nType=Fixed\n"
    (target / "index.theme").write_text(content)
    return name
