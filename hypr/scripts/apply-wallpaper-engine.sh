#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

wallpaper="${1:-}"
if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
    echo ":: Wallpaper file not found: $wallpaper" >&2
    exit 1
fi

engine_file="$HOME/.config/ml4w/settings/wallpaper-engine.sh"
engine="swww"

if [ -f "$engine_file" ]; then
    engine="$(tr -d '\n' <"$engine_file")"
fi

if [ -z "$engine" ]; then
    engine="swww"
fi

apply_hyprpaper() {
    local target="$HOME/.config/hypr/hyprpaper.conf"
    local -a monitors=()

    if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        while IFS= read -r name; do
            [ -n "$name" ] && monitors+=("$name")
        done < <(hyprctl monitors -j 2>/dev/null | jq -r '.[].name')
    else
        while IFS= read -r name; do
            [ -n "$name" ] && monitors+=("$name")
        done < <(hyprctl monitors 2>/dev/null | awk '/^Monitor / {print $2}')
    fi

    {
        printf '# Preload Wallpapers\n'
        printf 'preload = %s\n\n' "$wallpaper"
        printf '# Set Wallpapers\n'
        if [ ${#monitors[@]} -gt 0 ]; then
            for monitor in "${monitors[@]}"; do
                printf 'wallpaper {\n'
                printf '    monitor = %s\n' "$monitor"
                printf '    path = %s\n' "$wallpaper"
                printf '    fit_mode = cover\n'
                printf '}\n\n'
            done
        else
            printf 'wallpaper {\n'
            printf '    monitor =\n'
            printf '    path = %s\n' "$wallpaper"
            printf '    fit_mode = cover\n'
            printf '}\n\n'
        fi
        printf '# Disable Splash\n'
        printf 'splash = false\n'
        printf 'ipc = true\n'
    } >"$target"

    pkill -x hyprpaper >/dev/null 2>&1 || true
    nohup hyprpaper >/tmp/hyprpaper.log 2>&1 </dev/null &
}

apply_swww() {
    local waypaper_config="$HOME/.config/waypaper/config.ini"
    local transition_type="any"
    local transition_step="90"
    local transition_duration="2"
    local transition_fps="60"
    local transition_angle="0"

    if ! command -v swww-daemon >/dev/null 2>&1 || ! command -v swww >/dev/null 2>&1; then
        echo ":: swww backend selected but swww is not installed" >&2
        exit 1
    fi

    if [ -f "$waypaper_config" ]; then
        transition_type="$(awk -F' = ' '/^swww_transition_type = / {print $2}' "$waypaper_config" | tail -n1)"
        transition_step="$(awk -F' = ' '/^swww_transition_step = / {print $2}' "$waypaper_config" | tail -n1)"
        transition_duration="$(awk -F' = ' '/^swww_transition_duration = / {print $2}' "$waypaper_config" | tail -n1)"
        transition_fps="$(awk -F' = ' '/^swww_transition_fps = / {print $2}' "$waypaper_config" | tail -n1)"
        transition_angle="$(awk -F' = ' '/^swww_transition_angle = / {print $2}' "$waypaper_config" | tail -n1)"
    fi

    pkill -x hyprpaper >/dev/null 2>&1 || true

    if ! pgrep -x swww-daemon >/dev/null 2>&1; then
        nohup swww-daemon >/tmp/swww.log 2>&1 </dev/null &
        sleep 0.5
    fi

    swww img "$wallpaper" \
        --transition-type "${transition_type:-any}" \
        --transition-step "${transition_step:-90}" \
        --transition-duration "${transition_duration:-2}" \
        --transition-fps "${transition_fps:-60}" \
        --transition-angle "${transition_angle:-0}"
}

case "$engine" in
hyprpaper)
    apply_hyprpaper
    ;;
swww)
    apply_swww
    ;;
*)
    apply_hyprpaper
    ;;
esac
