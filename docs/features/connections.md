# Connections

[System overview](../overview.md) · [Deployment and recovery](../maintenance.md)

## Quick sound and connection controls

Hovering the Sound, Wi-Fi or Bluetooth top-bar icon shows its native quick
controls. Clicking the icon opens its matching built-in Settings page and closes
the preview. The quick popups have no Settings footer button. Escape dismisses
open overlays; moving away closes hover previews. Sound offers
volume/mute, microphone volume/mute and output selection; Wi-Fi offers its
radio, refresh, connection status, nearby networks and disconnect; Bluetooth
shows power and connect/disconnect for already known devices. Lists have bounded
height and use the shared fast scroll. Error text is bounded inside the popup.

The icon click opens the matching built-in Settings page and dismisses the quick
popup through shared visibility/navigation state. Application audio streams,
connection profiles, pairing and trust controls remain in detailed Settings.
Password entry remains in NetworkManager's native prompt, and pairing stays in
the Bluetooth manager. Device actions reuse the bounded helper and existing
network/Bluetooth state owners; completion requests a fresh snapshot without a
polling timer. Wi-Fi disconnect accepts a validated interface name, while the
status helper selects only a connected Wi-Fi interface. Short SSIDs remain
visible. Native tests use fake devices, so routine validation does not change
the live connection or audio state.

Wi-Fi lists share a grouped view that prefers the active access point for each
SSID, even when another band or mesh node is stronger or appeared first. If none
is active, the strongest access point represents the name. Connected rows show
Connected and offer Disconnect in both the popup and detailed Network page.
Grouping reads every AP's active/signal fields so roaming updates the row without
waiting for a list rebuild. Read-only `networkStatus.state` IPC reports whether
the current SSID's grouped row is connected for troubleshooting.

Rotation deadlines derive from persistent successful photo timestamps and the
saved rotation enable/interval/filter anchor, so renderer restarts and unrelated
picker/color preferences cannot postpone them indefinitely. Old private records
migrate using their existing modification time, without changing the selected
wallpaper. The publisher preserves the photo timestamp for color-only commits.
Only a successful wallpaper change advances it; failures retry after one minute.
Settings shows the real schedule or specific pause reason, and `wallpaper.state`
IPC includes timer-running, due-time, remaining-seconds and pause-reason fields.
There is still one one-shot timer, no recurring countdown polling and no new
wallpaper owner. Deadline values are epoch milliseconds, independent of timezone.


## Independent device-state owners

NacreAudio tracks the default PipeWire output and microphone without process
polling. Missing/unbound/removed nodes are unavailable. Volume writes are finite,
bounded to0–100%, and preserve mute; optional original-node arguments prevent a
stale request from affecting a newly selected default. Native changes still
drive the existing on-screen indicator.

NacreBluetooth reads native Quickshell/BlueZ adapters and device models. Aliases,
pairing, trust and connection changes update views directly; opening it never
powers/scans/pairs/connects a device. Known disconnected devices remain listed.

NacreNetwork takes read-only snapshots through network-state.py. It never asks
for secrets or forces a radio scan when opening controls. One NetworkManager
monitor coalesces changes; explicit action completion and opening Wi-Fi refresh
the snapshot. Duplicate SSIDs prefer the connected AP, then signal strength.
Escaped names and hidden active networks are preserved. A failed snapshot keeps
the last valid state; failed monitoring retries with bounded backoff, without
periodic successful snapshots. networkStatus.state adds error/busy/monitor/read
diagnostics to its existing connection fields; refresh requests a read-only
snapshot. DeviceActions remains the sole write owner.

Old Audio/Network/Bluetooth service names are small external compatibility
forwarders. Their popup filenames are separate presentation components and
remain unchanged. The [service spec](../specs/device-services.md) records source
boundaries; other services/popouts and helper provenance remain pending.

## Independent bar targets

NacreActiveTitle, NacreStatusIcons and NacrePowerButton now implement the bar's
focused title, five status targets and explicit power-menu activation. Shared
native services own the data; these views add no polling. Unknown battery data
stays unknown until UPower is ready. The read-only `barStatus-OUTPUT state` IPC
reports target geometry/counts for interaction checks without exposing window
titles, network identities or notification text.

NacreBatteryPopup uses native profile buttons with availability guards; opening
it does not change a profile. NacreCalendarPopup uses Nacre's own local-date helper
and locale week order. The inherited CalendarGrid is retired after its last caller
was replaced. Old component names are small forwarders. Popup assembly and the
other quick controls remain separate audit areas. See the
[bar behavior spec](../specs/bar-controls.md).

## Independent quick popup assembly

NacreSoundPopup, NacreNetworkPopup, NacreBluetoothPopup and NacreHistoryPopup use
existing native owners. Display reads never issue an action; sound tracks current
output nodes, and Wi-Fi/Bluetooth resolve row identifiers against current state
before acting. Full device Settings remains on header click, while hovering keeps
compact controls. Notification history reuses the Nacre notice presentation and
writes only for explicit clear/remove/DND actions.

NacrePopupPanel/NacrePopupContent load six supported views on demand. Closing
releases pin/interaction immediately, retains clipped rendering for180ms, then
unloads it. Reduced motion closes immediately. NacreQuickList gives bounded fast
wheel scrolling with finite easing/native drag; NacreQuickSlider uses native Qt
user-moved semantics and palette-colored rounded controls. No polling or extra
data owner is introduced. Old names are compatibility forwarders. See the
[popup spec](../specs/quick-popups.md).

The notification popup's Do Not Disturb button uses the desktop setting owner's
set API. The native fixture mirrors that real interface, so a stale mocked method
cannot hide a broken click. Lock snapshots convert native battery fractions to
percent values and use null for unavailable data, matching the bar's semantics.
