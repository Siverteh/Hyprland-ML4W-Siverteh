#!/usr/bin/env bash
set -euo pipefail
shell_runtime="$HOME/.local/share/siverteh-ai/shell-runtime"
# Desktop binaries and Qt plugins are owned and updated together by pacman.
unset LD_LIBRARY_PATH QT_PLUGIN_PATH QML_IMPORT_PATH QML2_IMPORT_PATH
export PATH="$HOME/.local/share/siverteh-ai/siverteh-shell/bin:$shell_runtime/venv/bin:/usr/local/bin:/usr/bin:/bin"
export QT_LOGGING_RULES='*.debug=false'
if [[ ! -x /usr/bin/quickshell ]]; then
    echo 'Install quickshell with pacman before starting Siverteh OS.' >&2
    exit 1
fi
exec /usr/bin/quickshell "$@"
