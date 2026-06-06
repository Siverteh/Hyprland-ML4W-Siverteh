#!/usr/bin/env bash
#                                      __   
#   ___ ____ ___ _  ___ __ _  ___  ___/ /__ 
#  / _ `/ _ `/  ' \/ -_)  ' \/ _ \/ _  / -_)
#  \_, /\_,_/_/_/_/\__/_/_/_/\___/\_,_/\__/ 
# /___/                                     
# 

siverteh_cache_folder="$HOME/.cache/siverteh/hyprland-dotfiles"
gamemode_monitor="$HOME/.config/hypr/conf/monitors/gamemode.conf"

if [ -f $HOME/.config/siverteh/core/settings/gamemode-enabled ]; then
  if [ -f $siverteh_cache_folder/last_monitor.conf ]; then
    cat $siverteh_cache_folder/last_monitor.conf > $HOME/.config/hypr/conf/monitor.conf
    rm $siverteh_cache_folder/last_monitor.conf
  fi
  if [ -f $siverteh_cache_folder/restart-wpauto ]; then
    rm $siverteh_cache_folder/restart-wpauto
    $HOME/.config/hypr/scripts/wallpaper-automation.sh &
  fi
  hyprctl reload
  rm $HOME/.config/siverteh/core/settings/gamemode-enabled
  notify-send "Gamemode deactivated" "Animations and blur enabled"
else
  if [ -f $gamemode_monitor ]; then
    cat $HOME/.config/hypr/conf/monitor.conf > $siverteh_cache_folder/last_monitor.conf
    echo "source = $gamemode_monitor" > $HOME/.config/hypr/conf/monitor.conf
  fi
  if [ -f $siverteh_cache_folder/wallpaper-automation ]; then
    touch $siverteh_cache_folder/restart-wpauto
    $HOME/.config/hypr/scripts/wallpaper-automation.sh
  fi
  hyprctl --batch "\
    keyword animations:enabled 0;\
    keyword decoration:shadow:enabled 0;\
    keyword decoration:blur:enabled 0;\
    keyword general:gaps_in 0;\
    keyword general:gaps_out 0;\
    keyword general:border_size 1;\
    keyword decoration:active_opacity 1;\
    keyword decoration:inactive_opacity 1;\
    keyword decoration:fullscreen_opacity 1;\
    keyword decoration:rounding 0"
  touch $HOME/.config/siverteh/core/settings/gamemode-enabled
  notify-send "Gamemode activated" "Animations and blur disabled"
fi