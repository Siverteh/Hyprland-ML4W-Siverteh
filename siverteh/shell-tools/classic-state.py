#!/usr/bin/env python3
"""Bridge maintained CLI palette output to the reference-era QML state files."""
import json,sys
from pathlib import Path
state=Path.home()/'.local/state/siverteh_shell';(state/'scheme').mkdir(parents=True,exist_ok=True)
try:
 d=json.loads((state/'scheme.json').read_text());colors=d['colours']
 (state/'scheme/current.txt').write_text('\n'.join(k+' '+v.lstrip('#') for k,v in colors.items())+'\n')
 (state/'scheme/current-mode.txt').write_text(d['mode'])
except (OSError,ValueError,KeyError):pass
if len(sys.argv)>1:
 (state/'wallpaper').mkdir(exist_ok=True);(state/'wallpaper/last.txt').write_text(str(Path(sys.argv[1]).expanduser().resolve()))
