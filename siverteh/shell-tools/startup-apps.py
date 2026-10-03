#!/usr/bin/env python3
"""Idempotent six-workspace session profile; ordinary terminals stay unrestricted."""
import fcntl,json,os,subprocess,time
from pathlib import Path
HOME=Path.home()
def plan(clients):
 classes={c['class'].casefold() for c in clients}
 return [
 ('Browser',1,['google-chrome-stable'],bool(classes&{'google-chrome','chromium','firefox'})),
 ('Siverteh AI',2,[str(HOME/'.local/bin/siverteh-os-shell'),'tasks'],'siverteh-ai-dashboard' in classes),
 ('Discord',3,['discord'],bool(classes&{'discord'})),
 ('Spotify',4,['spotify'],'spotify' in classes),
 ('Mail',5,['bash',str(HOME/'.config/siverteh/core/settings/email.sh')],bool(classes&{'evolution','org.gnome.evolution','thunderbird','chrome-mail.google.com__-default'})),
 ('Brain',6,['systemctl','--user','start','siverteh-observatory-brain.service'],any(c['class']=='siverteh-brain' or c.get('title')=='Siverteh Brain' for c in clients))]
def main():
 lock=Path(os.environ.get('XDG_RUNTIME_DIR',f'/run/user/{os.getuid()}'))/'siverteh-startup-apps.lock'
 with lock.open('w') as guard:
  try:fcntl.flock(guard,fcntl.LOCK_EX|fcntl.LOCK_NB)
  except BlockingIOError:return
  clients=json.loads(subprocess.check_output(['hyprctl','clients','-j']))
  for label,workspace,argv,exists in plan(clients):
   if exists:continue
   subprocess.run(['hyprctl','eval',f'hl.dispatch(hl.dsp.focus({{workspace={workspace},on_current_monitor=true}}))'],stdout=subprocess.DEVNULL,check=True)
   subprocess.Popen(['systemd-run','--user','--scope','--collect','--quiet',*argv],start_new_session=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
   time.sleep(.35)
  subprocess.run(['hyprctl','eval','hl.dispatch(hl.dsp.focus({workspace=1,on_current_monitor=true}))'],check=True,stdout=subprocess.DEVNULL)
if __name__=='__main__':main()
