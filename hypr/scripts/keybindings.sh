#!/usr/bin/env bash
#    __            __   _         ___             
#   / /_____ __ __/ /  (_)__  ___/ (_)__  ___ ____
#  /  '_/ -_) // / _ \/ / _ \/ _  / / _ \/ _ `(_-<
# /_/\_\\__/\_, /_.__/_/_//_/\_,_/_/_//_/\_, /___/
#          /___/                        /___/     
# 

config_file="$HOME/.config/hypr/conf/keybinding.conf"

# -----------------------------------------------------
# Load Launcher
# -----------------------------------------------------
launcher=$(cat $HOME/.config/ml4w/settings/launcher)

# -----------------------------------------------------
# Path to keybindings config file
# -----------------------------------------------------
keybinds=$(awk -F',' '
    $1 ~ /^bind/ || $1 ~ /^binde/ || $1 ~ /^bindm/ {
        gsub(/\$mainMod/, "SUPER", $1)
        split($1, head, "=")
        modifiers = head[2]
        key = $2
        action = $3
        detail = $4

        gsub(/^[[:space:]]+|[[:space:]]+$/, "", modifiers)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", action)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", detail)

        combo = key
        if (modifiers != "") {
            combo = modifiers " + " key
        }

        if (detail != "") {
            action = action " " detail
        }

        print combo "\r" action
    }
' "$config_file")

sleep 0.2

if [ "$launcher" == "walker" ]; then
    keybinds=$(echo -n "$keybinds" | tr '\r' ':')
    $HOME/.config/walker/launch.sh -d -N -H -p "Search Keybinds" <<<"$keybinds"
else
    rofi -dmenu -i -markup -eh 2 -replace -p "Siverteh Keys" -config ~/.config/rofi/config-compact.rasi <<<"$keybinds"
fi
