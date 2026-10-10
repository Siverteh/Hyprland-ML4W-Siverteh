# How Nacre fits together

Nacre is the maintained software and configuration for this CachyOS desktop.
The [maintenance guide](maintenance.md) explains checks, deployment and rollback.

## The main pieces

- **Base configuration** uses independent Nacre compositor/terminal defaults;
  private overrides and generated palette stay separate.
- **UWSM** starts the graphical session and gives user services their environment.
- **Hyprland** places windows, handles workspaces and runs keyboard shortcuts.
- **Quickshell** draws the bar, frame, top settings menu, launchers, notifications,
  wallpaper views and AI sidebar. Desktop/AI launch actions live in desktop helpers,
  separately from Brain knowledge actions. Its renderer is separate from the AI worker.
- **Dashboard assembly** uses NacreDashboardPanel and immediate five-tab
  navigation. The overview cards are fresh Nacre components; full Media and Performance pages also use new components. Workspaces now uses a fresh overview; Settings navigation and shared controls also use fresh components; Appearance now has fresh controls; Desktop/Displays/Workflows/Maintenance pages also use new views. All twelve Settings pages now use Nacre views; their underlying helper audit
  remains separate.
- **Notification presentation** uses NacreNotice and a bounded popup stack; the
  NacreNotifs owns expiry, DND and private retained history.
- **Root and panel routing** use NacrePanelState, NacreShellIpc and
  NacreShellShortcuts; display recovery and private workers keep their ownership.
- **Top bar and hover policy** use NacreTopBar/Header/WorkspaceRow and
  NacreHoverIntent, with separate nonmodal trigger and passive click forwarding.
- **Bar controls** use NacreActiveTitle, NacreStatusIcons and NacrePowerButton;
  all six popouts use NacrePopupPanel with native data, bounded controls and
  Nacre calendar calculations.
- **Wallpaper and weather providers** use NacreWallpapers and NacreWeather.
  Wallpaper commits share one queue and preserved rotation deadline; weather reads
  private cached forecasts and reports unavailable/stale data.
- **The palette publisher** applies wallpaper colors to the shell, window borders,
  GTK/Qt settings, Kitty, lock screen and login appearance.
- **OSD/session/background presentation** uses independent Nacre wrappers and
  native buffers/media. Existing providers and frame input remain the owners.
- **Hypridle and Hyprlock** handle managed sleep locking and private idle timeouts and password authentication.
  The physical power-button tap locks through the same session path; its user
  inhibitor prevents a competing short-press shutdown. A prepared single-tile
  dashboard supplies weather, media, palette, resource gauges and notifications;
  Hyprlock owns its password field. SDDM handles the initial login. Wallpaper code
  supplies appearance only.
  The login theme installs four presentation files; the unused console banner
  imported with the old dotfiles is retired. The system console banner stays
  owned by the distribution.
- **Nacre AI** manages Codex/Claude conversations and project work. **Brain**
  browses saved knowledge in a separate local server and browser window. Accounts,
  conversations and the Markdown vault are private data outside this repository.
- **Desktop presets** change desktop behavior and recall explicitly saved workflows.
  They preserve current lock-screen privacy and weather preferences, including Docked.

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
   The shell service uses `nacre-shell start`, its supervisor and the Qt-checked
   `launch.sh` wrapper. The unused reference-era `run.fish` launcher is retired.
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

Launcher mode assembly is now owned by NacreLauncherPanel and the fresh legacy
search/action view NacreSearchPanel. The inherited list/item stack is retired;
app/wallpaper presentation now uses fresh NacreAppBrowser/WallpaperPicker types;
backend service/extra-mode provenance remains pending its own areas.

The twelve Settings pages now use independently implemented Nacre components.
Sound binds native PipeWire nodes only while loaded; connection, time, lock and AI
pages request explicit actions through existing owners. Notification history
reuses NacreNotice and asks for confirmation before clearing. Backend provenance
remains a separate task; see [Settings behavior](features/settings-lock.md).

Default audio and connection state now belong to NacreAudio, NacreNetwork and
NacreBluetooth. Audio/Bluetooth use native event models; Wi-Fi uses a read-only
NetworkManager snapshot helper and a long-lived monitor. Legacy service names
only forward to these owners. Existing DeviceActions owns connection writes;
see [connection services](features/connections.md).

NacrePlayers owns media selection/IPC using native MPRIS capabilities.
NacreSystemUsage reads fast proc counters natively only for visible resource
views and uses occasional read-only disk/sysfs snapshots. NacreNotifs owns the
single notification server, live entries and guarded private-history merging/
saving; old service names forward to these owners. See
[the service guide](features/state-services.md) for limits and lifecycle behavior.

NacreApps owns native desktop discovery and independently ranked search, while
AppLaunch retains parsed-command/themed-entry scope. NacreTime supplies one native
minute clock with optional seconds. NacreHyprland exposes stable native client
views, canonical addresses, event-driven metadata/focus and Lua-aware dispatch.
See [platform services](features/platform-services.md); palette and brightness
providers remain separate work.

NacreColours validates complete Orient roles and publishes one QColor snapshot
from the matched presentation owner. NacreBrightness/NacreKeyboardLight share
read-only discovery and NacreLightChannel native file readers/user-only writes.
Controls use NacreBacklight, with explicit adjusted signals for the indicator.
See [colour and light services](features/colour-light.md).

The unused generic Thumbnailer provider is retired. Optional NacreImage uses
native Qt loading/size/cache/error behavior, while maintained wallpaper previews
stay with their prepared-cache owner. NacrePresentation validates and stages one
watched wallpaper/palette record; only matching readiness activates a new poster.
The ThemePresentation name forwards to it. See
[image and presentation behavior](features/image-presentation.md).

The [whole-tree provenance audit](nacre/CURRENT-TREE-AUDIT.md) inventories source,
helpers, tests, configuration and assets separately from functional acceptance.

The unused legacy file-thumbnail Python helper is retired; native Qt images and
prepared wallpaper posters supply previews without a second thumbnail worker.

The unused Cava/Spectrum visualizer and its beat utility are retired. Maintained
media views read the native player provider; no audio visualizer process is needed.

Session input/layout/window/output defaults are independently expressed in the
six small Hyprland config files; UWSM owns cursor preference and private overrides
retain final precedence. See [the session-default spec](specs/session-defaults.md).

Compositor motion defaults use four owned Nacre curves and transition families,
leaving child inheritance and private accessibility overrides intact. Unused
legacy curves are retired; see [motion defaults](specs/motion-defaults.md).

The own startup composition submits wallet/polkit/clipboard/battery/app helpers
only on the actual startup event, with literal argument boundaries. Enabled
systemd services keep separate ownership; see [startup spec](specs/session-startup.md).

NacreBatteryAlerts shares cached native UPower data with the bar and owns20%/15%
warning policy once per discharge episode. No shell battery polling loop remains;
see [battery alert ownership](specs/battery-alerts.md).

Managed shortcuts use own declarative groups and generated workspace/direction
families. Restricted Lua contract capture keeps conflict checks effective for
generated keys; see [shortcut specification](specs/keybindings.md).

Own ordered named application routes preserve the current workspace map and
Thunar popup. Restricted rule capture checks generated route/float conflicts;
see [routing specification](specs/window-routing.md).

The compositor entry point now uses an independently composed ordered module list.
Private overrides keep their monitor → palette → desktop → shortcuts → host order
and contained errors. Brain and extra shortcut declarations retain their verified
local authoring history; their command implementations remain separate audit areas.
See [the entry-point spec](specs/compositor-entrypoint.md).

The palette publisher validates all required roles before applying them and
serializes direct, prepared and CLI selections through the same commit guard.
It keeps the current wallpaper deadline when only colors are re-published.
See [appearance publication behavior](features/appearance.md#publishing-a-palette-safely).

Fonts are independently provisioned from pinned official assets and retained
notices. The font owner verifies checksums, protects edits and records rollback
before moving recognized legacy files to the canonical Nacre user directory.
See [font ownership](features/fonts.md).
