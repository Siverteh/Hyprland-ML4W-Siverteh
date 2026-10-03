#!/usr/bin/env python3
"""Validated desktop preferences and reversible connected-display arrangement."""
import argparse,fcntl,json,os,subprocess,sys,time,uuid
from pathlib import Path
from importlib.util import spec_from_file_location,module_from_spec
spec=spec_from_file_location('palette',Path(__file__).with_name('classic-state.py'));palette=module_from_spec(spec);spec.loader.exec_module(palette)
HOME=Path.home();STATE=HOME/'.config/siverteh-shell/desktop.json';LUA=STATE.with_name('desktop.lua');PENDING=STATE.with_name('display-pending.json')
DEFAULTS=dict(animations=True,blur=True,shadow=True,followMouse=True,naturalScroll=True,gapsIn=6,gapsOut=12,borderSize=1,rounding=10,frameWidth=10,frameRounding=25,topEdge=True,leftEdge=True,rightEdge=True,bottomEdge=True,leftDrawer=True,livePreviews=True,nativePalette=True,nativeOverview=True,nativeClipboard=True,dnd=False)
OPTIONS={'animations':'animations.enabled','blur':'decoration.blur.enabled','shadow':'decoration.shadow.enabled','followMouse':'input.follow_mouse','naturalScroll':'input.touchpad.natural_scroll','gapsIn':'general.gaps_in','gapsOut':'general.gaps_out','borderSize':'general.border_size','rounding':'decoration.rounding'}
RANGES={'gapsIn':(0,30),'gapsOut':(0,80),'borderSize':(0,8),'rounding':(0,40),'frameWidth':(0,30),'frameRounding':(0,40)}

def hypr(*args):
    result=subprocess.run(['hyprctl',*args],capture_output=True,text=True,timeout=8)
    if result.returncode:raise RuntimeError(result.stderr.strip() or result.stdout.strip() or 'Hyprland command failed')
    return result.stdout

def monitor_state():return [{k:m.get(k) for k in ('name','width','height','refreshRate','scale','x','y','transform','disabled','mirrorOf')} for m in json.loads(hypr('monitors','all','-j')) if not m.get('disabled')]

def initial():
    data=dict(DEFAULTS)
    for key,option in OPTIONS.items():
        try:
            value=json.loads(hypr('getoption',option,'-j'))
            data[key]=value['bool'] if 'bool' in value else value['int'] if 'int' in value else int(value['css'].split()[0])
            if key=='followMouse':data[key]=data[key]!=0
        except (RuntimeError,ValueError,KeyError):pass
    return data

def load():
    data={**DEFAULTS,**json.loads(STATE.read_text())} if STATE.exists() else initial()
    data.pop('wallpaperTransition',None)
    if isinstance(data.get('normalSnapshot'),dict):data['normalSnapshot'].pop('wallpaperTransition',None)
    return data

def validate(key,value):
    if key not in DEFAULTS:raise ValueError('Unknown setting')
    if key in RANGES:
        low,high=RANGES[key]
        if type(value) is not int or not low<=value<=high:raise ValueError(f'{key} must be an integer from {low} to {high}')
    elif type(value) is not bool:raise ValueError(f'{key} must be true or false')
    return value

def lua_value(value):return 'true' if value is True else 'false' if value is False else json.dumps(value,ensure_ascii=True)

def monitor_lua(monitors):
    lines=[]
    for m in monitors:
        name=m['name'];mode=f"{int(m['width'])}x{int(m['height'])}@{float(m['refreshRate']):.3f}"
        mirror=m.get('mirrorOf') or ''
        if mirror=='none':mirror=''
        lines.append('hl.monitor({output='+lua_value(name)+',mode='+lua_value(mode)+',scale='+str(float(m['scale']))+',position='+lua_value(f"{int(m['x'])}x{int(m['y'])}")+',transform='+str(int(m.get('transform') or 0))+',mirror='+lua_value(mirror)+'})')
    return '\n'.join(lines)

def config_lua(data):
    entries=[]
    for key,option in OPTIONS.items():entries.append('['+lua_value(option)+']='+lua_value(int(data[key]) if key=='followMouse' else data[key]))
    return 'hl.config({'+','.join(entries)+'})\n'

def persist(data):
    palette.atomic_write(STATE,json.dumps(data,indent=2)+'\n')
    palette.atomic_write(LUA,config_lua(data)+monitor_lua(data.get('displays',[]))+'\n')

def ensure_include():
    path=HOME/'.config/hypr/hyprland.lua';text=path.read_text();marker='-- Siverteh desktop settings'
    if marker not in text:
        backup=HOME/'.local/state/siverteh-native-shell/backups'/('desktop-settings-'+time.strftime('%Y%m%dT%H%M%S'))/'hyprland.lua'
        palette.atomic_write(backup,text)
        palette.atomic_write(path,text+'\n'+marker+'\nlocal desktop_path = os.getenv("HOME") .. "/.config/siverteh-shell/desktop.lua"\nlocal desktop_file = io.open(desktop_path, "r")\nif desktop_file then desktop_file:close(); dofile(desktop_path) end\n')

def display_plan(monitors,primary,mode):
    if mode not in ('extend-right','extend-left','mirror'):raise ValueError('Unsupported display arrangement')
    if len(monitors)<2:raise ValueError('Connect a second display first')
    main=next((m for m in monitors if m['name']==primary),None)
    if not main:raise ValueError('Selected display is disconnected')
    main=dict(main,x=0,y=0,mirrorOf='none');result=[main]
    width=lambda m:round((m['height'] if (m.get('transform') or 0)%2 else m['width'])/m['scale'])
    x=width(main) if mode=='extend-right' else 0
    for original in monitors:
        if original['name']==primary:continue
        m=dict(original,y=0,mirrorOf=primary if mode=='mirror' else 'none')
        if mode=='extend-left':x-=width(m)
        m['x']=0 if mode=='mirror' else x
        result.append(m)
        if mode=='extend-right':x+=width(m)
    return result

def revert(token=None):
    if not PENDING.exists():return
    saved=json.loads(PENDING.read_text())
    if token and token!=saved['token']:return
    hypr('eval',monitor_lua(saved['monitors']))
    data=load();data['displays']=saved['previous'];persist(data);PENDING.unlink(missing_ok=True)

def state():
    data=load();return dict(data=data,monitors=monitor_state(),pending=PENDING.exists(),message='Changes save automatically')

def main():
    p=argparse.ArgumentParser();p.add_argument('action',choices=['state','init','set','display','confirm','revert','rollback-after','preset']);p.add_argument('args',nargs='*');a=p.parse_args()
    if a.action=='rollback-after':
        time.sleep(20)
    STATE.parent.mkdir(parents=True,exist_ok=True)
    with STATE.with_suffix('.lock').open('w') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX)
        try:
            if a.action=='init':
                if PENDING.exists():revert()
                persist(load())
                ensure_include()
            elif a.action=='set':
                key,raw=a.args;value=validate(key,json.loads(raw));data=load();data[key]=value
                if key in OPTIONS:hypr('eval','hl.config({['+lua_value(OPTIONS[key])+']='+lua_value(int(value) if key=='followMouse' else value)+'})')
                persist(data)
            elif a.action=='preset':
                name=a.args[0]
                if name not in ('normal','focused','presentation','minimal'):raise ValueError('Unknown desktop preset')
                data=load()
                baseline=data.get('normalSnapshot') if data.get('preset','normal')!='normal' else {k:data[k] for k in DEFAULTS}
                baseline=baseline or dict(DEFAULTS)
                overrides={'normal':{},'focused':dict(blur=False,shadow=False,animations=False,dnd=True),
                    'presentation':dict(leftDrawer=False,topEdge=False,leftEdge=False,rightEdge=False,bottomEdge=False,dnd=True),
                    'minimal':dict(topEdge=True,leftEdge=False,rightEdge=False,bottomEdge=False,frameWidth=0,gapsIn=3,gapsOut=6,borderSize=0,shadow=False)}
                data.update(baseline);data.update(overrides[name]);data['preset']=name;data['normalSnapshot']=baseline
                hypr('eval',config_lua(data));persist(data)
            elif a.action=='display':
                if PENDING.exists():raise ValueError('Keep or revert the current display change first')
                mode,primary=a.args;data=load();monitors=monitor_state();plan=display_plan(monitors,primary,mode);token=uuid.uuid4().hex
                saved=dict(token=token,previous=data.get('displays',[]),monitors=monitors)
                palette.atomic_write(PENDING,json.dumps(saved));data['displays']=plan
                subprocess.Popen([sys.executable,__file__,'rollback-after',token],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,start_new_session=True)
                try:hypr('eval',monitor_lua(plan));persist(data)
                except Exception:revert(token);raise
            elif a.action=='confirm':PENDING.unlink(missing_ok=True)
            elif a.action in ('revert','rollback-after'):revert(a.args[0] if a.args else None)
            print(json.dumps(state()))
        except Exception as error:print(json.dumps(dict(data=load(),error=str(error),pending=PENDING.exists())))

if __name__=='__main__':main()
