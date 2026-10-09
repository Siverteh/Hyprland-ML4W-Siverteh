# Media, notifications and resource state

NacrePlayers follows a valid manual choice, then playing Spotify/another player,
idle Spotify and the first available player. Removed selections clear safely.
Media IPC and shortcuts check native capabilities before sending commands.
Selection never starts playback or changes volume. Existing widgets continue to
sample progress only while visible.

NacreSystemUsage reads proc CPU/memory/load/kernel files asynchronously. Visible
overview/performance tabs sample at1Hz; other tabs and closed menus stop sampling.
CPU is unknown until two valid counter samples are available and resets its
baseline on reopening. Memory uses MemAvailable, with a bounded older-kernel
fallback. KiB values use real numbers, avoiding signed integer overflow on large
disks. Disk and readable CPU/GPU sysfs sensors refresh once at startup and every
30seconds only while a resource view is visible. Missing GPU usage/temperature
remains unavailable; no nvidia-smi or sensors process wakes a GPU. Unsupported
GPU interfaces are intentionally unknown. resources.state exposes bounded counts
and values for verification. Hidden lock-prepared data uses the last snapshot.

NacreNotifs keeps one native server and one live entry per notification. Valid
actions remain native; closed/expired normal messages freeze into display-only
history. Native replacement updates reuse an entry/key. Transient feedback never
enters history. Existing DND/lock privacy and feedback policy stay in effect.
Popup expiry pauses while hovered or while menu geometry still suppresses the
stack; permanent native timeout0 is respected. Explicit dismissal differs from
native expiry; history clearing stays an explicit Settings action.

The current private history helper retains atomic writes and0600/0700 permissions.
Loading merges existing rows with arrivals before any write; clean load performs
no save. Clear/dismiss during loading cannot resurrect old messages. Invalid
loading protects the file from overwrite; failures expose bounded diagnostics.
Save requests coalesce behind a single writer. Native notification IDs, action
objects and handles are excluded. Restart/reload restores snapshots, not closed
action handles; live notifications are not replayed as new popups.

Originality boundaries and acceptance are in
[the specification](../specs/media-notification-resource-services.md). Other
providers/helpers and final provenance audit remain; applicable notices stay.
