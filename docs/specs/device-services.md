# Independent Nacre device services

2026-10-09. Three separately committed replacements: default audio, Wi-Fi state,
and Bluetooth state. No visual redesign or new system/device configuration owner.

## Source boundary

Delete services/{Audio,Network,Bluetooth}.qml bodies before implementing replacements
from this specification, public declaration/consumer identifiers, existing tests,
runtime behavior and official dependency documentation. No upstream implementations
consulted. Prior turns inspected some provider schemas; this is not a legal
clean-room assertion. Existing notices remain until the whole-tree audit.
Use NacreAudio/NacreNetwork/NacreBluetooth for maintained consumers. Minimal old-name
forwarders may remain for external users; they contain no inherited bodies. Popup
file names and other native namespaces are unchanged. Helper/backend provenance
outside these three services remains a separate task.

## Default audio

Native PipeWire default output/input, tracked with PwObjectTracker. Expose sink,
source, volume/muted, micVolume/micMuted/micAvailable and safe output readiness.
Null, unbound and removed nodes are unavailable; do not read invalid audio values.
User-only volume/mute methods reject nonfinite values, clamp to 0–1, preserve mute
when adjusting volume, and optionally accept the originally chosen node so a stale
request cannot transfer to a new default. Native property changes must still
notify the existing OSD. Never select devices or write on startup/default changes.
No polling, Python or subprocess audio collector.

## Wi-Fi

NetworkManager remains the owner. New read-only Python snapshot helper uses nmcli
terse escaping with a fixed locale, explicit fields and deadlines, and never asks
for secrets or forces rescans. Preserve SSID/BSSID/strength/frequency/active and
connected Wi-Fi interface/radio state. Decode escaped colons/backslashes, validate
bounded records, prefer active AP over stronger duplicate SSID, sort stably and
retain a hidden active connection. Never substitute Ethernet for Wi-Fi.

One long-lived nmcli monitor coalesces events into snapshots; no periodic successful
refresh. Refresh on startup, explicit action completion and opening Wi-Fi controls.
Failed reads retain the last valid snapshot with bounded error/busy status. Queue
at most one repeat while busy, debounce bursts, and back off a failed monitor up
to 60 seconds. Snapshot publication is atomic. Keep networkStatus.state compatible
and add bounded read-only diagnostics. Native password/disconnect/radio/scan actions
remain with DeviceActions. No new credential reader or connection writer.

## Bluetooth

Use Quickshell.Bluetooth native BlueZ models with an explicit namespace alias.
Expose powered/discovering/available and known-device name/alias/address/icon/
connected/paired/trusted views across adapters. Native changes update existing UI;
removal and absence are safe. Preserve known paired devices while disconnected.
No polling, shell parsing, discovery/pairing/trust/power action on startup. Existing
DeviceActions and native manager own writes; refresh is a compatibility notification,
not a subprocess. Do not mutate native models while creating views.

## Acceptance

Native Qt tests load actual new service code with fake dependency models: reads
without writes; audio node readiness/removal/default switch/clamping/mute safety;
Bluetooth field changes/removal/absent adapter; network valid/error publication,
monitor burst/busy coalescing. Python helper tests cover escaping, duplicate/hidden
APs, interface/radio state, malformed records, command failures/deadlines and no
rescan/secret queries. Preserve existing popup/Settings tests with new service names.
Run full checks, target Hyprland, shell plan/apply, strict live release/source/IPC
checks, actual pages/popups and Escape/offclick. Compare private preference hashes,
current connections and default audio state without printing credentials or device
IDs. Physical roaming/reconnect/hotplug/cold login and battery drain require later
hardware acceptance. Update overview/architecture/feature/provenance docs.

## Dependency references

- https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/Pipewire/
- https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/PwNode/
- https://quickshell.org/docs/v0.3.1/types/Quickshell.Bluetooth/Bluetooth/
- https://quickshell.org/docs/v0.3.1/types/Quickshell.Bluetooth/BluetoothDevice/
- https://networkmanager.dev/docs/api/latest/nmcli.html
