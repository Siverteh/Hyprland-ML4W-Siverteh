#!/bin/bash
# Siverteh Hub Launcher

WELCOME_DIR="$HOME/.config/siverteh/core/welcome"
WELCOME_APP="$WELCOME_DIR/welcome-app.py"

# Create welcome directory if it doesn't exist
mkdir -p "$WELCOME_DIR"

# Always relaunch the Hub so the SH button never shows a stale in-memory UI
# after local CSS/code changes.
pkill -f "$WELCOME_APP" >/dev/null 2>&1 || true
sleep 0.15

# Parse keybindings (always update before showing)
if [ -f "$WELCOME_DIR/parse-keybindings.sh" ]; then
    bash "$WELCOME_DIR/parse-keybindings.sh"
fi

# Launch detached so Waybar clicks stay responsive.
setsid -f python3 "$WELCOME_APP" "$@" >/dev/null 2>&1
