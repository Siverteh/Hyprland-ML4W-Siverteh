# Nacre full Media and Performance pages

Date: 2026-10-09. Next batch after overview cards.

## Source boundary

Delete dashboard/{Media,Performance}.qml bodies without opening them, implement
fresh NacreMediaPage/NacrePerformancePage and focused helpers from this spec,
public property/import declarations, runtime screenshots and dependency APIs.
Keep notices. Declaration/ref searches are prior exposure, not legal certainty.
Existing Players/SystemUsage providers and unrelated page/helper bodies remain
pending independent replacement. Remove assets/bongocat.gif only after confirming
no maintained caller remains; no new unlicensed artwork or animation replacement.

## Media behavior

Retain circular cached album art, track/album/artist text, previous/play/next,
progress/seek/time labels and native player choice/open behavior. Handle no player,
missing metadata/art, unavailable duration, capability changes and player removal.
Prefer intrinsic content around766×340px, fluid two-column art/content on wide
outputs and a scrolling vertical layout on narrower ones. Use Nacre body/ink/
accent tokens and existing fonts; no bongo or perpetual frame animation.

Only visible playing media reads position, at most once/second. Keep loaded pixels
until replacement art is ready; no new art fetches while closed. Guard all native
commands with shouldUpdate, current-player membership and canControl/canX flags.
Choose a player through Players.manualActive, never another MPRIS owner. Raise
only if canRaise; close dashboard only after that explicit user action. Known
native shuffle/repeat/volume support may be exposed with capability guards.

Seek is seconds-based. Normal property updates must never send a command. Pointer
seek commits once on release; keyboard changes can commit immediately. Capture
player and unique track ID on press, and refuse a release targeting a removed or
changed player/track or newly unsupported capability. Disable seek for unknown/
zero duration. Position sampling pauses during dragging. Clamp fractions/volume
and never restore/change playback implicitly during verification.

## Performance behavior

Retain CPU/GPU temperature and usage, memory used/total, root storage used/free,
load averages and kernel information. Consume shared resource fractions0–1 and
KiB quantities; no new scripts/collectors/timers. Separate unavailable GPU usage
from a genuine0% reading, and invalid temperatures from0°C. Clamp only gauge
geometry, display sensible unknown placeholders and preserve actual data labels.

Own paired arc gauges and measured text replace inherited rendering. Preferred
content about835×342px; narrow outputs scroll rather than overlap labels/controls.
Use current neutral surfaces and distinct real palette accents. Data-driven redraw
only, no continuous decorative animation.

## Verification

Actual production QML tests with contract providers: metadata/empty/selection,
transport/open/shuffle/repeat/volume capabilities, paused/hidden progress, pointer
and keyboard seek, no seeks during render, track/player changes during drag,
resource units/bounds/missing values, wide/narrow layout. Native Quickshell render
both pages; inspect actual live tabs without skipping/seeking the user's track.
Full checks/Hyprland verification, plan/apply, live/source/IPC, configerrors and CI
before publication. Retain private preferences, playback, accounts and busy AI.
Record single-output/synthetic-input limits and pending dependencies honestly.

Reference: [Quickshell MprisPlayer](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Mpris/MprisPlayer/)
and [loop states](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Mpris/MprisLoopState/).
Use native Slider interaction contracts and own styling, not copied shell controls.
