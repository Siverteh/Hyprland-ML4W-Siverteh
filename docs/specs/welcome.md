# Nacre Welcome

## Purpose and research

A reopenable starting point for Nacre's existing desktop: explain the name,
personalize appearance, discover applications/shortcuts, find help and recovery.
Read primary product documentation for behavior, without inspecting/copying their
application implementations:

- [EndeavourOS Welcome](https://discovery.endeavouros.com/welcome/): information,
  after-install tasks, help and an explicit reversible login-autostart choice.
- [CachyOS Welcome](https://github.com/CachyOS/CachyOS-Welcome) and
  [release notes](https://wiki.cachyos.org/cachyos_basic/changelogs/gui_installer/):
  discoverable maintenance, optional tools, single-instance/window matching.
- [Noctalia setup](https://noctalia.dev/changelogs/v5.0.0-beta.3): guided wallpaper
  setup, accessibility/keyboard navigation and clear settings ownership.
- [DMS getting started](https://danklinux.com/docs/getting-started) and
  [shortcut discovery](https://danklinux.com/blog/v1-2-release): coherent setup
  routes, backed-up existing configuration and discoverable compositor controls.

Nacre's implementation is independently authored from these behavior goals.
No other shell's welcome code, graphics or styling is imported.

## Design

Use Orient body/raised/ink/mutedInk/accent/outline tokens, IBM Plex Sans for
content and JetBrains Mono only for key caps. No fixed theme overrides. The
approved standard shell logo is the visual focal point; ample quiet space makes
its wallpaper colors readable. A large logo/name introduction and three clear
starting actions lead to short setup rows, rather than a dense grid of settings.
Four compact sections: Start here, Shortcuts, Nacre apps, Help. Left-align text,
keep paragraphs short and columns responsive. No caption control buttons.

Minimum720x540; comfortable1040x760 window. Keep the footer/show-at-login toggle
visible and scroll only page content. Use existing fast/kinetic scrolling,
keyboard focus, reduced motion and palette-change behavior. No idle animation.
Standard logo for window and launcher; reuse the existing branding owner.

## Behavior and ownership

One lazy normal Quickshell window hosted by the existing shell, like Settings
and Colors. Repeated launcher/CLI activation focuses the same window, including
restoring its hidden workspace. Escape, Ctrl+W, the footer and normal Super+Q
work. A warm open uses IPC; a cold open starts the existing user service with
bounded retries, never creates another shell process or restarts the AI worker.

Routes open existing Settings pages, Colors previews and the wallpaper picker.
AI/Brain are discoverable only when their local command/runtime is available;
Welcome never installs packages, changes accounts or modifies AI permissions.
Help is readable offline and offers explicit public documentation/project links.
Maintenance and updates route to existing Settings, rather than a second owner.

welcome.py owns versioned private ~/.config/nacre/welcome.json with atomic writes
and a file lock. Show at login defaults on; disabling remains disabled through
manual opens, service restarts and upgrades. CLI enable/disable reuses this owner.
A Hyprland session-start hook calls nacre-welcome --login through UWSM. An atomic
per-instance claim prevents repeated activation; shell restarts/deploys do not
count as new sessions. Failed activation releases its claim. No continuous
startup timer or idle process polling. Ordinary opening never modifies other
preferences or applies a wallpaper/palette.

Shortcuts come from a reviewed catalog of actual maintained bindings and carry
clear explanations of hide/trash/restore versus close. Host-specific key choices
remain in their current owner; Welcome is a guide, not a keybind editor.

## Validation

Test normalized/atomic preferences, malformed data, preserved unknown fields,
session deduplication/retry and disabled/manual launch behavior. Verify CLI warm/
cold activation, deployment map and desktop entry. Native Qt test page navigation,
responsive sizing, footer/toggle, keyboard controls and real action routing through
mocks. Parse/format all QML; full checks and Hyprland verification before release.
Inspect actual live screenshots at wide/narrow sizes, dark/light palettes and the
same standard logo. Verify one window, real Escape, disabled login persistence,
current source/IPC health and preserved busy AI backend. Never simulate a new login
by restarting the user's real compositor. Physical next-login acceptance is separate.
