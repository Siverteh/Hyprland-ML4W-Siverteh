#!/usr/bin/env bash
killall hypridle 2>/dev/null || true
sleep 1
hyprctl dispatch exec "hypridle" >/dev/null
notify-send "hypridle has been restarted."
