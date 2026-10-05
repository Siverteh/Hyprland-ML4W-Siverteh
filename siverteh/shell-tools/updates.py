#!/usr/bin/env python3
"""Read-only cached update count; refreshing never upgrades or modifies packages."""
import argparse,fcntl,json,os,shutil,subprocess,time
from pathlib import Path
CACHE=Path.home()/".cache/siverteh-os/updates.json"
def count_updates():
    commands=[["checkupdates"]] if shutil.which("checkupdates") else [["pacman","-Qu"]]
    helper=next((x for x in ("paru","yay") if shutil.which(x)),None)
    if helper:commands.append([helper,"-Qua"])
    total=0
    for command in commands:
        if not shutil.which(command[0]):continue
        result=subprocess.run(command,capture_output=True,text=True,timeout=90)
        if result.returncode not in ((0,1) if command[0]=="pacman" else (0,2)):raise RuntimeError("Update check failed")
        total+=len([line for line in result.stdout.splitlines() if line.strip()])
    return {"text":str(total),"count":total,"checked":time.time()}
def refresh():
    CACHE.parent.mkdir(parents=True,exist_ok=True)
    with CACHE.with_suffix(".lock").open("w") as guard:
        try:fcntl.flock(guard,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError:return
        data=count_updates();temp=CACHE.with_suffix(".next");temp.write_text(json.dumps(data));os.replace(temp,CACHE)
def main():
    parser=argparse.ArgumentParser();parser.add_argument("--refresh",action="store_true");args=parser.parse_args()
    if args.refresh:refresh();return
    try:data=json.loads(CACHE.read_text())
    except (OSError,ValueError):data={"text":"0","count":0,"checked":0}
    print(json.dumps(data),flush=True)
    if time.time()-data.get("checked",0)>1800:
        subprocess.Popen([sys.executable,str(Path(__file__).resolve()),"--refresh"],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,start_new_session=True)
import sys
if __name__=="__main__":main()
