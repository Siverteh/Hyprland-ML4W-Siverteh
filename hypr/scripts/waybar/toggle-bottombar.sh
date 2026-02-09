#!/bin/bash
# Toggle nwg-dock only
DOCK_DISABLED="$HOME/.config/ml4w/settings/dock-disabled"

if [ -f "$DOCK_DISABLED" ]; then
    # Dock is disabled, enable it
    rm "$DOCK_DISABLED"
    ~/.config/nwg-dock-hyprland/launch.sh &
else
    # Dock is enabled, disable it
    touch "$DOCK_DISABLED"
    killall nwg-dock-hyprland
fi