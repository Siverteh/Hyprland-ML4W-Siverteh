#!/usr/bin/env bash
if [ -f /usr/bin/waypaper ]; then
    echo ":: Launching waybar in /usr/bin"
    GTK_THEME=Breeze-Dark waypaper $1 &
elif [ -f $HOME/.local/bin/waypaper ]; then
    echo ":: Launching waybar in $HOME/.local/bin"
    GTK_THEME=Breeze-Dark $HOME/.local/bin/waypaper $1 &
else
    echo ":: waypaper not found"
fi
