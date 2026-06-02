#!/usr/bin/env bash

set -euo pipefail

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send -t 2000 "$@" || true
}

active_address() {
    hyprctl activewindow -j | jq -r '.address // empty'
}

window_exists() {
    local address="$1"

    hyprctl clients -j | jq -e --arg address "$address" '
        any(.[]; .address == $address)
    ' >/dev/null
}

close_window() {
    local address="$1"

    hyprctl dispatch closewindow "address:$address" >/dev/null 2>&1 || true
}

force_window() {
    local address="$1"

    hyprctl dispatch killwindow "address:$address" >/dev/null 2>&1 || true
}

main() {
    local mode="${1:-close}"
    local address

    address="$(active_address)"
    if [[ -z "$address" || "$address" == "null" ]]; then
        notify "No active window to close"
        return 0
    fi

    if [[ "$mode" == "force" ]]; then
        force_window "$address"
        return 0
    fi

    close_window "$address"
    sleep 1

    if window_exists "$address"; then
        notify "Window did not close" "Press SUPER+CTRL+SHIFT+Q to force quit it"
    fi
}

main "$@"
