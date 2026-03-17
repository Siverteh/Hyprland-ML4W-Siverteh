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

# Function to move windows into the personal workspace map
move_to_personal_layout() {
    echo "Reorganizing windows for the Siverteh layout..." | tee -a "$LOG_FILE"
    
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

    # Move mail to workspace 5
    echo "Moving mail to workspace 5..." | tee -a "$LOG_FILE"
    hyprctl clients -j | jq -r '.[] | select(.class | ascii_downcase | test("evolution")) | .address' | while read addr; do
        echo "  Moving $addr" >> "$LOG_FILE"
        hyprctl dispatch movetoworkspacesilent 5,address:$addr
    done

    # Move Mission Center to workspace 6
    echo "Moving Mission Center to workspace 6..." | tee -a "$LOG_FILE"
    hyprctl clients -j | jq -r '.[] | select(.class | ascii_downcase | test("mission-center|missioncenter")) | .address' | while read addr; do
        echo "  Moving $addr" >> "$LOG_FILE"
        hyprctl dispatch movetoworkspacesilent 6,address:$addr
    done
}

if [ "$EXTERNAL_ACTIVE" == "false" ]; then
    echo "External monitor detected - keeping the personal workspace map" | tee -a "$LOG_FILE"
    move_to_personal_layout
    
    # External Monitor Rules
    cat > "$RULES_FILE" << 'EOF'
# =====================================================
# External Monitor: Siverteh Workspace Map
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

# Workspace 5: Mail
windowrule = match:class ^(evolution)$, workspace 5 silent
windowrule = match:class ^(org.gnome.Evolution)$, workspace 5 silent

# Workspace 6: System and misc
windowrule = match:class ^(mission-center)$, workspace 6 silent
windowrule = match:class ^(mission-center)$, float off
windowrule = match:class ^(io.missioncenter.MissionCenter)$, workspace 6 silent
windowrule = match:class ^(io.missioncenter.MissionCenter)$, float off

EOF

else
    echo "Laptop only - applying the personal workspace map" | tee -a "$LOG_FILE"
    
    move_to_personal_layout

    # Laptop Rules
    cat > "$RULES_FILE" << 'EOF'
# =====================================================
# Laptop Mode: Siverteh Workspace Map
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

# Workspace 5: Mail
windowrule = match:class ^(evolution)$, workspace 5 silent
windowrule = match:class ^(org.gnome.Evolution)$, workspace 5 silent

# Workspace 6: System and misc
windowrule = match:class ^(mission-center)$, workspace 6 silent
windowrule = match:class ^(mission-center)$, float off
windowrule = match:class ^(io.missioncenter.MissionCenter)$, workspace 6 silent
windowrule = match:class ^(io.missioncenter.MissionCenter)$, float off

EOF

fi

# Reload Hyprland
hyprctl reload

# Log monitor status
echo "External disabled status: $EXTERNAL_ACTIVE" >> "$LOG_FILE"
hyprctl monitors -j | jq -r '.[] | "\(.name): disabled=\(.disabled)"' >> "$LOG_FILE"
