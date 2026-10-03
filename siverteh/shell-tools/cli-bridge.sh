#!/usr/bin/env bash
set -euo pipefail
cli="$HOME/.local/share/siverteh-ai/shell-runtime/venv/bin/siverteh_shell"
bridge="$HOME/.local/share/siverteh-ai/siverteh-shell/tools/classic-state.py"
if [[ "${1:-}" == update ]]; then exec "$HOME/.local/bin/siverteh-os-shell" updates; fi
mkdir -p "$HOME/.local/state/siverteh_shell"
exec 9>"$HOME/.local/state/siverteh_shell/palette-commit.lock"
flock 9
"$cli" "$@"
if [[ "${1:-}" == scheme ]]; then python3 "$bridge"; fi
if [[ "${1:-}" == wallpaper && "${2:-}" == -f ]]; then python3 "$bridge" "${3:-}"; fi
