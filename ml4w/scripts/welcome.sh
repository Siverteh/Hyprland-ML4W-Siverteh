#!/bin/bash
# Siverteh Hub Launcher

WELCOME_DIR="$HOME/.config/ml4w/welcome"
WELCOME_APP="$WELCOME_DIR/welcome-app.py"

# Create welcome directory if it doesn't exist
mkdir -p "$WELCOME_DIR"

# Focus the existing visible window if it is already open.
if hyprctl clients -j | jq -e '.[] | select(.title == "Siverteh OS")' >/dev/null 2>&1; then
    hyprctl dispatch focuswindow "title:^(Siverteh OS)$" >/dev/null 2>&1
    exit 0
fi

# Parse keybindings (always update before showing)
if [ -f "$WELCOME_DIR/parse-keybindings.sh" ]; then
    bash "$WELCOME_DIR/parse-keybindings.sh"
fi

# Launch detached so Waybar clicks stay responsive.
setsid -f python3 "$WELCOME_APP" >/dev/null 2>&1
