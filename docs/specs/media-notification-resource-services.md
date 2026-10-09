# Independent media, notification and resource services

2026-10-09. Separate provider commits from consumer contracts, native dependency
docs, existing tests and runtime observations. Delete Players/SystemUsage/Notifs
bodies before fresh implementation; no upstream source consulted. Prior provider
schemas and helper sources exposed in earlier work are acknowledged; not a legal
clean-room assertion. Retain all notices and separately audit remaining helpers.
Maintained names: NacrePlayers, NacreSystemUsage, NacreNotifs, plus small legacy
forwarders. One notification server, collector and native media model owner.

## Media

Native MPRIS models. Selection priority: valid manual choice, playing Spotify,
other playing player, idle Spotify, first available, null. Clear removed manual
choices; never control/select a vanished player. Preserve existing mpris IPC
getActive/list and play/pause/playPause/previous/next/stop plus shortcuts. Capability
checks precede every command. Selection/state reads never play, seek, pause, raise
or change volume. Preserve current widgets' visible-only position observation.

## Resources

Read CPU/memory/load/kernel asynchronously with native FileView. CPU first sample
is a baseline, subsequent aggregate counter deltas use first eight counters,
idle+iowait excluded from busy and guest not double-counted. Handle invalid/reset/
unchanged counters without fabricated percentages. MemAvailable preferred, bounded
legacy fallback; units remain KiB and fractions, using real values for large disks.
Visible overview/performance tabs sample fast native files at1Hz, stop when hidden,
rebase CPU on reopen. One startup snapshot for lock-prepared data; sysfs temperature,
optional GPU busy and root disk reads via a small read-only helper at startup and
30-second intervals only while visible. No sensors/nvidia commands or GPU wakeup.
Absent sensors are NaN/unavailable, not zero. Preserve existing UI and formatting
contracts; expose bounded read-only collector diagnostics for verification. No
constant interpreter launches when idle and no proc/sys writes.

## Notifications

Native notification server with live entry objects and display snapshots after
native handles close. Preserve actions while valid, replacement updates, native
user-dismiss vs expire distinction, DND, shared feedback/transient retention policy,
hover/suppression pause, finite popup expiry, native timeout0 permanence, explicit
history clearing/dismissal and existing notifs IPC/counts/shortcut. Plain-text
presentation remains; do not advertise unsupported markup or inline reply.

Read existing private history through its current permission/atomic helper and
merge by stable key before any write. No rewrite on clean load. Events arriving
while load is pending must be retained; dismiss/clear must not resurrect loaded
rows. Failed/malformed loads protect the file from overwrite and show bounded
error diagnostics; save coalesces mutations with at most one writer plus pending
latest state. Persist only display fields, never native action/notification objects.
Closed/expired normal messages remain history; transient/feedback entries do not.
Popup suppression and hover cannot retain timers after close. History remains
outside source/releases. Native replacements update one entry instead of duplicate
history; native IDs and handles are absent from saved snapshots.

## Acceptance

Native Qt tests load actual new service/entry code with fake dependency models:
media selection/capabilities/removal, CPU counter/memory/reset/visibility behavior,
notification receive/replace/close/dismiss/expiry/DND/hover/suppression/transient/
feedback/load race/clear/save queue guards. Read-only helper tests cover sensors,
missing/malformed files, large disks, unit conversion and no commands/proc writes.
Retain real overview/media/performance/notice/settings tests with new names.
Full checks, target Hyprland, shell plan/apply/strict source and native gates, actual
panels, temporary transient notification and quiet collector check. Private
history/preference hashes and playback state compared without printing contents.
Do not stop actual media, clear real messages or restart busy AI workers. Hardware,
cold login and battery measurements remain separate acceptance.

References: Quickshell0.3.1 Mpris/MprisPlayer, NotificationServer/Notification,
Io/FileView and Linux kernel proc documentation (primary docs).
