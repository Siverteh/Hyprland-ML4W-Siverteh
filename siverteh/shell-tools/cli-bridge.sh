#!/usr/bin/env bash
set -euo pipefail
cli="$HOME/.local/share/siverteh-ai/shell-runtime/venv/bin/siverteh_shell"
bridge="$HOME/.local/share/siverteh-ai/siverteh-shell/tools/classic-state.py"
if [[ "${1:-}" == update ]]; then exec "$HOME/.local/bin/siverteh-os-shell" updates; fi
if [[ "${1:-}" == scheme && "${2:-}" == print ]]; then
    "$cli" wallpaper -p "${3:-}" | python3 -c 'import json,sys; d=json.load(sys.stdin); c=d.get("colours",d.get("colors",{})); print("\n".join(k+" "+v.lstrip("#") for k,v in c.items()))'
    exit
fi
mkdir -p "$HOME/.local/state/siverteh_shell"
exec 9>"$HOME/.local/state/siverteh_shell/palette-commit.lock"
flock 9
"$cli" "$@"
if [[ "${1:-}" == scheme ]]; then python3 "$bridge"; fi
if [[ "${1:-}" == wallpaper && "${2:-}" == -f ]]; then python3 "$bridge" "${3:-}"; fi
