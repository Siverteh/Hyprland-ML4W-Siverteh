# Retire the unused reference-era shell launcher

2026-10-10 UTC. The current tree contains one unaudited shell-source artifact:
`nacre/shell/run.fish`, imported in 4874385 and renamed mechanically in 548f0b4.
Its body was inspected during discovery; this is recorded prior exposure. Do not
adapt or reimplement it. Remove it after establishing that no maintained caller
uses it, and prohibit its reintroduction in the retired-path check.

The supported service enters through `nacre-shell start` (control.sh), then
shell-supervisor.py and the installed bin/qs generated from launch.sh. That owner
checks native Quickshell/Qt compatibility and preserves process failures; no
secondary launcher or log-filtering pipeline is needed. Caller tracing must
include the actual installed user service, supervisor and helper copies.

Preserve the current renderer, palettes, private preferences, account/worker
state and supported shell command names. Deployment replaces source copies and
must remove run.fish from current/good source. Historical rollback snapshots are
retained; do not rewrite history or delete old releases to claim originality.

Acceptance: no maintained source caller; retirement guard, full checks and native
Hyprland validation; reviewed plan/apply with strict release/source/IPC gates;
installed entry chain and exact source check; busy worker/private state unchanged;
owned overlay/input checks and exact-main CI. Update overview and architecture.
Other helper/test/asset/login/packaging origins and final upstream comparison
remain separate. Keep notices and the complete goal active.
