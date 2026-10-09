#!/usr/bin/env bash
set -euo pipefail
cli="$HOME/.local/share/nacre/palette-runtime/venv/bin/nacre_shell"
bridge="$HOME/.local/share/nacre/shell/tools/classic-state.py"
if [[ "${1:-}" == update ]]; then exec "$HOME/.local/bin/nacre-shell" updates; fi
mkdir -p "$HOME/.local/state/nacre"
exec 9>"$HOME/.local/state/nacre/palette-commit.lock"
flock 9
"$cli" "$@"
if [[ "${1:-}" == scheme ]]; then python3 "$bridge"; fi
if [[ "${1:-}" == wallpaper && "${2:-}" == -f ]]; then python3 "$bridge" "${3:-}"; fi
