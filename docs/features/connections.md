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
