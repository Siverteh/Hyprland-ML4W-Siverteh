#!/bin/bash
# Clean up lock files and cache that can prevent apps from starting

# Chrome cleanup
rm -f ~/.config/google-chrome/Singleton* 2>/dev/null
rm -f ~/.config/google-chrome/*/Singleton* 2>/dev/null
rm -f ~/.config/google-chrome/*/lockfile 2>/dev/null

# Spotify cleanup
rm -f ~/.config/spotify/Users/*/lock 2>/dev/null
rm -f /tmp/spotify-*.lock 2>/dev/null

# Clear GPU cache (can cause Chrome issues)
rm -rf ~/.config/google-chrome/*/GPUCache/* 2>/dev/null

echo "Cleanup complete"
