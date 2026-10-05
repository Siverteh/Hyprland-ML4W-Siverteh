# Component ownership

| Component | Source | Owner and deployed location |
|---|---|---|
| Session and compositor | `hypr/` | SDDM → UWSM → Hyprland; installed configuration copies in `~/.config/hypr` |
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
daemon are removed. Hypridle handles locking around suspend. KWallet PAM unlocks
the encrypted wallet using password login, with its initialization hook in the
Hyprland startup configuration.

Compositor loading order is base Lua configuration, optional private monitor
overrides, committed palette, saved desktop settings and native shortcuts. App
routing comes from Lua rules. Startup opens the six requested workspace apps
idempotently; ordinary terminals are unrestricted. No background script rewrites
the source routing rules or broadly moves browser windows.

The native palette bridge publishes to `~/.config/siverteh-shell`, GTK and the
installed Hyprlock configuration. The repository contains one current boot seed
and generation code, rather than checked-in generated colors or a catalogue of
old themes. Wallpapers live under the user's Pictures directory. App choices can
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
