#!/usr/bin/env python3
"""Prepare the requested reference artwork locally; never add it to public source."""
import subprocess,urllib.request
from pathlib import Path
cache=Path.home()/'.cache/siverteh-shell-reference';cache.mkdir(parents=True,exist_ok=True)
video=cache/'reference.mp4'
if not video.exists():urllib.request.urlretrieve('https://github.com/user-attachments/assets/0840f496-575c-4ca6-83a8-87bb01a85c5f',video)
image=Path.home()/'Pictures/Wallpapers/Caelestia/reference-landscape.jpg';image.parent.mkdir(parents=True,exist_ok=True)
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-ss','11','-i',str(video),'-frames:v','1','-vf','crop=1750:1040:70:20',str(image)],check=True)
print(image)
