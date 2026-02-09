#!/bin/bash
# Dotfiles installer with symlinks

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  ML4W Hyprland Dotfiles Installer${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo "Dotfiles: $DOTFILES_DIR"
echo "Config: $CONFIG_DIR"
echo ""

create_symlink() {
    local source="$1"
    local target="$2"
    
    mkdir -p "$(dirname "$target")"
    
    # Backup existing files/dirs (not symlinks)
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        backup="${target}.backup-$(date +%Y%m%d-%H%M%S)"
        echo -e "${YELLOW}  Backing up: $target -> $backup${NC}"
        mv "$target" "$backup"
    fi
    
    # Remove existing symlink
    if [ -L "$target" ]; then
        rm "$target"
    fi
    
    # Create new symlink
    ln -s "$source" "$target"
    echo -e "${GREEN}  ✓ Linked: $target -> $source${NC}"
}

echo -e "${YELLOW}Installing symlinks...${NC}"
echo ""

# Hyprland
if [ -d "$DOTFILES_DIR/hypr" ]; then
    echo "→ Hyprland configuration"
    create_symlink "$DOTFILES_DIR/hypr" "$CONFIG_DIR/hypr"
fi

# Kanshi
if [ -d "$DOTFILES_DIR/kanshi" ]; then
    echo "→ Kanshi configuration"
    create_symlink "$DOTFILES_DIR/kanshi" "$CONFIG_DIR/kanshi"
fi

# Waybar
if [ -d "$DOTFILES_DIR/waybar" ]; then
    echo "→ Waybar configuration"
    create_symlink "$DOTFILES_DIR/waybar" "$CONFIG_DIR/waybar"
fi

# GTK
if [ -d "$DOTFILES_DIR/gtk-3.0" ]; then
    echo "→ GTK-3.0 configuration"
    create_symlink "$DOTFILES_DIR/gtk-3.0" "$CONFIG_DIR/gtk-3.0"
fi

if [ -d "$DOTFILES_DIR/gtk-4.0" ]; then
    echo "→ GTK-4.0 configuration"
    create_symlink "$DOTFILES_DIR/gtk-4.0" "$CONFIG_DIR/gtk-4.0"
fi

# SwayNC
if [ -d "$DOTFILES_DIR/swaync" ]; then
    echo "→ SwayNC configuration"
    create_symlink "$DOTFILES_DIR/swaync" "$CONFIG_DIR/swaync"
fi

# Rofi
if [ -d "$DOTFILES_DIR/rofi" ]; then
    echo "→ Rofi configuration"
    create_symlink "$DOTFILES_DIR/rofi" "$CONFIG_DIR/rofi"
fi

# Kitty
if [ -d "$DOTFILES_DIR/kitty" ]; then
    echo "→ Kitty configuration"
    create_symlink "$DOTFILES_DIR/kitty" "$CONFIG_DIR/kitty"
fi

# nwg-dock-hyprland
if [ -d "$DOTFILES_DIR/nwg-dock-hyprland" ]; then
    echo "→ nwg-dock-hyprland configuration"
    create_symlink "$DOTFILES_DIR/nwg-dock-hyprland" "$CONFIG_DIR/nwg-dock-hyprland"
fi

# ML4W core (REQUIRED)
if [ -d "$DOTFILES_DIR/ml4w" ]; then
    echo "→ ML4W core configuration"
    create_symlink "$DOTFILES_DIR/ml4w" "$CONFIG_DIR/ml4w"
fi

# Wlogout (power menu)
if [ -d "$DOTFILES_DIR/wlogout" ]; then
    echo "→ Wlogout configuration"
    create_symlink "$DOTFILES_DIR/wlogout" "$CONFIG_DIR/wlogout"
fi

# Waypaper (wallpaper selector)
if [ -d "$DOTFILES_DIR/waypaper" ]; then
    echo "→ Waypaper configuration"
    create_symlink "$DOTFILES_DIR/waypaper" "$CONFIG_DIR/waypaper"
fi

# Matugen (color scheme generator - IMPORTANT)
if [ -d "$DOTFILES_DIR/matugen" ]; then
    echo "→ Matugen configuration"
    create_symlink "$DOTFILES_DIR/matugen" "$CONFIG_DIR/matugen"
fi

# Fastfetch (system info)
if [ -d "$DOTFILES_DIR/fastfetch" ]; then
    echo "→ Fastfetch configuration"
    create_symlink "$DOTFILES_DIR/fastfetch" "$CONFIG_DIR/fastfetch"
fi\

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo "Your configs are now symlinked to $DOTFILES_DIR"
echo ""
echo "Next steps:"
echo "  1. Reload Hyprland: SUPER+SHIFT+R"
echo "  2. Test everything works"
echo "  3. Commit changes: cd $DOTFILES_DIR && git add . && git commit -m 'Setup dotfiles'"
echo ""
