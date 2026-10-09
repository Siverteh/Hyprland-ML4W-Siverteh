# Independent low-battery alerts

Implemented and natively deployed, 2026-10-09. Physical discharge/AC-cycle acceptance remains unclaimed. Target inherited `hypr/scripts/low-battery.sh` and its
startup ownership. History follows the explicit ML4W import `989022d`; an active
UWSM low-battery scope confirms this is still running. Larger keybindings/routing
and other helpers remain separate. Do not replace this only by renaming it.

## Contract discovery before replacement

Capture public threshold/notification/command declarations, actual power/battery
provider interfaces and existing notification lifecycle behavior. Record low and
critical thresholds, AC/charging suppression, rearm/repeat policy, urgency and
required notification text/identity. Do not infer them from common defaults.
Use these functional contracts and safe black-box fixtures without consulting/
copying the old implementation body or upstream ML4W/Caelestia source. Any prior
source/declaration exposure is acknowledged; no legal clean-room claim.

Native UPower already supplies the shell's battery data, with BAT0 and DisplayDevice
present on this target. Prefer sharing that native cached/event-driven source over
another periodic interpreter/process/sysfs poll. Select the smallest owner that
preserves the verified policy and works independently of Brain. No new power-profile,
brightness, suspend/shutdown or hardware control behavior belongs in an alert owner.

## Independent ownership and behavior

Delete the inherited body before freshly implementing validated low-battery alert
policy and delivery. Confirm whether a small shell-native owner can replace the
old watcher without a second notification server or power daemon. If a companion
helper is needed, keep it separately owned, event-driven and bounded.

Missing/unknown/out-of-range/stale/incoherent startup battery data must not produce
a false critical alert. Handle no battery, charging/AC transitions, descending
thresholds, recovery/rearm and renderer/process restarts without noisy duplicate
alerts. Preserve actual warning usefulness; never silently remove low-battery
protection. Notifications go through the existing notification server, with no
real test notifications sent to the user's retained history.

Remove the old startup launch only after the replacement owner is ready. Reassess
the SHA-bound startup-file review if its task list changes. Stop only the positively
identified inherited low-battery scope after cutover; never broad-pkill shell/user
processes, restart AI workers, log out or change power hardware to make a test pass.
Keep old release backup; inactive rollback code is not an active dependency.

## Acceptance

Safe deterministic policy/clock/provider fixtures for low/critical/charging/rearm/
startup/restart/error cases; no actual service/credential/hardware writes. Native
UPower interfaces/readiness must be verified against installed Quickshell/system
versions before choosing APIs. Full formatter/tests/native Hyprland, drift plan/
apply selected configs/shell components, exact source/live IPC and input gates.

Require a ready native alert owner, unchanged private preferences/history and
worker identity, old scope absent and no duplicate active alert owner. Do not
claim physical low-battery/AC unplug tests from synthetic fixtures. Inspect natural
provider state without forcing a charge cycle; retain those limits and final
runtime/source comparison requirements. Record dependencies/origin/current hashes,
keep applicable notices, ordinary main push and exact-main CI. Full goal stays
active until all remaining areas/audits are done.

## Captured contract and authored implementation

Public threshold/notification declarations: normal <=20% and >15%, critical <=15%,
only while discharging. Flags reset above20% or when not discharging. Battery Low /
Remaining: N% messages use normal/critical urgency. Current helper reads capacity/
status once per60-second loop and is an explicit ML4W import. The scalar thresholds,
command/message declarations and branch predicates were exposed as contracts; prior
exposure acknowledged, no upstream body consultation/legal clean-room claim.

Deleted helper before fresh Qt policy/native owner. NacreBatteryAlertPolicy holds
highest successful warning severity in a discharge episode; 20% then15% warnings
remain, but recovering from critical to19% does not produce a downgraded warning.
Known charging/above20%/absent battery rearms. Unknown/not-ready/nonfinite/out-of-range
inputs do not mutate severity or generate alerts. UPower cached displayDevice is
shared with the existing bar; ready/type/present/state/fraction and onBattery are
validated, empty/pending-discharge handled without another power daemon/poller.

One root singleton, not one per output.150ms event coalescer, no repeating timer.
notify-send runs only for real warning delivery; five-second command watchdog and
at most two timed retries after failure, then wait for native state changes.
Severity advances on successful delivery only, with stale-cycle replies rejected.
Atomic small private state keeps ordinary renderer-restart deduplication. Read/write
errors are reported in bounded read-only IPC diagnostics, never hide a warning
because persistence failed. A crash between delivery acknowledgement and async
state-write completion can repeat an alert on restart; no exactly-once guarantee.
Corrupt state falls back safely with diagnostics; unknown data is not taken as0%.

Tests execute actual policy and actual native owner code with fixture-only UPower,
FileView, Process and IPC dependencies. They cover threshold/order/rearm/no battery/
invalid/boot readiness/ack/cache restart/failed delivery/bounded retry/watchdog/
late reply/charging/corrupt-state cases without any real notification/private file.
The startup fixture now verifies4 tasks and no battery watcher launch. Source
startup hash reassessed; retired path guarded. Old running scope cutover waits
until the installed native owner is confirmed ready.

References: [UPower device readiness/data](https://quickshell.org/docs/v0.2.0/types/Quickshell.Services.UPower/UPowerDevice/),
[device states](https://quickshell.org/docs/v0.2.0/types/Quickshell.Services.UPower/UPowerDeviceState/),
[FileView atomic writes](https://quickshell.org/docs/v0.2.0/types/Quickshell.Io/FileView/).

A regression added after initial cutover showed a failed reply from an older
discharge cycle left stale error/retry state after charging. The owner now ignores
old-cycle replies and clears delivery errors when rearmed; the actual-owner
fixture fails before the fix and passes after it. Both native deployments keep
private history/preference hashes and worker identity; the old scope was stopped
only after the first replacement was ready.
