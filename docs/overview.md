# How Siverteh OS fits together

Siverteh OS is the maintained software and configuration for this CachyOS desktop.
The [maintenance guide](maintenance.md) explains checks, deployment and rollback.

## The main pieces

- **UWSM** starts the graphical session and gives user services their environment.
- **Hyprland** places windows, handles workspaces and runs keyboard shortcuts.
- **Quickshell** draws the bar, frame, top settings menu, launchers, notifications,
  wallpaper views and AI sidebar. Its renderer is separate from the AI worker.
- **The palette publisher** applies wallpaper colors to the shell, window borders,
  GTK/Qt settings, Kitty, lock screen and login appearance.
- **Hypridle and Hyprlock** handle idle/sleep locking and password authentication.
  SDDM handles the initial login. Wallpaper code supplies appearance only.
- **Siverteh AI** manages Codex/Claude conversations and project work. **Brain**
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
3. Enabled user services start the desktop shell, Brain and Hypridle. Hyprland's
   small startup hook launches wallet initialization, the authentication agent,
   clipboard watcher and selected apps through UWSM.
4. Startup apps reuse existing windows: browser 1, AI 2, Discord 3, Spotify 4,
   mail 5 and Brain 6. Editors route to 7; ordinary terminals are unrestricted.

## To change something

| Change | Edit |
|---|---|
| Workspaces and app placement | `hypr/conf/windowrule.lua`; Brain exceptions in `brain.lua` |
| Keys and window appearance | `hypr/conf/keybinding.lua`, `siverteh/shell-tools/shortcuts.lua`, `window.lua`, `decoration.lua` |
| Environment and cursor defaults | `uwsm/env`, `uwsm/env-hyprland`, `hypr/conf/cursor.lua` |
| Idle locking | `hypr/hypridle.conf` |
| Bar, menus and picker layouts | `siverteh/shell/modules/` |
| Shared UI state and background work | `siverteh/shell/services/` |
| Wallpaper/palette publication | `siverteh/shell-tools/wallpaper-media.py`, `classic-state.py`; generator in `siverteh/shell-cli/` |
| Startup selections and host preferences | Settings UI; private `~/.config/siverteh-shell/` files |
| AI commands or Brain behavior | `ai/` or `brain/`; follow their project instructions |

Source is deployed as copies. Generated colors, wallpaper libraries and personal
settings remain outside Git. Older commits retain previously published artwork;
that is different from the current private wallpaper library. See the
[repository boundary proposal](repository-boundaries.md) for optional future splits.
