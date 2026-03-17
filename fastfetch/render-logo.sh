#!/usr/bin/env bash

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/fastfetch"
cache_file="$cache_dir/siverteh-logo.txt"

mkdir -p "$cache_dir"
"$HOME/.config/fastfetch/logo.sh" >"$cache_file"
