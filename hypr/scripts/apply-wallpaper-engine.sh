#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

wallpaper="${1:-}"
if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
    echo ":: Wallpaper file not found: $wallpaper" >&2
    exit 1
fi

engine_file="$HOME/.config/siverteh/core/settings/wallpaper-engine.sh"
engine="awww"

if [ -f "$engine_file" ]; then
    engine="$(tr -d '\n' <"$engine_file")"
fi

if [ -z "$engine" ]; then
    engine="awww"
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

apply_awww() {
    local waypaper_config="$HOME/.config/waypaper/config.ini"
    local transition_type="any"
    local transition_step="90"
    local transition_duration="2"
    local transition_fps="60"
    local transition_angle="0"

    if ! command -v awww-daemon >/dev/null 2>&1 || ! command -v awww >/dev/null 2>&1; then
        echo ":: awww backend selected but awww is not installed" >&2
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

    if ! awww query >/dev/null 2>&1; then
        nohup awww-daemon >"${XDG_RUNTIME_DIR:?}/siverteh-awww.log" 2>&1 </dev/null &
        for _ in $(seq 1 30); do
            awww query >/dev/null 2>&1 && break
            sleep 0.1
        done
        awww query >/dev/null
    fi

    awww img "$wallpaper" \
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
awww)
    apply_awww
    ;;
*)
    echo ":: Unsupported wallpaper engine: $engine" >&2
    exit 2
    ;;
esac
