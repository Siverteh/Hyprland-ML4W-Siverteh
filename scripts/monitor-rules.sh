#!/bin/bash
# Dynamic window rules based on monitor setup with window reorganization

RULES_FILE="$HOME/.config/hypr/conf/windowrule.conf"
LOG_FILE="/tmp/monitor-rules.log"

# Clear log
echo "=== Monitor Rules Debug $(date) ===" > "$LOG_FILE"

# Wait for monitors to be detected
sleep 1

# Check if DP-1 is ACTUALLY ACTIVE
EXTERNAL_ACTIVE=$(hyprctl monitors -j | jq -r '.[] | select(.name == "DP-1") | .disabled' 2>/dev/null)

# Function to move windows to laptop mode
move_to_laptop_mode() {
    echo "Reorganizing windows for laptop mode..." | tee -a "$LOG_FILE"
    
    # Get all clients and log them
    echo "Current windows:" >> "$LOG_FILE"
    hyprctl clients -j | jq -r '.[] | "\(.class) - \(.address)"' >> "$LOG_FILE"
    
    # Move browsers to workspace 1
    echo "Moving browsers to workspace 1..." | tee -a "$LOG_FILE"
    hyprctl clients -j | jq -r '.[] | select(.class | ascii_downcase | test("chrome|chromium|firefox")) | .address' | while read addr; do
        echo "  Moving $addr" >> "$LOG_FILE"
        hyprctl dispatch movetoworkspacesilent 1,address:$addr
    done
    
    # Move code editors to workspace 2
    echo "Moving code editors to workspace 2..." | tee -a "$LOG_FILE"
    hyprctl clients -j | jq -r '.[] | select(.class | ascii_downcase | test("code|cursor|vscodium")) | .address' | while read addr; do
        echo "  Moving $addr" >> "$LOG_FILE"
        hyprctl dispatch movetoworkspacesilent 2,address:$addr
    done
    
    # Move Discord to workspace 3
    echo "Moving Discord to workspace 3..." | tee -a "$LOG_FILE"
    hyprctl clients -j | jq -r '.[] | select(.class | ascii_downcase | test("discord")) | .address' | while read addr; do
        echo "  Moving $addr" >> "$LOG_FILE"
        hyprctl dispatch movetoworkspacesilent 3,address:$addr
    done
    
    # Move Spotify to workspace 4
    echo "Moving Spotify to workspace 4..." | tee -a "$LOG_FILE"
    hyprctl clients -j | jq -r '.[] | select(.class | ascii_downcase | test("spotify")) | .address' | while read addr; do
        echo "  Moving $addr" >> "$LOG_FILE"
        hyprctl dispatch movetoworkspacesilent 4,address:$addr
    done

    # Move Mission Center to workspace 10
    echo "Moving Mission Center to workspace 10..." | tee -a "$LOG_FILE"
    hyprctl clients -j | jq -r '.[] | select(.class | ascii_downcase | test("mission-center|missioncenter")) | .address' | while read addr; do
        echo "  Moving $addr" >> "$LOG_FILE"
        hyprctl dispatch movetoworkspacesilent 10,address:$addr
    done
}

# Function to move windows to external mode
move_to_external_mode() {
    echo "Reorganizing windows for external mode..." | tee -a "$LOG_FILE"
    
    # Get all clients and log them
    echo "Current windows:" >> "$LOG_FILE"
    hyprctl clients -j | jq -r '.[] | "\(.class) - \(.address)"' >> "$LOG_FILE"
    
    # Move browsers and code to workspace 1
    echo "Moving browsers and code to workspace 1..." | tee -a "$LOG_FILE"
    hyprctl clients -j | jq -r '.[] | select(.class | ascii_downcase | test("chrome|chromium|firefox|code|cursor|vscodium")) | .address' | while read addr; do
        echo "  Moving $addr" >> "$LOG_FILE"
        hyprctl dispatch movetoworkspacesilent 1,address:$addr
    done
    
    # Move Discord and Spotify to workspace 2
    echo "Moving Discord and Spotify to workspace 2..." | tee -a "$LOG_FILE"
    hyprctl clients -j | jq -r '.[] | select(.class | ascii_downcase | test("discord|spotify")) | .address' | while read addr; do
        echo "  Moving $addr" >> "$LOG_FILE"
        hyprctl dispatch movetoworkspacesilent 2,address:$addr
    done
}

# Function to update waybar workspace icons
update_waybar_icons() {
    local mode=$1
    local modules_file="$HOME/.config/waybar/modules.json"
    
    if [ "$mode" == "external" ]; then
        # Laptop: Replace just the icon lines
        sed -i 's/"1": ".*"/"1": ""/' "$modules_file"
        sed -i 's/"2": ".*"/"2": ""/' "$modules_file"
        sed -i 's/"3": ".*"/"3": ""/' "$modules_file"
        sed -i 's/"4": ".*"/"4": ""/' "$modules_file"
        sed -i 's/"5": ".*"/"5": ""/' "$modules_file"
        sed -i 's/"6": ".*"/"6": ""/' "$modules_file"
        sed -i 's/"7": ".*"/"7": ""/' "$modules_file"
        sed -i 's/"8": ".*"/"8": ""/' "$modules_file"
        sed -i 's/"9": ".*"/"9": ""/' "$modules_file"
        sed -i 's/"10": ".*"/"10": ""/' "$modules_file"

    else
        # External: Replace just the icon lines
        sed -i 's/"1": ".*"/"1": ""/' "$modules_file"
        sed -i 's/"2": ".*"/"2": ""/' "$modules_file"
        sed -i 's/"3": ".*"/"3": ""/' "$modules_file"
        sed -i 's/"4": ".*"/"4": ""/' "$modules_file"
        sed -i 's/"5": ".*"/"5": ""/' "$modules_file"
        sed -i 's/"6": ".*"/"6": ""/' "$modules_file"
        sed -i 's/"7": ".*"/"7": ""/' "$modules_file"
        sed -i 's/"8": ".*"/"8": ""/' "$modules_file"
        sed -i 's/"9": ".*"/"9": ""/' "$modules_file"
        sed -i 's/"10": ".*"/"10": ""/' "$modules_file"
    fi
    killall waybar 2>/dev/null
    sleep 1
    ~/.config/waybar/launch.sh &
    
    echo "Waybar icons updated to $mode mode" | tee -a "$LOG_FILE"
}

if [ "$EXTERNAL_ACTIVE" == "false" ]; then
    echo "External monitor detected - applying dual-window workspaces" | tee -a "$LOG_FILE"
    
    # Move existing windows to external layout
    move_to_external_mode

    update_waybar_icons "external"
    
    # External Monitor Rules
    cat > "$RULES_FILE" << 'EOF'
# =====================================================
# External Monitor: Multi-Window Workspaces
# =====================================================

# Workspace 1: Browser + Code
windowrule = match:class ^(Google-chrome)$, workspace 1
windowrule = match:class ^(google-chrome)$, workspace 1
windowrule = match:class ^(chromium)$, workspace 1
windowrule = match:class ^(firefox)$, workspace 1
windowrule = match:class ^(Firefox)$, workspace 1
windowrule = match:class ^(Code)$, workspace 1
windowrule = match:class ^(code)$, workspace 1
windowrule = match:class ^(VSCodium)$, workspace 1
windowrule = match:class ^(cursor)$, workspace 1
windowrule = match:class ^(Cursor)$, workspace 1

# Workspace 2: Discord + Spotify
windowrule = match:class ^(discord)$, workspace 2
windowrule = match:class ^(Discord)$, workspace 2
windowrule = match:class ^(Spotify)$, workspace 2
windowrule = match:class ^(spotify)$, workspace 2

# Workspace 10: Monitoring (disable floating, then fullscreen)
windowrule = match:class ^(mission-center)$, workspace 10
windowrule = match:class ^(mission-center)$, float off
windowrule = match:class ^(io.missioncenter.MissionCenter)$, workspace 10
windowrule = match:class ^(io.missioncenter.MissionCenter)$, float off

EOF

else
    echo "Laptop only - applying single-window workspaces" | tee -a "$LOG_FILE"
    
    # Move existing windows to laptop layout
    move_to_laptop_mode
    
    update_waybar_icons "laptop"

    # Laptop Rules
    cat > "$RULES_FILE" << 'EOF'
# =====================================================
# Laptop Mode: One App Per Workspace
# =====================================================

# Workspace 1: Browser
windowrule = match:class ^(Google-chrome)$, workspace 1 silent
windowrule = match:class ^(google-chrome)$, workspace 1 silent
windowrule = match:class ^(chromium)$, workspace 1 silent
windowrule = match:class ^(firefox)$, workspace 1 silent
windowrule = match:class ^(Firefox)$, workspace 1 silent

# Workspace 2: Code
windowrule = match:class ^(Code)$, workspace 2 silent
windowrule = match:class ^(code)$, workspace 2 silent
windowrule = match:class ^(VSCodium)$, workspace 2 silent
windowrule = match:class ^(cursor)$, workspace 2 silent
windowrule = match:class ^(Cursor)$, workspace 2 silent

# Workspace 3: Discord
windowrule = match:class ^(discord)$, workspace 3 silent
windowrule = match:class ^(Discord)$, workspace 3 silent

# Workspace 4: Spotify
windowrule = match:class ^(Spotify)$, workspace 4 silent
windowrule = match:class ^(spotify)$, workspace 4 silent

# Workspace 10: Monitoring (disable floating, then fullscreen)
windowrule = match:class ^(mission-center)$, workspace 10 silent
windowrule = match:class ^(mission-center)$, float off
windowrule = match:class ^(io.missioncenter.MissionCenter)$, workspace 10 silent
windowrule = match:class ^(io.missioncenter.MissionCenter)$, float off

EOF

fi

# Reload Hyprland
hyprctl reload

# Log monitor status
echo "External disabled status: $EXTERNAL_ACTIVE" >> "$LOG_FILE"
hyprctl monitors -j | jq -r '.[] | "\(.name): disabled=\(.disabled)"' >> "$LOG_FILE"
