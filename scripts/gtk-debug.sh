#!/bin/bash
echo "=== GTK DEBUG START ===" >> /tmp/gtk-debug.log
date >> /tmp/gtk-debug.log
echo "GTK-3 before:" >> /tmp/gtk-debug.log
grep "gtk-application-prefer-dark-theme" ~/.config/gtk-3.0/settings.ini >> /tmp/gtk-debug.log

# Force dark
sed -i 's/gtk-application-prefer-dark-theme=0/gtk-application-prefer-dark-theme=1/' ~/.config/gtk-3.0/settings.ini
sed -i 's/gtk-application-prefer-dark-theme=false/gtk-application-prefer-dark-theme=true/' ~/.config/gtk-4.0/settings.ini

echo "GTK-3 after:" >> /tmp/gtk-debug.log
grep "gtk-application-prefer-dark-theme" ~/.config/gtk-3.0/settings.ini >> /tmp/gtk-debug.log

# Run normal gtk.sh
~/.config/hypr/scripts/gtk.sh

echo "=== GTK DEBUG END ===" >> /tmp/gtk-debug.log

