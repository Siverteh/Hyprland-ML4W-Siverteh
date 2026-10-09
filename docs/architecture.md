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
window space. Shell layer namespaces start with `siverteh-`; blur targets visible
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
private per-image accent overrides. A dedicated frame role supplies the shell's
wallpaper tint without changing panel geometry.

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
