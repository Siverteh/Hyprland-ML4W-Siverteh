#!/usr/bin/env bash

if command -v gnome-calculator >/dev/null 2>&1; then
    exec gnome-calculator
fi

if command -v qalculate-gtk >/dev/null 2>&1; then
    exec qalculate-gtk
fi

exec google-chrome-stable --app="https://www.google.com/search?q=calculator"
