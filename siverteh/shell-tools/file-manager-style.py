#!/usr/bin/env python3
"""Set compact Files defaults once, retaining later user zoom preferences."""

from pathlib import Path
import json
import subprocess

HOME = Path.home()
MARKER = HOME / ".local/state/siverteh-os/file-manager-style.json"


def main():
    if MARKER.exists():
        return
    schema = "org.gnome.nautilus.icon-view"
    before = subprocess.run(
        ["gsettings", "get", schema, "default-zoom-level"],
        capture_output=True,
        text=True,
    )
    if before.returncode:
        return
    subprocess.run(
        ["gsettings", "set", schema, "default-zoom-level", "small"], check=True
    )
    MARKER.parent.mkdir(parents=True, exist_ok=True)
    MARKER.write_text(
        json.dumps(
            {
                "schema": schema,
                "key": "default-zoom-level",
                "before": before.stdout.strip(),
                "applied": "small",
            },
            indent=2,
        )
        + "\n"
    )
    MARKER.chmod(0o600)


if __name__ == "__main__":
    main()
