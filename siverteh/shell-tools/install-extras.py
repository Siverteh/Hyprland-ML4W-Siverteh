#!/usr/bin/env python3
"""Own the native shortcut routes without replacing personal compositor config."""

from pathlib import Path
import datetime as dt, subprocess

ROOT = Path(__file__).resolve().parent
HOME = Path.home()


def put(path, text):
    if path.exists() and path.read_text() == text:
        return
    if path.exists():
        backup = (
            HOME
            / ".local/state/siverteh-native-shell/backups"
            / (
                "extras-"
                + dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
            )
            / path.relative_to(HOME)
        )
        backup.parent.mkdir(parents=True, exist_ok=True)
        backup.write_text(path.read_text())
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def install():
    subprocess.run(["python3", str(ROOT / "install-thunar.py")], check=True)
    if __import__("shutil").which("dolphin"):
        subprocess.run(["python3", str(ROOT / "file-manager-runtime.py")], check=True)
    subprocess.run(["python3", str(ROOT / "file-manager-style.py")], check=True)
    put(
        HOME / ".config/siverteh-shell/shortcuts.lua",
        (ROOT / "shortcuts.lua").read_text(),
    )
    main = HOME / ".config/hypr/hyprland.lua"
    text = main.read_text()
    marker = "-- Siverteh native desktop shortcuts"
    if marker not in text:
        put(
            main,
            text
            + "\n"
            + marker
            + '\nlocal shortcuts_path = os.getenv("HOME") .. "/.config/siverteh-shell/shortcuts.lua"\nlocal shortcuts_file = io.open(shortcuts_path, "r")\nif shortcuts_file then shortcuts_file:close(); dofile(shortcuts_path) end\n',
        )
    # Register the three new bindings in the live compositor; base routes use reload.
    subprocess.run(["hyprctl", "reload"], check=True, stdout=subprocess.DEVNULL)


if __name__ == "__main__":
    install()
