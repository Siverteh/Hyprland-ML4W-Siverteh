#!/usr/bin/env bash
#                    __
#  _    _____ ___ __/ /  ___ _____
# | |/|/ / _ `/ // / _ \/ _ `/ __/
# |__,__/\_,_/\_, /_.__/\_,_/_/
#            /___/
#

# -----------------------------------------------------
# Prevent duplicate launches: only the first parallel
# invocation proceeds; all others exit immediately.
# -----------------------------------------------------

exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

# -----------------------------------------------------
# Quit all running waybar instances
# -----------------------------------------------------

killall waybar || true
pkill waybar || true
sleep 0.5

# -----------------------------------------------------
# Default theme: /THEMEFOLDER;/VARIATION
# -----------------------------------------------------

default_theme="/siverteh-glass;/siverteh-glass/default"

# -----------------------------------------------------
# Remove incompatible themes
# -----------------------------------------------------

if [ -f ~/.config/siverteh/core/settings/waybar-theme.sh ]; then
    themestyle=$(cat ~/.config/siverteh/core/settings/waybar-theme.sh)
    case "$themestyle" in
    "/siverteh-modern;/siverteh-modern/light")
        echo "$default_theme" >~/.config/siverteh/core/settings/waybar-theme.sh
        ;;
    "/siverteh-modern;/siverteh-modern/dark")
        echo "$default_theme" >~/.config/siverteh/core/settings/waybar-theme.sh
        ;;
    "/siverteh;/siverteh/light")
        echo "$default_theme" >~/.config/siverteh/core/settings/waybar-theme.sh
        ;;
    "/siverteh;/siverteh/dark")
        echo "$default_theme" >~/.config/siverteh/core/settings/waybar-theme.sh
        ;;
    "/siverteh-glass-classic;/siverteh-glass-classic/default")
        echo "$default_theme" >~/.config/siverteh/core/settings/waybar-theme.sh
        ;;
    "/siverteh-modern;/siverteh-modern/default")
        echo "$default_theme" >~/.config/siverteh/core/settings/waybar-theme.sh
        ;;
    *)
        echo
        ;;
    esac
    if [ -d $HOME/.config/waybar/themes/siverteh-modern/light ]; then
        rm -rf $HOME/.config/waybar/themes/siverteh-modern/light
    fi
    if [ -d $HOME/.config/waybar/themes/siverteh-modern/dark ]; then
        rm -rf $HOME/.config/waybar/themes/siverteh-modern/dark
    fi
    if [ -d $HOME/.config/waybar/themes/siverteh/light ]; then
        rm -rf $HOME/.config/waybar/themes/siverteh/light
    fi
    if [ -d $HOME/.config/waybar/themes/siverteh/dark ]; then
        rm -rf $HOME/.config/waybar/themes/siverteh/dark
    fi
fi

# -----------------------------------------------------
# Get current theme information from ~/.config/siverteh/core/settings/waybar-theme.sh
# -----------------------------------------------------

if [ -f ~/.config/siverteh/core/settings/waybar-theme.sh ]; then
    themestyle=$(cat ~/.config/siverteh/core/settings/waybar-theme.sh)
else
    touch ~/.config/siverteh/core/settings/waybar-theme.sh
    echo "$default_theme" >~/.config/siverteh/core/settings/waybar-theme.sh
    themestyle=$default_theme
fi

IFS=';' read -ra arrThemes <<<"$themestyle"
echo ":: Theme: ${arrThemes[0]}"

if [ ! -f ~/.config/waybar/themes${arrThemes[1]}/style.css ]; then
    themestyle=$default_theme
fi

# -----------------------------------------------------
# Loading the configuration
# -----------------------------------------------------

config_file="config"
style_file="style.css"
config_path="$HOME/.config/waybar/themes${arrThemes[0]}/$config_file"
style_path="$HOME/.config/waybar/themes${arrThemes[1]}/$style_file"

# Standard files can be overwritten with an existing config-custom or style-custom.css
if [ -f ~/.config/waybar/themes${arrThemes[0]}/config-custom ]; then
    config_file="config-custom"
fi
if [ -f ~/.config/waybar/themes${arrThemes[1]}/style-custom.css ]; then
    style_file="style-custom.css"
fi
config_path="$HOME/.config/waybar/themes${arrThemes[0]}/$config_file"
style_path="$HOME/.config/waybar/themes${arrThemes[1]}/$style_file"

# Check if waybar-disabled file exists
if [ ! -f $HOME/.config/siverteh/core/settings/waybar-disabled ]; then
    setsid -f env -u LD_PRELOAD /usr/bin/waybar \
        -c "$config_path" \
        -s "$style_path" \
        >/tmp/waybar.log 2>&1 </dev/null &
else
    echo ":: Waybar disabled"
fi

# Explicitly release the lock (optional) -> flock releases on exit
flock -u 200
exec 200>&-
