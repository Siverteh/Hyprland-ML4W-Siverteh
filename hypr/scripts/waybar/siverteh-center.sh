#!/usr/bin/env bash

settings_file="$HOME/.config/siverteh/settings.json"
state_file="$HOME/.cache/siverteh/shell-overlay.state"

vibe="glass"
if command -v jq >/dev/null 2>&1 && [ -f "$settings_file" ]; then
    vibe=$(jq -r '.appearance.vibe // "glass"' "$settings_file" 2>/dev/null)
fi

open_state="false"
active_tab="dashboard"
state_pid=""
if command -v jq >/dev/null 2>&1 && [ -f "$state_file" ]; then
    open_state=$(jq -r 'if .open == true then "true" else "false" end' "$state_file" 2>/dev/null || printf 'false')
    active_tab=$(jq -r '.tab // "dashboard"' "$state_file" 2>/dev/null || printf 'dashboard')
    state_pid=$(jq -r '.pid // ""' "$state_file" 2>/dev/null || true)
fi

case "$active_tab" in
now)
    active_tab="dashboard"
    ;;
dashboard|media|actions|settings)
    ;;
*)
    active_tab="dashboard"
    ;;
esac

if [ "$open_state" = "true" ] && { [ -z "$state_pid" ] || ! kill -0 "$state_pid" 2>/dev/null; }; then
    open_state="false"
fi

case "$vibe" in
minimal)
    vibe_label="Minimal Luxe"
    ;;
neon)
    vibe_label="Dark Neon"
    ;;
nordic)
    vibe_label="Nordic Terminal"
    ;;
custom)
    vibe_label="Full Custom"
    ;;
*)
    vibe="glass"
    vibe_label="Glass / Cyber"
    ;;
esac

state_label="closed"
open_class=""
if [ "$open_state" = "true" ]; then
    state_label="open · $active_tab"
    open_class="open"
fi

clock_label="$(date '+%H:%M  %a %d')"

case "$active_tab" in
media)
    icon=""
    ;;
actions)
    icon="󰣇"
    ;;
settings)
    icon="󰒓"
    ;;
*)
        icon="󰎆"
        ;;
esac

if [ "$open_state" = "true" ]; then
    text="<span font_family=\"JetBrainsMono Nerd Font\" weight=\"900\">$icon</span> <span weight=\"900\">$clock_label</span>"
else
    text="<span font_family=\"JetBrainsMono Nerd Font\" weight=\"900\">󰣇</span> <span weight=\"900\">Siverteh</span> <span weight=\"700\">$clock_label</span>"
fi
tooltip="Left: Toggle Siverteh Shell\nRight: Settings tab\nMiddle: Tools tab\nScroll: Cycle Dashboard/Media/Tools/Settings\nState: $state_label\nVibe: $vibe_label\nPalette: live Matugen wallpaper colors"

if command -v jq >/dev/null 2>&1; then
    classes=$(jq -cn --arg vibe "vibe-$vibe" --arg open "$open_class" --arg tab "tab-$active_tab" \
        '[$vibe] + (if $open == "" then ["state-closed"] else ["state-open", $open, $tab] end)')
    jq -cn --arg text "$text" --argjson classes "$classes" --arg tooltip "$tooltip" \
        '{text:$text, class:$classes, tooltip:$tooltip}'
else
    TEXT="$text" VIBE="$vibe" OPEN="$open_class" TAB="tab-$active_tab" TOOLTIP="$tooltip" python3 - <<'PY'
import json
import os

classes = ["vibe-" + os.environ["VIBE"]]
if os.environ["OPEN"]:
    classes.extend(["state-open", os.environ["OPEN"], os.environ["TAB"]])
else:
    classes.append("state-closed")

print(json.dumps({
    "text": os.environ["TEXT"],
    "class": classes,
    "tooltip": os.environ["TOOLTIP"],
}))
PY
fi
