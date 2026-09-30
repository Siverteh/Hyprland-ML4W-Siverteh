#!/usr/bin/env bash
set -euo pipefail
# The older, still-running CLI owns this home. Never migrate it through this wrapper.
legacy_home=$(realpath -m "$HOME/.codex")
selected_home=$(realpath -m "${CODEX_HOME:-$HOME/.local/share/siverteh-ai/codex-home}")
if [[ "$selected_home" == "$legacy_home" ]]; then
    selected_home="$HOME/.local/share/siverteh-ai/codex-home"
fi
export CODEX_HOME="$selected_home"
exec "$HOME/.local/share/siverteh-ai/codex/packages/0.159.2/bin/codex" "$@"
