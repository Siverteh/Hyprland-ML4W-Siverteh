# Siverteh OS

Personal CachyOS/Hyprland desktop with a wallpaper-driven horizontal Quickshell bar, curved desktop frame, native dashboard and persistent AI sidebar. Siverteh AI supports conversation-first Codex/Claude chats; the private Brain organizes saved knowledge into subjects and topics without a coding-project registry.

[System overview](docs/overview.md) explains the components, startup order and where to make changes.

## Current components

- [Desktop shell](siverteh/shell/README.md) and [deployment helpers](siverteh/shell-tools/README.md): settings, audio/microphone/display/keyboard sliders, notification history, clipboard, app launcher and wallpaper chooser.
- [Siverteh AI](ai/README.md): provider/account settings, new/resume/load chats, isolated project work and shared memory.
- [Brain](brain/README.md): overview, connections, full-text notes and inline reading. [Discovery design](brain/DISCOVERY.md) explains local semantic grouping, evidence-led growth and limitations.
- [Login theme](siverteh/login/README.md): wallpaper-matched SDDM with manual authentication.

## Deployment

This repository contains the current desktop, rather than historical dotfile profiles. Waybar, SwayNC, Waypaper, Wlogout, the old dock/welcome app, old wallpaper assets, shader presets and generated color files have been removed. The shell and palette library retain their applicable licenses.

Start with [component ownership](docs/architecture.md) and [maintenance](docs/maintenance.md).

```sh
python3 tools/check.py       # syntax and regression checks
./install.sh                # review the deployment plan
./install.sh --apply        # apply reviewed components
```

Installed configurations are copies with hash-based drift protection and private backups. Wallpaper colors, display preferences, accounts, chats and images stay outside the source tree. Desktop deployment parses QML and checks the running shell before marking a revision good. CI runs portable checks; the target host supplies compositor and UI validation.

The semantic model is optional: `siverteh-ai-tools python brain/provision-semantic.py` prepares its isolated CPU environment and downloads public weights once. Normal note inference is offline. Private notes, chat/account state, the current wallpaper library and credentials remain outside public Git. Older commits retain previously published artwork removed from the current tree; see [repository boundaries](docs/repository-boundaries.md).

## Useful shortcuts

| Shortcut | Action |
|---|---|
| Super+A | App launcher |
| Super+W | Wallpaper chooser |
| Super+X | Native power menu |
| Super+Z | Fade bar and frame |
| Super+B | Brain on workspace 6 |

Startup targets browser 1, AI 2, Discord 3, Spotify 4, mail 5 and Brain 6; editors route to 7. Plain terminals can open on any workspace. The native shell is maintained under siverteh/; retained third-party licenses and notices are included alongside adapted components, including the [palette-engine NOTICE](siverteh/shell-cli/NOTICE).
