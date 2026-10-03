#!/usr/bin/env bash
cache_file="$HOME/.cache/toggle_animation"
if [[ $(cat $HOME/.config/hypr/conf/animation.conf) == *"disabled"* ]]; then
    echo ":: Toggle blocked by disabled.conf variation."
else
    if [ -f $cache_file ]; then
        "$HOME/.config/hypr/scripts/hyprctl-lua.sh" animations true
        rm $cache_file
    else
        "$HOME/.config/hypr/scripts/hyprctl-lua.sh" animations false
        touch $cache_file
    fi
fi
