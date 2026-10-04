# Siverteh OS

Personal CachyOS/Hyprland desktop with a wallpaper-driven horizontal Quickshell bar, curved desktop frame, native dashboard and persistent AI sidebar. Siverteh AI supports conversation-first Codex/Claude chats; the private Brain organizes saved knowledge into subjects and topics without a coding-project registry.

## Current components

- [Desktop shell](siverteh/shell/README.md) and [deployment helpers](siverteh/shell-tools/README.md): settings, audio/microphone/display/keyboard sliders, notification history, clipboard, app launcher and wallpaper chooser.
- [Siverteh AI](ai/README.md): provider/account settings, new/resume/load chats, isolated project work and shared memory.
- [Brain](rice/observatory/README.md): overview, connections, full-text notes and inline reading. [Discovery design](rice/observatory/DISCOVERY.md) explains local semantic grouping, evidence-led growth and limitations.
- [Login theme](siverteh/login/README.md): wallpaper-matched SDDM with manual authentication.

## Deployment

This repository is the maintained source for an existing Siverteh setup, not a one-command installer for an arbitrary Linux system. Component instructions describe their prerequisites, private backups and deployment scope. The old root install.sh and legacy dotfile directories remain historical compatibility material; use the current component deployment helpers for this desktop.

The semantic model is optional: `siverteh-ai-tools python rice/observatory/provision-semantic.py` prepares its isolated CPU environment and downloads public weights once. Normal note inference is offline. Private notes, chat/account state, wallpapers and credentials remain outside public Git.

## Useful shortcuts

| Shortcut | Action |
|---|---|
| Super+A | App grid |
| Super+W | Wallpaper chooser |
| Super+X | Native power menu |
| Super+Z | Fade bar and frame |
| Super+B | Brain on workspace 6 |

Startup targets browser1, AI2, Discord3, Spotify4, mail5 and Brain6. Plain terminals can open on any workspace. The native shell is maintained under siverteh/; retained third-party licenses and notices are included alongside adapted components.
