#!/usr/bin/env python3
"""Private launcher favorites/hidden IDs; atomic updates preserve concurrent edits."""

import argparse, fcntl, json, os, tempfile, sys
from pathlib import Path

PATH = Path.home() / ".config/siverteh-shell/launcher.json"


def load():
    try:
        data = json.loads(PATH.read_text())
    except FileNotFoundError:
        data = {}
    if not isinstance(data, dict) or any(
        not isinstance(data.get(key, []), list) for key in ("favorites", "hidden")
    ):
        raise ValueError("Invalid launcher preferences; original file preserved")
    return {
        key: list(dict.fromkeys(x for x in data.get(key, []) if isinstance(x, str)))
        for key in ("favorites", "hidden")
    }


def change(action, value):
    key = {"favorite": "favorites", "hide": "hidden"}[action]
    ident = value.get("id")
    enabled = value.get("enabled")
    if (
        not isinstance(ident, str)
        or not ident
        or len(ident) > 256
        or any(ord(c) < 32 for c in ident)
        or type(enabled) is not bool
    ):
        raise ValueError("Invalid launcher preference")
    PATH.parent.mkdir(parents=True, exist_ok=True)
    with PATH.with_suffix(".lock").open("w") as guard:
        os.chmod(guard.name, 0o600)
        fcntl.flock(guard, fcntl.LOCK_EX)
        data = load()
        data[key] = [x for x in data[key] if x != ident]
        if enabled:
            data[key].append(ident)
        fd, name = tempfile.mkstemp(dir=PATH.parent)
        try:
            with os.fdopen(fd, "w") as stream:
                json.dump(data, stream)
            os.chmod(name, 0o600)
            os.replace(name, PATH)
        finally:
            if os.path.exists(name):
                os.unlink(name)
        return data


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("action", choices=["load", "favorite", "hide"])
    a = p.parse_args()
    try:
        if a.action == "load" and not PATH.exists():
            PATH.parent.mkdir(parents=True, exist_ok=True)
            try:
                with PATH.open("x") as stream:
                    json.dump({"favorites": [], "hidden": []}, stream)
                PATH.chmod(0o600)
            except FileExistsError:
                pass
        print(
            json.dumps(
                load()
                if a.action == "load"
                else change(a.action, json.loads(sys.stdin.readline()))
            )
        )
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)
