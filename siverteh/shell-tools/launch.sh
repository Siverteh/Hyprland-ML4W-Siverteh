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
version_info=$(/usr/bin/quickshell --version -vv 2>&1)
if [[ "$version_info" =~ Qt:\ ([0-9.]+)\ \(built\ against\ ([0-9.]+)\) ]]; then
    if [[ "${BASH_REMATCH[1]}" != "${BASH_REMATCH[2]}" ]]; then
        echo "Quickshell Qt mismatch: system ${BASH_REMATCH[1]}, build ${BASH_REMATCH[2]}. Install a matching package or rebuild it; see docs/features/runtime.md." >&2
        exit 1
    fi
else
    echo 'Unable to verify the Quickshell Qt build; refusing an unchecked desktop runtime.' >&2
    exit 1
fi
exec /usr/bin/quickshell "$@"
