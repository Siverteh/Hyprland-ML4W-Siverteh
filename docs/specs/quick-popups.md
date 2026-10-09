# Independent quick popups and shared assembly

2026-10-09. Delete mixed/inherited bar/popouts/{Audio,Network,Bluetooth,
Notifications,QuickList,QuickSlider,Content,Wrapper}.qml bodies before implementing
Nacre equivalents. References: public declarations, caller routing/input geometry,
existing behavior tests, own native service interfaces and Qt/Quickshell APIs.
Earlier reviews exposed device-view/assembly portions; record exposure, do not
claim a legal clean room. No upstream implementation consulted. Retain notices.

## Device views

Keep compact hover controls and header-click Settings navigation. Sound includes
output/microphone levels and mute, plus native output selection. Read-only display
creates no actions. Writes go through NacreAudio and native preferred-default-sink
only after explicit activation, with readiness/current membership checks; stale or
removed objects are rejected. Track output objects while the popup is alive.

Wi-Fi reads active-first deduplicated rows from NacreNetwork; do not scan merely
by opening. Radio/disconnect/connect actions use DeviceActions. Bluetooth shows
known paired/trusted/connected devices; no scan/pair/trust on open. Both reject
stale row actions, use busy/power guards, label unavailable/empty state and show
bounded errors. No second provider/process poll. Header icons still open detailed
Settings, so omit extra Settings-link buttons from compact panels.

Notification history reuses NacreNotice with history=true; no retained native
actions are invoked. Read/filter history without writing it. Clear/remove and DND
are explicit user actions through existing owners. Keep empty/loading states,
bounded scroll area and history expansion; opening/closing must not alter records.

Shared list: bounded native Flickable with a visible themed scrollbar, fast wheel
steps and native drag/inertia, stable content geometry. Shared slider: native Qt
mouse/keyboard/user-moved semantics, bounded0–1 value, themed track/handle/focus,
no white square or writes on value bindings.

## Assembly and lifecycle

NacrePopupContent maps the six supported names to Nacre device/history/battery/
calendar views. Load on demand, keep the closing view until finite presentation
ends, then unload. Never retain an unrelated stale source after a route switch.
Keep useful cached dimensions while loading, bound error/empty dimensions, and
avoid Loader/item sizing loops. Source errors show readable bounded fallback.

NacrePopupPanel preserves screen/currentName/currentCenter/hasCurrent/headerHovered/
pinned/targetWidth contracts for TopBar and the independent frame input. Logical
close immediately clears pin/interaction; closing rendering remains clipped in
stable geometry. Independent frame masks release the hit region immediately.
Only explicit pinning may acquire keyboard focus. Escape closes pinned views;
hover lifetime remains owned by NacrePanelInput. Reduced motion settles sizing
immediately; rapid reversal targets newest state. No tile reservation/retile.

Maintained callers/routes use Nacre names; old names small own forwarders. Reuse
existing Qt checks and add actual assembly tests for every route, resize/retention/
unload/reversal/error/reduced motion, stale actions and zero writes on display.
Full checks/native Hyprland/plan/apply/native source and real five hover targets,
Settings links/notification pin/Escape/offclick/application-return acceptance are
required. Live QA does not write volume/radios/history/profile preferences.

References: https://doc.qt.io/qt-6/qml-qtquick-loader.html
https://quickshell.org/docs/v0.2.1/types/Quickshell.Services.Pipewire/Pipewire/

Live Escape follow-up: pinned history closed correctly but immediately reopened
from the header still under the pointer. Escape also calls the existing
HoverIntent.dismiss(screen) before logical close; the header must be left/rearmed
before passive reopening. Keep the native regression and fixture dismiss count.
