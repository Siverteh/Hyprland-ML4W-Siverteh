# Nacre Welcome

Open **Nacre Welcome** from the app launcher or run `nacre-welcome`.
It is a single normal app window hosted by the existing Quickshell service,
with the standard Nacre shell logo and current Orient colors.

- **Start here** explains Nacre/mother-of-pearl and opens wallpaper/Colors,
  Settings, shortcuts or Maintenance.
- **Shortcuts** is a readable guide to the maintained default bindings. Host
  overrides may differ. Super+Q puts a window away; Super+Shift+Q restores it;
  Super+Ctrl+Q closes it. Files is Super+Shift+F; Super+F is fullscreen.
- **Nacre apps** opens Settings, Colors and available optional AI/Brain tools.
  Accounts, models, notes and optional packages are not set up by Welcome.
- **Help** keeps practical guidance offline, with explicit links to the public
  Nacre project and Hyprland, Quickshell and CachyOS documentation.

The **Show at login** switch saves immediately. Turn it off to stop automatic
activation; Welcome remains available from the launcher. `nacre-welcome --enable`
and `--disable` change the same preference. `nacre-welcome shortcuts`, `apps` or
`help` opens a particular section. Escape, Ctrl+W and Start using Nacre close the
window; ordinary compositor shortcuts remain available. The header has no caption
buttons. Content scrolls while the footer remains visible.

Private `~/.config/nacre/welcome.json` is versioned and written atomically by
`welcome.py`, preserving unknown fields. Login startup is on by default. A real
Hyprland session-start hook invokes `nacre-welcome --login` through UWSM; a private
per-instance claim prevents duplicate activation. Failed activation releases its
claim. Deploying/restarting the shell, unlocking or opening Welcome manually does
not count as a new login or change the saved preference. There is no startup
polling timer or second shell/settings/palette owner. Physical next-login behavior
requires hardware/session acceptance beyond an isolated claim test.

Welcome follows the existing app pattern: `NacreWelcomeApp` owns visibility,
focus/routing and a serialized preference helper queue; `NacreWelcomeHost` lazily
creates the window. Hidden windows stop drawing. Setup buttons route to existing
services rather than duplicating configuration logic. The shared branding owner
publishes the standard `nacre` launcher icon alongside the app-specific ones.

## Research choices

[EndeavourOS Welcome](https://discovery.endeavouros.com/welcome/) groups information,
after-install tasks and help, with reversible autostart control. Nacre adopts the
reopenable/helpful approach while routing maintenance to its existing Settings.
[CachyOS Welcome](https://github.com/CachyOS/CachyOS-Welcome) and its
[release notes](https://wiki.cachyos.org/cachyos_basic/changelogs/gui_installer/)
show why tool availability and single-instance activation matter.
[Noctalia's setup notes](https://noctalia.dev/changelogs/v5.0.0-beta.3) emphasize
appearance setup and accessible controls; [DMS setup](https://danklinux.com/docs/getting-started)
and [keybind discovery](https://danklinux.com/blog/v1-2-release) emphasize clear
entry points into a coherent desktop. These are behavior references; Nacre's
layout, content and implementation are authored locally. See [specification](../specs/welcome.md).
