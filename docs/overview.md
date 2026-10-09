# How Nacre fits together

Nacre is the maintained software and configuration for this CachyOS desktop.
The [maintenance guide](maintenance.md) explains checks, deployment and rollback.

## The main pieces

- **UWSM** starts the graphical session and gives user services their environment.
- **Hyprland** places windows, handles workspaces and runs keyboard shortcuts.
- **Quickshell** draws the bar, frame, top settings menu, launchers, notifications,
  wallpaper views and AI sidebar. Desktop/AI launch actions live in desktop helpers,
  separately from Brain knowledge actions. Its renderer is separate from the AI worker.
- **The palette publisher** applies wallpaper colors to the shell, window borders,
  GTK/Qt settings, Kitty, lock screen and login appearance.
- **Hypridle and Hyprlock** handle managed sleep locking and private idle timeouts and password authentication.
  The physical power-button tap locks through the same session path; its user
  inhibitor prevents a competing short-press shutdown. A prepared single-tile
  dashboard supplies weather, media, palette, resource gauges and notifications;
  Hyprlock owns its password field. SDDM handles the initial login. Wallpaper code
  supplies appearance only.
- **Nacre AI** manages Codex/Claude conversations and project work. **Brain**
  browses saved knowledge in a separate local server and browser window. Accounts,
  conversations and the Markdown vault are private data outside this repository.

## From wallpaper to desktop colors

The wallpaper helper prepares small thumbnails, a larger preview and a still
poster for videos/GIFs. File identity and modification time invalidate cached
results. A low-priority worker prepares palettes and login images once; unchanged
files reuse their results. The original image or video remains the desktop source.

A selection uses the existing palette publisher and its lock. It writes toolkit,
terminal and lock/login appearance, plus a record containing the poster and shell
palette together. Quickshell retains the old background until the matching new
image is ready, then starts its transition and presents its colors in the same
rendering step. Missing caches use the normal generation path. No timer repeatedly
regenerates colors or images. Moving videos pause behind covered workspaces,
on lock and on sleep; the picker temporarily allows a live preview.

## Startup order

1. SDDM authenticates; UWSM loads `uwsm/env` and `uwsm/env-hyprland` before starting
   the compositor and graphical user services.
2. Hyprland loads its base window, appearance, routing and shortcut files. Private
   monitor overrides, the generated palette, saved desktop settings and private
   shortcuts load afterward, so host preferences keep their priority.
3. Enabled user services start the desktop shell, authenticated Brain server and Hypridle. Hyprland's
   small startup hook launches wallet initialization, the authentication agent,
   clipboard watcher and selected apps through UWSM.
4. Startup apps reuse existing windows: browser 1, AI 2, Discord 3, Spotify 4,
   mail 5 and Brain 6. Editors route to 7; ordinary terminals are unrestricted.

## To change something

| Change | Edit |
|---|---|
| Workspaces and app placement | `hypr/conf/windowrule.lua`; Brain exceptions in `brain.lua` |
| Keys and window appearance | `hypr/conf/keybinding.lua`, `nacre/shell-tools/shortcuts.lua`, `window.lua`, `decoration.lua` |
| Environment and cursor defaults | `uwsm/env`, `uwsm/env-hyprland`, `hypr/conf/cursor.lua` |
| Idle locking | Private listeners in `~/.config/nacre/hypridle.local.conf`; sleep hooks in `hypr/hypridle.conf` |
| Bar, menus and picker layouts | `nacre/shell/modules/` |
| Shared UI state and background work | `nacre/shell/services/` |
| Wallpaper/palette publication | `nacre/shell-tools/wallpaper-media.py`, `classic-state.py`; generator in `nacre/shell-cli/` |
| Startup selections and host preferences | Settings UI; private `~/.config/nacre/` files |
| AI commands or Brain behavior | `ai/` or `brain/`; follow their project instructions |

Source is deployed as copies. Host-generated colors, wallpaper libraries and personal
settings remain outside Git. Older commits retain previously published artwork;
that is different from the current private wallpaper library. See the
[repository boundary proposal](repository-boundaries.md) for optional future splits.

## Feature guides

- [Shared UI foundation](features/foundation.md), [frame and panel ownership](features/frame-panels.md)
- [Settings and prepared lock screen](features/settings-lock.md)
- [Wallpaper previews and layouts](features/wallpapers.md)
- [Rotation and fixed color palettes](features/appearance.md)
- [Launcher](features/launcher.md), [edge menus and hover intent](features/edge-menus.md)
- [Audio, Wi-Fi and Bluetooth](features/connections.md)
- [Thunar appearance](file-manager.md), [terminal branding](features/terminal-branding.md)
- [Session environment](features/session.md), [travel timezone](features/travel-timezone.md)
- [Runtime dependencies and path compatibility](features/runtime.md)

Quickshell, Thunar, Qt plugins and Papirus are system packages updated by pacman.
Only the palette engine's Python environment and compiled Thunar style module
remain private. Fixed palettes are reproducible, checked-in generated presets;
wallpaper-derived host colors remain private.

The [health and recovery guide](features/health-and-recovery.md) explains sync,
portal status and per-output view recovery. [Brain authentication](features/brain-authentication.md)
explains the automatic local browser session and private credential boundary.

The [Nacre name migration](features/nacre-rename.md) lists canonical directories,
legacy aliases, namespace recovery and the separate system-owned migration.

## Independent implementation work

The [rewrite tracker](nacre/PROVENANCE.md) records the planned replacement of
inherited implementation. [Orient](specs/orient.md) describes the independent palette engine. The separate
[comparison proposal](specs/orient-comparison.md) was superseded by the user
request for direct production implementation. See [Orient behavior](features/orient.md)
for extraction, readability, cached per-wallpaper palette choices, frame tint and compatibility.

Shared shell controls and layout defaults are owned by the independent
[Nacre foundation](features/foundation.md). Maintained consumers use Nacre type
names; compatibility adapters preserve older external configuration. Exterior
chrome uses one body token, while inner cards use raised surfaces.

Appearance offers Natural wallpaper colors or optional Harmony, which favors related
supporting accents. The [Orient guide](features/orient.md) explains the setting,
readability and cache behavior. Both use the same publisher and no idle extraction.
