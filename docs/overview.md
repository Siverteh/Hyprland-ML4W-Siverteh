# How Nacre fits together

Nacre is the software and configuration for this personal CachyOS/Hyprland desktop.
This repository maintains an existing supported host; a general public installer
is future work. See [maintenance](maintenance.md) for changes and recovery and
[component ownership](architecture.md) for the boundaries between components.

## The main pieces

Hyprland places windows and handles workspaces and keyboard bindings. UWSM supplies
the session environment and starts enabled user services. Quickshell draws Nacre's
bar, frame, dashboard, settings, launcher, wallpaper picker, notifications and
control center and temporary level feedback. The bar, frame and panels share one
window per output so their drawing order stays fixed. Its renderer is separate from the persistent AI backend, so UI
recovery can preserve running conversations.

Orient extracts wallpaper colors and generates readable UI roles. Desktop helpers
publish those roles to the shell, window borders, GTK/Qt, Kitty, branding, lock
screen and optional login appearance. Dolphin uses a scoped native Qt/KDE palette adapter;
Quickshell, Dolphin, Qt/KDE plugins and Papirus are system packages owned by pacman.
The palette Python environment and compiled Dolphin style adapter stay local.

Hypridle and Hyprlock own idle/sleep locking and password authentication. SDDM
owns login authentication. Nacre prepares their appearance; it does not replace
those authentication boundaries. Nacre AI manages Codex/Claude conversations and
project work. Brain indexes the separate private Markdown vault through an
authenticated local server and dedicated browser profile.

## From wallpaper to desktop colors

1. The wallpaper helper caches thumbnails, previews and still posters for moving
   wallpapers. An event-driven watcher prepares missing palettes and appearance
   assets; unchanged files reuse their results.
2. Selection uses one commit queue and palette lock. The publisher validates the
   complete palette before writing companion themes and a matched poster/palette
   record. These files are replaced individually, not as one filesystem transaction.
3. Quickshell keeps the old image until the matching new image is ready, then
   activates its palette and starts the transition. Appearance settings and the
   picker share the same cache and publication owner.

Natural keeps distinct source colors; optional Harmony favors related supporting
accents. Per-image choices persist privately. Fixed palettes use reproducible
checked-in presets. Rotation selects existing library entries on a saved deadline;
video playback follows lock, sleep, battery and visibility policy. See
[Orient](features/orient.md) and [Appearance](features/appearance.md).

## Startup order

1. SDDM authenticates and starts UWSM, which reads `uwsm/env` and
   `uwsm/env-hyprland` for the compositor and graphical user services.
2. Hyprland loads managed Lua modules, then private monitor, palette, desktop,
   shortcuts and host overrides in that order. An error in one private file is
   reported without preventing later files from loading.
3. Enabled services own the shell, Brain, Hypridle and power-key handling.
   Hyprland's startup hook submits wallet initialization, polkit, clipboard
   watching and selected startup apps through UWSM.
4. Startup reuses existing windows: browser 1, AI 2, Discord 3, Spotify 4, mail 5,
   Brain 6. Editors route to 7; plain terminals are unrestricted.

## To change something

| Change | Owner |
|---|---|
| App placement | `hypr/conf/windowrule.lua`; Brain exceptions in `hypr/conf/brain.lua` |
| Keyboard bindings | `hypr/conf/keybinding.lua` and `nacre/shell-tools/shortcuts.lua` |
| Window appearance | `hypr/conf/window.lua`, `decoration.lua`, `animation.lua`; private overrides load last |
| Cursor and toolkit environment | `uwsm/env`, `uwsm/env-hyprland`, `hypr/conf/cursor.lua` |
| Idle timeouts | Private `~/.config/nacre/hypridle.local.conf`; managed sleep hooks in `hypr/hypridle.conf` |
| Bar, menus and picker | `nacre/shell/modules/`; shared controls in `widgets/` |
| Shared UI state and native data | `nacre/shell/services/` |
| Colors and wallpaper publication | Orient in `nacre/shell-cli/`; `wallpaper-media.py` and `classic-state.py` in `shell-tools/` |
| Host preferences and startup selections | Settings UI and private `~/.config/nacre/` files |
| AI or knowledge tools | `ai/`, `bin/`, `brain/`; read `ai/AGENTS.md` before workflow changes |

Managed configuration is deployed as copies with drift protection. Wallpapers,
accounts, conversations, browser profiles, generated host colors and the vault
stay outside Git. Historical commits still contain retired material; the
[current-tree audit](nacre/CURRENT-TREE-AUDIT.md) distinguishes history, current
source and active runtime. Its review remains separate from functional and visual
acceptance. The [repository boundary proposal](repository-boundaries.md) covers
possible future extraction; it is not an implemented public installer.

## Feature guides

- [Foundation](features/foundation.md), [frame/input ownership](features/frame-panels.md)
- [Settings and lock screen](features/settings-lock.md), [wallpapers](features/wallpapers.md)
- [Rotation and fixed palettes](features/appearance.md), [Orient](features/orient.md)
- [Launcher](features/launcher.md), [frame lips](features/edge-menus.md), [control center](features/control-center.md)
- [Audio, Wi-Fi and Bluetooth](features/connections.md), [state services](features/state-services.md)
- [Platform services](features/platform-services.md), [color/light services](features/colour-light.md)
- [Image/presentation state](features/image-presentation.md), [fonts](features/fonts.md)
- [Dolphin](file-manager.md), [terminal branding](features/terminal-branding.md)
- [Session environment](features/session.md), [travel timezone](features/travel-timezone.md)
- [Runtime ownership](features/runtime.md), [Nacre name migration](features/nacre-rename.md)
- [Nacre Brain](features/nacre-brain.md)
- [Health and recovery](features/health-and-recovery.md), [Brain authentication](features/brain-authentication.md)

The [provenance tracker](nacre/PROVENANCE.md) records rewrite and audit evidence.
Source review and passing tests do not prove that every physical device, cold
login or preferred layout has passed acceptance. Visual cleanup is planned after
the complete originality audit.

The [shared logo specification](specs/nacre-logo.md) describes the approved shell
master and its small/large, web, login, lock and terminal forms.

`nacre-ai` opens the AI workspace menu. `siverteh-ai` remains a compatibility
command for existing sessions and private workflow helpers.

Terminal logo colors follow palette events through the existing publisher. The
Fastfetch startup hook prepares its registered image; see the
[terminal guide](features/terminal-branding.md) for behavior and limits.

Search for **Nacre AI** in the app launcher to open its terminal workspace menu.
