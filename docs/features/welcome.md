# Nacre Welcome

Open **Nacre Welcome** from the app launcher or run `nacre-welcome`.
It is a single normal app window hosted by the existing Quickshell service,
with the standard Nacre shell logo and current Orient colors.

- **Start here** offers four curated artist wallpapers: After Rain, The Healer,
  Point of View and Red Jungle. These are available even with an empty
  personal library. Each has a dominant family and a contrasting detail,
  so Natural and Pop make visibly different choices; Pearl demonstrates Nacre's
  signature tones. Dark/Light and personality controls use the existing publisher.
  Opening Welcome captures a private starting point and does not apply changes.
  **Back to how it was** restores the opening wallpaper (including its original
  animated source), exact captured palette and palette preferences, while keeping
  unrelated rotation/layout/motion settings. It remains available after multiple
  demo choices and shows confirmation on success. Reopening an already visible
  window preserves the baseline; closing and reopening captures a new one.
  Automatic rotation pauses while the active home page is visible. More wallpapers
  still opens the personal picker. Busy/error states prevent overlapping commits.
  Missing/deleted starting artwork produces an error before any restore writes.
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

## Bundled artwork and demo recovery

`demo-wallpapers.py` validates the offline, licensed artwork bundle in
`nacre/shell-tools/demo-wallpapers/`. After Rain, The Healer and Point of View are
by **David Revoy**, under **CC BY 4.0**; Red Jungle is by **Nick Nazzaro**, published
by System76 under **CC BY-SA 4.0**. The expandable **Wallpaper credits** section
shows the artists and explicit license/source links. Full attribution, original
titles, source/download URLs, dimensions, hashes and license texts ship alongside
images in `NOTICE.md`, `manifest.json`, `CC-BY-4.0.txt`, `CC-BY-SA-4.0.txt`.

The original bytes and native dimensions are preserved: 3840×2047 for After Rain
and Point of View, 4200×2625 for The Healer, and 4800×2700 for Red Jungle. There is
no upscaling, recoloring, AI modification or re-encoding. Ordinary picker thumbnails
are viewing previews. Install validates the bundle and copies it to a content-
identified cache; Welcome repairs missing/corrupt cache copies without network
access or writing the private library. Immutable originals remain valid through
software upgrades. These explicitly licensed demo files are the sole bundled-
wallpaper exception to the private-artwork boundary; not public-domain/Nacre-
authored artwork. Old procedural scene caches are no longer offered by the demo.

`wallpaper-media.py demo-start` captures before enabling choices. The serialized
QML restore action calls `demo-restore`, which validates and republishes through
`classic-state.py` and its existing publication lock. It never copies generated
GTK/terminal/lock outputs as a shortcut. An initially flat desktop gets a cached
solid image matching its starting background, so it can also be restored without
requiring an existing wallpaper. Private 0600 snapshots live under
`~/.local/state/nacre/welcome/demo/`, retain at most ten entries, and contain no
accounts or credentials. Cache preparation does not publish or add idle polling.
Tests cover unaltered native-resolution/offline cache reuse and repair, visibly separated Natural/Pop accents in
both modes, palette validation, empty-library capture, exact restoration with
animated source and unrelated preferences preserved, and unavailable-file refusal.
