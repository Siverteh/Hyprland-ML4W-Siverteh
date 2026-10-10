# Thunar Files and live colors

Thunar is the maintained file manager. Super+Shift+F, the Files app route, the
Thunar Files launcher and directory associations all use its styled launcher.
Super+F remains the fullscreen shortcut. Explicit personal app routes in
`~/.config/nacre/apps.json` remain supported.

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

## Icon artwork and other applications

Pacman owns Papirus artwork under the system icon directory. `file-icons.py`
creates a small user-local folder overlay linking to that artwork and inheriting
its app/MIME icons. It does not copy the native package into a private runtime.
Folder colors follow the nearest accent family. GTK settings and GNOME’s icon
preference select the same overlay; generated themes stay outside Git.

Other GTK applications may require reopening to read a changed custom stylesheet.
Thunar’s app-scoped file-event module refreshes its existing window instead. Palette
publication never terminates active file operations. Papirus retains its upstream
license; its artwork is not original Nacre art.
