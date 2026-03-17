#!/usr/bin/env bash

read_color() {
    local file="$1"
    local fallback="$2"

    if [ -f "$file" ]; then
        tr -d '\n\r ' <"$file"
    else
        printf '%s' "$fallback"
    fi
}

host=$(hostname)
user=${USER:-siverteh}
distro=$(awk -F= '/^PRETTY_NAME=/{gsub(/"/, "", $2); print $2}' /etc/os-release 2>/dev/null)
primary=$(read_color "$HOME/.config/ml4w/colors/primary" "#c495ff")
secondary=$(read_color "$HOME/.config/ml4w/colors/secondary" "#8fd6ff")

if [ -z "$distro" ]; then
    distro="Linux"
fi

text="<span font_family=\"JetBrainsMono Nerd Font\" foreground=\"$primary\" weight=\"900\">S</span><span font_family=\"JetBrainsMono Nerd Font\" foreground=\"$secondary\" weight=\"900\">H</span>"

jq -cn --arg text "$text" --arg tooltip "$user@$host\n$distro\nOpen Siverteh Hub" '{text:$text, tooltip:$tooltip}'
