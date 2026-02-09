#!/bin/bash
# Window minimize/restore script

STATE_DIR="$HOME/.cache/hypr-minimize"
mkdir -p "$STATE_DIR"

hide_window() {
    # Get active window address and current workspace
    local window_addr=$(hyprctl activewindow -j | jq -r '.address')
    local workspace_id=$(hyprctl activewindow -j | jq -r '.workspace.id')
    
    if [ "$window_addr" = "null" ] || [ -z "$window_addr" ]; then
        notify-send "No active window to hide"
        return
    fi
    
    # Store which workspace this window came from
    echo "$workspace_id" > "$STATE_DIR/$window_addr"
    
    # Move to special workspace silently
    hyprctl dispatch movetoworkspacesilent special:hidden,address:$window_addr
    notify-send "Window hidden" "Press SUPER+SHIFT+H to restore"
}

restore_last() {
    # Get all windows in special:hidden workspace
    local windows=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:hidden") | .address')
    
    if [ -z "$windows" ]; then
        notify-send "No hidden windows to restore"
        return
    fi
    
    # Get the last window (most recently hidden)
    local last_window=$(echo "$windows" | tail -n 1)
    
    # Get the workspace it came from
    if [ -f "$STATE_DIR/$last_window" ]; then
        local target_ws=$(cat "$STATE_DIR/$last_window")
        hyprctl dispatch movetoworkspacesilent $target_ws,address:$last_window
        rm "$STATE_DIR/$last_window"
        hyprctl dispatch focuswindow address:$last_window
        notify-send "Window restored"
    else
        # If we don't know where it came from, move to current workspace
        hyprctl dispatch movetoworkspace name:current,address:$last_window
        notify-send "Window restored to current workspace"
    fi
}

restore_all_current_workspace() {
    local current_ws=$(hyprctl activeworkspace -j | jq -r '.id')
    local windows=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:hidden") | .address')
    
    if [ -z "$windows" ]; then
        notify-send "No hidden windows"
        return
    fi
    
    local count=0
    while IFS= read -r window_addr; do
        if [ -f "$STATE_DIR/$window_addr" ]; then
            local orig_ws=$(cat "$STATE_DIR/$window_addr")
            if [ "$orig_ws" = "$current_ws" ]; then
                hyprctl dispatch movetoworkspacesilent $current_ws,address:$window_addr
                rm "$STATE_DIR/$window_addr"
                ((count++))
            fi
        fi
    done <<< "$windows"
    
    if [ $count -gt 0 ]; then
        notify-send "Restored $count window(s)"
    else
        notify-send "No hidden windows from this workspace"
    fi
}

case "$1" in
    hide)
        hide_window
        ;;
    restore-last)
        restore_last
        ;;
    restore-current)
        restore_all_current_workspace
        ;;
    *)
        echo "Usage: $0 {hide|restore-last|restore-current}"
        exit 1
        ;;
esac
