# Shell and graphical-session default composition

Spec ready, 2026-10-09. Area: fish/conf.d/90-nacre.fish and uwsm/env,
uwsm/env-hyprland. Trace Fish fragment origin2fa3a95 and rename548f0b4;
UWSM migration85316eb, cursor additionsd0bf508 and single-owner correctionc0816b6.
Preserve user environment behavior and personal Fish configuration outside the
managed fragment. Authoring/migration history alone does not settle copied origin.

Capture the exported variable/value public contracts with an isolated POSIX shell,
and the Fish fragment's startup effect using fake application owners under an
isolated HOME. Retain verified own Fish behavior; replace any inherited composition
from this spec after deletion. UWSM exports are standard toolkit/cursor preferences:
write fresh grouped defaults, retaining measured values and toolkit behavior.
No old implementation body used while writing replacements. Previous exposure to
public export declarations and local feature history acknowledged. No legal
clean-room or whole-tree license conclusion.

The baseline contracts govern exact names/values. UWSM owns the session
identity and activation environment, not Hyprland env calls. Toolkit values belong
in env; HYPR variables in env-hyprland. Cursor theme and size have one owner in env,
with Hyprcursor following the same size. Do not reintroduce obsolete XDG/Mozilla/
Clutter/autoscale/SDL forcing or per-launch private library paths. Preserve user's
interactive terminal greeting without running it in noninteractive scripts.
No login restart, keyboard/layout/scale/power/account changes for this work.

Acceptance: execute real sh/Fish with isolated fixtures, compare exact exports and
interactive/noninteractive behavior before/after, syntax/full checks and native
Hyprland, plan/apply changed static configuration with drift protection. Verify
installed bytes, private state/worker identity and live IPC/configerrors; current
user-service values sampled only from this non-secret whitelist. New UWSM values
activate at next login, so cold-login propagation remains explicit until observed.
Exact-main CI before finishing, keep whole-tree notices/audit goal active.
