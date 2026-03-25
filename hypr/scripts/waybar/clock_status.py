#!/usr/bin/env python3

import json
from datetime import datetime


def main():
    now = datetime.now()
    payload = {
        "text": f"󰥔 {now:%H:%M}  │  󰃭 {now:%a %d %b}",
        "tooltip": f"{now:%A, %d %B %Y}",
        "class": "clock",
    }
    print(json.dumps(payload))


if __name__ == "__main__":
    main()
