#!/bin/bash
# Emoji Picker - copy then auto-paste

# Copy emoji to clipboard
rofimoji --action copy

# Small delay for focus to return
sleep 0.1

# Auto-paste using wtype
wtype -M ctrl v -m ctrl
