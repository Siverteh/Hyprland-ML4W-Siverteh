# Nacre notification presentation

Date: 2026-10-09. Area follows the verified independent launcher.

## Origin and boundaries

Delete the inherited `modules/notifications/{Notification,Content,Wrapper}.qml`
bodies, then implement fresh NacreNotice and NacreNotificationStack from this
spec, consumer declarations, behavior documentation and Qt/Quickshell public APIs.
Do not consult upstream or local target bodies. Previously searched public target
properties and reference lines are source exposure, not a clean-room guarantee.
Keep LICENSE/NOTICE. This task replaces presentation; Notifs service, history
storage, policy, settings and bar popup containers remain separate pending areas.

## Data and ownership

Cards consume service-owned objects: key, appName/appIcon/image, summary/body,
time/timeStr, actions, hovered, popup and notification. They never copy native
notification actions into history, become a second notification server, or delete
another app's entry implicitly. Dismiss through Notifs.dismiss. Actions use the
public NotificationAction.invoke API, only while the action object is current.
Plain text is the default; message bodies are not arbitrary executable/rich HTML.

Popup stacking consumes Notifs.popups. Do not show retained history as popups
again. DND remains the service's filter. Dashboard/session/popout suppression
hides the stack and releases input immediately without deleting notifications.
Hover pauses the existing service timer; leaving/teardown clears hovered. Each
output owns presentation, with a 400px preferred width clamped to available room
and a finite height cap based on actual parent height. The popup stream supports
fast scrolling when a burst exceeds that cap. No new subprocesses or idle polling.

## Interaction and visual contract

Preserve readable wallpaper-derived neutral surfaces, IBM Plex typography and
existing dimensions. Show app and timestamp above summary, short body collapsed,
expanded wrapped body, optional cropped image and action buttons. All layout
measurements must include margins and actions; long text and images stay inside
background bounds. A critical notice gets a small error-colored edge, not a big
red surface. Close and expand buttons have circular focus/hover geometry and
accessible labels. History cards use the same rendering but never resurrect native
actions from snapshots.

Clicking body toggles details. Optional actionOnClick invokes only a genuine
current default action; it never invents or invokes the first unrelated action.
Right click dismisses. Horizontal drag beyond the configured width fraction
dismisses; a shorter drag returns smoothly. Actions, dismiss and expand controls
consume clicks without triggering the card below. Keyboard Space/Enter expands,
Delete dismisses and Tab reaches controls. Motion is finite and respects reduced
motion. A dismissed/suppressed card releases its hover/input state immediately.

## Integration and acceptance

Frame host uses NacreNotificationStack and preserves its `suppressed` property and
actual box geometry contract. History delegate uses NacreNotice with history=true.
Remove inherited paths rather than retaining derived compatibility bodies.

Tests use actual replacement QML with fake service-owned entries: long-content
bounds, expand/collapse, active/default versus frozen actions, dismissal, hover
release, empty/burst stack, suppression and reduced-motion presentation. Inspect
native rendered cards; run full checks and Hyprland verification, plan/apply with
rollback, source/IPC checks and a temporary real transient notification. Preserve
existing private history and never clear it to validate a test. Document physical
output/cold-login limits and any retained provider/asset dependencies honestly.
