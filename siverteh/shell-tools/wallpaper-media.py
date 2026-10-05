#!/usr/bin/env python3
"""Local wallpaper catalog, video posters, private picker preferences and selection."""
import argparse,fcntl,hashlib,json,os,shutil,subprocess,sys,tempfile,urllib.parse
from pathlib import Path
from PIL import Image
HOME=Path.home();LIBRARY=HOME/'Pictures/Wallpapers';CACHE=HOME/'.cache/siverteh-os/wallpaper-media';STATE=HOME/'.local/state/siverteh_shell/wallpaper';PREFS=HOME/'.config/siverteh-shell/wallpaper-picker.json'
IMAGES={'.jpg','.jpeg','.png','.webp','.gif','.tif','.tiff'};VIDEOS={'.mp4','.webm','.mkv','.mov','.avi','.m4v'}
def atomic(path,data):
 path.parent.mkdir(parents=True,exist_ok=True);fd,name=tempfile.mkstemp(dir=path.parent)
 try:
  with os.fdopen(fd,'w') as stream:json.dump(data,stream)
  os.chmod(name,0o600);os.replace(name,path)
 finally:
  if os.path.exists(name):os.unlink(name)
def read(path,default):
 try:return json.loads(path.read_text())
 except FileNotFoundError:return default

def settings():return dict({'kind':'static','layout':'carousel','paused':False,'pauseCovered':True},**read(PREFS,{}))
def preference(value):
 allowed={'kind':('static','dynamic'),'layout':('carousel','spotlight','hexagons')}
 if not isinstance(value,dict) or any(k not in (*allowed,'paused','pauseCovered') for k in value):raise ValueError('Unknown picker preference')
 for k,v in value.items():
  if k in allowed and v not in allowed[k]:raise ValueError('Invalid picker preference')
  if k not in allowed and type(v) is not bool:raise ValueError('Expected a boolean preference')
 PREFS.parent.mkdir(parents=True,exist_ok=True)
 with PREFS.with_suffix('.lock').open('w') as lock:
  os.chmod(lock.name,0o600);fcntl.flock(lock,fcntl.LOCK_EX);result=settings();result.update(value);atomic(PREFS,result);return result

def describe(path):
 path=Path(path).expanduser().resolve()
 if not path.is_file() or path.suffix.lower() not in IMAGES|VIDEOS:raise ValueError('Select a local image, GIF or video')
 animated=False
 if path.suffix.lower()=='.gif':
  with Image.open(path) as image:animated=getattr(image,'n_frames',1)>1
 dynamic=path.suffix.lower() in VIDEOS or animated;poster=path
 if dynamic:
  stat=path.stat();key=hashlib.sha256((str(path)+str(stat.st_size)+str(stat.st_mtime_ns)).encode()).hexdigest();CACHE.mkdir(parents=True,exist_ok=True);poster=CACHE/(key+'.png')
  if not poster.exists():
   temporary=CACHE/(key+'.next.png')
   try:
    if animated:
     with Image.open(path) as image:
      image.seek(0);image=image.convert('RGB');image.thumbnail((1920,1080));image.save(temporary)
    else:
     subprocess.run(['ffmpeg','-nostdin','-v','error','-threads','2','-i',str(path),'-frames:v','1','-vf','scale=1920:1080:force_original_aspect_ratio=decrease','-y',str(temporary)],capture_output=True,timeout=30,check=True)
    with Image.open(temporary) as image:image.verify()
    temporary.chmod(0o600);temporary.replace(poster)
   finally:temporary.unlink(missing_ok=True)
 return dict(path=str(path),name=path.stem.replace('_',' '),poster=str(poster),dynamic=dynamic,animated=animated)

def catalog():
 LIBRARY.mkdir(parents=True,exist_ok=True);(LIBRARY/'Dynamic').mkdir(exist_ok=True);rows=[];errors=[]
 for path in sorted(LIBRARY.rglob('*'),key=lambda p:str(p).casefold()):
  if path.is_file() and path.suffix.lower() in IMAGES|VIDEOS:
   try:rows.append(describe(path))
   except Exception:errors.append(path.name)
 return dict(entries=rows,preferences=settings(),media=read(STATE/'media.json',{}),errors=errors)

def select(path):
 item=describe(path)
 # The existing palette pipeline only sees a still image. Publish media identity
 # after its palette/lock/login poster commits successfully.
 subprocess.run([str(HOME/'.local/bin/siverteh-os-shell'),'wallpaper-image',item['poster']],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE,timeout=60)
 atomic(STATE/'media.json',item);return item

def import_files(paths):
 copied=[]
 for value in paths:
  source=Path(urllib.parse.unquote(urllib.parse.urlparse(value).path) if str(value).startswith('file:') else value).expanduser().resolve();item=describe(source)
  if source.is_relative_to(LIBRARY.resolve()):copied.append(str(source));continue
  folder=LIBRARY/('Dynamic' if item['dynamic'] else 'Static');folder.mkdir(parents=True,exist_ok=True);target=folder/source.name;index=1
  while target.exists():target=folder/(source.stem+'-'+str(index)+source.suffix);index+=1
  temporary=target.with_name(target.name+'.importing')
  try:shutil.copy2(source,temporary);temporary.chmod(0o600);temporary.replace(target)
  finally:temporary.unlink(missing_ok=True)
  copied.append(str(target))
 return copied

def main():
 p=argparse.ArgumentParser();p.add_argument('action',choices=['catalog','select','preferences','import','pick','session']);p.add_argument('path',nargs='?');a=p.parse_args()
 try:
  if a.action=='session':
   display=subprocess.check_output(['loginctl','show-user',str(os.getuid()),'--property=Display','--value'],text=True,timeout=3).strip()
   if not display:result={'locked':False,'path':''}
   else:
    locked=subprocess.check_output(['loginctl','show-session',display,'--property=LockedHint','--value'],text=True,timeout=3).strip()=='yes'
    raw=subprocess.check_output(['busctl','--system','call','org.freedesktop.login1','/org/freedesktop/login1','org.freedesktop.login1.Manager','GetSession','s',display],text=True,timeout=3).strip()
    result={'locked':locked,'path':raw.split(' ',1)[1].strip('"')}
  elif a.action=='catalog':result=catalog()
  elif a.action=='select':result=select(a.path)
  elif a.action=='preferences':result=preference(json.loads(sys.stdin.readline()))
  else:
   if a.action=='pick':
    picker=subprocess.run(['zenity','--file-selection','--multiple','--separator=\n','--title=Add wallpapers','--file-filter=Wallpapers | *.png *.jpg *.jpeg *.webp *.gif *.mp4 *.webm *.mkv *.mov *.m4v'],capture_output=True,text=True)
    if picker.returncode:print(json.dumps({'cancelled':True}));return
    paths=picker.stdout.strip().splitlines()
   else:paths=json.loads(sys.stdin.readline())
   result={'imported':import_files(paths)}
  print(json.dumps(result))
 except Exception as e:print(json.dumps({'error':str(e)}));sys.exit(1)
if __name__=='__main__':main()
