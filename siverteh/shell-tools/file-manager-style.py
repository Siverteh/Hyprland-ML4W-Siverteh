#!/usr/bin/env python3
"""Set comfortable native Files defaults once, preserving later user choices."""

from pathlib import Path
import json
import subprocess

HOME = Path.home()
MARKER = HOME / ".local/state/siverteh-os/file-manager-style.json"


def main():
    import configparser
    import io
    import shutil

    # Migrate only the small size previously applied by this desktop.
    previous = json.loads(MARKER.read_text()) if MARKER.exists() else {}
    schema = "org.gnome.nautilus.icon-view"
    before = subprocess.run(
        ["gsettings", "get", schema, "default-zoom-level"],
        capture_output=True,
        text=True,
    )
    if before.returncode == 0 and previous.get("version", 1) < 2:
        current = before.stdout.strip().strip("'")
        if not previous or current == previous.get("applied"):
            subprocess.run(
                ["gsettings", "set", schema, "default-zoom-level", "small-plus"],
                check=True,
            )
            previous = dict(
                previous,
                schema=schema,
                key="default-zoom-level",
                before=previous.get("before", before.stdout.strip()),
                applied="small-plus",
            )
        previous["version"] = 2
        MARKER.parent.mkdir(parents=True, exist_ok=True)
        MARKER.write_text(json.dumps(previous, indent=2) + "\n")
        MARKER.chmod(0o600)
    if not shutil.which("dolphin"):
        return
    dolphin_marker = MARKER.with_name("dolphin-style.json")
    first_setup = not dolphin_marker.exists()
    if first_setup:
        path = HOME / ".config/dolphinrc"
        original = path.read_text() if path.exists() else ""
        config = configparser.ConfigParser(interpolation=None, strict=False)
        config.optionxform = str
        config.read_string(original)
        defaults = {
            "General": {
                "GlobalViewProps": "true",
                "ShowStatusBar": "FullWidth",
                "OpenExternallyCalledFolderInNewTab": "true",
            },
            "IconsMode": {
                "IconSize": "80",
                "PreviewSize": "96",
                "MaximumTextLines": "2",
            },
            "MainWindow": {"MenuBar": "Disabled"},
            "KFileDialog Settings": {
                "Places Icons Auto-resize": "false",
                "Places Icons Static Size": "22",
            },
            "UiSettings": {"ColorScheme": ""},
        }
        for section, values in defaults.items():
            if not config.has_section(section):
                config.add_section(section)
            for key, value in values.items():
                config[section][key] = value
        kde_path = HOME / ".config/kdeglobals"
        kde = configparser.ConfigParser(interpolation=None, strict=False)
        kde.optionxform = str
        kde.read(kde_path)
        for section in ("General", "KDE"):
            if not kde.has_section(section):
                kde.add_section(section)
        if "font" not in kde["General"]:
            kde["General"]["font"] = "Noto Sans,11,-1,5,50,0,0,0,0,0"
        if "SingleClick" not in kde["KDE"]:
            kde["KDE"]["SingleClick"] = "false"
        stream = io.StringIO()
        kde.write(stream, space_around_delimiters=False)
        kde_path.parent.mkdir(parents=True, exist_ok=True)
        kde_path.write_text(stream.getvalue())
        path.parent.mkdir(parents=True, exist_ok=True)
        stream = io.StringIO()
        config.write(stream, space_around_delimiters=False)
        path.write_text(stream.getvalue())
        dolphin_marker.write_text(
            json.dumps({"before": original, "applied": defaults}, indent=2) + "\n"
        )
        dolphin_marker.chmod(0o600)
    # Ensure app-menu and directory launches use the same per-app integration.
    source = Path("/usr/share/applications/org.kde.dolphin.desktop")
    if source.exists():
        text = source.read_text()
        import re

        text = re.sub(
            r"(?m)^Exec=dolphin.*$",
            "Exec=" + str(HOME / ".local/bin/siverteh-os-app") + " files %U",
            text,
        )
        text = re.sub(r"(?m)^DBusActivatable=.*$", "DBusActivatable=false", text)
        target = HOME / ".local/share/applications/org.kde.dolphin.desktop"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text)
        if first_setup:
            subprocess.run(
                ["xdg-mime", "default", "org.kde.dolphin.desktop", "inode/directory"],
                check=True,
            )


if __name__ == "__main__":
    main()
