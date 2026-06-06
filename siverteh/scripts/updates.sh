#!/usr/bin/env bash
#  _   _           _       _             
# | | | |_ __   __| | __ _| |_ ___  ___  
# | | | | '_ \ / _` |/ _` | __/ _ \/ __| 
# | |_| | |_) | (_| | (_| | ||  __/\__ \ 
#  \___/| .__/ \__,_|\__,_|\__\___||___/ 
#       |_|                              
#  

# Check if command exists
_checkCommandExists() {
    cmd="$1"
    if ! command -v "$cmd" >/dev/null; then
        echo 1
        return
    fi
    echo 0
    return
}

script_name=$(basename "$0")

# Count the instances
instance_count=$(ps aux | grep -F "$script_name" | grep -v grep | grep -v $$ | wc -l)

if [ $instance_count -gt 1 ]; then
    sleep $instance_count
fi


# ----------------------------------------------------- 
# Define threshholds for color indicators
# ----------------------------------------------------- 

threshhold_green=0
threshhold_yellow=25
threshhold_red=100

# ----------------------------------------------------- 
# Check for updates
# ----------------------------------------------------- 

updates=0

# Arch
if [[ $(_checkCommandExists "pacman") == 0 ]]; then

    check_lock_files() {
        local pacman_lock="/var/lib/pacman/db.lck"
        local checkup_lock="${TMPDIR:-/tmp}/checkup-db-${UID}/db.lck"

        while [ -f "$pacman_lock" ] || [ -f "$checkup_lock" ]; do
            sleep 1
        done
    }

    check_lock_files

    yay_installed="false"
    paru_installed="false"
    if [[ $(_checkCommandExists "yay") == 0 ]]; then
        yay_installed="true"
    fi
    if [[ $(_checkCommandExists "paru") == 0 ]]; then
        paru_installed="true"
    fi
    if [[ $yay_installed == "true" ]] && [[ $paru_installed == "false" ]]; then
        aur_helper="yay"
    elif [[ $yay_installed == "false" ]] && [[ $paru_installed == "true" ]]; then
        aur_helper="paru"
    else
        aur_helper="yay"
    fi
    updates_aur=0
    updates_pacman=0

    if [[ $(_checkCommandExists "$aur_helper") == 0 ]]; then
        updates_aur=$($aur_helper -Qum 2>/dev/null | wc -l)
    fi
    if [[ $(_checkCommandExists "checkupdates") == 0 ]]; then
        updates_pacman=$(checkupdates 2>/dev/null | wc -l)
    fi

    updates=$((updates_aur+updates_pacman))
    
# Fedora
elif [[ $(_checkCommandExists "dnf") == 0 ]]; then
    updates=$(dnf check-update -q | grep -c ^[a-z0-9])
# Others
else
    updates=0
fi

# ----------------------------------------------------- 
# Output in JSON format for Waybar Module custom-updates
# ----------------------------------------------------- 

css_class="neutral"
tooltip="No updates available"
text="$updates"

updates_visibility="always"
settings_file="$HOME/.config/siverteh/settings.json"
if [ -f "$settings_file" ] && command -v jq >/dev/null 2>&1; then
    updates_visibility=$(jq -r '.bar.updates_visibility // "always"' "$settings_file" 2>/dev/null || echo "always")
fi

if [ "$updates" -gt $threshhold_green ]; then
    css_class="green"
    tooltip="Click to update your system"
fi

if [ "$updates" -gt $threshhold_yellow ]; then
    css_class="yellow"
fi

if [ "$updates" -gt $threshhold_red ]; then
    css_class="red"
fi

if [ "$updates_visibility" = "pending_only" ] && [ "$updates" -eq 0 ]; then
    text=""
fi

printf '{"text": "%s", "alt": "%s", "tooltip": "%s", "class": "%s"}' "$text" "$updates" "$tooltip" "$css_class"
