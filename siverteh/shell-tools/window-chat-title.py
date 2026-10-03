#!/usr/bin/env python3
"""Resolve only a running terminal's named chat; never read auth/conversation bodies."""
import json,os,re,sys,unicodedata
from pathlib import Path

def resolve(pid):
    todo=[pid];seen=set()
    while todo and len(seen)<64:
        current=todo.pop()
        if current in seen:continue
        seen.add(current);proc=Path('/proc')/str(current)
        try:
            if proc.stat().st_uid!=os.getuid():continue
            todo.extend(map(int,(proc/'task'/str(current)/'children').read_text().split()))
            args=(proc/'cmdline').read_bytes().decode(errors='replace').split('\0')
            if 'resume' not in args:continue
            thread=args[args.index('resume')+1]
            if not re.fullmatch(r'[0-9a-f-]{36}',thread):continue
            file=Path.home()/'.local/state/siverteh-ai/chat-titles'/f'{thread}.json'
            data=json.loads(file.read_text())
            return ''.join(c for c in str(data['title']) if not unicodedata.category(c).startswith('C'))[:100]
        except (OSError,ValueError,IndexError,KeyError):continue
    return ''

if __name__=='__main__':print(json.dumps({'title':resolve(int(sys.argv[1]))}))
