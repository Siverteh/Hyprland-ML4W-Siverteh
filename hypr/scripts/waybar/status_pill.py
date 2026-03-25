#!/usr/bin/env python3

import json
from datetime import datetime
from pathlib import Path


SETTINGS_PATH = Path.home() / ".config" / "siverteh" / "settings.json"


def load_show_clock():
    try:
        data = json.loads(SETTINGS_PATH.read_text())
    except (OSError, json.JSONDecodeError):
        return True
    return data.get("bar", {}).get("show_clock", True)


def main():
    now = datetime.now()
    show_clock = load_show_clock()

    if show_clock:
        text = f"{now:%H:%M} {now:%a}".lower()
        tooltip = f"{now:%A, %d %B %Y}\nLeft click: Calendar"
        classes = ["status-pill", "clock-visible"]
    else:
        text = ""
        tooltip = "Calendar"
        classes = ["status-pill", "clock-hidden"]

    print(
        json.dumps(
            {
                "text": text,
                "tooltip": tooltip,
                "class": classes,
            }
        )
    )


if __name__ == "__main__":
    main()
