# Siverteh Observatory

First desktop pass: matte tidal surfaces, a Quickshell bar and OS control panel,
original orbital wallpapers, and a local 3D knowledge explorer. Source and private
knowledge remain separate. This directory contains no vault data.

## Daily use

- Click the center star or press **Super+O** for the OS panel. Escape closes it.
- Click outside the panel or press the center button again to close it. Wi-Fi
  and Bluetooth icons on the right open their selectors. Compact app icons are
  grouped across all workspaces and ordered by the lowest workspace in each
  group; click a multiple-window group to choose a window.
- Wi-Fi/Bluetooth icons have no hover text and activate on mouse press. The
  package cube shows the existing cached update count and opens the original
  terminal updater/confirmation flow. Counts refresh asynchronously through the
  existing checker, at most every 30 minutes, without gating workspace events.
- **Super+B** opens Brain on workspace 6; **Super+N** captures a thought.
- Brain stays running throughout the graphical session. Its user service starts
  at login, keeps the local server alive and reopens the window on workspace 6
  if closed, while preserving your current workspace. Super+B brings it forward.
  Stop it deliberately with `systemctl --user stop siverteh-observatory-brain`.
- **Super+Alt+C** retains the existing AI workspace launcher.
- Workspaces: 1 Browse, 2 Work, 3 Chat, 4 Music, 5 Mail, 6 Brain, 7 Spare.
  Existing editors are preserved on 7, reachable with Super+7.
- In Brain, projects and personal worlds are compact warm suns with orbital systems.
  Topics are planets on separate orbits; individual evidence notes are cratered moons with readable names.
  Click a star to reveal planets, then a planet to reveal its moons. Moon labels
  are clickable and hover shows the full title.
  Selection smoothly centers and zooms to that constellation while unrelated
  branches fade. Back or Escape returns one level and folds the branch you left;
  Overview returns to the full map. The Zoom button pulls back without leaving
  the selected object.
  Drag to orbit and scroll to zoom. The inspector reads the original Markdown;
  Open original launches Obsidian. Knowledge searches note titles and paths.
- Recent focus sizes hubs from dated notes with a 21-day half-life and capped
  daily contribution. All knowledge sizes by related-note count. Neither mode
  tracks complete conversations or equates size with factual confidence.
- Ambient motion can be disabled. Rendering pauses while the page is hidden.
- Workspace highlights and app icons use native Hyprland events. They update
  independently of the slower audio/network/calendar status polling.
- Wallpaper selection stays within `~/Pictures/Wallpapers/Observatory`.
  Rotation is every 90 minutes. The pause icon holds the current wallpaper;
  `siverteh-observatory hold` toggles the same setting.

## Installation and rollback

Run `python3 rice/observatory/install.py` from the chosen source checkout.
The installer targets this user's Lua Hyprland configuration. It installs its
code under `~/.local/share/siverteh-ai/observatory`, preserves existing terminal
configuration, and adds appearance/routing rather than replacing the OS tree.
When Quickshell is absent, current distro repository packages are extracted into
a user-local runtime. No root privileges or assistant authentication changes.

Modified configuration and original workspace positions are snapshotted under
`~/.local/state/siverteh-observatory/backups`. Use:

```bash
siverteh-observatory rollback
```

Rollback refuses to overwrite manually changed configuration. Theme-generated
palettes and wallpaper caches may change during normal rotation and are restored
from the snapshot. The separately installed code/runtime and generated wallpaper
collection are retained. Existing application sessions are never closed.

## Knowledge and privacy

The map is extensible. New entries in the existing Siverteh AI project registry
become worlds automatically. Optional `brain.category`, `brain.name`, and
`brain.aliases` in a project entry configure its appearance and matching.
Current wiki pages can declare additional knowledge worlds with `Entity: world`
or `Entity: project`, plus `Name:` and optionally `Category:`. Their filename stem
is the world ID unless `Project:` supplies one. A wiki page with `Entity: topic`
and `Parent: WORLD_ID` creates a smaller topic planet. These are organizational
annotations, not commands or factual-confidence labels.

Evidence notes can include `Project: WORLD_ID` and `Topics: soldering, cameras`
to grow new topic planets without editing the renderer. Existing notes remain
usable with keyword grouping. Do not rewrite historical evidence just to add
metadata; attach annotations to new evidence/current pages. Fields inside code
examples and world declarations in raw imports are ignored.

Colors follow broad subjects: AI blue, electronics amber, software violet,
networks mint, personal gold, music rose, research cyan. Explicit `Category:`
overrides inference; the inspector identifies how the theme was chosen. Color
does not encode correctness or importance. Supported categories: ai,
electronics, software, infrastructure, personal, music, research, general.
New worlds get persistent positions in the local app profile; the overview fits
additional systems instead of reusing the first six positions.

The server binds `127.0.0.1:17843`. It serves local assets and a derived index of
managed Markdown notes, excluding hidden state, instruction files, and external
symlinks. Actions require same-origin JSON and a fixed allowlist. Reader paths
are checked against the private vault. No CDN, telemetry, or remote AI call is
needed for the explorer. Chrome uses a separate app profile without accounts.

Topic membership is an initial keyword grouping; it is not a verified dependency
graph. Explicit Markdown evidence links remain distinct. Future refinement can
replace suggested groupings with curated topic pages and typed relationships.
No arbitrary private transcript ingestion, automatic note rewriting, or deletion.

## Validation

```bash
python3 -m unittest discover -s rice/observatory/tests -v
env -u CODEX_HOME python3 -m unittest discover -s ai/tests
lua -e 'assert(loadfile("rice/observatory/observatory.lua"))'
bash -n rice/observatory/launch.sh
```

Browser interaction checks use an isolated headless Chrome CDP session on port
17944 and `siverteh-ai-tools node rice/observatory/tests/browser-check.mjs`.
Screenshots and private QA output go to the user state directory, never Git.
Lockscreen appearance is configured but an actual lock/unlock must be tested by
the user; installation does not lock the active session. Calendar shows dates,
not appointments from an unconnected account.
