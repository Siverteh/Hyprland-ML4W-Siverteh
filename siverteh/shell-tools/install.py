#!/usr/bin/env python3
"""Install or reload Siverteh's native shell source with a reversible cutover."""
import argparse,datetime as dt,hashlib,json,os,shutil,signal,subprocess
from pathlib import Path
HOME=Path.home();ROOT=Path(__file__).resolve().parent;SHELL=ROOT.parent/'shell';DEST=HOME/'.local/share/siverteh-ai/siverteh-shell';STATE=HOME/'.local/state/siverteh-native-shell'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
def stop_other_shells():
 for proc in Path('/proc').iterdir():
  if not proc.name.isdigit():continue
  try:args=(proc/'cmdline').read_bytes().split(b'\0')
  except OSError:continue
  if not args or Path(args[0].decode()).name not in ('qs','quickshell'):continue
  if any(b'/observatory/shell/' in x or b'/os-shell/shell.qml' in x for x in args):
   try:os.kill(int(proc.name),signal.SIGTERM)
   except ProcessLookupError:pass

def deploy(code_only=False):
 runtime=HOME/'.local/share/siverteh-ai/shell-runtime'
 if not (HOME/'.local/share/siverteh-ai/rice-runtime/usr/bin/quickshell').exists() and not (runtime/'usr/bin/quickshell').exists():raise RuntimeError('Provision the user-local dependencies first')
 pending=DEST/'source.next'
 if pending.exists():shutil.rmtree(pending)
 shutil.copytree(SHELL,pending,ignore=shutil.ignore_patterns('build','__pycache__'))
 if (DEST/'source').exists():
  stale=DEST/'source.previous'
  if stale.exists():shutil.rmtree(stale)
  (DEST/'source').rename(stale)
 pending.rename(DEST/'source')
 shutil.copytree(ROOT,DEST/'tools',dirs_exist_ok=True,ignore=shutil.ignore_patterns('__pycache__','tests'))
 # Keep ordinary terminal titles aligned with the desktop labels.
 title=HOME/".config/fish/functions/fish_title.fish"
 title.parent.mkdir(parents=True,exist_ok=True)
 if title.exists() and title.read_bytes()!=(ROOT/"fish_title.fish").read_bytes():
  saved=STATE/"backups"/dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")/"fish_title.fish"
  saved.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(title,saved)
 shutil.copyfile(ROOT/"fish_title.fish",title)
 if code_only:
  for src,dest in [('control.sh',HOME/'.local/bin/siverteh-os-shell'),('cli-bridge.sh',DEST/'bin/siverteh_shell'),('launch.sh',DEST/'bin/qs')]:
   shutil.copyfile(ROOT/src,dest);dest.chmod(0o755)
  subprocess.run(['systemctl','--user','restart','siverteh-os-shell'],check=True);return
 STATE.mkdir(parents=True,exist_ok=True,mode=0o700)
 backup=STATE/'backups'/dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ');backup.mkdir(parents=True,mode=0o700);entries=[]
 def write(path,body=None,link=None,mode=None):
  entry={'target':str(path),'type':'absent'}
  if path.is_symlink():entry.update(type='symlink',link=os.readlink(path))
  elif path.exists():
   saved=backup/path.relative_to(HOME);saved.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,saved);entry.update(type='file',backup=str(saved))
  entries.append(entry);path.parent.mkdir(parents=True,exist_ok=True)
  if link:
   path.unlink(missing_ok=True);path.symlink_to(link)
  else:
   path.write_text(body)
   if mode:path.chmod(mode)
  entry['after_link']=os.readlink(path) if path.is_symlink() else None;entry['after_hash']=digest(path)
 for name in ['shell.json','cli.json']:write(HOME/'.config/siverteh_shell'/name,(ROOT/name).read_text())
 write(HOME/'.config/quickshell/siverteh_shell',link=DEST/'source')
 write(HOME/'.local/bin/siverteh-os-shell',(ROOT/'control.sh').read_text(),mode=0o755)
 write(DEST/'bin/qs',(ROOT/'launch.sh').read_text(),mode=0o755)
 write(DEST/'bin/siverteh_shell',(ROOT/'cli-bridge.sh').read_text(),mode=0o755)
 write(HOME/'.config/siverteh-shell/rofi.rasi',(ROOT/'rofi.rasi').read_text())
 write(HOME/'.config/rofi/config.rasi','@import "'+str(HOME/'.config/siverteh-shell/rofi.rasi')+'"\n')
 write(HOME/'.config/systemd/user/siverteh-os-shell.service',(ROOT/'siverteh-os-shell.service').read_text())
 # Source-owned profile aliases keep the base OS startup integration small.
 for name in ['autostart','keybinding']:
  path=HOME/'.config/hypr/conf'/f'{name}.lua';text=path.read_text()
  text=text.replace('hl.exec_cmd("~/.local/bin/siverteh-observatory start")','hl.exec_cmd("systemctl --user start siverteh-os-shell.service")').replace('~/.local/bin/siverteh-observatory toggle','~/.local/bin/siverteh-os-shell toggle').replace('~/.config/hypr/scripts/launcher.sh','~/.local/bin/siverteh-os-shell launcher')
  if name=='keybinding':
   for old,new in json.loads((ROOT/'shortcut-routes.json').read_text()).items():text=text.replace(old,new)
  if name=='autostart':
   text=text.replace('~/.config/siverteh/core/listeners.sh --startall','~/.config/siverteh/core/listeners.sh --start low-bat-notification')
   text=text.replace('hl.exec_cmd("~/.config/hypr/scripts/gtk.sh")','-- Committed native palette manages GTK settings.')
   text=text.replace('hl.exec_cmd("~/.local/bin/siverteh-observatory restore-wallpaper")','-- Native shell restores its committed wallpaper.')
   text=text.replace('hl.exec_cmd("swaync")','-- Native Siverteh shell owns notification rendering.')
   text=text.replace('hl.exec_cmd("swayosd-server")','-- Native Siverteh shell owns the audio/brightness OSD.')
  if text!=path.read_text():write(path,text)
 # Apply the selected palette last, after any older profile overrides.
 path=HOME/'.config/hypr/hyprland.lua'
 marker='-- Siverteh committed wallpaper palette'
 if marker not in path.read_text():
  write(path,path.read_text()+'\n'+marker+'\nlocal palette_path = os.getenv("HOME") .. "/.config/siverteh-shell/palette.lua"\nlocal palette_file = io.open(palette_path, "r")\nif palette_file then palette_file:close(); dofile(palette_path) end\n')
 # The reference style is code; wallpaper files remain private user assets.
 style=json.loads((ROOT/'reference-style.json').read_text())
 scheme=HOME/'.local/state/siverteh_shell/scheme'
 if not (scheme/'current.txt').exists():write(scheme/'current.txt','\n'.join(k+' '+v.lstrip('#') for k,v in style['colours'].items())+'\n')
 if not (scheme/'current-mode.txt').exists():write(scheme/'current-mode.txt',style['mode'])
 wallpaper=HOME/'Pictures/Wallpapers/Caelestia/reference-landscape.jpg'
 if wallpaper.exists() and not (HOME/'.local/state/siverteh_shell/wallpaper/last.txt').exists():write(HOME/'.local/state/siverteh_shell/wallpaper/last.txt',str(wallpaper))
 if (HOME/'.local/state/siverteh_shell/scheme.json').exists():
  # Palette generation also owns these files; include them in cutover rollback.
  tracked={e['target'] for e in entries}
  outputs=['.config/siverteh-shell/palette.lua','.config/siverteh-shell/qt.conf','.config/kitty/colors-matugen.conf','.config/hypr/colors.lua','.config/hypr/hyprlock.conf','.config/siverteh/core/colors/primary','.config/siverteh/core/colors/secondary','.config/siverteh/core/colors/onsurface','.config/siverteh/core/colors/onprimary','.config/siverteh/core/colors/surface','.config/siverteh/core/colors/surfacecontainer']
  outputs += [f'.config/gtk-{v}/{name}' for v in ['3.0','4.0'] for name in ['gtk.css','settings.ini']]
  outputs += [f'.config/qt{v}ct/qt{v}ct.conf' for v in [5,6]]
  for rel in outputs:
   path=HOME/rel
   if str(path) in tracked:continue
   entry={'target':str(path),'type':'absent','after_link':None}
   if path.is_symlink():entry.update(type='symlink',link=os.readlink(path))
   elif path.is_file():
    saved=backup/rel;saved.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,saved);entry.update(type='file',backup=str(saved))
   entries.append(entry)
  subprocess.run(['python3',str(DEST/'tools/classic-state.py')],check=True)
  for entry in entries:entry['after_hash']=digest(Path(entry['target']))
 (backup/'manifest.json').write_text(json.dumps(entries,indent=2));(STATE/'latest-backup').write_text(str(backup))
 stop_other_shells()
 subprocess.run(['systemctl','--user','disable','--now','siverteh-observatory-wallpaper.timer'],capture_output=True)
 subprocess.run(['systemctl','--user','daemon-reload'],check=True)
 subprocess.run(['systemctl','--user','enable','--now','siverteh-os-shell.service'],check=True,capture_output=True)
 subprocess.run(['hyprctl','reload'],check=True,capture_output=True)
 print('Native shell installed. Backup:',backup)

def restore():
 backup=Path((STATE/'latest-backup').read_text());entries=json.loads((backup/'manifest.json').read_text())
 for e in entries:
  path=Path(e['target'])
  if digest(path)!=e['after_hash'] or (os.readlink(path) if path.is_symlink() else None)!=e['after_link']:raise RuntimeError('Later edit preserved: '+str(path))
 subprocess.run(['systemctl','--user','stop','siverteh-os-shell'],check=True)
 for e in reversed(entries):
  path=Path(e['target']);path.unlink(missing_ok=True)
  if e['type']=='symlink':path.symlink_to(e['link'])
  elif e['type']=='file':shutil.copy2(e['backup'],path)
 subprocess.run(['systemctl','--user','daemon-reload'],check=True)
 subprocess.run(['hyprctl','reload'],check=True,capture_output=True)
 print('Previous configuration restored; restart its shell service or launcher.')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--code-only',action='store_true');p.add_argument('--restore',action='store_true');a=p.parse_args();restore() if a.restore else deploy(a.code_only)
