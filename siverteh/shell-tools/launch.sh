#!/usr/bin/env bash
set -euo pipefail
shell_runtime="$HOME/.local/share/siverteh-ai/shell-runtime"
export LD_LIBRARY_PATH="$shell_runtime/usr/lib:${LD_LIBRARY_PATH:-}"
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_PLUGIN_PATH="$shell_runtime/usr/lib/qt6/plugins:${QT_PLUGIN_PATH:-}"
export QML_IMPORT_PATH="$shell_runtime/usr/lib/qt6/qml:${QML_IMPORT_PATH:-}"
export QML2_IMPORT_PATH="$QML_IMPORT_PATH"
export PATH="$shell_runtime/usr/bin:${PATH:-}"
export PATH="$HOME/.local/share/siverteh-ai/siverteh-shell/bin:$shell_runtime/venv/bin:$PATH"
export QT_LOGGING_RULES='*.debug=false'
qs="$shell_runtime/usr/bin/quickshell"
if [[ ! -x "$qs" ]]; then qs="$HOME/.local/share/siverteh-ai/rice-runtime/usr/bin/quickshell"; fi
exec "$qs" "$@"
