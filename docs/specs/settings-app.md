# Nacre Settings application

User requested moving full settings out of the top dashboard into a fast normal
application. Retain all settings/backend behavior, palette integration, cached
wallpaper previews and 20-second display Keep/Revert safeguards.

Use one Quickshell FloatingWindow hosted by the existing shell. Independent UI
lifecycle, shared singleton backends: no second notification/audio/network daemon,
new config owner or web runtime. Instantiate the window only on first use; retain
its lightweight navigation when hidden, load only the active page, and stop page
polling when closed/minimized. Repeated activation focuses the existing window;
never toggle it closed or spawn duplicates. Close/Escape/Ctrl+W affect Settings
only. Search uses Ctrl+F, keyboard navigation and existing accelerated scrolling.

Design: opaque wallpaper-tinted body, quieter category rail, readable existing
fonts, thin separator and compact window controls. Initial size fits the focused
monitor; resize/maximize normally. Move the old content/pages into modules/settings;
keep dashboard's four overview/media/performance/workspace tabs. Settings entry
points open/focus the app, with page targets for device/settings controls. Legacy
settingsView IPC and the former fifth-tab action forward to the same app.

Provide nacre-settings and its .desktop entry, page actions and own radial cog
under the approved shell lip. All variants share the existing branding owner.
Cold CLI launch starts the existing user shell unit and retries within a bound;
failures are visible. No credentials, privilege prompt or assistant restart needed.

Research informed behavior, not copied implementation:
- Noctalia documents open/focus/close settings with an optional target section:
  https://github.com/noctalia-dev/noctalia-docs/blob/main/src/content/docs/noctalia/ipc/shell.mdx
- DankMaterialShell documents page-directed settings IPC (its modal differs from
  the requested normal window): https://danklinux.com/docs/dankmaterialshell/ipc
- Quickshell FloatingWindow/QsWindow public APIs:
  https://quickshell.org/docs/v0.3.0/types/Quickshell/FloatingWindow/
  https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow/

Acceptance: all prior settings page tests, normal-window close/reopen/focus/page
routes, one-instance lifecycle, hidden/minimized polling guards, legacy callers,
launcher registration, native runtime/render/resize/keyboard checks, actual
backend operations and palette updates; full checks/Hyprland/plan/apply/live
source/IPC and unchanged worker checks before publishing. Retain licenses/notices.
