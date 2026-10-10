# Nacre Welcome

Open **Nacre Welcome** from the app launcher or run `nacre-welcome`.
It is a single normal app window hosted by the existing Quickshell service,
with the standard Nacre shell logo and current Orient colors.

- **Start here** keeps four cached library samples visible. Click a scene to
  change the desktop and the Welcome logo together. Dark/Light and Natural/Pop/
  Pearl apply through the same existing wallpaper/theme publisher. Opening
  Welcome does not apply changes; the controls explicitly say changes are live.
  Open Colors for preview-only exploration and more choices. Empty libraries
  offer the existing wallpaper import path. Automatic rotation pauses while the
  active Welcome demo is visible; sample positions stay stable during choices.
- **Shortcuts** reads `hyprctl binds -j` for this live session. Named actions,
  modifier masks, aliases and complete workspace ranges generate the displayed
  keys; no static key list remains. Related restore/close/save combinations also
  come from the live data. Missing/unbound actions disappear rather than guessing
  their old keys. It refreshes on open, entry to Shortcuts, visible config-reload
  events or Refresh bindings, without polling. Lua registrations carry
  `description="Nacre:files"` and similar action IDs. Reuse that metadata on private
  remapped binds to keep them discoverable; undescribed Lua callbacks cannot be
  inferred from their opaque compositor IDs. Outside Hyprland an unavailable
  message replaces the list. See [public flags](https://wiki.hypr.land/configuring/core/binds/flags/).
- **Nacre apps** always includes AI and Brain. Installed tools open normally;
  absent tools have muted branding and an enabled Setup guide that explains
  requirements and the component documentation inside Welcome. Public optional
  packages are not yet released, so the guide does not invent install commands.
  AI and Brain use distinct chat/brain fallback glyphs while their shared logos
  are unavailable; ready artwork stays visible during palette reloads.
- **Help** keeps practical guidance offline, with explicit project/Hyprland/
  Quickshell/CachyOS links. The intro says “a desktop for Hyprland”; Quickshell
  implementation context belongs here.

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

The [live-demo specification](../specs/welcome-live-demo.md) records publication,
binding metadata, performance and optional-component boundaries.
