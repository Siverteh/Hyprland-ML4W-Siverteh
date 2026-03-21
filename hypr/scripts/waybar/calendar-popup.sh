#!/usr/bin/env bash

popup="$HOME/.config/hypr/scripts/waybar/mini-calendar.py"
layer_preload="/usr/lib/libgtk4-layer-shell.so"
pidfile="$HOME/.cache/siverteh/mini-calendar.pid"

start_daemon() {
    mkdir -p "$(dirname "$pidfile")"

    if [ -f "$pidfile" ]; then
        pid="$(cat "$pidfile" 2>/dev/null || true)"
        if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
            return
        fi
        rm -f "$pidfile"
    fi

    setsid -f env LD_PRELOAD="$layer_preload" python3 "$popup" --daemon >/dev/null 2>&1

    for _ in $(seq 1 20); do
        if [ -f "$pidfile" ]; then
            pid="$(cat "$pidfile" 2>/dev/null || true)"
            if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
                return
            fi
        fi
        sleep 0.05
    done
}

if [ "${1:-}" = "--daemon" ]; then
    start_daemon
    exit 0
fi

start_daemon

if [ -f "$pidfile" ]; then
    pid="$(cat "$pidfile" 2>/dev/null || true)"
    if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
        kill -USR1 "$pid"
        exit 0
    fi
fi

setsid -f env LD_PRELOAD="$layer_preload" python3 "$popup" >/dev/null 2>&1
