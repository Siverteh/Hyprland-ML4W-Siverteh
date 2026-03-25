#!/usr/bin/env bash

set -euo pipefail

if ! command -v playerctl >/dev/null 2>&1; then
    exit 0
fi

action="${1:-play-pause}"

case "$action" in
    previous)
        playerctl previous >/dev/null 2>&1 || true
        ;;
    next)
        playerctl next >/dev/null 2>&1 || true
        ;;
    play-pause)
        playerctl play-pause >/dev/null 2>&1 || true
        ;;
esac
