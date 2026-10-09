#!/usr/bin/env python3
"""Idempotent six-workspace session profile; ordinary terminals stay unrestricted."""

import fcntl, json, os, subprocess, time, shutil, importlib.util
from pathlib import Path

HOME = Path.home()


def plan(clients):
    classes = {c["class"].casefold() for c in clients}
    return [
        (
            "Browser",
            1,
            ["google-chrome-stable"],
            bool(classes & {"google-chrome", "chromium", "firefox"}),
        ),
        (
            "Nacre AI",
            2,
            [str(HOME / ".local/bin/nacre-shell"), "tasks"],
            "siverteh-ai-dashboard" in classes,
        ),
        ("Discord", 3, ["discord"], bool(classes & {"discord"})),
        ("Spotify", 4, ["spotify"], "spotify" in classes),
        (
            "Mail",
            5,
            [str(HOME / ".local/bin/nacre-app"), "mail"],
            bool(
                classes
                & {
                    "evolution",
                    "org.gnome.evolution",
                    "thunderbird",
                    "chrome-mail.google.com__-default",
                }
            ),
        ),
        (
            "Brain",
            6,
            ["systemctl", "--user", "start", "siverteh-observatory-brain.service"],
            any(
                c["class"] == "siverteh-brain" or c.get("title") == "Nacre Brain"
                for c in clients
            ),
        ),
    ]


def main():
    lock = (
        Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))
        / "siverteh-startup-apps.lock"
    )
    with lock.open("w") as guard:
        try:
            fcntl.flock(guard, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        spec = importlib.util.spec_from_file_location(
            "session", Path(__file__).with_name("session-watch.py")
        )
        session = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(session)
        session.readiness()
        clients = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"]))
        for label, workspace, argv, exists in plan(clients):
            if exists or not shutil.which(argv[0]):
                continue
            subprocess.run(
                [
                    "hyprctl",
                    "eval",
                    f"hl.dispatch(hl.dsp.focus({{workspace={workspace},on_current_monitor=true}}))",
                ],
                stdout=subprocess.DEVNULL,
                check=True,
            )
            subprocess.Popen(
                ["systemd-run", "--user", "--scope", "--collect", "--quiet", *argv],
                start_new_session=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            # Wait for a real window/service acknowledgement; never relaunch a slow app.
            deadline = time.monotonic() + 8
            while time.monotonic() < deadline:
                current = json.loads(
                    subprocess.check_output(["hyprctl", "clients", "-j"])
                )
                if (
                    next(
                        (entry[3] for entry in plan(current) if entry[0] == label),
                        False,
                    )
                    or label == "Brain"
                ):
                    break
                time.sleep(0.2)
        subprocess.run(
            [
                "hyprctl",
                "eval",
                "hl.dispatch(hl.dsp.focus({workspace=1,on_current_monitor=true}))",
            ],
            check=True,
            stdout=subprocess.DEVNULL,
        )


if __name__ == "__main__":
    main()
