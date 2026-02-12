#!/bin/bash
# Siverteh's OS Welcome Screen Launcher

WELCOME_DIR="$HOME/.config/ml4w/welcome"

# Create welcome directory if it doesn't exist
mkdir -p "$WELCOME_DIR"

# Parse keybindings (always update before showing)
if [ -f "$WELCOME_DIR/parse-keybindings.sh" ]; then
    bash "$WELCOME_DIR/parse-keybindings.sh"
fi

# Launch the GTK app
python3 "$WELCOME_DIR/welcome-app.py"
