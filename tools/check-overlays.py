#!/usr/bin/env python3
"""Opt-in target-host check of the launcher routes and real Wayland Escape events."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--keyboard', default=shutil.which('wtype'), help='wtype executable; may be an isolated temporary build')
    args = parser.parse_args()
    if not args.keyboard:
        raise SystemExit('Provide wtype to send Wayland key events; headless Qt tests cannot check compositor focus.')
    home = Path.home()
    ipc = [str(home / '.local/share/siverteh-ai/siverteh-shell/bin/qs'), '-c', 'siverteh_shell', 'ipc', 'call', 'siverteh']

    def state():
        return json.loads(subprocess.check_output([*ipc, 'state'], text=True))

    initial = state()
    if any(initial.get(k) for k in ('launcher', 'session', 'left', 'dashboard', 'osd')):
        raise SystemExit('Close shell panels first; this check must not disturb an existing view or draft.')
    try:
        for action, mode in (('launcher', 'apps'), ('wallpaper', 'wallpaper')):
            subprocess.run([str(home / '.local/bin/siverteh-os-shell'), action], check=True)
            time.sleep(.6)
            opened = state()
            if not opened['launcher'] or opened['launcherMode'] != mode:
                raise RuntimeError(action + ' closed during focus acquisition')
            subprocess.run([args.keyboard, '-k', 'Escape'], check=True)
            time.sleep(.3)
            if state()['launcher']:
                raise RuntimeError(action + ' did not receive Escape before a mouse click')
            print(action + ': opened, remained open, and received Escape')
    finally:
        subprocess.run([*ipc, 'close'], check=True)


if __name__ == '__main__':
    main()
