#!/usr/bin/env bash

overlay="$HOME/.config/siverteh/core/welcome/siverteh-shell.py"
layer_preload="/usr/lib/libgtk4-layer-shell.so"
pidfile="$HOME/.cache/siverteh/shell-overlay.pid"
readyfile="$HOME/.cache/siverteh/shell-overlay.ready"
statefile="$HOME/.cache/siverteh/shell-overlay.state"
requestfile="$HOME/.cache/siverteh/shell-overlay.request"
requested_tab=""
tab_direction=""
control_action=""

mkdir -p "$(dirname "$pidfile")"

if [ "${1:-}" = "--tab" ]; then
    requested_tab="${2:-}"
elif [[ "${1:-}" == --tab=* ]]; then
    requested_tab="${1#--tab=}"
elif [ "${1:-}" = "--next-tab" ]; then
    tab_direction="next"
elif [ "${1:-}" = "--prev-tab" ]; then
    tab_direction="prev"
elif [ "${1:-}" = "--quit" ] || [ "${1:-}" = "--stop" ]; then
    control_action="quit"
elif [ "${1:-}" = "--restart" ]; then
    control_action="restart"
fi

valid_tab() {
    case "$1" in
    now|dashboard|media|actions|settings)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

normalize_tab() {
    case "$1" in
    now)
        printf 'dashboard\n'
        ;;
    dashboard|media|actions|settings)
        printf '%s\n' "$1"
        ;;
    *)
        printf 'dashboard\n'
        ;;
    esac
}

request_tab() {
    local pid="$1"
    local tab="$2"
    printf '{"tab":"%s"}\n' "$(normalize_tab "$tab")" >"$requestfile"
    kill -USR2 "$pid"
}

current_tab() {
    if command -v jq >/dev/null 2>&1 && [ -f "$statefile" ]; then
        jq -r '.tab // "dashboard"' "$statefile" 2>/dev/null | while IFS= read -r tab; do normalize_tab "$tab"; done
    else
        printf 'dashboard\n'
    fi
}

cycle_tab() {
    local direction="$1"
    local current
    current="$(current_tab)"

    case "$current:$direction" in
    dashboard:next)
        printf 'media\n'
        ;;
    media:next)
        printf 'actions\n'
        ;;
    actions:next)
        printf 'settings\n'
        ;;
    settings:next)
        printf 'dashboard\n'
        ;;
    dashboard:prev)
        printf 'settings\n'
        ;;
    media:prev)
        printf 'dashboard\n'
        ;;
    actions:prev)
        printf 'media\n'
        ;;
    settings:prev)
        printf 'actions\n'
        ;;
    *)
        printf 'dashboard\n'
        ;;
    esac
}

read_live_daemon() {
    local pid=""
    local ready_pid=""

    [ -f "$pidfile" ] || return 1
    [ -f "$readyfile" ] || return 1
    pid="$(cat "$pidfile" 2>/dev/null || true)"
    ready_pid="$(cat "$readyfile" 2>/dev/null || true)"

    if [ -n "$pid" ] && [ "$pid" = "$ready_pid" ] && kill -0 "$pid" 2>/dev/null; then
        printf '%s\n' "$pid"
        return 0
    fi

    return 1
}

start_daemon() {
    if read_live_daemon >/dev/null; then
        return
    fi

    rm -f "$pidfile" "$readyfile"

    setsid -f env LD_PRELOAD="$layer_preload" python3 "$overlay" --daemon >/tmp/siverteh-shell.log 2>&1

    for _ in $(seq 1 40); do
        if read_live_daemon >/dev/null; then
            return
        fi
        sleep 0.05
    done
}

stop_daemon() {
    local pid=""

    if ! pid="$(read_live_daemon)"; then
        rm -f "$pidfile" "$readyfile" "$statefile"
        return 0
    fi

    kill -TERM "$pid" 2>/dev/null || true
    for _ in $(seq 1 40); do
        if ! kill -0 "$pid" 2>/dev/null; then
            rm -f "$pidfile" "$readyfile"
            return 0
        fi
        sleep 0.05
    done

    return 1
}

if [ "$control_action" = "quit" ]; then
    stop_daemon
    exit $?
fi

if [ "$control_action" = "restart" ]; then
    stop_daemon || true
    start_daemon
    exit 0
fi

if [ "${1:-}" = "--daemon" ]; then
    start_daemon
    exit 0
fi

if pid="$(read_live_daemon)"; then
    if [ -n "$tab_direction" ]; then
        request_tab "$pid" "$(cycle_tab "$tab_direction")"
        exit 0
    fi
    if valid_tab "$requested_tab"; then
        request_tab "$pid" "$requested_tab"
        exit 0
    fi
    kill -USR1 "$pid"
    exit 0
fi

start_daemon

if pid="$(read_live_daemon)"; then
    if [ -n "$tab_direction" ]; then
        request_tab "$pid" "$(cycle_tab "$tab_direction")"
        exit 0
    fi
    if valid_tab "$requested_tab"; then
        request_tab "$pid" "$requested_tab"
        exit 0
    fi
    kill -USR1 "$pid"
    exit 0
fi

setsid -f env LD_PRELOAD="$layer_preload" python3 "$overlay" >/tmp/siverteh-shell.log 2>&1
