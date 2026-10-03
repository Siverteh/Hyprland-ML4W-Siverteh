#!/usr/bin/env python3
"""Deploy only the knowledge browser and launcher branding; preserve desktop/auth state."""
import ast,datetime,os,shutil,signal,subprocess,time,urllib.request,json,tempfile,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parent
HOME=Path.home();DEST=HOME/'.local/share/siverteh-ai/observatory'
def function_text(text,name):
    node=next(n for n in ast.parse(text).body if isinstance(n,ast.FunctionDef) and n.name==name)
    return node,'\n'.join(text.splitlines()[node.lineno-1:node.end_lineno])
def main():
    ast.parse((ROOT/'control.py').read_text())
    subprocess.run(['siverteh-ai-tools','node','--check',str(ROOT/'web/app.js')],check=True)
    runtime=(HOME/'.local/bin/siverteh-ai').resolve();before=runtime.read_text();source=(ROOT.parents[1]/'bin/siverteh-ai').read_text();node,current=function_text(before,'select');_,desired=function_text(source,'select')
    if current!=desired and hashlib.sha256(current.encode()).hexdigest() not in ('085569af25da439c1e194f7f9c64c570590f7d22d852935274a3e1e64587a6b2','7c9076561f38cbdfe27b89c5db391002d4727481932a87f85f8c3e4b6c08496b'):raise RuntimeError('Launcher changed since this task; preserve its changes before deploying.')
    backup=HOME/'.local/state/siverteh-observatory/backups'/('brain-'+datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ'));backup.mkdir(parents=True,mode=0o700)
    shutil.copytree(DEST/'web',backup/'web');shutil.copy2(DEST/'control.py',backup/'control.py');shutil.copy2(runtime,backup/'siverteh-ai')
    subprocess.run(['systemctl','--user','stop','siverteh-observatory-brain.service'],check=True)
    # Some earlier launches preceded the persistent service. Match only this app's paths/profile.
    control=str(DEST/'control.py').encode();profile=('--user-data-dir='+str(HOME/'.local/share/siverteh-ai/observatory-browser')).encode()
    for p in Path('/proc').iterdir():
        if not p.name.isdigit() or int(p.name)==os.getpid():continue
        try:
            if p.stat().st_uid!=os.getuid():continue
            args=(p/'cmdline').read_bytes().split(b'\0')
        except OSError:continue
        if (control in args and b'serve' in args) or (profile in args and not any(a.startswith(b'--type=') for a in args)):
            try:os.kill(int(p.name),signal.SIGTERM)
            except ProcessLookupError:pass
    time.sleep(.5)
    for name in ('index.html','style.css','app.js'):shutil.copy2(ROOT/'web'/name,DEST/'web'/name)
    shutil.copy2(ROOT/'control.py',DEST/'control.py')
    if current!=desired:
        lines=before.splitlines(keepends=True);lines[node.lineno-1:node.end_lineno]=[desired+'\n'];updated=''.join(lines);ast.parse(updated)
        fd,tmp=tempfile.mkstemp(dir=runtime.parent,prefix='.brain-brand-')
        with os.fdopen(fd,'w') as f:f.write(updated)
        os.chmod(tmp,runtime.stat().st_mode&0o777);os.replace(tmp,runtime)
    subprocess.run(['systemctl','--user','start','siverteh-observatory-brain.service'],check=True)
    for _ in range(50):
        try:
            with urllib.request.urlopen('http://127.0.0.1:17843/api/health',timeout=1) as r:
                if json.load(r).get('ready'):print('Brain deployed. Backup: '+str(backup));return
        except OSError:pass
        time.sleep(.2)
    raise RuntimeError('Brain did not become ready; deployment backup: '+str(backup))
if __name__=='__main__':main()
