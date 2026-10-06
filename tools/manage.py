#!/usr/bin/env python3
"""Explicit component deployment for an existing supported Siverteh OS host."""
import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true', help='apply the reviewed plan')
    parser.add_argument('--migrate-owned', action='store_true', help='convert old repository-linked config into private installed copies')
    parser.add_argument('--component', action='append', choices=['configs', 'shell', 'brain', 'ai'], help='repeat to select components; default configs, shell, brain')
    args = parser.parse_args()
    components = args.component or ['configs', 'shell', 'brain']
    commands = {
        'configs': ['python3', str(ROOT / 'tools/configure.py'), *(['--migrate-owned'] if args.migrate_owned else []), '--apply'],
        'shell': ['python3', str(ROOT / 'siverteh/shell-tools/install.py'), *(['--code-only'] if (Path.home()/'.local/share/siverteh-ai/siverteh-shell/bin/qs').exists() else [])],
        'brain': ['python3', str(ROOT / 'brain/install.py')],
        'ai': ['python3', str(ROOT / 'ai/install.py')],
    }
    for name in components:
        print(name + ': ' + ' '.join(commands[name]), flush=True)
    if not args.apply:
        print('Plan only. Read docs/maintenance.md and tools/check.py output before applying.')
        return
    if 'ai' in components:raise RuntimeError('AI workflow deployment is separate; use ai/install.py to preserve account setup')
    subprocess.run([sys.executable,str(ROOT/'tools/releases.py'),'deploy',str(ROOT),*(['--migrate-owned'] if args.migrate_owned else []),*[part for name in components for part in ('--component',name)]],check=True)


if __name__ == '__main__':
    main()
