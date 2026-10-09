# Nacre device, notification, lock, time and AI Settings

Date: 2026-10-09. Final seven dashboard Settings page bodies.

## Source boundary

Delete settings/{Sound,Network,Bluetooth,Notification,Lock,Time,Ai}Page.qml bodies
without opening them, implement fresh Nacre-prefixed pages and focused shared
helpers from this spec, public declarations/API identifiers, existing tests,
live views and native dependency documentation. No upstream source consulted.
Public source/schema exposure is recorded; no legal clean-room guarantee. Keep
notices. Backend providers, lock rendering and shared helpers remain own tasks.

## Sound and connections

Native PipeWire node/default output/input and application stream controls. Bind
nodes through PwObjectTracker; read/write audio only when ready and still present.
Selecting input/output writes only preferred default, preserving mute/volume.
User-only volume/mute, readonly updates never mutate devices, stale drag/node
removal must not adjust another target. Cache labels, bound long device names and
use own palette-styled slider. Native pavucontrol remains advanced route.

Wi-Fi uses existing radio/scan/disconnect/connect owner and unique visible networks,
current connection/strength, empty/busy/error states. Connections requiring
credentials keep the existing interactive native terminal/manager; no password
entry in QML/IPC. Bluetooth uses existing bounded power/connect/disconnect/trust
allowlist; no implicit pairing/trust/power changes when page opens. Discovery and
advanced connection editing stay native manager routes. Preserve public data IDs.

## Notifications and lock

Existing DND/message-history/privacy preference toggles; retained history uses the
independent NacreNotice card. Clear/dismiss only explicit clicks, no new expiry/
retention owner. Preserve actual history, screenshots/window feedback policy and
lock privacy defaults.

Lock controls retain layout preview, explicit loginctl lock-session, lock widget
visibility/message-content booleans, weather override/save/refresh/Fahrenheit.
Opening must not lock, request a password or rewrite idle listeners. Authentication,
sleep/power locking and saved timeouts remain Hyprlock/PAM/Hypridle owned. Do not
unlock or suspend the real session for UI verification.

## Time and AI

Local time/timezone/status read from existing service, explicit install/upgrade/
refresh/device-location/automatic on-off/confirmed/manual zone actions. Native
pkexec handles administrator authentication; no time/location system change on
mount or during verification. Show bounded error/status text, preserve confirmed
fallback and GeoClue policy; public IP never changes timezone.

AI page preserves default-assistant choice for new chats, sidebar visibility and
accounts/usage/projects/Brain/sidebar actions through existing owners. Historical
chats keep their original agent/account and busy workers stay alive. Personal
Codex full-access/never and Claude skip-permissions remain unchanged. No credential
reads/migrations/permissions setting/reinstall in this task; private state stays
outside Git. Follow ai/AGENTS.md when using assistant configuration interfaces.

## Acceptance

Actual QML tests retain all-route/palette/device/lock/scroll checks and add fake
node/connection/notification/time/assistant command guards, readonly mounting,
stale/busy behavior and long text bounds. Test destructive/system writes only
with fixtures. Full checks/target Hyprland, plan/apply strict release gates, exact
installed source/IPC and native all-route/search/tab/Escape/offclick inspection.
Compare preference/account/notification state without printing credentials. CI
must pass before declaring publication complete. Single-output synthetic tests
are not physical multi-monitor/cold-login/authentication or battery measurements.
