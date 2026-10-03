#!/usr/bin/env python3
"""Draw original vector landscapes for the Observatory wallpaper collection."""
from pathlib import Path
import random
import sys

out=Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=True)
for name,sky,mist,accent in [('tidal-orbit','#0a171e','#28565c','#80d9cc'),('blue-hour','#101a2b','#344a69','#a4bfe3'),('ember-orbit','#1b2024','#5b5147','#e6bc89')]:
    random.seed(74)
    parts=[f'''<svg xmlns="http://www.w3.org/2000/svg" width="3840" height="2400" viewBox="0 0 3840 2400"><defs>
    <linearGradient id="sky" x2="0" y2="1"><stop stop-color="{sky}"/><stop offset="1" stop-color="{mist}"/></linearGradient>
    <radialGradient id="haze"><stop stop-color="{accent}" stop-opacity=".18"/><stop offset="1" stop-color="{accent}" stop-opacity="0"/></radialGradient>
    <radialGradient id="planet" cx=".3" cy=".25"><stop stop-color="{accent}" stop-opacity=".7"/><stop offset=".6" stop-color="{mist}"/><stop offset="1" stop-color="{sky}"/></radialGradient>
    <linearGradient id="fade" x2="0" y2="1"><stop stop-color="{sky}" stop-opacity="0"/><stop offset="1" stop-color="{sky}"/></linearGradient>
    </defs><path fill="url(#sky)" d="M0 0H3840V2400H0Z"/><ellipse cx="2800" cy="1300" rx="1700" ry="1250" fill="url(#haze)"/>''']
    for i in range(420):
        x=random.randrange(3840);y=random.randrange(1750);r=random.choice([.7,1,1.4,1.9]);a=random.uniform(.08,.45)
        parts.append(f'<circle cx="{x}" cy="{y}" r="{r}" fill="#d9e9e3" opacity="{a:.2f}"/>')
    parts.append(f'''<g transform="translate(2870 680) rotate(-24)"><ellipse rx="315" ry="92" fill="none" stroke="{accent}" stroke-opacity=".13" stroke-width="1.5"/><circle r="166" fill="url(#planet)"/><ellipse rx="315" ry="92" fill="none" stroke="{accent}" stroke-opacity=".22" stroke-width="1.5"/></g>
    <circle cx="2380" cy="870" r="13" fill="{accent}" opacity=".38"/>
    <path d="M0 1790L430 1530 660 1690 1100 1400 1500 1640 1880 1540 2210 1690 2610 1470 2950 1700 3330 1510 3840 1730V2400H0Z" fill="{sky}" opacity=".27"/>
    <path d="M0 1940L320 1810 580 1880 960 1710 1320 1920 1720 1810 2150 1930 2440 1750 2840 1930 3220 1810 3560 1950 3840 1830V2400H0Z" fill="{sky}" opacity=".5"/>
    <path d="M0 2100L510 2070 900 2140 1510 2020 2020 2140 2680 2060 3200 2130 3840 2090V2400H0Z" fill="{sky}" opacity=".85"/>
    <path fill="url(#fade)" d="M0 1550H3840V2400H0Z"/>
    <g transform="translate(1880 2020)" fill="none" stroke="{accent}" stroke-opacity=".38"><path d="M-26 80V-8Q0-60 26-8V80M-45 80H45M-35 15H35"/><path d="M0-30V-73M-15-65L15-81"/><circle cy="-84" r="3" fill="{accent}"/></g></svg>''')
    (out/(name+'.svg')).write_text(''.join(parts))
