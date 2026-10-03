#!/usr/bin/env bash
set -euo pipefail
rice_runtime="$HOME/.local/share/siverteh-ai/shell-runtime"
export LD_LIBRARY_PATH="$rice_runtime/usr/lib:$HOME/.local/share/siverteh-ai/rice-runtime/usr/lib:${LD_LIBRARY_PATH:-}"
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_PLUGIN_PATH="$rice_runtime/usr/lib/qt6/plugins:${QT_PLUGIN_PATH:-}"
export QML_IMPORT_PATH="$rice_runtime/usr/lib/qt6/qml:${QML_IMPORT_PATH:-}"
export QML2_IMPORT_PATH="$QML_IMPORT_PATH"
export SIVERTEH_LIB_DIR="$rice_runtime/usr/lib/siverteh_shell"
export PATH="$rice_runtime/usr/bin:${PATH:-}"
export PATH="$HOME/.local/share/siverteh-ai/siverteh-shell/bin:$rice_runtime/venv/bin:$PATH"
export QT_LOGGING_RULES='*.debug=false'
qs="$rice_runtime/usr/bin/quickshell"
if [[ ! -x "$qs" ]]; then qs="$HOME/.local/share/siverteh-ai/rice-runtime/usr/bin/quickshell"; fi
exec "$qs" "$@"
