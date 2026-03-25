#!/usr/bin/env bash

export PATH="$HOME/.local/bin:$PATH"

engine_file="$HOME/.config/ml4w/settings/wallpaper-engine.sh"
waypaper_config="$HOME/.config/waypaper/config.ini"

backend="swww"
if [ -f "$engine_file" ]; then
    backend="$(tr -d '\n' <"$engine_file")"
fi

if [ -z "$backend" ]; then
    backend="swww"
fi

if [ -f "$waypaper_config" ]; then
    if grep -q '^backend = ' "$waypaper_config"; then
        sed -i "s/^backend = .*/backend = $backend/" "$waypaper_config"
    else
        printf '\nbackend = %s\n' "$backend" >>"$waypaper_config"
    fi
fi

if [ -x /usr/bin/waypaper ]; then
    waypaper_bin="/usr/bin/waypaper"
elif [ -x "$HOME/.local/bin/waypaper" ]; then
    waypaper_bin="$HOME/.local/bin/waypaper"
else
    echo ":: waypaper not found"
    exit 1
fi

cmd=(env GTK_THEME=Breeze-Dark "$waypaper_bin" --backend "$backend")

if [ $# -gt 0 ]; then
    "${cmd[@]}" "$@"
else
    "${cmd[@]}" >/dev/null 2>&1 &
fi
