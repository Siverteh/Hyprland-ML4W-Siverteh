#!/usr/bin/env bash
set -euo pipefail

settings_file="$HOME/.config/siverteh/settings.json"

if ! command -v hyprctl >/dev/null 2>&1; then
    exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
    exit 0
fi

if [ ! -f "$settings_file" ]; then
    exit 0
fi

mapfile -t monitor_lines < <(hyprctl -j monitors | jq -r '.[] | select(.disabled == false) | [.name, .description] | @tsv')

if [ ${#monitor_lines[@]} -eq 0 ]; then
    exit 0
fi

active_monitors=()
internal_monitors=()
external_monitors=()

for line in "${monitor_lines[@]}"; do
    name=${line%%$'\t'*}
    description=${line#*$'\t'}
    active_monitors+=("$name")
    if [[ "$name" == eDP* || "$name" == LVDS* || "$name" == DSI* ]] || [[ "${description,,}" == *"built-in"* ]] || [[ "${description,,}" == *"panel"* ]]; then
        internal_monitors+=("$name")
    else
        external_monitors+=("$name")
    fi
done

mode=$(jq -r '.display_setup.mode // "extend"' "$settings_file")
layout=$(jq -r '.display_setup.workspace_layout // "split"' "$settings_file")

choose_primary() {
    if [ "$mode" = "mirror" ] && [ ${#internal_monitors[@]} -gt 0 ]; then
        printf '%s' "${internal_monitors[0]}"
    elif [ ${#external_monitors[@]} -gt 0 ]; then
        printf '%s' "${external_monitors[0]}"
    elif [ ${#active_monitors[@]} -gt 0 ]; then
        printf '%s' "${active_monitors[0]}"
    elif [ ${#internal_monitors[@]} -gt 0 ]; then
        printf '%s' "${internal_monitors[0]}"
    fi
}

primary=$(choose_primary)

if [ -z "$primary" ]; then
    exit 0
fi

move_ws() {
    local workspace="$1"
    local monitor="$2"
    [ -n "$monitor" ] || return 0
    hyprctl dispatch moveworkspacetomonitor "$workspace $monitor" >/dev/null 2>&1 || true
}

if [ "$mode" = "laptop_only" ] || [ "$mode" = "external_only" ] || [ "$mode" = "mirror" ] || [ ${#active_monitors[@]} -le 1 ]; then
    for ws in 1 2 3 4 5 6; do
        move_ws "$ws" "$primary"
    done
    exit 0
fi

if [ "$layout" = "unified" ]; then
    for ws in 1 2 3 4 5 6; do
        move_ws "$ws" "$primary"
    done
elif [ "$layout" = "split" ]; then
    secondary=""
    for mon in "${active_monitors[@]}"; do
        if [ "$mon" != "$primary" ]; then
            secondary="$mon"
            break
        fi
    done

    if [ -z "$secondary" ]; then
        for ws in 1 2 3 4 5 6; do
            move_ws "$ws" "$primary"
        done
    else
        for ws in 1 2 6; do
            move_ws "$ws" "$primary"
        done
        for ws in 3 4 5; do
            move_ws "$ws" "$secondary"
        done
    fi
else
    index=0
    count=${#active_monitors[@]}
    for ws in 1 2 3 4 5 6; do
        target=${active_monitors[$((index % count))]}
        move_ws "$ws" "$target"
        index=$((index + 1))
    done
fi
