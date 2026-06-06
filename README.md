# Siverteh OS Hyprland Dotfiles

My personal Hyprland dotfiles built on Siverteh OS.

## Structure
```
dotfiles/
├── hypr/              # Hyprland config
├── kanshi/            # Monitor management
├── waybar/            # Status bar
├── gtk-3.0/           # GTK3 theme
├── gtk-4.0/           # GTK4 theme
├── swaync/            # Notification center
├── rofi/              # App launcher
├── kitty/             # Terminal
├── nwg-dock-hyprland/ # Dock
└── install.sh         # Installer
```

## Installation
```bash
git clone https://github.com/yourusername/siverteh-os.git ~/siverteh-os
cd ~/siverteh-os
./install.sh
```

## Features

- 🪟 Window minimization (SUPER+H)
- 🖥️ Dynamic monitor management with Kanshi
- ⚡ Custom coding environment setup
- 🎨 Material You color scheme
- ⌨️ ASUS Zenbook optimized

## Key Bindings

- `SUPER + H` - Minimize window
- `SUPER + SHIFT + H` - Restore last minimized
- `SUPER + CTRL + H` - Restore all from current workspace
- `SUPER + ALT + C` - Launch coding setup

See [hypr/conf/keybinding.conf](hypr/conf/keybinding.conf) for full list.

## Credits

Built for Siverteh OS.
