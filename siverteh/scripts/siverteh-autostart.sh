#!/usr/bin/env bash

# Start Siverteh OS Welcome App
if [ ! -f $HOME/.cache/siverteh-welcome-autostart ]; then
    echo ":: Starting Siverteh OS Welcome App ..."
    sleep 2
    "$HOME/.config/hypr/scripts/siverteh-hub.sh"
else
    echo ":: Autostart of Siverteh OS Welcome App disabled."
fi
