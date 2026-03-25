#!/usr/bin/env bash
#  _      __     ____                      
# | | /| / /__ _/ / /__  ___ ____  ___ ____
# | |/ |/ / _ `/ / / _ \/ _ `/ _ \/ -_) __/
# |__/|__/\_,_/_/_/ .__/\_,_/ .__/\__/_/   
#                /_/       /_/             

# Source library.sh
source $HOME/.config/ml4w/library.sh

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

# -----------------------------------------------------
# Check to use wallpaper cache
# -----------------------------------------------------

if [ -f ~/.config/ml4w/settings/wallpaper_cache ]; then
    use_cache=1
    _writeLog "Using Wallpaper Cache"
else
    use_cache=0
    _writeLog "Wallpaper Cache disabled"
fi

# -----------------------------------------------------
# Create cache folder
# -----------------------------------------------------
ml4w_cache_folder="$HOME/.cache/ml4w/hyprland-dotfiles"

if [ ! -d $ml4w_cache_folder ]; then
    mkdir -p $ml4w_cache_folder
fi

# -----------------------------------------------------
# Set defaults
# -----------------------------------------------------

force_generate=0

# Cache for generated wallpapers with effects
generatedversions="$ml4w_cache_folder/wallpaper-generated"
if [ ! -d $generatedversions ]; then
    mkdir -p $generatedversions
fi

cachefile="$ml4w_cache_folder/current_wallpaper"
blurredwallpaper="$ml4w_cache_folder/blurred_wallpaper.png"
squarewallpaper="$ml4w_cache_folder/square_wallpaper.png"
rasifile="$ml4w_cache_folder/current_wallpaper.rasi"
blurfile="$HOME/.config/ml4w/settings/blur.sh"
defaultwallpaper="$HOME/.config/ml4w/wallpapers/default.jpg"
wallpapereffect="$HOME/.config/ml4w/settings/wallpaper-effect.sh"
blur="50x30"
blur=$(cat $blurfile)

# -----------------------------------------------------
# Get selected wallpaper
# -----------------------------------------------------

if [ -z "$1" ]; then
    if [ -f "$cachefile" ]; then
        wallpaper=$(cat "$cachefile")
        # Remove escaped backslashes from the path (convert "\ " to " ")
        wallpaper=$(echo "$wallpaper" | sed 's/\\ / /g')
    else
        wallpaper="$defaultwallpaper"
    fi
else
    wallpaper="$1"
    # Remove escaped backslashes from the path (convert "\ " to " ")
    wallpaper=$(echo "$wallpaper" | sed 's/\\ / /g')
fi
used_wallpaper="$wallpaper"
_writeLog "Setting wallpaper with source image $wallpaper"
tmpwallpaper=$wallpaper

# -----------------------------------------------------
# Copy path of current wallpaper to cache file
# -----------------------------------------------------

if [ ! -f $cachefile ]; then
    touch $cachefile
fi
echo "$wallpaper" > $cachefile
_writeLog "Path of current wallpaper copied to $cachefile"

# -----------------------------------------------------
# Get wallpaper filename
# -----------------------------------------------------

wallpaperfilename=$(basename "$wallpaper")
_writeLog "Wallpaper Filename: $wallpaperfilename"

# -----------------------------------------------------
# Wallpaper Effects
# -----------------------------------------------------

if [ -f "$wallpapereffect" ]; then
    effect=$(cat "$wallpapereffect")
    if [ ! "$effect" == "off" ]; then
        used_wallpaper="$generatedversions/$effect-$wallpaperfilename"
        if [ -f "$generatedversions/$effect-$wallpaperfilename" ] && [ "$force_generate" == "0" ] && [ "$use_cache" == "1" ]; then
            _writeLog "Use cached wallpaper $effect-$wallpaperfilename"
        else
            _writeLog "Generate new cached wallpaper $effect-$wallpaperfilename with effect $effect"
            notify-send --replace-id=1 "Using wallpaper effect $effect..." "with image $wallpaperfilename" -h int:value:33
            source $HOME/.config/hypr/effects/wallpaper/$effect
        fi
        _writeLog "Loading wallpaper $generatedversions/$effect-$wallpaperfilename with effect $effect"
        _writeLog "Prepared wallpaper $used_wallpaper"
    else
        _writeLog "Wallpaper effect is set to off"
    fi
else
    effect="off"
fi

# -----------------------------------------------------
# Apply wallpaper with the active engine
# -----------------------------------------------------

if [ "${ML4W_SKIP_ENGINE_APPLY:-0}" = "1" ] && [ "$used_wallpaper" = "$wallpaper" ]; then
    _writeLog "Skipping engine apply because Waypaper already set the wallpaper"
else
    _writeLog "Applying wallpaper with active engine: $used_wallpaper"
    "$HOME/.config/hypr/scripts/apply-wallpaper-engine.sh" "$used_wallpaper"
fi

# -----------------------------------------------------
# Detect Theme
# -----------------------------------------------------

SETTINGS_FILE="$HOME/.config/gtk-3.0/settings.ini"
THEME_PREF=$(grep -E '^gtk-application-prefer-dark-theme=' "$SETTINGS_FILE" | awk -F'=' '{print $2}')

# -----------------------------------------------------
# Execute matugen
# -----------------------------------------------------

_writeLog "Execute matugen with $used_wallpaper"
if [ "$THEME_PREF" -eq 1 ]; then
    $HOME/.local/bin/matugen image "$used_wallpaper" -m "dark"
else
    $HOME/.local/bin/matugen image "$used_wallpaper" -m "light"
fi

# -----------------------------------------------------
# Reload Waybar
# -----------------------------------------------------

sleep 1
"$HOME/.config/fastfetch/render-logo.sh"
$HOME/.config/hypr/scripts/gtk.sh
restart_nautilus_if_running

$HOME/.config/waybar/launch.sh

# -----------------------------------------------------
# Update Pywalfox
# -----------------------------------------------------

if type pywalfox >/dev/null 2>&1; then
    pywalfox update
fi

# -----------------------------------------------------
# Update SwayNC
# -----------------------------------------------------

sleep 0.1
swaync-client -rs

# -----------------------------------------------------
# Created blurred wallpaper
# -----------------------------------------------------

if [ -f "$generatedversions/blur-$blur-$effect-$wallpaperfilename.png" ] && [ "$force_generate" == "0" ] && [ "$use_cache" == "1" ]; then
    _writeLog "Use cached wallpaper blur-$blur-$effect-$wallpaperfilename"
else
    _writeLog "Generate new cached wallpaper blur-$blur-$effect-$wallpaperfilename with blur $blur"
    # notify-send --replace-id=1 "Generate new blurred version" "with blur $blur" -h int:value:66
    magick "$used_wallpaper" -resize 75% "$blurredwallpaper"
    _writeLog "Resized to 75%"
    if [ ! "$blur" == "0x0" ]; then
        magick "$blurredwallpaper" -blur $blur "$blurredwallpaper"
        cp "$blurredwallpaper" "$generatedversions/blur-$blur-$effect-$wallpaperfilename.png"
        _writeLog "Blurred"
    fi
fi
cp "$generatedversions/blur-$blur-$effect-$wallpaperfilename.png" "$blurredwallpaper"

# -----------------------------------------------------
# Create rasi file
# -----------------------------------------------------

if [ ! -f $rasifile ]; then
    touch $rasifile
fi
echo "* { current-image: url(\"$blurredwallpaper\", height); }" >"$rasifile"

# -----------------------------------------------------
# Created square wallpaper
# -----------------------------------------------------

_writeLog "Generate new cached wallpaper square-$wallpaperfilename"
magick "$tmpwallpaper" -gravity Center -extent 1:1 "$squarewallpaper"
cp "$squarewallpaper" "$generatedversions/square-$wallpaperfilename.png"
