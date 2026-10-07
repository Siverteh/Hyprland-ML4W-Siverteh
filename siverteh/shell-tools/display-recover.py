#!/usr/bin/env python3
"""Recreate renderer surfaces after output geometry/DPR changes, preserving safe UI flags."""

import argparse, fcntl, json, os, subprocess, time, sys
from pathlib import Path

HOME = Path.home()


def main():
    p = argparse.ArgumentParser()
    p.add_argument("view")
    a = p.parse_args()
    view = json.loads(a.view)
    runtime = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))
    with (runtime / "siverteh-display-recovery.lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        try:
            subprocess.run(
                ["python3", str(Path(__file__).with_name("lock-config.py"))],
                check=True,
                capture_output=True,
                timeout=4,
            )
        except (OSError, subprocess.SubprocessError):
            print(
                "Could not refresh lock layout; preserving the previous configuration",
                file=sys.stderr,
            )
        subprocess.run(
            ["systemctl", "--user", "restart", "siverteh-os-shell.service"],
            check=True,
            timeout=15,
        )
        ipc = [
            str(HOME / ".local/share/siverteh-ai/siverteh-shell/bin/qs"),
            "-c",
            "siverteh_shell",
            "ipc",
            "call",
            "siverteh",
        ]
        deadline = time.monotonic() + 15
        while time.monotonic() < deadline:
            result = subprocess.run(
                [*ipc, "state"], capture_output=True, text=True, timeout=2
            )
            try:
                ready = result.returncode == 0 and "launcherMode" in json.loads(
                    result.stdout
                )
            except ValueError:
                ready = False
            if ready:
                subprocess.run(
                    [*ipc, "restoreViews", json.dumps(view)],
                    check=True,
                    capture_output=True,
                    timeout=3,
                )
                if view.get("dashboard") and view.get("tab") == 4:
                    subprocess.run(
                        [*ipc[:-1], "settingsView", "open", "displays"],
                        capture_output=True,
                        timeout=3,
                    )
                return
            time.sleep(0.2)
        raise RuntimeError("Display renderer did not become ready")


if __name__ == "__main__":
    main()
