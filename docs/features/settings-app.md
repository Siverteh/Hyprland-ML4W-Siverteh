# Nacre Settings

Open **Nacre Settings** from the app launcher, press Super+Shift+O, or run
`nacre-settings`. It is a normal resizable desktop window, independent of the
hover dashboard. The dashboard contains Dashboard, Media, Performance and
Workspaces. The control center's Settings button opens the application.

Jump to a page with `nacre-settings sound` (or appearance, desktop, displays,
network, bluetooth, notifications, workflows, lock, time, ai, maintenance).
Repeated launches focus the existing window, retaining navigation; an explicit
page opens that section. The launcher entry also has Appearance/Displays/Sound
context actions. Ctrl+F searches settings, Ctrl+W closes the window, and Escape
first clears a search or closes Settings when no child popup consumes it.

Nacre's existing shell hosts one lazy FloatingWindow. Audio, network, settings,
wallpaper, notifications and persistence remain shared services, so changing a
value updates the same desktop state immediately. Only the selected page loads.
Closing or minimizing stops settings-only refreshes; display rollback deadlines
continue independently. Wallpaper previews use the existing shared caches.

The window and its radial-cog shell logo follow the live palette. Window movement
and resizing belong to the compositor; titlebar controls provide minimize,
maximize/restore and close. Opening Settings dismisses competing temporary shell
menus while preserving manually pinned AI content.

`nacre-settings` uses Settings IPC; if the shell is absent, it starts
`nacre-shell.service` and retries briefly, reporting failure instead of silently
hanging. Compatibility calls to `nacre-shell settings` or `settingsView open PAGE`
reach the same instance. It requires the native shell/runtime, with no second
package stack or web server. Source lives in `nacre/shell/modules/settings`;
configuration ownership and deployment remain in [maintenance](../maintenance.md).
