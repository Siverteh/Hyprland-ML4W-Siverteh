#!/bin/bash
current=$(hyprctl activeworkspace -j | jq -r '.id')

if [ "$1" == "next" ]; then
    # Go to next workspace number
    if [ $current -eq 10 ]; then
        next=1
    else
        next=$((current + 1))
    fi
else
    # Go to previous workspace number
    if [ $current -eq 1 ]; then
        next=10
    else
        next=$((current - 1))
    fi
fi

hyprctl dispatch workspace $next
