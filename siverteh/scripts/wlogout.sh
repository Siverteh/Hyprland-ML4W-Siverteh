#!/usr/bin/env bash
set -euo pipefail

# Hyprland reports physical pixels; wlogout margins use logical pixels.
if ! w_margin=$(hyprctl -j monitors | jq -er '
    (map(select(.focused == true)) | first) as $focused
    | ($focused // first)
    | select(.height > 0 and .scale > 0)
    | (.height / .scale * 0.24 | floor)
'); then
    printf 'Cannot determine the focused monitor dimensions for wlogout.\n' >&2
    exit 1
fi

exec wlogout -b 3 -c 10 -r 10 -T "$w_margin" -B "$w_margin"
