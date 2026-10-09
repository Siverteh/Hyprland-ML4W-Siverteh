# Independent top bar, workspaces and hover policy

2026-10-09. Delete mixed modules/topbar/{TopBar,WorkspaceStrip}.qml and
services/HoverIntent.qml bodies before fresh Nacre implementations. Use current
caller declarations/public layout and IPC contract, tests, own bar controls and
native Quickshell/Qt APIs. Earlier fixes exposed these bodies; record that prior
exposure, no upstream source/no legal clean-room claim. Notices remain.

Preserve per-output50px(default) body-coloured upper surface, SH logo and seven
workspace pills on left, centred mono title/hint, shared update count, five native
status targets, clock/calendar and power on right. No bar-exclusive reservation
or new process/update checker. Respect top-edge off, hidden/reveal, output recovery,
scale and palette roles. Root NacreWindow owns namespace/layer defaults.

Workspace row keeps46x30 pills/3px spacing, seven current icons/numbers, active
accent and occupied dot; explicit left/keyboard activation uses native workspace
owner, no app launch/routing/write on display. Own controls and action protocols
remain unchanged. Unknown metadata produces existing Desktop/empty fallbacks.

Title trigger: central min700px/45%-width band, upper half-header depth25px default,
entry through lower header then movement into title opens immediately. Passive
hover stays nonmodal, no focus/grab. Session/launcher/pinned settings suppress it.
Drag/fullscreen suppress automatic entry.120ms grace on exit checks panel hover,
pin and explicit edge mode. Click-handle preference retains explicit top overlay.

Status hover chooses nearest native target from actual mapped geometry, records
header region, reads current owner/state and opens compact popout. Click audio/
network/Bluetooth opens detailed Settings; notifications toggle manual pin; battery/
calendar preserve compact behavior. Popout header exit grace/pin semantics and
geometric dismissal guard survive modal header occlusion. Ordinary hover must not
consume application clicks after closure or issue device actions.

NacreHeaderForwarder is passive PointHandler only while existing frame input is
modal. Forward outside presses to that owner; pinned status/calendar presses can
operate their own targets. Never install a second exclusive keyboard/window grab.

NacreHoverIntent owns bounded per-output point/rectangle/blocked/header state with
public compatibility maps/methods. Validate finite coordinates/dimensions, preserve
3px side edges and frame-dependent title depth. Real fullscreen flag2 suppresses
on focused monitor, maximized flag1 does not. Dismiss blocks only relevant current
edges/popup header; movement out of title region or genuine exit rearms. No polling,
process/timer, preference write or animation. Output teardown releases only state
owned by that bar instance; obsolete surfaces must not erase new registrations.

Maintained callers use Nacre names; old names own minimal adapters. header-OUTPUT
state and barStatus-OUTPUT diagnostics stay compatible without private app titles.
Actual Qt tests instantiate own trigger/forwarder/row with safe service fixtures;
retain frame tests and add maps/bounds/ownership/routing/no-display-write cases.
Native actual title approach/exit, five hover targets, header settings/pinned Escape/
offclick, workspace click and application-input return required. Full checks,
Hyprland, plan/apply/source/live and exact-main CI precede acceptance; no user
volume/radio/history/AI/private-state changes during QA.
