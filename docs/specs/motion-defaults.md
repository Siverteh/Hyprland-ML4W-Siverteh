# Independent compositor motion defaults

Spec ready, 2026-10-09. Target: `hypr/conf/animation.lua`; larger startup/binding/
routing files follow independently. The Lua file was introduced in `f3290a5`
alongside old dotfile edits; translation and preset-header removal alone do not
establish original implementation. Prior exposure must remain explicit.

## Behavior and source boundary

Use the native `hyprctl animations -j` record, public curve/animation declarations,
private-preference contracts and official Hyprland animation APIs. Capture enabled,
speed, style, curve name and overridden/inherited flags before deletion. Native
records include both animation nodes and registered cubic-Bezier curves. An
unoverridden child may inherit its effective behavior; do not turn all zero-speed
reported children into explicit zero-speed animations.

Preserve the current visible window/workspace/layer/fade/border animation behavior,
private desktop profile precedence and reduced-motion ownership. Other configs or
helpers can refer to curve identifiers; inventory those contracts before removing
unused registrations. Do not replace profile settings or change the user's choice.
The private profile's helper/data origin stays a separate audit.

Delete the inherited body before independently expressing the actual motion graph
and curve registrations. Use fresh grouping/ownership rather than copying the old
preset or control structure. Native observed values are behavior data; matching
values alone neither prove original authorship nor justify copying implementation.
No upstream ML4W/Caelestia body consultation. Any already-exposed declaration/source
is honestly recorded; no legal clean-room claim. Keep notices and final comparison.

## Acceptance

Full formatting/syntax/regression checks, native Hyprland verification, reviewed
config-only drift plan/apply through release/rollback. Compare the actual animation
records and effective relevant options before/after under matching private profile
conditions, distinguish inherited children and intentionally retired unused curves.
Open/close owned temporary application/panels to check motion and input return;
restore focus/workspace and stop only owned QA processes. A numerical match is not
visual inspection or a battery benchmark; report scope and inspect actual behavior.

Retain static/private state and busy worker identity. No device, power, AI permission,
update policy, wallpaper/palette or Qt shell redesign in this task. Require native
configerrors/source/IPC readiness and exact-main CI; SHA-bound provenance review
follows actual source/dependency inspection. Other source/assets/tests/publisher/
packaging and the final whole-runtime comparison remain part of the full goal.
