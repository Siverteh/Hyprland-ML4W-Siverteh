# Dolphin as Nacre's file manager

User selected Dolphin again for folder-style archive browsing. Keep the native
pacman-owned app, KIO ZIP worker, Breeze style and existing Nacre KDE palette.
Files/default folder/ZIP launch routes use one Dolphin wrapper. First-run setup
backs up native preferences and MIME associations, enables BrowseThroughArchives,
uses 80px icons/96px previews, quiet breadcrumb/toolbar layout and double-click
activation. Later user edits are retained. Thunar remains a compatibility fallback;
do not terminate its active file operations during migration.

The existing palette publisher writes Nacre.colors and kdeglobals. A small
independently authored style adapter consumes that native scheme using public Qt
and KDE APIs, refreshes KDE's shared color cache and Dolphin graphics-view style
options on atomic file changes, and updates icons. A 40ms single-shot debounce
coalesces events; no idle polling, app restart or new palette generator. Only the
Dolphin application activates its watcher. Its style-only plugin directory has a
unique name and contains no extracted Qt libraries, QML or platform plugins.
The scoped launcher uses the system xdgdesktopportal platform integration to
avoid qt6ct overriding app-specific style activation. No Plasma session is enabled.

Acceptance: one-time backup/setup retains unknown preferences and later edits;
Files route forwards literal paths; unique class rules have no conflicts; Qt/KDE
style builds with warnings-as-errors and native tests cover atomic scheme updates
and unrelated-app isolation. Actual Dolphin renders with current Nacre colors,
changes an existing window's accents, and browses a synthetic ZIP without
extraction. Full checks, Hyprland, plan/apply and live IPC/source gates; native
packages remain owned and updated by pacman. No account/worker changes.
