#!/usr/bin/env python3
"""Install a reversible user-local Observatory layer; never replace the OS checkout."""
import argparse
import configparser
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import urllib.request

ROOT=Path(__file__).resolve().parent
HOME=Path.home()
DEST=HOME/'.local/share/siverteh-ai/observatory'
STATE=HOME/'.local/state/siverteh-observatory'
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest() if p.exists() else None
def run(argv,check=True): return subprocess.run(argv,check=check,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
def stop_owned():
    for entry in Path('/proc').iterdir():
        if not entry.name.isdigit(): continue
        try:
            raw=(entry/'cmdline').read_bytes().split(b'\0')
            args=[x.decode(errors='replace') for x in raw if x]
            if not args: continue
            is_shell=Path(args[0]).name in ('quickshell','qs') and any('/rice/observatory/shell/' in x or str(DEST/'shell') in x for x in args)
            is_server=Path(args[0]).name.startswith('python') and any(x.endswith('observatory/control.py') for x in args) and 'serve' in args
            if is_shell or is_server: os.kill(int(entry.name),signal.SIGTERM)
        except (OSError,ProcessLookupError): pass

def provision_runtime():
    if shutil.which('quickshell'): return
    runtime=HOME/'.local/share/siverteh-ai/rice-runtime'
    if (runtime/'usr/bin/quickshell').exists(): return
    runtime.mkdir(parents=True,exist_ok=True)
    urls=subprocess.check_output(['pacman','-Sp','--print-format','%l','quickshell'],text=True).splitlines()
    for url in urls:
        package=runtime/url.rsplit('/',1)[-1]
        urllib.request.urlretrieve(url,package)
        run(['bsdtar','-xf',str(package),'-C',str(runtime)])

def install():
    for binary in ['hyprctl','magick','python3','wpctl','nmcli','rofi']:
        if not shutil.which(binary): raise RuntimeError('Missing required tool: '+binary)
    hypr=HOME/'.config/hypr/hyprland.lua'
    if not hypr.exists(): raise RuntimeError('This installer targets the current Lua Hyprland configuration')
    provision_runtime()
    STATE.mkdir(parents=True,exist_ok=True,mode=0o700)
    os.chmod(STATE,0o700)
    backup=STATE/'backups'/dt.datetime.now().strftime('%Y%m%d-%H%M%S')
    backup.mkdir(parents=True,mode=0o700)
    manifest={'files':{},'wallpaper':'','clients':[]}
    oldcache=HOME/'.cache/siverteh/hyprland-dotfiles/current_wallpaper'
    if oldcache.exists(): manifest['wallpaper']=oldcache.read_text().strip()
    clients=json.loads(subprocess.check_output(['hyprctl','clients','-j'],text=True))
    manifest['clients']=[{'address':c['address'],'workspace':c['workspace']['id']} for c in clients]
    def save(p):
        p=p.resolve()
        key=str(p)
        if key not in manifest['files']:
            saved=backup/('file-'+str(len(manifest['files'])))
            if p.exists(): shutil.copy2(p,saved)
            manifest['files'][key]={'saved':saved.name if p.exists() else None,'before':digest(p),'after':None}
        return p
    def write(p,body):
        p=save(p);p.parent.mkdir(parents=True,exist_ok=True);p.write_text(body)
    def replace(p,old,new):
        body=p.read_text()
        if old in body: write(p,body.replace(old,new))
        elif new not in body: raise RuntimeError('Expected configuration marker missing: '+str(p))
    try:
        stop_owned()
        if ROOT!=DEST:
            shutil.copytree(ROOT,DEST,dirs_exist_ok=True,ignore=shutil.ignore_patterns('__pycache__','tests'))
        wrapper=HOME/'.local/bin/siverteh-observatory'
        write(wrapper,(ROOT/'launch.sh').read_text());wrapper.chmod(0o755)
        write(HOME/'.config/hypr/conf/observatory.lua',(ROOT/'observatory.lua').read_text())
        body=hypr.read_text()
        if 'require("conf.observatory")' not in body: write(hypr,body+'\n-- Siverteh Observatory\nrequire("conf.observatory")\n')
        autostart=HOME/'.config/hypr/conf/autostart.lua'
        replace(autostart,'hl.exec_cmd("~/.config/waybar/launch.sh")','hl.exec_cmd("~/.local/bin/siverteh-observatory start")')
        body=autostart.read_text()
        body=body.replace('    hl.exec_cmd("~/.config/hypr/scripts/siverteh-shell.sh --daemon")','    -- Observatory owns the center dropdown.')
        body=body.replace('    hl.exec_cmd("~/.config/hypr/scripts/waybar/calendar-popup.sh --daemon")','    -- Calendar is integrated in the Observatory panel.')
        body=body.replace('hl.exec_cmd("~/.config/hypr/scripts/wallpaper-restore.sh")','hl.exec_cmd("~/.local/bin/siverteh-observatory restore-wallpaper")')
        write(autostart,body)
        keybindings=HOME/'.config/hypr/conf/keybinding.lua'
        replace(keybindings,'~/.config/hypr/scripts/siverteh-shell.sh','~/.local/bin/siverteh-observatory toggle')
        # Explicit launcher config handles launcher and clipboard menus consistently.
        write(HOME/'.config/rofi/config.rasi','@import "'+str(HOME/'.config/siverteh-observatory/rofi.rasi')+'"\n')
        for gtk in ['gtk-3.0','gtk-4.0']:
            path=HOME/'.config'/gtk/'gtk.css'
            body=path.read_text() if path.exists() else ''
            marker='@import url("'+str(HOME/'.config/siverteh-observatory/gtk.css')+'");'
            if marker not in body:
                if "@import 'colors.css';" in body:
                    write(path,body.replace("@import 'colors.css';","@import 'colors.css';\n"+marker,1))
                else: write(path,marker+'\n'+body)
        write(HOME/'.config/swaync/style.css','@import "'+str(HOME/'.config/siverteh-observatory/swaync.css')+'";\n')
        write(HOME/'.config/swayosd/style.css','@import url("'+str(HOME/'.config/siverteh-observatory/swayosd.css')+'");\n')
        css=(ROOT/'themes/wlogout.css').read_text().replace('../../wlogout/icons',str(HOME/'.config/wlogout/icons'))
        write(HOME/'.config/wlogout/style.css',css)
        write(HOME/'.config/hypr/hyprlock.conf',(ROOT/'themes/hyprlock.conf').read_text())
        # Preserve terminal colors while keeping wallpaper palettes available.
        matugen=HOME/'.config/matugen/config.toml'
        body=matugen.read_text()
        body=body.replace("output_path = '~/.config/kitty/colors-matugen.conf'","output_path = '~/.cache/siverteh-observatory/kitty-colors.conf'")
        body=body.replace("post_hook = 'pkill -SIGUSR1 kitty'",'# Terminal palette is pinned for the Observatory pass.')
        write(matugen,body)
        (HOME/'.cache/siverteh-observatory').mkdir(parents=True,exist_ok=True)
        # AI controller opens the new explorer; Notes remains separately available.
        ai=HOME/'.local/bin/siverteh-ai'
        body=ai.read_text()
        marker='    elif args.command == "brain":\n'
        if 'SIVERTEH_BRAIN_VIEW' not in body:
            insertion='''        explorer = Path.home() / ".local/bin/siverteh-observatory"
        if explorer.exists() and os.environ.get("SIVERTEH_BRAIN_VIEW") != "notes":
            subprocess.Popen([str(explorer), "brain"], start_new_session=True)
            return
'''
            if marker not in body: raise RuntimeError('AI launcher integration marker missing')
            write(ai,body.replace(marker,marker+insertion))
        # Qt applications retain their style and icons, using a coordinated palette.
        palette=HOME/'.config/siverteh-observatory/qt.conf'
        colors=['#ffe2ebe6','#ff172930','#ff456169','#ff20343c','#ff0b171c','#ff1a2c32','#ffe2ebe6','#ffe2ebe6','#ffe2ebe6','#ff111f25','#ff13232a','#ff0b171c','#ff80d9cc','#ff10272c','#ff80d9cc','#ffe6bc89','#ff1a2c32','#ffe2ebe6','#ff91a9ae','#ffe2ebe6','#80000000']
        write(palette,'[ColorScheme]\n'+'\n'.join(k+'='+', '.join(colors) for k in ['active_colors','disabled_colors','inactive_colors'])+'\n')
        for folder in ['qt5ct','qt6ct']:
            p=HOME/'.config'/folder/(folder+'.conf')
            if p.exists():
                cfg=configparser.ConfigParser(interpolation=None);cfg.optionxform=str;cfg.read(p)
                cfg['Appearance']['color_scheme_path']=str(palette)
                import io
                buf=io.StringIO();cfg.write(buf);write(p,buf.getvalue())
        # Capture palette/cache files that the wallpaper operation changes.
        for p in [oldcache,HOME/'.cache/siverteh/hyprland-dotfiles/blurred_wallpaper.png']:
            save(p)
        import tomllib
        for template in tomllib.loads(matugen.read_text()).get('templates',{}).values():
            if template.get('output_path'):
                p=save(Path(os.path.expanduser(template['output_path'])))
                manifest['files'][str(p)]['generated']=True
        for name in ['rofi.rasi','swaync.css','gtk.css','swayosd.css']:
            p=save(HOME/'.config/siverteh-observatory'/name)
            manifest['files'][str(p)]['generated']=True
        for p in [oldcache,HOME/'.cache/siverteh/hyprland-dotfiles/blurred_wallpaper.png']:
            manifest['files'][str(p.resolve())]['generated']=True
        collection=HOME/'Pictures/Wallpapers/Observatory'
        run([sys.executable,str(DEST/'wallpaper.py'),str(collection)])
        for svg in collection.glob('*.svg'): run(['magick',str(svg),str(svg.with_suffix('.png'))])
        # Rotate PNGs; retain source vectors separately so the picker stays tidy.
        source=collection/'sources';source.mkdir(exist_ok=True)
        for svg in collection.glob('*.svg'): shutil.move(str(svg),str(source/svg.name))
        run([sys.executable,str(DEST/'control.py'),'wallpaper',str(collection/'tidal-orbit.png')])
        (STATE/'wallpaper-current').write_text(str(collection/'tidal-orbit.png'))
        # Stop the superseded surfaces, never application windows.
        run(['pkill','-x','waybar'],False)
        run([str(HOME/'.config/hypr/scripts/siverteh-shell.sh'),'--quit'],False)
        run(['hyprctl','reload'])
        errors=subprocess.check_output(['hyprctl','configerrors'],text=True).strip()
        if errors: raise RuntimeError('Hyprland rejected configuration: '+errors)
        run([str(wrapper),'start'])
        run(['swaync-client','-rs'],False)
        run(['pkill','-x','swayosd-server'],False)
        subprocess.Popen(['swayosd-server'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,start_new_session=True)
        # Preserve the old editor in a reachable spare workspace.
        for c in clients:
            if c['class'] in ('Code','code','com.microsoft.VSCode','VSCodium','cursor','Cursor'):
                run(['hyprctl','eval','hl.dispatch(hl.dsp.window.move({workspace="7",window="address:'+c['address']+'",follow=false}))'],False)
        service=HOME/'.config/systemd/user'
        write(service/'siverteh-observatory-brain.service',(ROOT/'brain.service').read_text())
        write(service/'siverteh-observatory-wallpaper.service','[Unit]\nDescription=Rotate Observatory wallpaper and palette\n[Service]\nType=oneshot\nExecStart='+str(wrapper)+' rotate\n')
        write(service/'siverteh-observatory-wallpaper.timer','[Unit]\nDescription=Slow Observatory wallpaper rotation\n[Timer]\nOnActiveSec=90min\nOnUnitActiveSec=90min\n[Install]\nWantedBy=timers.target\n')
        run(['systemctl','--user','daemon-reload'])
        run(['systemctl','--user','enable','--now','siverteh-observatory-wallpaper.timer'])
        run(['systemctl','--user','enable','--now','siverteh-observatory-brain.service'])
        for p,e in manifest['files'].items(): e['after']=digest(Path(p))
        (backup/'manifest.json').write_text(json.dumps(manifest,indent=2))
        (STATE/'latest-backup').write_text(str(backup))
        print('Observatory installed. Rollback snapshot: '+str(backup))
    except Exception:
        for p,e in manifest['files'].items(): e['after']=digest(Path(p))
        (backup/'manifest.json').write_text(json.dumps(manifest,indent=2))
        print('Installation failed; restoring saved configuration.',file=sys.stderr)
        restore(backup,force=True)
        raise

def restore(backup,force=False):
    manifest=json.loads((backup/'manifest.json').read_text())
    conflicts=[p for p,e in manifest['files'].items() if not e.get('generated') and digest(Path(p))!=e['after']]
    if conflicts and not force: raise RuntimeError('Configuration changed since installation; refusing to overwrite: '+', '.join(conflicts))
    run(['systemctl','--user','disable','--now','siverteh-observatory-brain.service'],False)
    stop_owned()
    run(['systemctl','--user','disable','--now','siverteh-observatory-wallpaper.timer'],False)
    for p,e in manifest['files'].items():
        p=Path(p)
        if e['saved']: shutil.copy2(backup/e['saved'],p)
        elif p.exists(): p.unlink()
    for c in manifest.get('clients',[]):
        if re.fullmatch(r'0x[0-9a-fA-F]+',c['address']) and c['workspace']>0:
            run(['hyprctl','eval','hl.dispatch(hl.dsp.window.move({workspace="'+str(c['workspace'])+'",window="address:'+c['address']+'",follow=false}))'],False)
    run(['hyprctl','reload'],False)
    wallpaper=manifest.get('wallpaper')
    if wallpaper and Path(wallpaper).exists(): run([str(HOME/'.config/hypr/scripts/apply-wallpaper-engine.sh'),wallpaper],False)
    run([str(HOME/'.config/waybar/launch.sh')],False)
    run(['swaync-client','-rs'],False)
    run(['systemctl','--user','daemon-reload'],False)
    print('Saved desktop configuration restored.')

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--restore',type=Path);args=parser.parse_args()
    if args.restore: restore(args.restore)
    else: install()
