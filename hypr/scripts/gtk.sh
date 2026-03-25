#!/usr/bin/env bash
#   _____________ __
#  / ___/_  __/ //_/
# / (_ / / / / ,<   
# \___/ /_/ /_/|_|  
#                   
# Source: https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland

# Check that settings file exists
config="$HOME/.config/gtk-3.0/settings.ini"
if [ ! -f "$config" ]; then exit 1; fi

# Read settings file
gnome_schema="org.gnome.desktop.interface"
gtk_theme="$(grep 'gtk-theme-name' "$config" | sed 's/.*\s*=\s*//')"
icon_theme="$(grep 'gtk-icon-theme-name' "$config" | sed 's/.*\s*=\s*//')"
cursor_theme="$(grep 'gtk-cursor-theme-name' "$config" | sed 's/.*\s*=\s*//')"
cursor_size="$(grep 'gtk-cursor-theme-size' "$config" | sed 's/.*\s*=\s*//')"
font_name="$(grep 'gtk-font-name' "$config" | sed 's/.*\s*=\s*//')"
prefer_dark_theme="$(grep 'gtk-application-prefer-dark-theme' "$config" | sed 's/.*\s*=\s*//')"
terminal=$(cat $HOME/.config/ml4w/settings/terminal.sh)
gtk4_colors="$HOME/.config/gtk-4.0/colors.css"

detect_accent_color() {
    local fallback="blue"

    if [ ! -f "$gtk4_colors" ]; then
        printf '%s' "$fallback"
        return
    fi

    python - "$gtk4_colors" <<'PY'
import re
import sys

path = sys.argv[1]
text = open(path, encoding="utf-8").read()
match = re.search(r'@define-color\s+accent_color\s+(#[0-9a-fA-F]{6})\s*;', text)
if not match:
    print("blue")
    raise SystemExit

hex_color = match.group(1).lstrip("#")
r = int(hex_color[0:2], 16) / 255.0
g = int(hex_color[2:4], 16) / 255.0
b = int(hex_color[4:6], 16) / 255.0

mx = max(r, g, b)
mn = min(r, g, b)
delta = mx - mn

if mx == mn:
    hue = 0.0
elif mx == r:
    hue = (60 * ((g - b) / delta) + 360) % 360
elif mx == g:
    hue = (60 * ((b - r) / delta) + 120) % 360
else:
    hue = (60 * ((r - g) / delta) + 240) % 360

saturation = 0.0 if mx == 0 else delta / mx
lightness = (mx + mn) / 2.0

if saturation < 0.14:
    print("slate")
elif hue < 18:
    print("red")
elif hue < 38:
    print("orange")
elif hue < 62:
    print("yellow")
elif hue < 150:
    print("green")
elif hue < 195:
    print("teal")
elif hue < 255:
    print("blue")
elif hue < 315:
    print("purple")
else:
    print("pink" if lightness > 0.58 else "red")
PY
}

# Echo value for debugging
echo "GTK-Theme:" $gtk_theme
echo "Icon Theme:" $icon_theme
echo "Cursor Theme:" $cursor_theme
echo "Cursor Size:" $cursor_size

prefer_dark_theme_value="prefer-dark"
accent_color="$(detect_accent_color)"

echo "Color Theme:" $prefer_dark_theme_value
echo "Accent Color:" $accent_color
echo "Font Name:" $font_name
echo "Terminal:" $terminal

# Update gsettings
gsettings set "$gnome_schema" gtk-theme "$gtk_theme"
gsettings set "$gnome_schema" icon-theme "$icon_theme"
gsettings set "$gnome_schema" cursor-theme "$cursor_theme"
gsettings set "$gnome_schema" font-name "$font_name"
gsettings set "$gnome_schema" color-scheme "$prefer_dark_theme_value"
gsettings set "$gnome_schema" accent-color "$accent_color"

# Update cursor for Hyprland
if [ -f ~/.config/hypr/conf/cursor.conf ]; then
    echo "exec-once = hyprctl setcursor $cursor_theme $cursor_size" >~/.config/hypr/conf/cursor.conf
    hyprctl setcursor $cursor_theme $cursor_size
fi

# Update gsettings for open any terminal
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal "$terminal"
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal use-generic-terminal-name "true"
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal keybindings "<Ctrl><Alt>t"

# Remove icon from titlebar
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
