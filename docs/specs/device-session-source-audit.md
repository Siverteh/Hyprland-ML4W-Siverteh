# Device, session and desktop action helper source audit

2026-10-10 UTC. Scope under shell-tools: desktop-actions.py, device-actions.py,
device-location.py, light-devices.py, network-state.py, resource-state.py,
timezone.py, weather.py, power-button-policy.py, idle-policy.py,
nacre-power-key.service, nacre-session-watch.service, session-watch.py,
isolate-apps.py, startup-apps.py, window-chat-title.py and workflow-profiles.py.
Count actual paths. UI/service consumer reviews do not certify these helpers.
Composer/sidebar/storage/wallpaper/maintenance/packaging and fixtures stay separate.

Read ai/AGENTS.md before inspecting helper routes touching AI launch/workflow.
Trace first authoring and current histories/producer contracts. Retain proven own
implementations with per-file SHA/evidence, not blanket new-filename/commit/green
test certification. For inherited or uncertain bodies, extend specific behavior
contracts before deleting and authoring fresh from native APIs/test/consumer
schemas without old/upstream implementation consultation while writing. Previous
source exposure is recorded honestly. Notices/final full comparison stay open.

Preserve actual desktop app/action routing, UWSM launch and native compositor
syntax, service ownership, busy worker/accounts and full-access AI policy. Device
writes must stay capability/target guarded; native package/sysfs/D-Bus tools remain
dependencies, not private library copies. Idle/power/sleep locking and private
timeouts remain; no real power/suspend/lock/auth probe for QA. Location/timezone
privacy, confirmed fallback and administrator ownership stay unchanged. Resource
reads remain visible/on-demand; no new idle polling. Startup/window/profile actions
remain idempotent and do not broadly move/kill unrelated user windows.

Verify through existing meaningful fake-backend/native interface fixtures and
read-only installed source/provider checks. Do not connect/disconnect devices,
change timezone/location/settings, launch/stop real AI workers, move user windows,
capture credentials or power the machine solely for testing. Real corrections
need specific regression evidence, full formatting/checks/native Hyprland,
reviewed plan/apply/strict source/IPC/private-state gates and exact-main CI.
Audit-only records retain the validated runtime with exact installed byte proof.
Keep all other goal requirements open; no hardware/cold-login or final-license
claim follows from mocked fixtures.

Demonstrated contract gap: network-state.py limits SSIDs to 32 UTF-8 bytes, while
device-actions.py counts characters. Correct the action builder to the same byte
boundary; accepted ASCII and international SSIDs remain unchanged. A pure command
regression must fail on an oversized multibyte SSID before correction, cover exact
32-byte ASCII/two-byte/four-byte boundaries and reject control characters. Never
invoke nmcli connection/rescan for this test. NetworkManager's wireless SSID byte
array and native validator are the protocol contract, not a copied implementation.
