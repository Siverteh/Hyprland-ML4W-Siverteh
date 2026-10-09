# Nacre personalization and desktop Settings pages

Date: 2026-10-09. Independent page bodies after the verified Settings foundation.

## Boundaries

Delete AppearancePage.qml and DesktopControls.qml bodies without opening/copying
them. Replace with NacreAppearancePage, NacreDesktopPage, NacreDisplaysPage,
NacreWorkflowsPage, NacreMaintenancePage and small own control components. Runtime
UI, public declarations, maintained behavior tests and existing backend command/
data schemas are contracts. Keep notices; helper/services remain separate audit
areas. Record public source/consumer exposure; no legal clean-room guarantee.

## Appearance

Keep current wallpaper cached preview/name/explicit picker, motion Full/Battery/
Still, rotation Manual/Automatic/Next,15/30(recommended)/60/120 and custom5–1440
minute interval, static/dynamic/all pool and shuffle/sequential. Preserve fixed
preset groups and wallpaper-derived accent choices, Match wallpaper reset,
Natural default/optional Harmony and light/dark. Tiles show actual cached palette
swatches; bounded responsive rows. Remember existing object contracts in tests.
Retain any supported scheme-flavour/variant operation through the existing palette
CLI owner; never duplicate generation/publish. Frame width/rounding and edge/menu
preferences remain private DesktopSettings fields, changed only on explicit input.
No startup preference write or new idle preparation/polling.

## Desktop

Window gaps/border/rounding ranges follow backend validation. Animations/blur/
shadow/follow-pointer/natural-scroll and edge-menu mode keep existing private
keys. Own styled number and choice controls replace old compressed templates;
readonly data updates never submit commands.

## Displays

Use actual connected monitor/mode data, supported scales1/1.25/1.5/1.75/2/2.5/3,
extend-left/right/mirror and per-output mode selection. Explicit changes use
existing display/display-edit backend. Keep pending Keep/Revert controls,20-second
backend revert and disconnected/one-monitor guards. Do not bypass confirmation,
write monitor Lua directly or perform actual scale changes during UI verification.

## Workflows and maintenance

Keep seven existing presets and explicit saved audio/display/startup intent.
Save through existing owner with selected allowed app roles; only connected device
recall, preserved microphone mute and no hidden app launch. Maintenance reads
existing facts, release/services/config drift/session/sync/performance and offers
explicit refresh/sample/session/portal/sync/restart/rollback actions. Busy state and
errors are visible. Restart/rollback need an explicit UI action, not mount/render.
Do not add update review or change personal AI permissions/account state.

## Verification

Use actual replacement QML plus fixture backends for user-only writes, interval/
palette semantics, responsive tiles, display request args/pending controls, preset/
workflow save and maintenance actions. Retain existing page tests. Native render/
source/IPC and live page navigation/scrolling without changing preferences or
physical displays. Full checks/Hyprland, plan/apply strict gates, configerrors and
CI for each batch. Never run UI-changing probes during deployment gates.
