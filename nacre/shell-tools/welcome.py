#!/usr/bin/env python3
"""Own only Welcome preferences/session claims; never change desktop setup."""

import argparse
from contextlib import contextmanager
import fcntl
import json
import os
from pathlib import Path
import shutil
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


def state(home):
    return {
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
