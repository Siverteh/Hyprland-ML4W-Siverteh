#!/usr/bin/env bash
# Siverteh OS Theme Glass

# Set waybar
echo "/siverteh-glass-classic;/siverteh-glass-classic/default" > $HOME/.config/siverteh/core/settings/waybar-theme.sh
$HOME/.config/waybar/launch.sh &

# Set nwg-dock-hyprland
echo "glass" > $HOME/.config/siverteh/core/settings/dock-theme
$HOME/.config/nwg-dock-hyprland/launch.sh &

# Set swaync
echo '@import "themes/glass/style.css";' > $HOME/.config/swaync/style.css
swaync-client -rs

# Set wlogout
echo '@import "themes/glass/style.css";' > $HOME/.config/wlogout/style.css

# Set launcher
echo 'rofi' > $HOME/.config/siverteh/core/settings/launcher

# Set walker theme
echo 'glass' > $HOME/.config/siverteh/core/settings/walker-theme

# Set Window Border
echo 'source = ~/.config/hypr/conf/windows/default.conf' > $HOME/.config/hypr/conf/window.conf

# Set rofi
echo '* { border-width: 1px; }' > $HOME/.config/siverteh/core/settings/rofi-border.rasi

echo ":: Theme set to Glass"