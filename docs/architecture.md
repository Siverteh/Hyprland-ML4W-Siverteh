# Component ownership

| Component | Source | Owner and deployed location |
|---|---|---|
| Session and compositor | `hypr/`, `uwsm/` | SDDM → UWSM → Hyprland; installed configuration copies in `~/.config/hypr` |
| Desktop UI | `nacre/shell/` | `nacre-shell.service`; validated source in `~/.local/share/nacre/shell` |
| Desktop helpers | `nacre/shell-tools/` | Native settings, notifications, clipboard, update checks, startup apps and assistant bridge |
| Palette and wallpaper engine | `nacre/shell-cli/` | Orient in an isolated Pillow-only Python environment; native bridge is the sole palette publisher |
| Knowledge browser | `brain/` | Loopback server and dedicated browser profile; private Markdown vault remains external |
| AI workflow | `ai/`, `bin/` | Codex/Claude accounts, chats, project registry, skills and memory helpers |
| Login appearance | `nacre/login/` | Optional root-owned SDDM theme; authentication remains SDDM/PAM-owned |
| Terminal presentation | `kitty/`, `fastfetch/` | Installed static config plus private generated SH logo and terminal palette |

NacreDashboardPanel and NacreDashboardNavigation own page selection and lazy
loading. NacreOverview owns overview card composition; its calendar is independent
of the retained CalendarGrid helper. Host cards use asynchronous FileView reads;
media uses the shared active-player service without another MPRIS owner. NacreMediaPage and NacrePerformancePage own media controls and metric rendering;
NacreWorkspacePage owns the seven-card workspace overview; NacreSettings and its shared section/page/toggle controls own navigation and
layout; NacreAppearancePage owns wallpaper/palette/frame preference controls through
existing owners. Four own Desktop/Displays/Workflows/Maintenance pages delegate to the existing
validated owners. Device/lock/time/AI/notification pages also use independent Nacre views.
Remaining helper audits are separate originality work.

NacreNotice and NacreNotificationStack own notification card/stack presentation.
NacreNotifs owns native notification objects, popup expiry and private history; neither
UI component becomes another server or stores native actions in history.

The desktop shell and its desktop-actions helper own core control commands.
Brain owns knowledge navigation/capture and its authenticated browser API.
The desktop shell owns the bar, frame, dashboard, notifications, launcher,
wallpaper chooser and audio/brightness controls. Display settings are stored in
private native state; the old display-rearrangement scripts and competing display
daemon are removed. The enabled Hypridle service uses managed authentication/sleep hooks and private
idle listeners. Existing idle timeouts are preserved; a missing private file is
created before service startup, leaving sleep locking active. KWallet PAM unlocks
the encrypted wallet using password login, with its initialization hook in the
Hyprland startup configuration.

Compositor loading order is base Lua configuration, optional private monitor
overrides, committed palette, saved desktop settings, native shortcuts and private
`host.lua`. Managed binds live in both `hypr/conf/keybinding.lua` and
`nacre/shell-tools/shortcuts.lua`; static app placement lives in `windowrule.lua`. App
routing comes from Lua rules. Startup opens the six requested workspace apps
idempotently; ordinary terminals are unrestricted. No background script rewrites
the source routing rules or broadly moves browser windows.

The native palette bridge publishes to `~/.config/nacre`, GTK and the
installed Hyprlock configuration. The repository contains a boot seed, generation code and generated
`palette-presets.json` fixed-color layouts. A pinned-engine regeneration test
checks the presets. Wallpaper-derived host colors are never committed. Wallpapers live under the user's Pictures directory. App choices can
be overridden with executable argument arrays in `~/.config/nacre/apps.json`.

Runtime names containing `observatory` remain compatibility identifiers for the
existing Brain service and profile. They do not install another desktop. The
public entry point is `siverteh-brain-ui`; the earlier command remains an alias.
Adapted shell and palette-library licenses remain with their source.

Research basis: [Hyprland session management](https://wiki.hypr.land/Useful-Utilities/Systemd-start/),
[Quickshell configuration](https://quickshell.org/docs/v0.2.0/guide/introduction/),
and [KDE automatic wallet selection](https://docs.kde.org/trunk_kf6/en/kwalletmanager/kwalletmanager/kwallet-kcontrol-module.html).
Live dependency tracing determined the retained components; documentation alone
was not used to infer that a component was running.

## Dependency and presentation boundaries

Pacman owns Quickshell, Qt multimedia/image plugins, Thunar/Xfconf and Papirus.
Shell launchers use the system binaries without private library or Qt import path
injection. `shell-runtime/venv` contains only the isolated palette Python engine;
`thunar-style/nacre-thunar-theme.so` is the private GTK style module. The module
applies generated CSS only inside Thunar and leaves applications it opens alone.
System icon artwork supplies the small palette-colored folder overlay.

Wallpaper rotation selects existing private library entries on a configurable
interval; fixed palettes bypass wallpaper extraction. Thumbnail/poster caches and
prepared palettes serve the picker and Appearance settings. The palette publisher
pairs wallpaper and shell color state so transitions share a presentation step.
Prepared lock text, artwork and the single-tile dashboard texture are updated
outside authentication startup. `lock-dashboard.py` owns bounded presentation
rasterization; `lock-config.py` scales the same design coordinates for each output.
Hyprlock alone owns password input, PAM and secure session locking.

`HoverIntent` guards accidental edge entry and immediate reopening. Precise hover
is the default; click handles are an optional overlay, without reserving tiled
window space. Shell layer namespaces start with `nacre-`; blur targets visible
UI surfaces, excluding wallpaper and invisible edge/input surfaces.

Feature behavior belongs in linked [feature guides](overview.md#feature-guides).
The [runtime guide](features/runtime.md) documents compatibility paths; state is
not renamed simply to tidy identifiers.

Brightness services read native sysfs values through FileView; hardware-key IPC
performs writes and drives the indicator. Native refresh runs every five seconds
only while controls are visible, and on opening controls. DDC monitors are read
at discovery and after writes, without a periodic DDC poll. Update launch and
completion share one Qt-version check. Errors remain readable in the update
terminal; a failed shell startup uses Hyprland's own notification channel.

Wallpaper preparation is event-driven through one native watcher, with debounced
catalogue/engine invalidation. Optional battery motion policy reuses cached posters;
shared wallpaper/video state survives per-output UI recovery. Display recovery
captures only UI state and retains the existing full restart fallback, using
private stdin/runtime files for draft-bearing snapshots.

Health queries include on-demand portals and private sync status. Config deployment
owns the shared sync helper and service, adopting only recognized previous bytes
and retaining backups. AI workers are not restarted by this update. Browser auth
uses rotating bootstrap tokens and a private restart-safe cookie credential; no
secret-bearing command arguments or public source snapshots are introduced.

The managed power-button binding locks on press, with the compatible
`nacre-power-key.service` owning low-level logind key inhibition. A
backup-preserving migration removes the recognized private DPMS release binding;
private display-wake and idle policies remain separate. Firmware continues to
own physical hold-to-force-off behavior.

## Nacre identity

Desktop-owned runtime/preferences now use the canonical Nacre roots described in
[the migration guide](features/nacre-rename.md). Old directory and desktop command
names remain compatibility aliases for existing callers and validated releases.
Personal AI accounts, workflows and the private vault retain their existing roots.
The rename does not change inherited-code provenance or license obligations.

## Orient engine boundary

The independent Orient implementation under `nacre/shell-cli` replaces the inherited
palette generator and CLI internals. The native publisher and existing wallpaper
preparation/rotation retain ownership. Both direct and prepared paths use the same
mode/settings and versioned cache identity. [Orient](features/orient.md) documents
compatibility names, per-image accents and measured acceptance requirements.
Runtime environments are built separately under private `palette-engines/` and
selected through `palette-runtime`; successful tests precede activation and
release snapshots retain the old engine bytes for recovery. Other inherited UI
areas and their attribution remain until their own rewrites and final audit.

Orient now includes a named set of natural image-derived palette alternatives in
its cached output. The existing publisher carries those previews/selection with
matched presentation state; Appearance calls the same locked CLI to set or clear
private per-image accent overrides. The decorative frame role supplies palette previews; exterior chrome uses the
same body token as the top bar.

## Shared primitive ownership

`nacre/shell/widgets/NacreTokens`, `NacreSurface`, `NacreText`, `NacreClip` and
`NacreInteraction` own the first independent UI foundation. Four legacy type
names are thin compatibility adapters. Tokens consume existing palette/settings
providers; native rounded clipping is a Quickshell dependency, not Nacre-owned
low-level rendering. [Foundation behavior](features/foundation.md) describes
input, focus, motion and the remaining control/config rewrite boundaries.

Shared shell controls and layout defaults are owned by the independent
[Nacre foundation](features/foundation.md). Maintained consumers use Nacre type
names; compatibility adapters preserve older external configuration. Exterior
chrome uses one body token, while inner cards use raised surfaces.

Orient's optional Harmony preference is owned by wallpaper-picker.json. Engine
and prepared-palette identities include it; the event-driven wallpaper watcher
warms invalidated palettes. Natural remains the default. Fixed-palette generation
uses the same independent contrast/tint policy and is checked reproducibly.


NacreDesktop/NacreScreen own frame assembly through NacrePanelHost, NacrePanelInput,
NacrePanelMask, NacreChrome and NacreReservedEdges. Logical input release is separate
from visual closing geometry; a stable layer and explicit hover contracts replace
parent-dependent input handling. Independent registry updates preserve newer and
other-output owners. The [frame guide](features/frame-panels.md) documents contracts
and target-host validation; composed panel/service bodies remain pending areas.

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

NacreWallpapers owns catalogue, user-selection/preference queues and rotation;
wallpaper-media.py remains the sole publication/cache helper. Matched active
NacrePresentation state controls displayed assets. NacreWeather owns validated
cached/live readings and coalesced refresh; weather.py owns bounded retrieval.
Legacy provider names are minimal forwarders, not duplicate workers.

NacreActiveTitle and NacreStatusIcons render existing compositor/device state;
NacrePowerButton only opens the session menu. NacreBatteryPopup consumes native
UPower/PowerProfiles; user activation alone changes a profile. NacreCalendarPopup
reuses the independent overview calendar helper; CalendarGrid is retired. TopBar
and dynamic popup assembly retain ownership of hover/focus and need their own
remaining originality audits. Compatibility names do not add data owners.

NacrePopupPanel/Content now own quick-view loading and finite clipped presentation;
NacreSoundPopup/NetworkPopup/BluetoothPopup/HistoryPopup delegate data and actions
to existing services. NacreQuickList/Slider own bounded native input presentation.
The frame input controller still owns hover dismissal and hit-region release.
Shared popup assembly never creates a notification/network/audio server.

NacreOsdPanel/Controls/Events present existing level owners with a visible-only
activity deadline; NacreSessionPanel/Controls launch four allowlisted user actions.
NacreBackground/WallpaperScene/DesktopVideo own noninteractive per-output native
poster/media rendering and matched readiness. Authentication, frame dismissal,
palette publication and shared playback policy stay with their existing owners.

NacreTopBar owns per-output header surfaces; NacreHeader composes existing bar
controls and shared update state. NacreWorkspaceRow dispatches selection through
the native compositor owner. NacreHeaderTrigger/Forwarder split passive hover from
modal click observation. NacreHoverIntent owns per-output rearm/geometry state;
old names are forwarding interfaces, not second owners. Surface recovery and frame
input remain separate existing owners.

The root shell now independently composes retained surfaces/providers once.
NacrePanelState owns shared/per-output visibility, NacreShellIpc owns supported
control/recovery queries, and NacreShellShortcuts owns native shortcut callbacks.
The writable Visibilities compatibility adapter forwards to this single owner;
registry/recovery still update owner-checked maps. App launch, palette/device and
private assistant services are separate and unchanged by visibility commands.

Independent misc/decoration/nacre Lua defaults own current base appearance and
maintained utility window rules; private loaders retain final precedence. Kitty
loads private generated palette and optional overrides. Fastfetch's plain layout
and validated filesystem-age helper are independent; logo helpers/generator remain
separate audit. Retiring an unused app rule does not uninstall that application.

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

Palette publication has one reentrant commit guard for direct, prepared and
CLI-owned calls. Complete role/mode validation precedes consumer writes; the
CLI's inherited descriptor is verified and its parent lock remains owned. This
serializes normal publication while retaining per-file replacement semantics.
Toolkit/branding/lock/login generators remain separate dependency audit areas.

Toolkit companions are locally authored helpers/templates with separately tracked
source histories. KDE output uses Nacre scheme identity; icon overlays link to
installed licensed Papirus artwork and repair only recognized generated caches.
Custom index/artwork files remain user-owned. Native Rofi theme dumping validates
the fallback theme; the installed 2.0.0 standalone validator has a reproduced
cleanup crash, including on a minimal theme.
