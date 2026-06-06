#!/usr/bin/env bash

set -euo pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <command> [args...]" >&2
    exit 2
fi

on_ac_power() {
    local device

    while IFS= read -r device; do
        [[ -z "$device" ]] && continue

        if upower -i "$device" 2>/dev/null | grep -q "online:[[:space:]]*yes"; then
            return 0
        fi
    done < <(upower -e 2>/dev/null | grep 'line_power' || true)

    return 1
}

if on_ac_power; then
    exit 0
fi

exec "$@"
