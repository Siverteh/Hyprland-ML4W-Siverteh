#!/bin/bash
#  ____          _ _               ____       _                 
# / ___|___   __| (_)_ __   __ _  / ___|  ___| |_ _   _ _ __    
#| |   / _ \ / _` | | '_ \ / _` | \___ \ / _ \ __| | | | '_ \   
#| |__| (_) | (_| | | | | | (_| |  ___) |  __/ |_| |_| | |_) |  
# \____\___/ \__,_|_|_| |_|\__, | |____/ \___|\__|\__,_| .__/   
#                          |___/                       |_|      

# Multi-workspace coding environment setup

notify-send "Coding Setup" "Setting up your development environment..." -t 2000

# Workspace 1: Browser with Claude
hyprctl dispatch workspace 1
google-chrome-stable --new-window "https://claude.ai" &
sleep 0.5

# Workspace 2: VS Code (main coding workspace)
hyprctl dispatch workspace 2
code &
sleep 0.5

# Workspace 3: Discord
hyprctl dispatch workspace 3
discord &
sleep 0.5

# Workspace 4: Spotify
hyprctl dispatch workspace 4
spotify &
sleep 0.5

# Workspace 10: Mission Center and ML4W Settings side by side
hyprctl dispatch workspace 10
flatpak run com.ml4w.settings &
sleep 1
flatpak run io.missioncenter.MissionCenter &
 


# Return to workspace 2 (your main coding area)
sleep 1
hyprctl dispatch workspace 2

notify-send "Coding Setup" "Environment ready! 🚀" -t 2000
