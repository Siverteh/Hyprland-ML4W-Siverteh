#!/usr/bin/env python3
"""Automatic travel timezone updates. The UTC clock remains NTP-owned."""
import argparse,datetime as dt,json,os,re,shutil,subprocess,time,urllib.request
from pathlib import Path
from zoneinfo import ZoneInfo
CONFIG=Path('/etc/siverteh-os/timezone.json');STATE=Path('/var/lib/siverteh-os/timezone');PROGRAM=Path('/usr/local/libexec/siverteh-timezone.py')
SERVICE='''[Unit]
Description=Siverteh automatic travel timezone
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=60
StartLimitBurst=2
[Service]
Type=oneshot
ExecStart=/usr/bin/python3 /usr/local/libexec/siverteh-timezone.py update
TimeoutStartSec=30
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes
ReadWritePaths=/var/lib/siverteh-os/timezone
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
CapabilityBoundingSet=
'''
TIMER='''[Unit]
Description=Check the travel timezone every15minutes
[Timer]
OnBootSec=1min
OnCalendar=*:0/15
Persistent=true
RandomizedDelaySec=20
[Install]
WantedBy=timers.target
'''
DISPATCH='''#!/bin/sh
case "$2" in
 up|dhcp4-change|dhcp6-change|connectivity-change) /usr/bin/systemctl start --no-block siverteh-timezone.service ;;
esac
'''
def run(*args):return subprocess.check_output(['/usr/bin/'+args[0],*args[1:]],text=True,stderr=subprocess.PIPE,timeout=15).strip()
def valid_zone(zone):
 if not isinstance(zone,str) or len(zone)>100 or not re.fullmatch(r'[A-Za-z0-9_+-]+(?:/[A-Za-z0-9_+-]+)*',zone):raise ValueError('Use a valid IANA timezone name')
 ZoneInfo(zone);return zone
def read(path,default):
 try:return json.loads(path.read_text())
 except (OSError,ValueError):return default

def atomic(path,data,mode=0o644):
 path.parent.mkdir(parents=True,exist_ok=True);temp=path.with_name(path.name+'.next');temp.write_text(json.dumps(data,indent=2)+'\n');temp.chmod(mode);temp.replace(path)

def state():
 zone=run('timedatectl','show','--property=Timezone','--value')
 data=read(STATE/'status.json',{})
 return dict(installed=PROGRAM.exists(),automatic=read(CONFIG,{}).get('automatic',False),timezone=zone,localTime=dt.datetime.now(ZoneInfo(zone)).strftime('%A, %d %B · %H:%M %Z'),**{k:v for k,v in data.items() if k in ('checked','detected','error','source')})

def detect():
 with urllib.request.urlopen(urllib.request.Request('https://ipinfo.io/json',headers={'User-Agent':'Siverteh-OS/1.0'}),timeout=8) as response:
  raw=response.read(20001)
  if len(raw)>20000:raise ValueError('Location response too large')
  return valid_zone(json.loads(raw)['timezone'])

def update(force=False):
 if not read(CONFIG,{}).get('automatic',False):return
 old=read(STATE/'status.json',{})
 if not force and time.time()-old.get('epoch',0)<300:return
 try:
  zone=detect();current=run('timedatectl','show','--property=Timezone','--value')
  if current!=zone:run('timedatectl','set-timezone',zone)
  atomic(STATE/'status.json',dict(epoch=time.time(),checked=dt.datetime.now(dt.timezone.utc).isoformat(),detected=zone,source='Public IP location',error=''))
 except Exception:
  atomic(STATE/'status.json',dict(old,error='Automatic lookup unavailable; the current timezone was kept'))

def require_root():
 if os.geteuid()!=0:raise PermissionError('Administrator authentication is required')

def install(zone=None):
 require_root();STATE.mkdir(parents=True,exist_ok=True)
 zone=zone or None
 if zone:valid_zone(zone)
 backup=STATE/('backup-'+dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%SZ'));backup.mkdir(mode=0o700)
 paths=[PROGRAM,CONFIG,Path('/etc/systemd/system/siverteh-timezone.service'),Path('/etc/systemd/system/siverteh-timezone.timer'),Path('/etc/NetworkManager/dispatcher.d/80-siverteh-timezone')]
 entries=[]
 for index,path in enumerate(paths):
  entry={'path':str(path),'existed':path.exists()}
  if path.exists():shutil.copy2(path,backup/str(index));entry['backup']=str(backup/str(index))
  entries.append(entry)
 atomic(backup/'manifest.json',dict(previousTimezone=run('timedatectl','show','--property=Timezone','--value'),entries=entries),0o600)
 PROGRAM.parent.mkdir(parents=True,exist_ok=True);
 if Path(__file__).resolve()!=PROGRAM.resolve():shutil.copyfile(Path(__file__).resolve(),PROGRAM)
 PROGRAM.chmod(0o755)
 for path,body in [(paths[2],SERVICE),(paths[3],TIMER),(paths[4],DISPATCH)]:path.parent.mkdir(parents=True,exist_ok=True);path.write_text(body);path.chmod(0o755 if path==paths[4] else 0o644)
 atomic(CONFIG,dict(automatic=True))
 if zone:run('timedatectl','set-timezone',zone)
 run('systemctl','daemon-reload');run('systemctl','enable','--now','siverteh-timezone.timer');update(force=True)

def main():
 p=argparse.ArgumentParser();p.add_argument('action',choices=['state','install','update','automatic','manual']);p.add_argument('value',nargs='?');a=p.parse_args()
 try:
  if a.action=='install':install(a.value)
  elif a.action=='update':require_root();update()
  elif a.action=='automatic':
   require_root()
   if a.value not in ('on','off'):raise ValueError('Choose on or off')
   atomic(CONFIG,dict(automatic=a.value=='on'))
   run('systemctl','enable' if a.value=='on' else 'disable','--now','siverteh-timezone.timer')
   if a.value=='on':update(force=True)
  elif a.action=='manual':
   require_root();zone=valid_zone(a.value);atomic(CONFIG,dict(automatic=False));run('systemctl','disable','--now','siverteh-timezone.timer');run('timedatectl','set-timezone',zone)
  print(json.dumps(state()))
 except Exception as e:print(json.dumps(dict(error=str(e))));raise SystemExit(1)
if __name__=='__main__':main()
