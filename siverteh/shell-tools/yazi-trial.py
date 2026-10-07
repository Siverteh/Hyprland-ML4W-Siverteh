#!/usr/bin/env python3
"""Open the isolated terminal Files trial without changing GUI associations."""

import os
from pathlib import Path
import shutil
import sys


def launch():
    home = Path.home()
    runtime = home / ".local/share/siverteh-ai/yazi-runtime"
    binary = shutil.which("yazi") or str(runtime / "usr/bin/yazi")
    if not Path(binary).is_file():
        raise SystemExit("Yazi is missing; rerun the shell component installation.")
    if not shutil.which("yazi"):
        os.environ["LD_LIBRARY_PATH"] = (
            str(runtime / "usr/lib") + ":" + os.environ.get("LD_LIBRARY_PATH", "")
        )
    os.environ["YAZI_CONFIG_HOME"] = str(Path(__file__).with_name("yazi-trial"))
    # Existing Kitty palette colors are retained; these overrides apply only here.
    command = [
        "kitty",
        "--class",
        "siverteh-yazi",
        "--title",
        "Yazi Files trial",
        "-o",
        "font_size=14",
        "-o",
        "background_opacity=0.96",
        "-o",
        "initial_window_width=1200",
        "-o",
        "initial_window_height=850",
        "-e",
        binary,
        *(sys.argv[1:] or [str(home)]),
    ]
    os.execvp(command[0], command)


if __name__ == "__main__":
    launch()
