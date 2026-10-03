#!/usr/bin/env python3
"""Local desktop actions and a private, read-only knowledge index."""
import argparse
import calendar
import fcntl
import datetime as dt
import hashlib
import json
import math
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs, quote, unquote

ROOT = Path(__file__).resolve().parent
HOME = Path.home()
STATE = HOME / '.local/state/siverteh-observatory'
VAULT = Path(os.environ.get('SIVERTEH_BRAIN_DIR', str(HOME / 'Documents/Siverteh-Brain')))
PORT = 17843
_last_update_check = None
PROJECTS = HOME / '.config/siverteh-ai/projects.json'
THEMES = {
    'ai': ('AI & learning', '#a9c9f2', ['ai','artificial intelligence','machine learning','inference','tensorrt','neural','codex','claude','llm']),
    'electronics': ('Electronics & hardware', '#efbd87', ['electronics','circuit','solder','sensor','camera','gun','bosch','firmware','motor','battery']),
    'software': ('Software & games', '#c3b2ec', ['software','frontend','backend','api','game','parser','code','release','package']),
    'infrastructure': ('Systems & networks', '#87cbbb', ['network','server','deployment','sync','ssh','wifi','latency']),
    'personal': ('Personal life', '#e6c796', ['personal','bouldering','climbing','goals','background','education','preference']),
    'music': ('Music & sound', '#dda9c8', ['music','musikki','spotify','audio','sound']),
    'research': ('Research & science', '#a4d6dc', ['research','science','experiment','investigation','comparison']),
    'general': ('Mixed knowledge', '#a2b8c4', []),
}

def slug(value):
    return re.sub(r'[^a-z0-9]+','-',str(value).lower()).strip('-')[:80]

def fields(body):
    clean=re.sub(r'(?ms)^```[^\n]*\n.*?^```[^\n]*$', '', body)
    clean=re.split(r'^##\s',clean,maxsplit=1,flags=re.M)[0]
    return {k.lower():v.strip().strip('"\'') for k,v in re.findall(r'(?mi)^(Entity|Name|Parent|Project|Worlds|Topics|Tags|Category|Aliases):\s*([^\n]+)',clean)}

def items(value):
    return [s.strip().strip('"\'') for s in str(value).strip('[]').split(',') if s.strip()]

def mentions(text,term):
    if term.endswith('/'): return text.lower().startswith(term.lower())
    return bool(re.search(r'(?<!\w)'+re.escape(term.lower())+r'(?!\w)',text.lower()))

def category(label,body='',declared=''):
    if declared in THEMES: return declared,'declared'
    body=re.sub(r'(?mi)^(Source|Recorded|Reviewed|Confidence|Status|Entity|Name|Project|Parent|Category|Aliases|Topics|Tags):[^\n]*','',body)
    scores={key:sum(4*int(mentions(label,t))+int(mentions(body[:1800],t)) for t in terms) for key,(_,_,terms) in THEMES.items()}
    best=max(scores,key=scores.get)
    return (best,'inferred') if scores[best] else ('general','inferred')

def definitions(notes):
    definitions={h[0]:list(h) for h in HUBS}
    declarations={}
    try:
        registry=json.loads(PROJECTS.read_text()).get('projects',[])
    except (OSError,ValueError): registry=[]
    for project in registry:
        ident=slug(project.get('id',''))
        if not ident: continue
        brain=project.get('brain',{})
        if not isinstance(brain,dict): brain={}
        label=str(brain.get('name') or project.get('label') or ident)
        aliases=brain.get('aliases',[])
        if not isinstance(aliases,list): aliases=[]
        terms=[str(t).lower() for t in [ident,label,*aliases] if len(str(t))>=4]
        if ident not in definitions: definitions[ident]=[ident,label,THEMES['general'][1],terms,[]]
        else: definitions[ident][3]=list(dict.fromkeys(definitions[ident][3]+terms))
        if brain.get('category') in THEMES: declarations[ident]=brain['category']
    for note in notes:
        meta=note['meta']
        # Only current wiki pages explicitly declare worlds, never raw imports.
        if note['path'].startswith('wiki/') and meta.get('entity') in ('project','world'):
            ident=slug(meta.get('project') or Path(note['path']).stem)
            label=meta.get('name') or note['label']
            if ident not in definitions: definitions[ident]=[ident,label,THEMES['general'][1],[ident.lower(),label.lower(),*map(str.lower,items(meta.get('aliases','')))],[]]
            elif meta.get('name'): definitions[ident][1]=label
            if meta.get('category') in THEMES: declarations[ident]=meta['category']
    for note in notes:
        meta=note['meta']
        if not note['path'].startswith('wiki/') or meta.get('entity')!='topic': continue
        parent=slug(meta.get('parent') or meta.get('project',''))
        if parent in definitions:
            label=meta.get('name') or note['label'];key='entity-'+slug(Path(note['path']).stem)
            definitions[parent][4]=[*definitions[parent][4],(key,label,[label.lower(),*map(str.lower,items(meta.get('aliases','')))])]
            if meta.get('category') in THEMES: declarations[parent+':'+key]=meta['category']
    return list(definitions.values()),declarations
HUBS = [
    ('newbringer', 'Newbringer', '#80d9cc', ['newbringer', 'gun', 'slinger', 'imx678', 'tensorrt', 'bosch'], [('devices','Devices', ['gun','device','bosch']), ('camera','Camera & vision',['camera','sensor','imx','inference','tensorrt']), ('frontend','Frontend',['frontend','overlay','android','apk']), ('systems','Systems & releases',['release','deployment','network','latency','server'])]),
    ('personal', 'Siverteh', '#e6bc89', ['personal/', 'wiki/personal.md'], [('interests','Interests',['bouldering','music','gaming','interests']), ('background','Background & goals',['education','degree','background','ownership']), ('preferences','Preferences',['preference','desktop','workflow'])]),
    ('os', 'Siverteh OS', '#9daee7', ['siverteh-ai', 'siverteh os', 'desktop','brain','workflow','codex','claude'], [('desktop','Desktop',['desktop','wallpaper','waybar','rice','power menu']), ('ai','AI workspace',['codex','claude','account','dashboard','task']), ('knowledge','Knowledge system',['brain','wiki','knowledge','sync','snapshot'])]),
    ('musikki', 'MusikKI', '#dbaaed', ['musikki', 'musik-ki'], [('project','Project knowledge',['musikki','musik-ki'])]),
    ('research', 'Research', '#91bde3', ['research', 'investigation', 'comparison', 'experiment'], [('findings','Findings & experiments',['research','investigation','comparison','experiment'])]),
]

def run(argv, fallback='', timeout=3):
    try:
        return subprocess.check_output(argv, text=True, stderr=subprocess.DEVNULL, timeout=timeout).strip()
    except (OSError, subprocess.SubprocessError):
        return fallback

def launch(argv):
    subprocess.Popen(argv, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)

def launch_app(argv):
    launch(['systemd-run','--user','--scope','--collect','--quiet','env','-u','LD_LIBRARY_PATH','-u','QML_IMPORT_PATH','-u','QT_PLUGIN_PATH',*argv])

def update_count():
    global _last_update_check
    now=time.monotonic()
    checker=HOME/'.config/hypr/scripts/waybar/updates_status.sh'
    if checker.exists() and (_last_update_check is None or now-_last_update_check>=1800):
        _last_update_check=now
        launch(['bash',str(checker)])
    try:
        data=json.loads((HOME/'.cache/siverteh/updates-waybar.json').read_text())
        count=str(data.get('alt',data.get('text','')))
        return int(count) if count.isdigit() else None
    except (OSError,ValueError): return None

def note_path(relative):
    p = (VAULT / relative).resolve()
    if not p.is_relative_to(VAULT.resolve()) or p.suffix != '.md' or not p.is_file() or any(x.startswith('.') for x in Path(relative).parts):
        raise ValueError('Note is outside the managed Markdown vault')
    return p

def note_date(body):
    match = re.search(r'^(?:Recorded|Reviewed):\s*(\d{4}-\d{2}-\d{2})', body, re.M)
    try:
        return dt.date.fromisoformat(match.group(1)) if match else None
    except ValueError:
        return None

def note_timestamp(body):
    match=re.search(r'^Recorded:\s*(\S+)',body,re.M)
    try:
        value=dt.datetime.fromisoformat(match.group(1).replace('Z','+00:00')) if match else None
        if value:return value.replace(tzinfo=value.tzinfo or dt.timezone.utc).astimezone(dt.timezone.utc).isoformat()
    except ValueError:pass
    return ''

def graph():
    """Derived topic grouping, explicit source links, dated-note activity proxy.

    Never counts file mtimes or claims to read private chat transcripts. Shared
    evidence appears once and may relate to more than one hub.
    """
    today = dt.datetime.now(dt.timezone.utc).date()
    nodes, links, notes, scores = [], [], [], {}
    lookup = {}
    if VAULT.exists():
        for p in sorted(VAULT.rglob('*.md')):
            rel = p.relative_to(VAULT).as_posix()
            if not p.resolve().is_relative_to(VAULT.resolve()):
                continue
            if any(x.startswith('.') for x in Path(rel).parts) or rel in ('AGENTS.md', 'CLAUDE.md', 'README.md', 'INDEX.md'):
                continue
            body = p.read_text(errors='replace')
            title = next((x[2:].strip() for x in body.splitlines() if x.startswith('# ')), p.stem)
            date = note_date(body)
            age = max(0, (today - date).days) if date else None
            weight = math.exp(-math.log(2) * age / 21) if age is not None else 0
            ident = 'note:' + hashlib.sha256(rel.encode()).hexdigest()[:16]
            confidence = re.search(r'^Confidence:\s*(.*)', body, re.M)
            meta=fields(body)
            theme,reason=category(title,body,meta.get('category',''))
            item = dict(id=ident, label=title, kind='note', path=rel, date=date.isoformat() if date else '', recorded=note_timestamp(body), confidence=confidence.group(1) if confidence else 'source page', text=body[:60000], activity=round(weight, 4),revision=hashlib.sha256(body.encode()).hexdigest()[:16],meta=meta,category=theme,color=THEMES[theme][1])
            notes.append(item)
            lookup[rel] = ident
    assigned = set()
    hubs,declarations=definitions(notes)
    for hub_id, label, color, terms, topics in hubs:
        matched = [n for n in notes if slug(n['meta'].get('project',''))==hub_id or slug(n['meta'].get('parent',''))==hub_id or any(slug(w)==hub_id or any(mentions(w,t) for t in terms) for w in items(n['meta'].get('worlds',''))) or any(mentions(n['path']+'\n'+n['label']+'\n'+n['text'],t) for t in terms)]
        # Explicit topic annotations can create a topic from one meaningful note.
        annotated={}
        for n in matched:
            for tag in items(n['meta'].get('topics',n['meta'].get('tags',''))):
                if slug(tag): annotated.setdefault(slug(tag),tag)
        known_topics={slug(label) for _,label,_ in topics}
        topics=[*topics,*[('tag-'+key,value,[value.lower()]) for key,value in sorted(annotated.items()) if key not in known_topics]]
        theme=declarations.get(hub_id) or {'personal':'personal','research':'research','musikki':'music'}.get(hub_id)
        if not theme:
            counts={key:sum(n['category']==key for n in matched) for key in THEMES if key!='general'}
            theme=max(counts,key=counts.get) if any(counts.values()) else category(label)[0]
        color=THEMES[theme][1]
        # One day of repetitive evidence has a capped contribution.
        days = {}
        for n in matched:
            if n['date']:
                days[n['date']] = min(3, days.get(n['date'], 0) + n['activity'])
        score = sum(days.values())
        scores[hub_id] = score
        nodes.append(dict(id=hub_id, label=label, kind='hub', color=color, category=theme,themeLabel=THEMES[theme][0],themeReason='declared' if hub_id in declarations else 'inferred',count=len(matched), activity=round(score, 3), radius=28 + min(26, 8 * math.log1p(score)), summary='Related knowledge grouped from your local notes. Recent focus follows dated evidence with a 21-day half-life; it does not measure all your conversations.'))
        for key, topic_label, topic_terms in topics:
            topic_id = hub_id + ':' + key
            children = [n for n in matched if any(mentions(n['label']+'\n'+n['text'],t) for t in topic_terms)]
            if not children:
                continue
            topic_theme,reason=category(topic_label+' '+ ' '.join(topic_terms))
            if topic_id in declarations: topic_theme,reason=declarations[topic_id],'declared'
            if topic_theme=='general': topic_theme=theme
            nodes.append(dict(id=topic_id, label=topic_label, kind='topic', parent=hub_id, color=THEMES[topic_theme][1],category=topic_theme,themeLabel=THEMES[topic_theme][0],themeReason=reason,groupReason='annotated' if key.startswith(('tag-','entity-')) else 'suggested',count=len(children), radius=10 + min(9, math.log1p(len(children))*2.4), summary='Topic annotations and related text organize this neighborhood. Suggested relationships are not verified dependencies.'))
            links.append(dict(source=hub_id, target=topic_id, kind='group'))
            for n in children:
                assigned.add(n['id'])
                links.append(dict(source=topic_id, target=n['id'], kind='group'))
            # Hub notes which do not match a subtopic remain reachable below it.
        for n in matched:
            if not any(e['source'].startswith(hub_id + ':') and e['target'] == n['id'] for e in links):
                links.append(dict(source=hub_id, target=n['id'], kind='group'))
                assigned.add(n['id'])
    unassigned = [n for n in notes if n['id'] not in assigned]
    if unassigned:
        nodes.append(dict(id='archive', label='Other knowledge', kind='hub', color='#869eaa', count=len(unassigned), activity=0, radius=24, summary='Notes awaiting a more specific topic grouping.'))
        links.extend(dict(source='archive', target=n['id'], kind='group') for n in unassigned)
    peak=max(scores.values(),default=0)
    for n in nodes:
        if n['kind']=='hub':
            relative=n['activity']/peak if peak else 0
            n['radius']=20+34*relative**.65
    source_pairs=set()
    stems={}
    for path,ident in lookup.items():stems.setdefault(Path(path).stem.casefold(),[]).append(ident)
    for n in notes:
        targets=[(value,False) for value in re.findall(r'\]\(([^)]+\.md)(?:#[^)]*)?\)',n['text'])]
        targets += [(value,True) for value in re.findall(r'\[\[([^]\n]+)\]\]',n['text'])]
        for value,wiki in targets:
            target=unquote(value.split('|')[0].split('#')[0]).strip()
            if not target or '://' in target:continue
            if wiki and not target.endswith('.md'):target += '.md'
            candidates=[VAULT/target,(VAULT/n['path']).parent/target] if wiki else [(VAULT/n['path']).parent/target]
            ident=None
            for path in candidates:
                try:rel=path.resolve().relative_to(VAULT.resolve()).as_posix()
                except ValueError:continue
                if rel in lookup:ident=lookup[rel];break
            if not ident and wiki and '/' not in target:
                matches=stems.get(Path(target).stem.casefold(),[])
                if len(matches)==1:ident=matches[0]
            if ident and ident!=n['id']:source_pairs.add((n['id'],ident))
    links.extend(dict(source=a,target=b,kind='source') for a,b in sorted(source_pairs))
    nodes.extend({k:v for k,v in n.items() if k not in ('text','meta')} for n in notes)
    return dict(nodes=nodes, links=links, noteCount=len(notes), theme=desktop_theme(), accent=palette(), generated=dt.datetime.now().isoformat(timespec='seconds'), activityModel='Dated knowledge activity · 21-day half-life · daily cap. Conversation tracking is not enabled.')

def search_notes(query):
    words=str(query)[:200].casefold().split()
    if not words:return []
    result=[]
    for p in VAULT.rglob('*.md'):
        rel=p.relative_to(VAULT).as_posix()
        if not p.resolve().is_relative_to(VAULT.resolve()) or any(x.startswith('.') for x in Path(rel).parts) or rel in ('AGENTS.md','CLAUDE.md','README.md','INDEX.md'):continue
        content=(rel+'\n'+p.read_text(errors='replace')).casefold()
        if all(word in content for word in words):result.append('note:'+hashlib.sha256(rel.encode()).hexdigest()[:16])
    return result

def status():
    now = dt.datetime.now()
    volume_text = run(['wpctl','get-volume','@DEFAULT_AUDIO_SINK@'])
    m = re.search(r'Volume:\s*([\d.]+)', volume_text)
    brightness = run(['brightnessctl','-m'])
    bmatch = re.search(r',(\d+)%', brightness)
    network = run(['nmcli','-t','-f','ACTIVE,SSID','device','wifi'], timeout=2)
    ssid = next((s[4:].replace('\\:', ':') for s in network.splitlines() if s.startswith('yes:')), '')
    connections = run(['nmcli','-t','-f','NAME,TYPE','connection','show','--active'])
    if not ssid and 'ethernet' in connections:
        ssid = 'Wired'
    batteries = list(Path('/sys/class/power_supply').glob('BAT*'))
    battery, charging = None, False
    if batteries:
        try:
            battery = int((batteries[0]/'capacity').read_text())
            charging = (batteries[0]/'status').read_text().strip() == 'Charging'
        except OSError:
            pass
    media = run(['playerctl','metadata','--format','{{artist}} — {{title}}'])
    playback = run(['playerctl','status'])
    notify = run(['swaync-client','-c'])
    # Calendar includes actual local date, never invented appointments.
    first, days = calendar.monthrange(now.year, now.month)
    return dict(clock=now.strftime('%H:%M'), date=now.strftime('%A, %d %B'), month=now.strftime('%B %Y'), today=now.day, calendar=[0]*first+list(range(1,days+1)), volume=round(float(m.group(1))*100) if m else 0, muted='MUTED' in volume_text, brightness=int(bmatch.group(1)) if bmatch else 0, network=ssid or 'Disconnected', bluetooth='Powered: yes' in run(['bluetoothctl','show']), battery=battery, charging=charging, media=media, playback=playback, notifications=int(notify) if notify.isdigit() else 0, accent=palette(),wallpaperHold=(STATE/'wallpaper-hold').exists(),updates=update_count())

def desktop_theme():
    try:
        return json.loads((HOME/'.local/state/siverteh_shell/scheme.json').read_text())['colours']
    except (OSError,ValueError,KeyError):
        return {}

def palette():
    p=HOME/'.config/siverteh/core/colors/primary'
    try:
        value=p.read_text().strip()
        return value if re.fullmatch(r'#[0-9a-fA-F]{6}',value) else '#808080'
    except OSError:
        return '#808080'

def action(name, value=''):
    actions = {
        'network':['nm-connection-editor'], 'bluetooth':['blueman-manager'],
        'updates':['bash',str(HOME/'.config/siverteh/core/settings/installupdates.sh')],
        'audio':['pavucontrol'], 'notifications':['swaync-client','-t'],
        'play':['playerctl','play-pause'], 'next':['playerctl','next'], 'previous':['playerctl','previous'],
        'mute':['wpctl','set-mute','@DEFAULT_AUDIO_SINK@','toggle'],
        'lock':['hyprlock'], 'power':[str(HOME/'.config/siverteh/core/scripts/wlogout.sh')],
        'files':[str(HOME/'.config/siverteh/core/settings/filemanager.sh')],
        'terminal':['kitty'], 'tasks':['kitty','--class','siverteh-ai-dashboard','--title','Siverteh AI','--','siverteh-ai','dashboard'],
        'new':['kitty','--class','siverteh-ai-task','--title','New chat','--','siverteh-ai','window','--worker-command','new'],
        'resume':['kitty','--class','siverteh-ai-task','--title','Resume task','--','siverteh-ai','window','--worker-command','latest'],
        'notes':['env','SIVERTEH_BRAIN_VIEW=notes','siverteh-ai','brain'],
    }
    if name in actions:
        if name=='tasks':
            clients=json.loads(run(['hyprctl','clients','-j'],'[]'))
            old=next((c for c in clients if c['class']=='siverteh-ai-dashboard'),None)
            if old:
                return action('focus',old['address'])
        launch_app(actions[name])
        if name in ('new','resume','tasks'):action('workspace','2')
        return
    if name=='volume':
        run(['wpctl','set-volume','@DEFAULT_AUDIO_SINK@',str(max(0,min(100,int(value))))+'%']); return
    if name=='brightness':
        run(['brightnessctl','set',str(max(5,min(100,int(value))))+'%']); return
    if name=='workspace':
        num=int(value)
        if num not in range(1,8): raise ValueError('Invalid workspace')
        run(['hyprctl','eval',f'hl.dispatch(hl.dsp.focus({{workspace={num},on_current_monitor=true}}))']); return
    if name=='focus':
        if not re.fullmatch(r'0x[0-9a-fA-F]+',value): raise ValueError('Invalid window')
        run(['hyprctl','eval','hl.dispatch(hl.dsp.focus({window="address:'+value+'"}))']); return
    if name=='app-windows':
        ids=json.loads(value)
        if not isinstance(ids,list) or not all(isinstance(i,str) and re.fullmatch(r'0x[0-9a-fA-F]+',i) for i in ids): raise ValueError('Invalid window group')
        clients=json.loads(run(['hyprctl','clients','-j'],'[]'))
        windows=sorted((c for c in clients if c['address'] in ids),key=lambda c:(c['workspace']['id'],c['title']))
        if len(windows)==1: return action('focus',windows[0]['address'])
        if not windows: return
        labels=[str(c['workspace']['id'])+'  '+c['title'].replace('\n',' ')[:120] for c in windows]
        try: choice=subprocess.check_output(['rofi','-dmenu','-i','-p','Choose window','-format','i'],input='\n'.join(labels),text=True,timeout=300).strip()
        except subprocess.SubprocessError: return
        if choice.isdigit() and int(choice)<len(windows): return action('focus',windows[int(choice)]['address'])
        return
    if name=='brain':
        ensure_brain(focus=True); return
    if name=='wifi':
        rows=[];seen=set()
        for line in run(['nmcli','-t','-f','IN-USE,SSID,SIGNAL,SECURITY','device','wifi','list','--rescan','no']).splitlines():
            parts=re.split(r'(?<!\\):',line)
            if len(parts)<4: continue
            active,ssid,signal,security=parts[:4];ssid=ssid.replace('\\:',':').replace('\\\\','\\')
            if not ssid or ssid in seen: continue
            seen.add(ssid);rows.append((ssid,('● ' if active=='*' else '  ')+ssid+'   '+signal+'%'+('  ' if security and security!='--' else '')))
        if not rows:
            launch(['kitty','--class','siverteh-os-control','--title','Wi-Fi connections','--','nmtui-connect']);return
        try:
            choice=subprocess.check_output(['rofi','-dmenu','-i','-p','Wi-Fi','-format','i'],input='\n'.join(label for _,label in rows),text=True,timeout=300).strip()
        except subprocess.SubprocessError: return
        if choice.isdigit() and int(choice)<len(rows):
            # Native NetworkManager prompt owns credentials; never capture passwords.
            launch(['kitty','--class','siverteh-os-control','--title','Connect Wi-Fi','--','nmcli','--ask','device','wifi','connect',rows[int(choice)][0]])
        return
    if name=='wallpaper':
        collection=HOME/'Pictures/Wallpapers/Observatory'
        images=sorted(p for p in collection.glob('*') if p.suffix.lower() in ('.png','.jpg','.jpeg','.webp'))
        if not images: return
        try:
            selected=subprocess.check_output(['rofi','-dmenu','-i','-p','Wallpaper'],input='\n'.join(p.stem for p in images),text=True,timeout=300).strip()
        except subprocess.SubprocessError: return
        image=next((p for p in images if p.stem==selected),None)
        if image:
            apply_wallpaper(image)
            STATE.mkdir(parents=True,exist_ok=True)
            (STATE/'wallpaper-current').write_text(str(image))
        return
    if name=='open-note':
        p=note_path(value)
        launch_app(['obsidian','obsidian://open?path='+quote(str(p),safe='')]); return
    if name=='capture':
        text=run(['zenity','--text-info','--editable','--title=Capture a thought','--width=580','--height=340'],timeout=3600)
        if text.strip():
            title=text.strip().splitlines()[0][:90]
            subprocess.run(['siverteh-brain','note','--kind','personal','--title',title,'--source','User quick capture in Siverteh Observatory','--confidence','reported'],input=text,text=True,stdout=subprocess.DEVNULL,check=True)
        return
    if name=='rotate':
        rotate_wallpaper(); return
    if name=='hold':
        STATE.mkdir(parents=True,exist_ok=True)
        hold=STATE/'wallpaper-hold'
        if hold.exists(): hold.unlink()
        else: hold.touch(mode=0o600)
        return
    raise ValueError('Unknown action')

def rotate_wallpaper():
    if (STATE/'wallpaper-hold').exists(): return
    # Only the selected collection, never arbitrary private picture folders.
    collection=HOME/'Pictures/Wallpapers/Observatory'
    images=sorted(p for p in collection.glob('*') if p.suffix.lower() in ('.png','.jpg','.jpeg','.webp'))
    if not images: return
    current=STATE/'wallpaper-current'
    old=current.read_text().strip() if current.exists() else ''
    idx=next((i for i,p in enumerate(images) if str(p)==old),-1)
    image=images[(idx+1)%len(images)]
    apply_wallpaper(image)
    STATE.mkdir(parents=True,exist_ok=True)
    current.write_text(str(image))

def apply_wallpaper(image):
    image=Path(image)
    if not image.is_file(): raise ValueError('Wallpaper not found')
    subprocess.run([str(HOME/'.config/hypr/scripts/apply-wallpaper-engine.sh'),str(image)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=True,timeout=30)
    subprocess.run([str(HOME/'.local/bin/matugen'),'image',str(image),'-m','dark'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=True,timeout=30)
    cache=HOME/'.cache/siverteh/hyprland-dotfiles'
    cache.mkdir(parents=True,exist_ok=True)
    (cache/'current_wallpaper').write_text(str(image))
    subprocess.run(['magick',str(image),'-resize','1920x1200','-blur','0x7',str(cache/'blurred_wallpaper.png')],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=True,timeout=30)
    update_theme()

def update_theme():
    accent=palette()
    generated=HOME/'.config/siverteh-observatory'
    generated.mkdir(parents=True,exist_ok=True)
    for name in ['rofi.rasi','swaync.css','gtk.css','swayosd.css']:
        (generated/name).write_text((ROOT/'themes'/name).read_text().replace('#80d9cc',accent))
    run(['swaync-client','-rs'])

class Handler(BaseHTTPRequestHandler):
    def log_message(self,*args): pass
    def allowed(self):
        return self.headers.get('Host') in ('127.0.0.1:'+str(PORT),'localhost:'+str(PORT))
    def send(self,body,mime='application/json',code=200):
        self.send_response(code)
        self.send_header('Content-Type',mime)
        self.send_header('Cache-Control','no-store')
        self.send_header('X-Content-Type-Options','nosniff')
        self.send_header('Content-Security-Policy',"default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; connect-src 'self'; object-src 'none'; frame-ancestors 'none'")
        self.end_headers(); self.wfile.write(body if isinstance(body,bytes) else body.encode())
    def do_GET(self):
        if not self.allowed(): return self.send('{}',code=403)
        path=urlparse(self.path)
        try:
            if path.path=='/api/brain': return self.send(json.dumps(graph()))
            if path.path=='/api/search': return self.send(json.dumps(dict(ids=search_notes(parse_qs(path.query).get('q',[''])[0]))))
            if path.path=='/api/navigation':
                nav=HOME/'.local/state/siverteh-native-shell/extras/brain-focus.json'
                value=json.loads(nav.read_text()) if nav.exists() else {}
                if time.time()-value.get('created',0)>60:value={}
                return self.send(json.dumps(value))
            if path.path=='/api/note':
                p=note_path(parse_qs(path.query).get('path',[''])[0])
                return self.send(json.dumps(dict(text=p.read_text(errors='replace'))))
            if path.path=='/api/health': return self.send('{"ready":true}')
            assets={'/':'index.html','/app.js':'app.js','/style.css':'style.css'}
            if path.path in assets:
                name=assets[path.path]
                return self.send((ROOT/'web'/name).read_bytes(),{'index.html':'text/html; charset=utf-8','app.js':'text/javascript','style.css':'text/css'}[name])
            self.send('{}',code=404)
        except (ValueError,OSError): self.send('{}',code=404)
    def do_POST(self):
        # Same-origin JSON requests only; no cross-origin action endpoints.
        origin=self.headers.get('Origin')
        if not self.allowed() or origin!='http://127.0.0.1:'+str(PORT) or self.headers.get('Content-Type')!='application/json': return self.send('{}',code=403)
        if self.path!='/api/action': return self.send('{}',code=404)
        try:
            size=int(self.headers.get('Content-Length','0'))
            if not 0<size<=4096: raise ValueError('Invalid length')
            data=json.loads(self.rfile.read(size))
            # Web interface only exposes its own narrow navigation actions.
            if data.get('name') not in ('open-note','capture','tasks','new','resume','notes'): raise ValueError('Invalid action')
            launch_app([sys.executable,str(ROOT/'control.py'),'action',data['name'],str(data.get('value',''))])
            self.send('{"ok":true}')
        except (ValueError,KeyError): self.send('{}',code=400)

def ensure_server():
    import urllib.request
    url='http://127.0.0.1:'+str(PORT)+'/api/health'
    try:
        with urllib.request.urlopen(url,timeout=1) as r:
            if json.load(r).get('ready'): return
    except (OSError,ValueError): pass
    launch([sys.executable,str(ROOT/'control.py'),'serve'])
    for _ in range(30):
        time.sleep(.1)
        try:
            with urllib.request.urlopen(url,timeout=1) as r:
                if json.load(r).get('ready'): return
        except (OSError,ValueError): pass
    raise ValueError('Observatory server did not start')

def brain_window():
    clients=json.loads(run(['hyprctl','clients','-j'],'[]'))
    return next((c for c in clients if c['class']=='siverteh-brain' or (c['class'].startswith('chrome-127.0.0.1') and c['title'] in ('Siverteh · Observatory','Siverteh Brain'))),None)

def ensure_brain(focus=False):
    STATE.mkdir(parents=True,exist_ok=True,mode=0o700)
    with (STATE/'brain-launch.lock').open('w') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX)
        ensure_server()
        window=brain_window()
        if not window:
            previous=json.loads(run(['hyprctl','activeworkspace','-j'],'{}')).get('id')
            browser=next((p for p in ['/opt/google/chrome/chrome',shutil.which('chromium')] if p and Path(p).exists()),None)
            if not browser: raise ValueError('Chrome or Chromium is required for the observatory')
            launch([browser,'--no-first-run','--no-default-browser-check','--ozone-platform=wayland','--class=siverteh-brain','--user-data-dir='+str(HOME/'.local/share/siverteh-ai/observatory-browser'),'--app=http://127.0.0.1:'+str(PORT)])
            for _ in range(100):
                window=brain_window()
                if window: break
                time.sleep(.1)
            if window and re.fullmatch(r'0x[0-9a-fA-F]+',window['address']):
                run(['hyprctl','eval','hl.dispatch(hl.dsp.window.move({workspace="6",window="address:'+window['address']+'",follow=false}))'])
            if not focus and isinstance(previous,int) and previous>0:
                run(['hyprctl','eval',f'hl.dispatch(hl.dsp.focus({{workspace={previous},on_current_monitor=true}}))'])
        if focus:
            action('workspace','6')
            if window: action('focus',window['address'])

def watch_brain():
    STATE.mkdir(parents=True,exist_ok=True,mode=0o700)
    with (STATE/'brain-watch.lock').open('w') as lock:
        try: fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError: return
        while True:
            # A missing compositor is a session boundary, not a reason to open
            # browser windows outside the desktop session.
            if run(['hyprctl','activeworkspace','-j']): ensure_brain(focus=False)
            time.sleep(3)

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('command',choices=['serve','stream','action','graph','status','wallpaper','theme','watch-brain'])
    parser.add_argument('name',nargs='?'); parser.add_argument('value',nargs='?',default='')
    args=parser.parse_args()
    if args.command=='serve': ThreadingHTTPServer(('127.0.0.1',PORT),Handler).serve_forever()
    elif args.command=='watch-brain': watch_brain()
    elif args.command=='action': action(args.name,args.value)
    elif args.command=='graph': print(json.dumps(graph()))
    elif args.command=='status': print(json.dumps(status()))
    elif args.command=='wallpaper': apply_wallpaper(args.name)
    elif args.command=='theme': update_theme()
    elif args.command=='stream':
        while True:
            print(json.dumps(status()),flush=True); time.sleep(3)

if __name__=='__main__':
    try: main()
    except (OSError,ValueError,subprocess.SubprocessError) as e:
        print('Observatory: '+str(e),file=sys.stderr); sys.exit(1)
