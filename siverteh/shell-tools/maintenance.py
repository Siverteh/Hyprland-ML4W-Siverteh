#!/usr/bin/env python3
"""Local maintenance facts and explicitly requested recovery actions."""

import argparse, datetime as dt, hashlib, json, os, subprocess, sys, time
from pathlib import Path

HOME = Path.home()
STATE = HOME / ".local/state/siverteh-os"
SERVICES = [
    "siverteh-os-shell.service",
    "siverteh-sidebar-ai.service",
    "siverteh-observatory-brain.service",
    "siverteh-session-watch.service",
]


def run(args, default="", timeout=5):
    try:
        return subprocess.check_output(
            args, text=True, stderr=subprocess.DEVNULL, timeout=timeout
        ).strip()
    except (OSError, subprocess.SubprocessError):
        return default


def state():
    release = STATE / "releases/current.json"
    managed = STATE / "configuration.json"
    drift = []
    for name, expected in (
        json.loads(managed.read_text()).items() if managed.exists() else []
    ):
        path = HOME / name
        if (
            not path.is_file()
            or hashlib.sha256(path.read_bytes()).hexdigest() != expected
        ):
            drift.append(name)
    cache = HOME / ".cache/siverteh-os/updates.json"
    current = json.loads(release.read_text()) if release.exists() else {}
    session = STATE / "session/latest.json"
    profile = STATE / "performance/latest.json"
    versions = {
        name: run(args)
        for name, args in {
            "Hyprland": ["Hyprland", "--version"],
            "Python": [sys.executable, "--version"],
        }.items()
    }
    return dict(
        release=current,
        services={
            s: run(["systemctl", "--user", "is-active", s], "unavailable")
            for s in SERVICES
        },
        drift=drift,
        configErrors=run(["hyprctl", "configerrors"]),
        updatesAgeSeconds=int(time.time() - cache.stat().st_mtime)
        if cache.exists()
        else None,
        session=json.loads(session.read_text()) if session.exists() else {},
        performance=json.loads(profile.read_text()) if profile.exists() else {},
        versions=versions,
        checked=dt.datetime.now(dt.timezone.utc).isoformat(),
    )


def sample(seconds, label):
    if not 1 <= seconds <= 30:
        raise ValueError("Sample duration must be 1–30 seconds")

    def read():
        return {
            k: int(v)
            for k, v in (
                line.split("=", 1)
                for line in run(
                    [
                        "systemctl",
                        "--user",
                        "show",
                        SERVICES[0],
                        "-p",
                        "CPUUsageNSec",
                        "-p",
                        "MemoryCurrent",
                    ]
                ).splitlines()
            )
            if v.isdigit()
        }

    before = read()
    start = time.monotonic()
    time.sleep(seconds)
    after = read()
    duration = time.monotonic() - start
    value = dict(
        label=label,
        seconds=round(duration, 2),
        cpuCorePercent=round(
            (after["CPUUsageNSec"] - before["CPUUsageNSec"]) / duration / 1e7, 2
        ),
        memoryMiB=round(after["MemoryCurrent"] / 1048576, 1),
        checked=dt.datetime.now(dt.timezone.utc).isoformat(),
    )
    path = STATE / "performance/latest.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value))
    return value


def main():
    p = argparse.ArgumentParser()
    p.add_argument(
        "action",
        choices=["state", "check", "profile", "restart", "rollback", "session"],
    )
    p.add_argument("--seconds", type=int, default=5)
    p.add_argument("--label", default="manual")
    a = p.parse_args()
    if a.action == "restart":
        subprocess.run(["systemctl", "--user", "restart", SERVICES[0]], check=True)
    elif a.action == "rollback":
        subprocess.run([str(HOME / ".local/bin/siverteh-os"), "rollback"], check=True)
    elif a.action == "profile":
        sample(a.seconds, a.label)
    elif a.action == "check":
        subprocess.run(
            [
                sys.executable,
                str(HOME / ".local/share/siverteh-os/control/check-overlays.py"),
                "--keyboard",
                str(HOME / ".local/share/siverteh-ai/shell-runtime/usr/bin/wtype"),
            ],
            check=True,
        )
    elif a.action == "session":
        subprocess.run(
            [
                sys.executable,
                str(Path(__file__).with_name("session-watch.py")),
                "check",
                "--event",
                "manual",
            ],
            check=True,
            stdout=subprocess.DEVNULL,
        )
    print(json.dumps(state()))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(json.dumps(dict(error=str(e))))
