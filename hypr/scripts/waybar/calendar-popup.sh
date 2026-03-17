#!/usr/bin/env bash

popup="$HOME/.config/hypr/scripts/waybar/mini-calendar.py"

if pgrep -f "$popup" >/dev/null 2>&1; then
    pkill -f "$popup"
    exit 0
fi

setsid -f python3 "$popup" >/dev/null 2>&1
