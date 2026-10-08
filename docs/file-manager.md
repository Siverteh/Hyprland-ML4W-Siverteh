# Thunar Files and live colors

Thunar is the maintained file manager. Super+Shift+F, the Files app route, the
Thunar Files launcher and directory associations all use its styled launcher.
Super+F remains the fullscreen shortcut. Explicit personal app routes in
`~/.config/siverteh-shell/apps.json` remain supported.

The layout uses a centered floating window, 96-pixel icons, 24-pixel Places
icons, readable Noto Sans text, breadcrumb navigation, a hidden menu bar and
local image thumbnails. Ctrl+M reveals the menu; Ctrl+L edits the path;
Ctrl+mouse-wheel adjusts zoom; F3 opens split view. Layout defaults are applied
once through Xfconf, recording previous values privately. Later user changes
are preserved. The folder association is also applied once and recorded.

## Shared wallpaper colors

`classic-state.py` remains the palette publisher. `thunar.css` uses its generated
GTK roles for the file view, toolbar, sidebar, text and selections. The existing
Papirus folder overlay follows the accent family; original Papirus app/MIME
artwork supplies fallbacks. Fixed palettes in Appearance remain fixed.

A small app-scoped GTK3 module watches atomic replacements of the generated
palette and settings files. It coalesces file events, reloads CSS and updates
folder icons and dark/light settings in the same process, without polling or
restarting. It checks the application name to avoid activating in unrelated
apps that inherit the launch environment. No second palette owner is introduced.
Settings and CSS use the [documented Xfce interfaces](https://docs.xfce.org/xfce/thunar/hidden-settings).
No Xfce desktop/session is enabled. Existing GVfs and Tumbler handle trash,
mounting and thumbnails.

## Installation and validation

Pacman owns Thunar, Xfconf and their native libraries and verifies package
signatures. `install-thunar.py` builds only the private app-scoped style module
using a C compiler, pkg-config and GTK3 headers. Distribution D-Bus activation
starts Xfconf on demand; personal preferences remain outside release snapshots.

The compiled style module and desktop launcher are included in release snapshots.
`./install.sh --component apps --component shell` updates Files routes and shell
software without replacing unrelated compositor configuration. Run
`python3 tools/check.py`, the Hyprland configuration check, plan/apply and live
IPC/source checks. The native GTK regression verifies actual CSS parsing and
atomic palette replacement recoloring an existing widget. It requires a display
and GTK3 headers; CI reports skips when these are absent. Live tests can use a
private copy of GTK palette/settings to verify colors and icons without changing
the user's wallpaper. Do not terminate active file operations to test theming.

The earlier Yazi and Dolphin/Nautilus trial launch/configuration code is retired.
The selected host removed those applications and their private trial runtimes;
shared toolkit libraries, themes, personal preferences and release backups remain.

## Native file manager appearance

Thunar is the default Files route and directory handler. Super+Shift+F opens its
styled window; Super+F remains fullscreen. The native GTK3 style uses the existing
wallpaper palette, comfortable 96-pixel icons, breadcrumbs and local thumbnails.
The app-scoped file-event hook updates an open window's colors and folder icons
without restarting it. See [file manager appearance](file-manager.md) for the
runtime, controls and validation. GTK and Qt colors remain shared with other apps.

Provisioning also installs the distribution's pacman-managed Papirus icons in
the user icon directory. `file-icons.py` generates small folder-only theme overlays
that inherit the full Papirus app/MIME set; folder colors track the nearest accent
family. Both GTK settings files and GNOME's icon preference use the same overlay.
Generated themes and original icon assets remain local, outside Git. Comfortable grid defaults are applied once; previous values are recorded privately
and later user zoom choices are preserved. Other GTK applications may need
to be reopened to load an updated custom stylesheet; no file-manager processes or
active file operations are terminated automatically on palette changes.

