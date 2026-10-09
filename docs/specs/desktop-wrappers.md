# Independent OSD, session and background presentation

2026-10-09. Delete mixed/inherited modules/osd/{Wrapper,Interactions,Content},
modules/session/{Wrapper,Content}, modules/background/{Background,Wallpaper,
DynamicWallpaper} bodies before fresh Nacre implementations. References are public
signatures/data/IPC schema, caller layout/input and existing own services/widgets,
native runtime observations and Qt/Quickshell APIs. Prior reviews exposed source
portions; no upstream source consulted/no legal clean-room assertion. Keep notices.

## OSD

Preserve right-edge controls: output and microphone volume/mute, screen and keyboard
brightness, availability/error labels. Existing native services remain sole owners.
Bindings/readiness changes never issue writes; explicit user moved/clicked events
use bounded owner APIs. Unknown/unavailable hardware disables the relevant control.
No extra polling/processes. Screen-specific brightness adjusted signal and focused-
output audio/keyboard adjustments reveal OSD; initial metadata/device readiness
must not show it. External volume/mute changes after a baseline may show it.
Two-second activity lifetime pauses while hovered; session/lock suppress overlay.
Closing releases logical visibility/input immediately while clipped finite width
animation retains internal geometry. Reduced motion settles, rapid reversal keeps
latest target. Hidden content is unloaded at end. Preserve public aliases/contracts;
new callers use Nacre names, old names small own adapters.

## Session

Four current actions: loginctl lock-session; Hyprland Lua exit; systemctl reboot;
systemctl poweroff. Launch only after explicit activation of an allowlisted key,
through existing AppLaunch; close session first. No process/action on open. Compact
four-button vertical layout, accessible labels, palette body/raised/error roles.
Finite clipped opening/closing, immediate logical input release and retained closing
geometry, reduced motion. Frame still owns Escape/outside-click/fullscreen masks.
Do not change password authentication, sleep hooks or hardware power policy.

## Background

One lower-layer, noninteractive, unreserved surface per output, hidden with shell.
NacreWallpaperScene owns two native asynchronous/cache/retained poster buffers.
Load pending poster in the unused buffer; only latest ready path can activate
NacrePresentation. Keep the previous image opaque under the new image's finite
fade, so total coverage never dips during source-over compositing. Coalesce rapid
requests during a fade, reject stale readiness, retain last good image on error.
File URLs encode literal percent/spaces. Native source-size follows logical output
and DPR. Initial/same-poster publication keeps established active pair semantics.

Moving GIF/video follows the matched active record, not pending selection. Poster
always remains behind media. Native muted infinite video exposes first-frame /
error state and retains poster until a frame arrives; no sound track or converter.
Pause on existing sleep/lock/user/battery/picker/coverage policy. No background
palette generation or duplicate state provider. Keep wallpaperFrame-OUTPUT and
wallpaperMotion-OUTPUT IPC contracts, including read-only readiness/colour/motion
fields, without adding metadata polling. Playback policy provider is a separate
remaining originality task; do not silently change user's motion settings.

Actual Qt/native tests verify controls read-only startup vs user actions, focused
OSD events/deadlines, lifecycle/reversal/reduced motion/session allowlist, poster
readiness/error/latest-wins/coverage and matched activation. Existing gallery/image
and publication tests remain. Native runtime/source/palette/motion read-only checks,
OSD/session/Escape/application return, private hash/device values, compositor and
full tests/plan/apply/main CI precede acceptance. No real lock/power/brightness/
volume/wallpaper selection writes during QA. Single-output acceptance does not
prove physical hotplug/cold login/battery behavior.

Live/ordering follow-up: session opening requests Qt focus after positive visible
geometry, with Escape still propagated to the existing frame owner. The poster
also listens to presentation revision, so an already-ready image retries matched
activation when palette data arrives later without changing the poster URL. No
polling/delay or image apply is introduced; both have actual Qt regressions.
