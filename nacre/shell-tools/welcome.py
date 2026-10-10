#!/usr/bin/env python3
"""Own only Welcome preferences/session claims; never change desktop setup."""

import argparse
from contextlib import contextmanager
import fcntl
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import uuid


def paths(home):
    return (
        home / ".config/nacre/welcome.json",
        home / ".local/state/nacre/welcome/session.json",
    )


def atomic(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(prefix=".welcome-", dir=path.parent)
    try:
        with os.fdopen(fd, "w") as stream:
            json.dump(value, stream, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(name, path)
    finally:
        Path(name).unlink(missing_ok=True)


@contextmanager
def locked(home):
    path = home / ".local/state/nacre/welcome/owner.lock"
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a") as stream:
        fcntl.flock(stream, fcntl.LOCK_EX)
        yield


def preferences(home):
    path, _ = paths(home)
    value = json.loads(path.read_text()) if path.exists() else {}
    if not isinstance(value, dict) or value.get("version", 1) != 1:
        raise ValueError(
            "Unsupported Welcome preferences; restore welcome.json or use version 1"
        )
    if not isinstance(value.get("showAtLogin", True), bool):
        raise ValueError("showAtLogin in welcome.json must be true or false")
    return dict(value, version=1, showAtLogin=value.get("showAtLogin", True))


SHORTCUTS = (
    ("launcher", "Find an application", "Search, use favorites or browse all apps."),
    (
        "wallpaper",
        "Choose a wallpaper",
        "Search your collection and choose static or dynamic scenes.",
    ),
    (
        "settings",
        "Open Settings",
        "Appearance, displays, sound, connections and maintenance.",
    ),
    ("files", "Open Files", "Browse folders and ZIP archives in your file manager."),
    (
        "terminal",
        "Open a terminal",
        "Your terminal follows the current desktop colors.",
    ),
    ("put-away", "Put a window away", "Restore or close it using the bindings below."),
    ("workspace", "Change workspace", "Switch to a configured workspace."),
    ("focus", "Move focus", "Focus a window in a direction."),
    ("screenshot", "Capture an area", "Pick a region to copy to the clipboard."),
    (
        "clipboard",
        "Clipboard history",
        "Find something copied earlier and paste it again.",
    ),
    ("ai-sidebar", "Open the AI sidebar", "Keep a conversation beside your work."),
    ("lock", "Lock the desktop", "The existing lock screen handles authentication."),
)


def friendly_key(key):
    if key == "XF86PowerOff":
        return "Power button"
    if key.lower() in ("return", "escape", "space", "left", "right", "up", "down"):
        return key[:1].upper() + key[1:]
    return key


def binding_labels(bindings):
    groups = {}
    for binding in bindings:
        if not isinstance(binding, dict) or binding.get("submap"):
            continue
        description = binding.get("description", "")
        if not isinstance(description, str) or not description.startswith("Nacre:"):
            continue
        key, mask = binding.get("key"), binding.get("modmask")
        if not isinstance(mask, int) or isinstance(mask, bool) or mask < 0:
            continue
        if not key and isinstance(binding.get("keycode"), int):
            key = "code:" + str(binding["keycode"])
        if not isinstance(key, str) or not key or len(key) > 80:
            continue
        groups.setdefault(description[6:], {}).setdefault(mask, set()).add(key)
    result = {}
    for action, masks in groups.items():
        labels = []
        for mask, keys in sorted(masks.items()):
            mods = [
                name
                for bit, name in (
                    (64, "Super"),
                    (4, "Ctrl"),
                    (8, "Alt"),
                    (1, "Shift"),
                    (2, "CapsLock"),
                    (16, "Mod2"),
                    (32, "Mod3"),
                    (128, "Mod5"),
                )
                if mask & bit
            ]
            prefix = " + ".join(mods) + (" + " if mods else "")
            if len(keys) >= 3 and all(key.isdigit() for key in keys):
                numbers = sorted(map(int, keys))
                if numbers == list(range(numbers[0], numbers[-1] + 1)):
                    labels.append(prefix + str(numbers[0]) + "–" + str(numbers[-1]))
                    continue
            if {key.lower() for key in keys} == {"left", "right", "up", "down"}:
                labels.append(prefix + "arrows")
                continue
            labels.extend(prefix + friendly_key(key) for key in sorted(keys))
        result[action] = "\n".join(labels)
    return result


def shortcut_rows(bindings):
    if not isinstance(bindings, list) or len(bindings) > 10000:
        raise ValueError("Invalid compositor binding list")
    labels = binding_labels(bindings)
    result = []
    for action, title, detail in SHORTCUTS:
        if action not in labels:
            continue
        if action == "put-away":
            parts = []
            for other, verb in (("restore", "Restore"), ("close", "Close")):
                if other in labels:
                    parts.append(
                        verb + " with " + labels[other].replace("\n", " or ") + "."
                    )
            detail = " ".join(parts) or "Put away the current window."
        elif action == "workspace" and "move-workspace" in labels:
            detail += (
                " Move the current window with "
                + labels["move-workspace"].replace("\n", " or ")
                + "."
            )
        elif action == "screenshot" and "save-screenshot" in labels:
            detail += (
                " Save the whole screen with "
                + labels["save-screenshot"].replace("\n", " or ")
                + "."
            )
        result.append(
            {"id": action, "key": labels[action], "title": title, "detail": detail}
        )
    return result


def live_shortcuts():
    try:
        query = subprocess.run(
            ["hyprctl", "binds", "-j"],
            capture_output=True,
            text=True,
            timeout=2,
            check=True,
        )
        rows = shortcut_rows(json.loads(query.stdout))
        return (
            rows,
            ""
            if rows
            else "No described Nacre shortcuts are registered. Reload your managed Hyprland configuration.",
        )
    except (OSError, ValueError, subprocess.SubprocessError):
        return [], "Shortcuts are available when running inside your Hyprland session."


def state(home):
    shortcuts, shortcut_error = live_shortcuts()
    return {
        "shortcuts": shortcuts,
        "shortcutError": shortcut_error,
        "preferences": preferences(home),
        "available": {
            "ai": bool(shutil.which("nacre-ai") and shutil.which("siverteh-ai")),
            "brain": bool(
                shutil.which("nacre-brain")
                and (home / ".local/share/nacre/brain/control.py").exists()
            ),
        },
    }


def set_startup(home, value):
    if not isinstance(value, bool):
        raise ValueError("Welcome startup choice must be a boolean")
    with locked(home):
        data = preferences(home)
        data["showAtLogin"] = value
        atomic(paths(home)[0], data)
    return state(home)


def claim_login(home, instance):
    if not instance:
        return {"show": False, "claim": ""}
    with locked(home):
        if not preferences(home)["showAtLogin"]:
            return {"show": False, "claim": ""}
        _, path = paths(home)
        try:
            previous = json.loads(path.read_text())
        except (OSError, ValueError):
            previous = {}
        if isinstance(previous, dict) and previous.get("instance") == instance:
            return {"show": False, "claim": ""}
        claim = uuid.uuid4().hex
        atomic(path, {"instance": instance, "claim": claim})
        return {"show": True, "claim": claim}


def release_login(home, instance, claim):
    with locked(home):
        _, path = paths(home)
        try:
            previous = json.loads(path.read_text())
        except (OSError, ValueError):
            return
        if previous == {"instance": instance, "claim": claim}:
            path.unlink()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "action", choices=("state", "set-startup", "claim-login", "release-login")
    )
    parser.add_argument("value", nargs="?", default="")
    args = parser.parse_args()
    home = Path.home()
    try:
        if args.action == "state":
            result = state(home)
        elif args.action == "set-startup":
            result = set_startup(home, json.loads(args.value))
        elif args.action == "claim-login":
            result = claim_login(
                home, os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
            )
        else:
            release_login(
                home, os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", ""), args.value
            )
            result = {"released": True}
        print(json.dumps(result))
    except (OSError, ValueError) as error:
        print(json.dumps({"error": str(error)}))
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
