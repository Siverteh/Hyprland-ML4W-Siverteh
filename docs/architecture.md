# Component ownership

This document describes the maintained personal desktop. The
[overview](overview.md) maps behavior and edit locations; [maintenance](maintenance.md)
describes validation, deployment and recovery. Specifications and provenance
records contain the rewrite history, rather than this component map.

## Source, deployment and private state

| Component | Source | Owner and installed location |
|---|---|---|
| Session/compositor | `hypr/`, `uwsm/` | SDDM → UWSM → Hyprland; managed copies under `~/.config/hypr` and `~/.config/uwsm` |
| Desktop UI | `nacre/shell/` | `nacre-shell.service`; source under `~/.local/share/nacre/shell` |
| Desktop helpers | `nacre/shell-tools/` | Settings, devices, notifications, wallpaper, launch/control, recovery and assistant bridge |
| Palette engine | `nacre/shell-cli/` | Orient in a tested private Python environment selected by `palette-runtime` |
| Knowledge browser | `brain/` | Local HTTP server and dedicated browser profile under the existing personal AI roots |
| AI workflow | `ai/`, `bin/` | Independent provider accounts, chats, worktrees, registry, skills and memory helpers |
| Login appearance | `nacre/login/` | Optional root-owned SDDM theme; SDDM/PAM authenticates |
| Terminal presentation | `kitty/`, `fastfetch/` | Managed static config plus private palette and generated logo |

Desktop preferences/state/cache use the canonical Nacre directories described in
[the migration guide](features/nacre-rename.md). Legacy command/path aliases keep
existing callers and releases compatible. Personal AI accounts and vault data
retain their established directories; renaming a desktop does not migrate those
credentials or conversations. `observatory` identifiers are compatibility names
for Brain's service/profile, not another desktop.

`tools/configure.py` owns the managed configuration map and its deployment hashes.
Component installers separately own their declared services/runtime files.
Private monitor → palette → desktop → shortcuts → host Lua files load last with
contained errors. Binds are declared in `hypr/conf/keybinding.lua` and
`nacre/shell-tools/shortcuts.lua`; named app rules live in `windowrule.lua`.
Startup app selection is private and idempotent; it does not rewrite those rules.

## UI and data owners

The shell composes shared providers once. `NacrePanelState` owns per-output view
state; `NacreShellIpc` exposes control/recovery queries; `NacreShellShortcuts`
handles native shortcut callbacks. Old type names forward to current owners.
`NacreDesktop`/`NacreScreen` compose the frame and panels; input masks release
closing regions before visual geometry finishes. Registration/teardown preserves
newer and other-output owners.

`NacreTopBar` and `NacreHeader` compose bar controls, workspace selection and shared
update state. Hover triggering and passive click forwarding are separate from
modal panel input. `NacreFrameLips` owns the three marked edge targets, with actual rectangles shared
by the frame input mask and hover-intent guard. `NacreControlCenter` owns explicit
right-menu presentation, while `NacreOsdEvents`/`NacreLevelNotice` own short automatic
level feedback. `NacreControlTools` discovers optional tools and delegates explicit
capture/night-light actions; it adds no idle polling. `NacreDashboardPanel` owns page loading/navigation. Settings
pages request changes through validated helpers; displaying a control does not
write a device preference.

Native audio/Bluetooth/MPRIS models supply their respective providers. Wi-Fi uses
read-only NetworkManager snapshots and an event monitor, with explicit connection
writes through `DeviceActions`. `NacreNotifs` owns the single notification server,
expiry/DND and private retained display snapshots; history never stores live
notification action handles. Brightness shares discovery and guarded native
file readers/writes. Sysfs refresh occurs every three seconds while controls are
visible and on opening; DDC reads happen at discovery and after writes.

Resources are sampled only for visible resource views. Time is a shared native
clock, with seconds opt-in. Wallpaper/weather providers validate cached data and
coalesce requests. The UI does not introduce competing device, notification,
wallpaper or display-setting owners. Details live in the linked
[feature guides](overview.md#feature-guides).

## Wallpaper, palette and companion appearance

`wallpaper-media.py` owns library metadata, prepared images/palettes and publication.
Orient owns extraction, palette choices and contrast policy. Natural is the
default; optional Harmony, mode, variant and per-image accent are part of cache
identity. Fixed presets and the boot seed are reproducible repository data;
wallpaper-derived host colors and artwork stay private.

The bridge/publisher share one reentrant commit guard. Complete role/mode
validation precedes toolkit writes. Files are individually replaced; this is not
a crash-atomic transaction covering every toolkit. `NacrePresentation` stages one
poster/palette record; matching image readiness activates it. Background buffers
retain the previous loaded image during replacement. Rotation keeps its saved
deadline when unrelated preferences or only colors change.

Companion helpers prepare GTK/Qt, Kitty, icon overlays, branding, Hyprlock and SDDM
appearance. The Thunar style module applies CSS inside Thunar, without leaking its
private environment into opened applications. Fonts are pinned official assets
with separate notices and an ownership/rollback registry; generated host branding
and icon caches are outside Git. Third-party font/icon artwork remains licensed
separately from Nacre code.

## Authentication and personal AI

Hyprlock owns password input, PAM and secure session locking. Nacre prepares a
bounded lock dashboard texture and scales its presentation coordinates per output.
Hypridle owns managed before/after-sleep hooks and private idle listeners. The
power-key service inhibits competing low-level short-press handling while the
managed key binding locks; firmware owns physical hold-to-force-off behavior.
SDDM similarly owns login authentication; its optional theme contains appearance
files only and does not own the distribution's console banner.

The desktop's action helpers own ordinary control and AI launch commands. Brain
owns note indexing, grouping/search, capture and knowledge navigation. Its server
binds localhost, checks Host/Origin and requires a private browser cookie for
non-health API requests. Rotating bootstrap tokens use private file-based browser
handoff; source snapshots exclude credentials, vault and browser profile.

The sidebar renderer and persistent worker are separate. UI recovery does not
restart a busy worker. Codex tasks explicitly use full access with approvals
`never`; Claude sidebar/terminal workers use `--dangerously-skip-permissions`.
Accounts remain isolated and authentication is never copied. Controller-only
updates are documented in [AI workflow](../ai/README.md#update-controller-code-without-account-setup).
The public/general packaging plan is separate from this personal workflow.

## Dependencies, updates and recovery

Pacman owns Quickshell, Qt plugins, Thunar/Xfconf and Papirus. The launcher removes
legacy private library/Qt import overrides and checks the Quickshell/Qt match.
Local code consists of the tested Orient Python environment and compiled Thunar
style module; native binaries are not unpacked into a private desktop runtime.
The optional Quickshell compatibility backport is separately credited LGPL
upstream code, not original Nacre implementation. See [runtime](features/runtime.md).

Updates retain `paru -Syu --skipreview`. Failures stay visible in the terminal;
startup mismatch errors also use Hyprland's notification channel. Full package
updates and desktop rollback are separate: rollback restores owned code/config,
not OS package versions.

Release snapshots use the candidate configuration map shared with deployment.
Old owned paths remain covered for retirement; unowned bytecode is excluded.
Private accounts, conversations, wallpapers, preferences and vault data are not
snapshot targets. Promotion requires checks, live services, source/IPC and normal
launcher/Escape gates. Retention keeps the newest ten good releases plus current,
previous and retired-native backups. Managed configuration drift blocks replacement. User-requested rollback refuses
post-deployment changes to captured paths. Installed runtime edits are backed up
but do not have a universal replacement-refusal guarantee; edit maintained source
and deploy it rather than relying on runtime copies as the source owner.

[Current-tree provenance](nacre/CURRENT-TREE-AUDIT.md) distinguishes source origin,
assets/dependencies and active runtime from historical releases and functional
acceptance. The [final comparison](nacre/FINAL-COMPARISON.md) joins the source/fixture,
dependency and active-runtime evidence. Current and historical attribution have
separate scope; passing source checks does not certify physical/visual acceptance.

The post-rewrite [visual cleanup specification](specs/visual-cleanup.md) preserves
these owners. Title paint bounds and the 2×2 level composition live in the existing
bar/OSD components. Settings, quick menus and galleries share the event-driven
FastScroll policy; picker travel/backdrop buffers remain local presentation state,
not another wallpaper publisher or input owner.

## Shared logo owner

The approved `nacre/shell/branding/nacre-master.svg` owns the shell and pearl
geometry. `branding.py` derives compact/symbolic forms, Qt/SDDM data modules, the
Brain symbol and palette-generated PNG/text outputs. Native librsvg is the PNG
rasterizer; Quickshell and SDDM use Qt SVG without private native libraries.
Visible labels use Nacre AI/Brain; private compatibility commands stay intact.
Login theme code is root-owned; only color/wallpaper appearance remains user-owned.

The public `nacre-ai` command is a managed entry point to the existing private AI
controller. It forwards arguments and exit status without migrating accounts,
conversations or worker state; legacy `siverteh-ai` callers remain compatible.

Terminal image refresh remains part of the palette publisher. The Fastfetch
startup hook registers a Kitty logo against its persistent shell and PTY; palette
events edit existing image data, without owning keyboard input or application
lifetime. The private registry is not configuration or public project data.

The managed `nacre-ai.desktop` launcher starts the existing AI menu in Kitty with
its established workspace class. Its icon is generated by the shared branding
owner under the user hicolor icon directory, using the current palette.
