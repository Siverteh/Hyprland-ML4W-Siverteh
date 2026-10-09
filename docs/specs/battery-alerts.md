# Independent low-battery alerts

Spec ready, 2026-10-09. Target inherited `hypr/scripts/low-battery.sh` and its
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
