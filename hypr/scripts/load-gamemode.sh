#!/usr/bin/env bash
#                                      __   
#   ___ ____ ___ _  ___ __ _  ___  ___/ /__ 
#  / _ `/ _ `/  ' \/ -_)  ' \/ _ \/ _  / -_)
#  \_, /\_,_/_/_/_/\__/_/_/_/\___/\_,_/\__/ 
# /___/                                     
# 

_loadGameMode() {
    "$HOME/.config/hypr/scripts/hyprctl-lua.sh" performance true
}

if [ -f $HOME/.config/siverteh/core/settings/gamemode-enabled ]; then
    _loadGameMode
    notify-send "Gamemode activated" "Animations and blur disabled"
fi
