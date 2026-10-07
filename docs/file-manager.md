# File manager appearance and live colors

Files uses Dolphin with an 80-pixel icon grid, 96-pixel previews, a modest Places
rail, breadcrumbs and a hidden menu bar. Split view and the normal hamburger
menu remain available. The setup applies these defaults once and preserves
later zoom/layout choices. Native Files (Nautilus) remains available; its earlier
small grid is migrated one step to small-plus only if that size is still owned
by the previous setup.

## Research and choice

[Caelestia's Thunar template](https://github.com/caelestia-dots/cli/blob/main/src/caelestia/data/templates/thunar.css)
uses shared palette roles for the view and navigation. [end-4's Dolphin defaults](https://github.com/end-4/dots-hyprland/blob/main/dots/.config/dolphinrc)
keep navigation compact, while its KDE color configuration defines complete
window/view/button/selection roles. Those ideas fit the existing Siverteh palette
publisher without adopting another desktop shell.

Nautilus can load the custom GTK palette at startup, but its open-window custom
stylesheet is not reliably reloaded. Qt6ct also deliberately avoids replacing
an application-owned palette. [KDE's color-scheme manager](https://github.com/KDE/kcolorscheme/blob/master/src/kcolorschememanager.cpp)
chooses a separate automatic Breeze scheme on non-KDE platform themes. This
combination can produce mixed colors or prevent live updates in Dolphin.

Dolphin therefore uses its native KDE platform integration, scoped to the Files
application only. The rest of the session keeps its existing toolkit settings.
It uses the system color scheme rather than a pinned app-specific scheme.

## One palette owner

`classic-state.py` still publishes the committed wallpaper or fixed palette.
`kde-palette.py` maps the same roles to KDE window, view, button, header,
selection, tooltip and complementary groups, preserving unrelated settings.
The publisher emits standard KDE palette/icon notifications after writing the
configuration. The native plugin receives these events and updates the existing
window, including its icon theme. There is no polling worker or application
restart on wallpaper changes. Fixed palettes in Appearance remain fixed.

The generated folder theme includes KDE's `inode-directory` alias as well as
GTK's folder names, so generic folders use the same palette family in both
applications. Original Papirus app/MIME artwork supplies fallbacks.

## Runtime and rollback

Dolphin is a distribution package. When the native integration plugin is absent,
`file-manager-runtime.py` extracts only two checksum-verified distribution
artifacts into the private file-manager runtime: plasma-integration and
kstatusnotifieritem. This supplies the platform plugin and its required library;
no desktop services are enabled. Qt major/minor compatibility is checked at
launch; an incompatible or missing local integration falls back to Nautilus.
A normal install refreshes the runtime after a Qt upgrade. Package licenses and
source hashes remain with the local artifacts.

The Files shortcut, app-menu entry and directory association use the same
`siverteh-os-app files` route. Explicit personal application routes remain
supported. Generated KDE colors, user zoom choices and icon assets remain
private. The small native runtime and owned desktop launcher are included in
release snapshots; one-time settings record their previous values separately.

Validate with `python3 tools/check.py`, the Hyprland config check and the normal
install plan/apply procedure. `./install.sh --component apps --component shell`
limits a Files-only deployment to app launch routes and shell software, preserving
unrelated compositor configuration edits; the usual full deployment retains its
drift checks. For live color tests, use an isolated compositor
and private config/bus, change its palette, send standard notifications and
check both pixels and the unchanged Dolphin PID. Do not unlock the real session
or restart a working file manager merely to claim a visual check passed.

## Yazi keyboard trial

Super+Shift+F opens Yazi in Kitty at the home directory. Dolphin remains the GUI
Files app and directory association. This trial adds no GUI handoff integration,
plugins or global Yazi configuration. `siverteh-os-shell yazi /path` can open a
specific directory. Press arrows or h/j/k/l to navigate, Enter to open, Space to
select, `/` to find a name, `~` for key help and `q` to quit.

The trial opens centered at 70% of screen width and 75% of screen height,
with 14-point text, a nearly opaque background and ANSI terminal colors
from the existing wallpaper palette. Native Kitty image previews need no overlay
service. Its config lives beside the installed shell tools, separate from
`~/.config/yazi`. A system Yazi is preferred; otherwise checksum-verified
distribution packages provide a private runtime, included in release snapshots.
No privileged package installation or background service is introduced.

To end the trial, remove the final Yazi binding override from
`siverteh/shell-tools/shortcuts.lua` and deploy the shell component. The earlier
GUI Files binding becomes active again. Personal files and GUI preferences are
untouched.

## Current Thunar trial

Super+Shift+F now opens Thunar, replacing the Yazi shortcut trial. Dolphin remains
the GUI Files association; Yazi is still available through `siverteh-os-shell yazi`.
Thunar Files also appears in Apps. The trial uses a centered floating window,
96-pixel icons, 24-pixel Places icons, breadcrumb navigation, a hidden menu bar
and local image thumbnails through the installed Tumbler service. Ctrl+M reveals
the menu; Ctrl+L edits the path; Ctrl+mouse-wheel adjusts zoom; F3 opens split view.

The layout is applied once through Xfconf, recording previous values privately.
Later user changes are preserved. No Xfce desktop/session is enabled. Native
Thunar and its missing libraries come from checksum-verified distribution
packages in the private `thunar-runtime`; subsequent installs compare package
metadata and refresh it after upgrades. Package licenses stay with the runtime.

`thunar.css` scopes spacing, toolbar, sidebar and selections to Thunar and uses
existing generated GTK palette roles. A small app-scoped GTK3 module watches
atomic replacements of the generated palette/settings files. It reloads the
style and folder icon theme in the same process, with coalesced file events and
no polling. It does not create another palette publisher or affect other apps.
The native regression test verifies GTK parsing and an actual atomic palette
replacement recoloring an existing widget. It requires a native display and GTK3
headers; portable CI reports the skip when those are absent.

Settings and styling use the [documented Xfce interfaces](https://docs.xfce.org/xfce/thunar/hidden-settings).
The distribution's Tumbler/GVfs handle thumbnails, trash and mounts. No file
operations are terminated when colors change. To end this trial, remove its
shortcut override and window rule from `shortcuts.lua`, then deploy shell;
Dolphin's earlier Files binding resumes. Preferences and files are preserved.
