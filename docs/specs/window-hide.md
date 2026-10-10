# Independent window hide and restore

2026-10-10 UTC. Replace uncertain imported window-minimize.sh body without opening
or copying it. CLI/caller contracts and sandbox behavior are the specification.
Native namespaces hide real /run,/tmp,/home,/proc and fake hyprctl handles every
backend query/dispatch; no host compositor, bus or user ledger is reachable.

Observed hide: active address moves silently to special:hidden, with original
workspace number stored as a newline-terminated record at
`${XDG_CACHE_HOME:-$HOME/.cache}/hypr-minimize/<address>`. Multiple records remain.
restore-last chooses newest record, moves to original workspace and focuses it.
restore-current restores only recorded windows belonging to active workspace,
without focusing or pulling windows from another workspace. Invalid/stale clients
are never targets; ledger removal follows successful restoration. Hiding is not
closing/trash and has no expiry timer. Keep existing positive workspace records
and address filenames compatible; preserve unrelated ledger/private state.

Fresh implementation may use a small Python helper behind the same .sh entry
point, native public hyprctl JSON/Lua and standard locks/atomic writes. Reject
malformed metadata/symlink records without executing or sourcing them. Bound
query/output time and target address/workspace strings. Named/special original
workspace IDs resolve through native workspace metadata when available; otherwise
keep the record/window untouched. New records private; no kill/close capability.

Tests: synthetic clients and temp ledger, hide/no active/already hidden, most recent
restore, current-workspace-only/no focus, missing/malformed/symlink/stale records,
failed move and old-format compatibility. Actual subprocess/shim checks use the
isolated fake compositor. Full repository/native configuration/deployment checks
and source/IPC verification; any live check owns its windows and restores context.
No real user-window action or actual history/policy change solely for QA. Record
public/native API and earlier wrapper exposure honestly; retain notices pending
full comparison, without claiming a legal clean room.
