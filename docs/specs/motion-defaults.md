# Independent compositor motion defaults

Implementation written, acceptance pending, 2026-10-09. Target: `hypr/conf/animation.lua`; larger startup/binding/
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

## Native contract and authored source

Native snapshot has35 nodes and15 curves. Eleven explicit user animation leaves
retain their durations/styles; unoverridden children remain unset. Four actually
used custom curve shapes are retained as observed scalar behavior data under
`nacre_window_enter/leave` and `nacre_panel_enter/leave`. Nine unused custom curves
are retired; native default/linear curves stay platform-owned. Tracked maintained
source and private override identifier checks found no other old-curve consumer.
No private override body was used as replacement implementation.

Target body deleted before fresh curve ownership and transition-family loops were
written. Windows/windowsIn share their observed3-decisecond60% pop-in; window exit
uses its observed exit curve. Panel enter/exit3/1.6, layer fades2/4.5, workspace7
slide and special workspace3slidevert retain current motion. Border10 remains;
no border/glow/shadow angle loop is enabled. Native built-in global/internal leaves
are not rewritten as defaults. Numeric observations/public curve declarations were
exposed; no upstream body consultation/no legal clean-room claim.

Lua fixture verifies real file execution registers4 owned curves/11 leaves, no
undefined curve references/duplicate scopes/loop style, and leaves inheritance
branches unset. Native parsing and subsequent normalized native graph comparison
validate the host's actual argument shape/values, not just this fixture's model.
Full source and assets/dependencies still need final review and comparison.

Reference: [Hyprland animation API/tree](https://wiki.hypr.land/configuring/core/animations/).
