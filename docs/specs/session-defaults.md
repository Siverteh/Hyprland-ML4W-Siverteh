# Independent session input and placement defaults

Implementation written, acceptance pending, 2026-10-09. Next originality area after the audio retirement and Orient
source review. Target: `hypr/conf/{keyboard,cursor-behavior,cursor,layout,monitor,window}.lua`.
The current Lua introduction (`f3290a5`) overlaps the old dotfile configuration;
keyboard.conf history reaches the initial dotfiles import (`e0ef6d7`). A language
conversion is not a fresh implementation. Per-file inheritance must stay explicit;
any locally authored updates and previous source exposure are acknowledged.

## Behavior contract

Capture native effective values and public option declarations before deleting
any target body. Input layout/repeat/touchpad/focus behavior, dwindle options,
window gaps/border policy, cursor preference source and monitor startup behavior
must retain their current effect. Do not assume stock defaults or the old review's
values. Compare effective native values before and after under matching conditions.
Current private monitor/desktop/host overrides remain last in the root load order;
do not read or commit personal host state as implementation source.

Cursor theme/size remain owned by UWSM environment. The new cursor adapter reads
that contract, without a competing hard-coded theme. Keep current monitor policy
and recovery owner; do not introduce another hotplug/display daemon. No actual
input, display scale, radio, hardware-brightness or power preference changes are
part of this rewrite. Personal key/workspace/startup behavior remains intact.

## Independent implementation

Use native observations, literal option/rule declarations as public behavior
contracts and official Hyprland Lua/configuration APIs. Delete inherited target
bodies before composing fresh, readable Nacre defaults. Do not consult/copy the old
implementation bodies or upstream ML4W/Caelestia sources. Do not copy inherited
headers, presets, control structure or unrelated option lists into a renamed file.
Keep names required by the root configuration as stable source interfaces.

Keyboard/layout/window/monitor option data is independently expressed to preserve
behavior; no new UI or public-release host defaults are selected here. General
public extraction and different default keyboard/layout choices follow originality.
Record exact paths, new implementation origin and dependencies in provenance;
retained notices stay until the full review/comparison is complete.

## Verification and deployment

Run formatting as applicable, full `python3 tools/check.py` and native Hyprland
verification. Review install/configuration drift plans, apply only changed managed
configs through the release transaction, and compare captured native options.
Require configerrors empty and current compositor/shell readiness. Exercise owned
temporary application input/placement/focus checks; restore original focus/workspace
and stop only owned QA processes. Do not restart busy assistant workers.

Monitor/cursor/input contracts need native declaration/value checks plus the
relevant settings/launcher/input return gates. A single connected display cannot
establish physical multi-monitor/hotplug behavior; a virtual keyboard probe does
not prove physical Fn keys. Preserve rollback/private-state hashes, publish ordinary
fast-forward main and require exact-main CI. Add SHA-bound file reviews only after
source/dependency review; tests or a new name alone do not establish origin.

Remaining larger config areas (animation, autostart, keybindings, window routing)
and other helpers are separate follow-up branches.

## Recorded contract and implementation origin

Native21-option capture before replacement: Norwegian layout with empty variant/
model/options, numlock enabled, follow_mouse1/mouse_refocusfalse, sensitivity0,
natural touchpad scrolling0.25 without disable-while-typing, no cursor warps,
dwindle preserve_split, back-and-forthfalse/cyclestrue/pass-mousefalse, gaps6/12,
border1/dwindle/resize-on-bordertrue. Monitor fallback is preferred/auto/scale1;
private output policy retains the actual150% scale. Current border colors are
palette-owned and naturally change with rotation; do not freeze them as defaults.
Three-finger horizontal workspace gesture retained from its public declaration.

Six bodies deleted before own flat-key option declarations and single startup
cursor adapter were written. Cursor reads UWSM theme/size, uses POSIX single-quoted
argument escaping, and ignores absent/invalid/noninteger native-int size values
instead of inventing another preference source. Tests invoke its captured startup
callback with a safe fake command owner, checking exact argv and malformed inputs.
No real shell command executes in those tests. The native compositor parses the
actual new config. Startup callback does not fire on ordinary config reload.

Public option/gesture/monitor declarations and partial cursor callback call site
were exposed during contract discovery; prior review/source exposure is acknowledged.
No upstream/inherited implementation body was consulted for this replacement; no
legal clean-room claim. Standard Hyprland API names and saved scalar preference
values are behavior contracts, not a reused legacy implementation.

References: [Lua utilities](https://wiki.hypr.land/configuring/core/advanced-configuration/lua-utilities/),
[gestures](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), and
[startup event](https://wiki.hypr.land/0.55.0/Configuring/Basics/Autostart/).
