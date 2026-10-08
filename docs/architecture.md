# Component ownership

| Component | Source | Owner and deployed location |
|---|---|---|
| Session and compositor | `hypr/`, `uwsm/` | SDDM → UWSM → Hyprland; installed configuration copies in `~/.config/hypr` |
| Desktop UI | `siverteh/shell/` | `siverteh-os-shell.service`; validated source in `~/.local/share/siverteh-ai/siverteh-shell` |
| Desktop helpers | `siverteh/shell-tools/` | Native settings, notifications, clipboard, update checks, startup apps and assistant bridge |
| Palette and wallpaper engine | `siverteh/shell-cli/` | Isolated Python package; the native bridge is the sole palette publisher |
| Knowledge browser | `brain/` | Loopback server and dedicated browser profile; private Markdown vault remains external |
| AI workflow | `ai/`, `bin/` | Codex/Claude accounts, chats, project registry, skills and memory helpers |
| Login appearance | `siverteh/login/` | Optional root-owned SDDM theme; authentication remains SDDM/PAM-owned |
| Terminal presentation | `kitty/`, `fastfetch/` | Installed static config plus private generated SH logo and terminal palette |

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
`siverteh/shell-tools/shortcuts.lua`; static app placement lives in `windowrule.lua`. App
routing comes from Lua rules. Startup opens the six requested workspace apps
idempotently; ordinary terminals are unrestricted. No background script rewrites
the source routing rules or broadly moves browser windows.

The native palette bridge publishes to `~/.config/siverteh-shell`, GTK and the
installed Hyprlock configuration. The repository contains a boot seed, generation code and generated
`palette-presets.json` fixed-color layouts. A pinned-engine regeneration test
checks the presets. Wallpaper-derived host colors are never committed. Wallpapers live under the user's Pictures directory. App choices can
be overridden with executable argument arrays in `~/.config/siverteh-shell/apps.json`.

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
`thunar-style/siverteh-thunar-theme.so` is the private GTK style module. The module
applies generated CSS only inside Thunar and leaves applications it opens alone.
System icon artwork supplies the small palette-colored folder overlay.

Wallpaper rotation selects existing private library entries on a configurable
interval; fixed palettes bypass wallpaper extraction. Thumbnail/poster caches and
prepared palettes serve the picker and Appearance settings. The palette publisher
pairs wallpaper and shell color state so transitions share a presentation step.
Prepared lock text and artwork are updated outside authentication startup.

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
