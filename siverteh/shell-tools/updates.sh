#!/usr/bin/env bash
set -euo pipefail
if command -v gum >/dev/null; then
    palette="$HOME/.config/siverteh-shell/colors"
    accent=$(cat "$palette/primary" 2>/dev/null || printf '#808080')
    text=$(cat "$palette/onprimary" 2>/dev/null || printf '#ffffff')
    gum confirm --selected.background="$accent" --selected.foreground="$text" 'Update system packages now?' || exit 0
else
    read -r -p 'Update system packages now? [y/N] ' answer
    [[ "$answer" == [yY] ]] || exit 0
fi
if command -v paru >/dev/null; then paru -Syu
elif command -v yay >/dev/null; then yay -Syu
else sudo pacman -Syu; fi
if command -v flatpak >/dev/null; then flatpak update; fi
python3 "$HOME/.local/share/siverteh-ai/siverteh-shell/tools/updates.py" --refresh
read -r -p 'Update complete. Press Enter to close.'
