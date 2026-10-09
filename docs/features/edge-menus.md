# Edge Menus

[System overview](../overview.md) · [Deployment and recovery](../maintenance.md)

## Hover input and retained notifications

Passive top-menu, device-popup and OSD hovers have no keyboard interactivity.
Pinned Settings, launcher/session and pinned popups retain keyboard support; the
chat drawer keeps its existing on-demand focus. Closing a drawer or popup removes
its input region immediately while the visual animation finishes; its content is clipped to the shrinking panel. This prevents the closing
panel from reopening or consuming clicks on application controls beneath it.
Pinned Settings retains exclusive keyboard focus and its existing outside-click
and Escape behavior.

The notification popup stream is separate from retained history. Notifications
marked transient and narrowly identified screenshot/window-action feedback appear
briefly but do not populate history, the unread badge or lock widgets. A shared
`notification-policy.json` defines the internal feedback sources and summaries;
legacy history uses the same policy. Messages, assistant completion and error
notifications remain retained. Clearing the history still removes retained items.

Lock labels wrap using measured IBM Plex Sans widths with a bounded line count
and ellipsis. Weather and media have dedicated text/artwork/control space;
notification cards leave padding around three detailed previews. Media buttons
use fixed pixel spacing around the per-output card center. Native Hyprlock uses
framebuffer coordinates for these widgets even at fractional scale; using logical
width displaces the controls. Output-mode recovery regenerates the next lock
layout using current monitor dimensions, while preserving renderer recovery if
that refresh fails. Authentication remains owned by Hyprlock/PAM.


## Clickable edge handles

Desktop → Edge menu activation offers Hover (default) and optional Click handles. Handles
fade in after a160ms hover and allow280ms to leave before hiding. They use the
current shell palette and layer surfaces with no reserved space; window geometry
and desktop spacing are unchanged. The top-center handle opens the dashboard;
small targets at the middle of the left and right edges open AI and quick sliders.
Hovering top-bar status icons shows a short label; clicking keeps the existing
Sound/Network/Bluetooth Settings routes and opens the other controls explicitly.
Calendar and notification popups remain open until dismissed.

Clicked edge panels close with Escape or outside click, and do not close merely
because the pointer leaves. Opening AI leaves its pin false; explicitly pinning
it releases the click-away grab and keeps the existing pinned behavior. Audio and
brightness hotkeys still show temporary OSD feedback. Hover mode restores the
previous automatic edge entry while retaining immediate input release on close.
The saved clickEdgeMenus preference is a validated private boolean, included in
normal desktop presets. Keyboard shortcuts are unchanged. The bar remains on top.


## Precise immediate-hover activation

Hover mode opens the dashboard when the pointer reaches the middle/title line
of the top bar, within its existing centre band. Left/right activation uses a
3-pixel outer-edge strip within each panel-height band.
Opening has no additional delay, while the existing panel animations remain.
Opened panels retain a larger padded interaction area. A120–140ms exit grace
allows moving from the header into content without adding an opening delay.

Explicit dismissal blocks only edges the pointer still touches. Leaving and
re-entering re-arms them. Automatic entry ignores held mouse buttons and true
fullscreen windows on the focused output; maximized windows still allow hover.
Explicit clicks and keyboard launch routes remain available. A non-consuming
Escape shortcut dismisses passive previews while allowing the application's
Escape action to continue; pinned AI and explicit modal panels keep their own
existing dismissal behavior. State follows pointer events and one-shot exit
signals, with no global pointer polling or additional input process.


## Independent notification presentation

NacreNotice renders both popups and retained-history entries. It wraps plain-text
messages inside measured card bounds and offers explicit expand/dismiss controls.
Short horizontal drags return; longer drags dismiss. Current default actions are
used only when action-on-click is enabled; frozen history never recreates native
actions. The popup stack is capped to the output height and uses fast scrolling
for bursts. Suppression removes the input region immediately and releases hover
state without deleting messages or history. Existing DND, retention, expiry and
history storage remain owned by Notifs and its private helpers.

## Independent header and hover owner

NacreTopBar/Header now assemble the existing bar controls. NacreWorkspaceRow
preserves the seven current workspace pills and dispatches only explicit user
selection. NacreHeaderTrigger implements immediate title-band hover with exit
grace; NacreHeaderForwarder observes modal outside presses passively, preserving
application click delivery. Native status and calendar targets use their measured
geometry; clicked device icons retain detailed Settings routes.

NacreHoverIntent replaces the shared policy body. It keeps per-output geometry /
blocked state, fullscreen/drag suppression, real-exit rearming and the modal-header
geometric guard. An obsolete header teardown cannot delete a newer registration.
No polling, update checker, process or user preference writer is added. Old names
remain small compatibility adapters. See the [header spec](../specs/topbar-hover.md).
