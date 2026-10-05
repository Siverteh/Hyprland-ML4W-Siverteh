#!/usr/bin/env bash
set -euo pipefail
case "${1:-brain}" in
 brain|capture|tasks|notes|resume|new) exec python3 "$HOME/.local/share/siverteh-ai/observatory/control.py" action "$1" ;;
 *) printf 'Usage: siverteh-observatory [brain|capture|tasks|notes|resume|new]\n' >&2; exit 2 ;;
esac
