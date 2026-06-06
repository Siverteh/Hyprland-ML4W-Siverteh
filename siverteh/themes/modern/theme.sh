#!/usr/bin/env bash
# Siverteh OS Theme Modern

# Set waybar
echo "/siverteh-modern;/siverteh-modern/default" > $HOME/.config/siverteh/core/settings/waybar-theme.sh
$HOME/.config/waybar/launch.sh &

# Set nwg-dock-hyprland
echo "modern" > $HOME/.config/siverteh/core/settings/dock-theme
$HOME/.config/nwg-dock-hyprland/launch.sh &

# Set swaync
echo '@import "themes/modern/style.css";' > $HOME/.config/swaync/style.css
swaync-client -rs

# Set wlogout
echo '@import "themes/modern/style.css";' > $HOME/.config/wlogout/style.css

# Set launcher
echo 'rofi' > $HOME/.config/siverteh/core/settings/launcher

# Set walker theme
echo 'modern' > $HOME/.config/siverteh/core/settings/walker-theme

# Set Window Border
echo 'source = ~/.config/hypr/conf/windows/border-2.conf' > $HOME/.config/hypr/conf/window.conf

# Set rofi
echo '* { border-width: 2px; }' > $HOME/.config/siverteh/core/settings/rofi-border.rasi

echo ":: Theme set to Modern"