#!/bin/bash
clear
aur_helper="$(cat ~/.config/siverteh/core/settings/aur.sh)"
figlet -f smslant "Cleanup"
echo
$aur_helper -Scc
