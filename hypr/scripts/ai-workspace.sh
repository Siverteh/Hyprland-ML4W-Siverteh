#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/siverteh-ai-workspace-$(id -u).lock"
flock -n 9 || exit 0
clients=$(hyprctl clients -j)
hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = 2, on_current_monitor = true }))' >/dev/null
if ! jq -e '.[] | select(.class == "Chatgpt")' <<<"$clients" >/dev/null; then
    chatgpt >/dev/null 2>&1 9>&- &
fi
if ! jq -e '.[] | select(.class == "siverteh-ai-dashboard")' <<<"$clients" >/dev/null; then
    kitty --class siverteh-ai-dashboard --title 'Siverteh AI' -- siverteh-ai dashboard 9>&- &
    for _ in $(seq 1 40); do
        hyprctl clients -j | jq -e '.[] | select(.class == "siverteh-ai-dashboard")' >/dev/null && break
        sleep 0.1
    done
fi
