#!/usr/bin/env bash
siverteh_cache_folder="$HOME/.cache/siverteh/hyprland-dotfiles"
generated_versions="$siverteh_cache_folder/wallpaper-generated"
rm $generated_versions/*
echo ":: Wallpaper cache cleared"
notify-send "Wallpaper cache cleared"
