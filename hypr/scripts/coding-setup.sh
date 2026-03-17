#!/bin/bash

launch_setting() {
    local file="$1"
    local cmd

    if [ ! -f "$file" ]; then
        return 1
    fi

    cmd=$(<"$file")
    if [ -z "$cmd" ]; then
        return 1
    fi

    bash -lc "$cmd" &
}

notify-send "Siverteh Daily Profile" "Opening your core workspaces..." -t 2000

hyprctl dispatch workspace 1
launch_setting "$HOME/.config/ml4w/settings/browser.sh"
sleep 0.6

hyprctl dispatch workspace 2
launch_setting "$HOME/.config/ml4w/settings/editor.sh"
sleep 0.6

hyprctl dispatch workspace 3
discord &
sleep 0.6

hyprctl dispatch workspace 4
spotify &
sleep 0.6

hyprctl dispatch workspace 5
launch_setting "$HOME/.config/ml4w/settings/email.sh"
sleep 0.8

hyprctl dispatch workspace 2

notify-send "Siverteh Daily Profile" "Browser, code, chat, music, and mail are ready." -t 2000
