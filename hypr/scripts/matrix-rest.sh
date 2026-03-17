#!/usr/bin/env bash

app="$HOME/.config/hypr/scripts/matrix-rest.py"

if pgrep -f "$app" >/dev/null 2>&1; then
    pkill -f "$app"
    exit 0
fi

pkill -x wlogout >/dev/null 2>&1 || true

setsid -f python3 "$app" >/dev/null 2>&1
