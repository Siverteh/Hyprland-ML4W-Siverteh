# Frame and panel ownership

[Overview](../overview.md) · [Behavior specification](../specs/frame-panels.md)

NacreDesktop creates one NacreScreen per available output. Each screen owns its
visibility state, NacrePanelHost, NacrePanelInput, NacrePanelMask, NacreChrome and
transparent edge reservations. The panel host composes the current existing
launcher, dashboard, sidebar, OSD, session, notification and popout components.
Their component bodies have separate source reviews in the provenance tracker.

The frame and joined backgrounds use the same dark body token as the bar. Native
Qt Shape geometry draws the rounded desktop opening and panel attachment curves;
full-screen wallpaper galleries retain their own backdrop. Clipping follows each
panel's current dimensions. No new process or idle animation draws the frame.

Input geometry follows logical visibility. A closing panel immediately stops
catching clicks while its visual dimensions animate to zero. A passive HoverHandler
observes movement without taking child clicks. The host exposes dashboardHovered
and popoutHovered explicitly, so callers no longer inspect a particular parent.

Explicit modal panels capture outside clicks and exclusive keyboard input. The
header shares the frame surface and draws above the panels. A modal header click
dismisses through the same controller and is consumed so it cannot also activate
a bar command. Pinned popout anchors retain their own interaction. No extra
Hyprland focus grab is taken.
Ordinary hover menus remain nonmodal. AI uses on-demand keyboard interaction whether or
not pinned; pinning releases the explicit click-away mode. Root layer/namespace
stay stable as panels open and close. Side hover activation shares the host's
click-through mask instead of creating a separately toggled left-edge window.
The existing precise hover guard, header exit grace and OSD activity timer remain.

registry.js replaces per-output maps atomically and releases only its own objects,
so an older output teardown cannot delete a newer host's registration. Existing
output recovery and recursive draft/scroll snapshots keep their contracts.

Read-only diagnostics are available through `quickshell ipc -c nacre call frame
state` and the existing `leftEdge state`. Tests exercise actual pointer/click-away
behavior, closing masks with nonzero visual geometry, pin/hidden modes, parent
coordinates, ownership replacement, and native rendered holes/joins/palette changes.
Live focus/application clicks require the target compositor, beyond headless tests.


The header diagnostic `header-OUTPUT state` reports pointer/guard state. After
explicit dismissal, the title band remains blocked until the pointer leaves or
passes through the lower header; entering at the title from a synthetic teleport
is not the same as a physical path through that boundary. Extended live tests
follow the lower-header/title path and use an ordinary temporary application to
verify click and keyboard delivery after closure. Immediate scripted back-to-back
clicks require a compositor commit; the test allows 200 ms and a 1px movement before
checking returned input, so it does not claim zero-latency pointer retargeting.

## Independent OSD and session wrappers

The former NacreOsdPanel/Controls types forward to the control center's explicit
right-menu presentation and horizontal levels. NacreOsdEvents/LevelNotice own
separate short automatic feedback, never the full panel. Existing audio/backlight/keyboard owners handle writes; loading/readiness
changes do not write hardware or reveal OSD. Actual adjustments reveal the focused
output only, with hover-paused two-second expiry. NacreSessionPanel/Controls expose
the four existing allowlisted actions through AppLaunch, with no action on display.
The enclosing frame retains Escape/outside-click/input ownership. Closing releases
logical regions immediately and clips a short transition before unloading content.
Reduced motion settles immediately. See the [wrapper spec](../specs/desktop-wrappers.md).

## Root composition and panel routing

NacrePanelState is the sole owner of panel flags and routing. NacreShellIpc preserves
maintenance/control commands, previews, galleries, workspace/tab selection and
recovery handoff. NacreShellShortcuts delegates keyboard/legacy drawer commands to
the same owner. The root composes the existing independent surfaces and shared
providers once. Ordinary reads/opening do not start an AI worker, change settings,
apply a wallpaper or run a device action. The old Visibilities interface forwards
mutable maps/preferences to the same owner for compatibility.

## Visual cleanup after the rewrite

The title's painted icon/text group now centers within its bounded header slot,
including short titles. Right-edge levels return to a narrow 2×2 layout: screen
and keyboard above output/microphone, with separate mute controls below. Fixed
content geometry remains clipped while the panel closes; device owners and user-only
writes are unchanged. Dashboard geometry eases over 360ms without delaying its
hover trigger. Quick popup geometry uses a finite 230ms transition.

Live notification popups share the header/right-frame background and downward
reveal rather than floating as detached cards. The right-edge grid omits unused
mute space below brightness controls, with closer columns and rows; audio mute
buttons stay contained. Full-screen wallpaper galleries cover the available
viewport without the launcher panel's enclosing background. Native pixel checks
cover both the notification join and transparent gallery chrome.
