# Independent app, clock and compositor services

2026-10-09. Delete Apps/Time/Hyprland provider bodies before fresh Nacre-prefixed
implementation, keeping small legacy forwarders. Source exposure: public provider
and caller declarations, current UI/tests, app launch helper contracts and primary
Quickshell/Hyprland API docs. No upstream implementation consulted; not a legal
clean-room assertion. Applicable notices remain; other providers/helpers are separate.

## Apps

Native DesktopEntries model, stable alphabetical name/id order and deduplicated
IDs. Keep NoDisplay and user-hidden apps out of normal results, but preserve full
non-NoDisplay metadata for the hide/unhide view. Preferences are never rewritten
when apps disappear. Pure own ranked search over name, generic name, description,
keywords and ID: normalize case/diacritics, exact/prefix/word/substring/acronym and
bounded subsequence fallback; all query words must match. Stable ties and no
third-party fuzzy-search import in this provider. Return original desktop objects,
not copied command records. Opening/search never launches. Launch validates current
visible membership, uses parsed argument lists and workingDirectory through existing
AppLaunch, and wraps terminal entries in kitty --. Preserve installed themed entry
commands, private environment cleanup, favorites/categories and launch scope. Never
parse Exec strings as shell. Removed/hidden/foreign command objects cannot execute.
The wallpaper provider still depends on the old fuzzy helper; do not delete it yet.

## Clock

One native SystemClock, default minute precision because current consumers display
minutes/date; opt-in seconds precision available. Expose enabled/date/hour/minute/
second and Qt local-civil format API, with legacy enabled synchronization. No extra
polling interpreter/timer, clock/timezone/location writer or administrator action.
Calendar, bar and lock preview use the same clock. Preserve saved timezone policy.

## Compositor

Native Hyprland workspace/monitor/toplevel models, normalized client views with
stable object identity per live native window. Preserve address, class/title,
initial identifiers, geometry, workspace, floating/fullscreen, pid and focus history
contracts; missing metadata uses safe defaults. Native activated/window/workspace
changes update live references; removed handles disappear, no retained dead client.
Debounce relevant raw events into native metadata refresh (needed for lastIpcObject
fields such as fullscreen), with no periodic clients polling and no event-object
retention beyond callback. Preserve toplevel refresh and workspace/window commands.

Current session uses Lua. Convert numeric legacy workspace requests into native
Lua dispatcher expressions, accept existing trusted internal hl.dsp expressions,
and use native dispatch expression transport (Quickshell wraps hl.dispatch). Do not silently send legacy
strings to Lua. Non-Lua native sessions preserve native dispatch. No commands on
startup/model reads beyond read-only refresh/cursor and bootstrap focus queries. Explicit reload means
refreshing state, not rewriting or reloading managed compositor configuration.
Keep monitor focus and cursor snapshot contracts. Bounded read-only diagnostics
must omit window titles/classes/process IDs. Every UI caller uses NacreHyprland;
aliased native namespace references remain distinct.

## Acceptance

Actual new QML with fake native models tests app ranking/Unicode/token/hidden/
duplicate/stale launch/terminal/cwd, clock precision/format/enable, stable compositor
views/metadata/focus/removal/event coalescing/dispatch mode and missing data. Real
launcher/workspace/hover/frame/calendar regressions retained. Full checks/target
Hyprland, shell plan/apply/strict source/IPC gates, native app/compositor/clock probe,
real launcher search/favorites/categories, workspace switch with focus restore,
hover-close application input, all Settings/tabs/Escape/offclick. Preserve private
favorites/history/palette/device/account state. Do not launch user apps or move
existing windows for command verification; synthetic fixture commands suffice.
Single-output physical/cold-login/battery behavior and remaining providers/audit
are not completion claims.

Primary references: Quickshell0.3.1 DesktopEntries/DesktopEntry/SystemClock,
Hyprland/HyprlandToplevel/HyprlandEvent; target Hyprland0.56 Lua dispatcher API.

Native acceptance refinement: this runtime supplies unprefixed native addresses
and no activated Wayland handle in a windowless probe. Canonicalize addresses to
0x-prefixed keys, seed focus once with a generation-guarded read-only activewindow
query, then consume activewindowv2 events. Do not issue native metadata requests
before Lua-mode initialization; refresh after usingLua changes. This preserves
focus/fullscreen guards without polling clients or focus.
