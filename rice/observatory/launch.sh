#!/usr/bin/env bash
set -euo pipefail
root="$HOME/.local/share/siverteh-ai/observatory"
runtime="$HOME/.local/share/siverteh-ai/rice-runtime"
export PATH="$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH="$runtime/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
qs="$(command -v quickshell || true)"
if [[ -z "$qs" ]]; then qs="$runtime/usr/bin/quickshell"; fi
case "${1:-start}" in
    start)
        "$qs" -p "$root/shell/shell.qml" --daemonize
        ;;
    toggle|close)
        "$qs" -p "$root/shell/shell.qml" ipc call observatory "${1}"
        ;;
    restore-wallpaper)
        image="$(cat "$HOME/.cache/siverteh/hyprland-dotfiles/current_wallpaper")"
        exec python3 "$root/control.py" wallpaper "$image"
        ;;
    rollback)
        exec python3 "$root/install.py" --restore "$(cat "$HOME/.local/state/siverteh-observatory/latest-backup")"
        ;;
    brain|capture|rotate|hold|tasks|notes|resume|new)
        exec python3 "$root/control.py" action "$1"
        ;;
    *) printf 'Usage: siverteh-observatory [start|toggle|brain|capture|tasks|notes|rotate|hold]\n' >&2; exit 2 ;;
esac
