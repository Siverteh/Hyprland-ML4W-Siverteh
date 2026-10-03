#!/usr/bin/env bash
killall hypridle 2>/dev/null || true
sleep 1
setsid -f hypridle >/dev/null 2>&1
notify-send "hypridle has been restarted."
