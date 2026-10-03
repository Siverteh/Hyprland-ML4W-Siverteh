#!/usr/bin/env bash
set -euo pipefail
rice_runtime="$HOME/.local/share/siverteh-ai/shell-runtime"
export LD_LIBRARY_PATH="$rice_runtime/usr/lib:$HOME/.local/share/siverteh-ai/rice-runtime/usr/lib:${LD_LIBRARY_PATH:-}"
export QML_IMPORT_PATH="$rice_runtime/usr/lib/qt6/qml:${QML_IMPORT_PATH:-}"
export QT_PLUGIN_PATH="$rice_runtime/usr/lib/qt6/plugins:${QT_PLUGIN_PATH:-}"
export SIVERTEH_LIB_DIR="$rice_runtime/usr/lib/siverteh_shell"
export PATH="$HOME/.local/share/siverteh-ai/siverteh-shell/bin:$rice_runtime/venv/bin:$PATH"
case "${1:-start}" in
 start) exec "$HOME/.local/share/siverteh-ai/siverteh-shell/bin/qs" -c siverteh_shell -n ;;
 close) exec "$HOME/.local/share/siverteh-ai/siverteh-shell/bin/qs" -c siverteh_shell ipc call siverteh close ;;
 scheme-mode) exec "$HOME/.local/share/siverteh-ai/siverteh-shell/bin/siverteh_shell" scheme set -m "${2:-light}" ;;
 wallpaper) exec "$HOME/.local/share/siverteh-ai/siverteh-shell/bin/qs" -c siverteh_shell ipc call siverteh launcher ">wallpaper " ;;
 settings) exec "$HOME/.local/share/siverteh-ai/siverteh-shell/bin/qs" -c siverteh_shell ipc call siverteh settings ;;
 left) exec "$HOME/.local/share/siverteh-ai/siverteh-shell/bin/qs" -c siverteh_shell ipc call siverteh left ;;
 palette|overview|keys) exec "$HOME/.local/share/siverteh-ai/siverteh-shell/bin/qs" -c siverteh_shell ipc call siverteh mode "$1" ;;
 clipboard)
  if python3 -c 'import json,pathlib,sys;p=pathlib.Path.home()/".config/siverteh-shell/desktop.json";sys.exit(0 if not p.exists() or json.loads(p.read_text()).get("nativeClipboard",True) else 1)';then
   exec "$HOME/.local/share/siverteh-ai/siverteh-shell/bin/qs" -c siverteh_shell ipc call siverteh mode clipboard
  else cliphist list | rofi -dmenu | cliphist decode | wl-copy;fi ;;
 session) exec "$HOME/.local/share/siverteh-ai/siverteh-shell/bin/qs" -c siverteh_shell ipc call siverteh session ;;
 hide) exec "$HOME/.local/share/siverteh-ai/siverteh-shell/bin/qs" -c siverteh_shell ipc call siverteh hide ;;
 launcher) exec "$HOME/.local/share/siverteh-ai/siverteh-shell/bin/qs" -c siverteh_shell ipc call siverteh launcher "" ;;
 toggle) exec "$HOME/.local/share/siverteh-ai/siverteh-shell/bin/qs" -c siverteh_shell ipc call drawers toggle dashboard ;;
 apps) exec python3 "$HOME/.local/share/siverteh-ai/observatory/control.py" action app-windows "${2:-}" ;;
 brain|capture|tasks|new|resume|updates|wifi|bluetooth) exec python3 "$HOME/.local/share/siverteh-ai/observatory/control.py" action "$1" "${2:-}" ;;
 *) exec "$rice_runtime/venv/bin/siverteh_shell" "$@" ;;
esac
