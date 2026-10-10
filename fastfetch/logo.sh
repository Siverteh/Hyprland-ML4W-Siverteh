#!/usr/bin/env bash

# Use Kitty palette indexes so already-open terminals can follow Nacre color
# updates when Kitty reloads its palette.
primary_ansi=$'\033[38;5;4m'
secondary_ansi=$'\033[38;5;14m'
reset_ansi=$'\033[0m'

cat <<EOF


${primary_ansi}██████████████╗   ${secondary_ansi}██╗     ██╗
${primary_ansi}██╔══════════██╗  ${secondary_ansi}██║     ██║
${primary_ansi}██║          ╚═╝  ${secondary_ansi}██║     ██║
${primary_ansi}██║               ${secondary_ansi}██║     ██║
${primary_ansi}██║               ${secondary_ansi}██║     ██║
${primary_ansi}██████████████╗   ${secondary_ansi}██████████║
${primary_ansi}╚═══════════██║   ${secondary_ansi}██╔═════██║
${primary_ansi}            ██║   ${secondary_ansi}██║     ██║
${primary_ansi}            ██║   ${secondary_ansi}██║     ██║
${primary_ansi}            ██║   ${secondary_ansi}██║     ██║
${primary_ansi}██████████████║   ${secondary_ansi}██║     ██║
${primary_ansi}╚═════════════╝   ${secondary_ansi}╚═╝     ╚═╝${reset_ansi}


EOF
