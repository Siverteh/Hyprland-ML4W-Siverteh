# Independent wallpaper and weather providers

2026-10-09. Replace mixed services/Wallpapers.qml and Weather.qml from public
caller signatures, existing behavioral tests, producer schemas and Quickshell
Process/FileView documentation. Delete old bodies before implementing. Earlier
reviews exposed portions of providers/helpers; this is an independent replacement
record, not a legal clean-room assertion. Retain notices and audit producers,
playback, fixtures and assets separately.

## Wallpaper behavior

Own NacreWallpapers provides a validated catalogue of local wallpaper records,
preferences and preset descriptions. Retain old Wallpapers name only as a small
forwarder; maintained callers use NacreWallpapers. Invalid refreshes preserve the
last good catalogue. Native file watches keep last poster/media state current.
Never apply a wallpaper or write preferences merely because a panel opens.

Browse updates a local preview selection. Actual selection uses the existing
single wallpaper-media.py publisher: 150ms debounce and latest-request-wins queue,
without cancelling an in-flight palette publication. Collect stdout before
completion; errors clear the failed request and allow a retry. A successful
publication clears only its own preview, not a newer selection. Active video and
poster follow NacrePresentation's matched active record rather than pending
selection. Static, animated and video records remain distinct.

Preference patches execute serially via JSON stdin; palette keys use `theme`,
others use `preferences`. Read confirmed preferences, never invent success.
Import uses the existing chooser/helper, reports errors, and refreshes/warm-caches
on success. Cancellation changes nothing. Command arguments remain separate
strings, never shell-interpolated filenames. Background cache preparation uses
nice priority and coalesces requests. Directory changes use the existing inotify
helper with bounded restart delays, not periodic whole-library scans.

Rotation retains its persisted anchor, 5–1440 minute interval, filtered pool and
no-repeat shuffle bag. Sleep, lock, picker, Settings and busy publication pause
rotation without moving its due time. An overdue resumed timer advances once;
new publication anchors the next interval. Manual advance respects publication
and device readiness. Failure backs off one minute rather than spinning. One
existing commit queue handles clicks, imports and rotation. Keep IPC wallpaper
get/set/configure/next/list/state contracts. Diagnostic additions expose counts
and errors, not private artwork paths. Remove unused fuzzy-prepared objects and
third-party fuzzysort after verifying no maintained callers remain.

## Weather behavior

Own NacreWeather keeps one atomic reading with Celsius measurements, optional
feels-like/high/low, location, description, icon, checked time and stale/error.
Initial unknown temperature is NaN. Load private cached data immediately without
network access, mark old readings stale, then refresh with existing bounded HTTPS
helper. Refresh every 30 minutes and on user request/location changes; coalesce
requests while busy and reject old-city results after a location change. A failed
or malformed response preserves last-good conditions and their timestamp, marks
stale and exposes an error. No repeated rapid network retry, subprocess polling,
timezone changes or preference writes. Fahrenheit formatting is view-only.

Native tests cover queue/error/stale/unknown/units, catalogue validation, rotation
pause/deadline and current-versus-displayed assets. Full checks, compositor parse,
plan/apply and native read-only picker/Settings/weather acceptance precede push.

References: https://quickshell.org/docs/v0.2.1/types/Quickshell.Io/Process/
and https://quickshell.org/docs/v0.2.1/types/Quickshell.Io/FileView/ .
