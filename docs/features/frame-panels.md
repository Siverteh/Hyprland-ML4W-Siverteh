# Frame and panel ownership

[Overview](../overview.md) · [Behavior specification](../specs/frame-panels.md)

NacreDesktop creates one NacreScreen per available output. Each screen owns its
visibility state, NacrePanelHost, NacrePanelInput, NacrePanelMask, NacreChrome and
transparent edge reservations. The panel host composes the current existing
launcher, dashboard, sidebar, OSD, session, notification and popout components.
Those component bodies have their own remaining rewrite areas.

The frame and joined backgrounds use the same dark body token as the bar. Native
Qt Shape geometry draws the rounded desktop opening and panel attachment curves;
full-screen wallpaper galleries retain their own backdrop. Clipping follows each
panel's current dimensions. No new process or idle animation draws the frame.

Input geometry follows logical visibility. A closing panel immediately stops
catching clicks while its visual dimensions animate to zero. A passive HoverHandler
observes movement without taking child clicks. The host exposes dashboardHovered
and popoutHovered explicitly, so callers no longer inspect a particular parent.

Explicit modal panels capture outside clicks and exclusive keyboard input. The separate
top bar forwards presses to the same outside-click controller through a passive
PointHandler. No Hyprland focus grab is taken.
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
clicks require a compositor commit; the test allows200ms and a1px movement before
checking returned input, so it does not claim zero-latency pointer retargeting.
