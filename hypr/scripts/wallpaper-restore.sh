#!/usr/bin/env bash
#                _ _
# __      ____ _| | |_ __   __ _ _ __   ___ _ __
# \ \ /\ / / _` | | | '_ \ / _` | '_ \ / _ \ '__|
#  \ V  V / (_| | | | |_) | (_| | |_) |  __/ |
#   \_/\_/ \__,_|_|_| .__/ \__,_| .__/ \___|_|
#                   |_|         |_|
#
# -----------------------------------------------------
# Restore last wallpaper
# -----------------------------------------------------

# -----------------------------------------------------
# Set defaults
# -----------------------------------------------------

restart_nautilus_if_running() {
    if ! nautilus_window_open; then
        return
    fi

    nautilus -q >/dev/null 2>&1 || true

    for _ in $(seq 1 30); do
        if ! pgrep -x nautilus >/dev/null 2>&1; then
            break
        fi
        sleep 0.1
    done

    if pgrep -x nautilus >/dev/null 2>&1; then
        pkill -TERM -x nautilus >/dev/null 2>&1 || true
        sleep 0.2
    fi

    nohup nautilus --new-window >/dev/null 2>&1 &
}

nautilus_window_open() {
    if ! command -v hyprctl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
        pgrep -x nautilus >/dev/null 2>&1
        return
    fi

    hyprctl clients -j 2>/dev/null | jq -e '
        .[]
        | (.class // "")
        | test("nautilus|org\\.gnome\\.Nautilus"; "i")
    ' >/dev/null 2>&1
}

ml4w_cache_folder="$HOME/.cache/ml4w/hyprland-dotfiles"

defaultwallpaper="$HOME/.config/ml4w/wallpapers/default.jpg"

cachefile="$ml4w_cache_folder/current_wallpaper"

# -----------------------------------------------------
# Get current wallpaper
# -----------------------------------------------------

if [ -f "$cachefile" ]; then
    sed -i "s|~|$HOME|g" "$cachefile"
    wallpaper=$(cat $cachefile)
    if [ -f $wallpaper ]; then
        echo ":: Wallpaper $wallpaper exists"
    else
        echo ":: Wallpaper $wallpaper does not exist. Using default."
        wallpaper=$defaultwallpaper
    fi
else
    echo ":: $cachefile does not exist. Using default wallpaper."
    wallpaper=$defaultwallpaper
fi

# -----------------------------------------------------
# Set wallpaper
# -----------------------------------------------------

echo ":: Setting wallpaper with source image $wallpaper"
if [ -f ~/.local/bin/waypaper ]; then
    export PATH=$PATH:~/.local/bin/
fi
waypaper --wallpaper "$wallpaper"

if [ -x "$HOME/.config/hypr/scripts/gtk.sh" ]; then
    "$HOME/.config/hypr/scripts/gtk.sh"
fi

restart_nautilus_if_running
