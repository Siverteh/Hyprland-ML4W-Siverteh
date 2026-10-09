# Independent compositor shortcut composition

Implemented and natively deployed, 2026-10-09. Physical key/Super/Fn probes remain separate. Target: `hypr/conf/keybinding.lua`; private/native
`nacre/shell-tools/shortcuts.lua` and app/window helper bodies require separate
provenance review. The Lua file was introduced during conversion `f3290a5`; old
keybinding.conf history reaches the original dotfile tree. Language translation
or renamed comments alone is not an original implementation.

## Contracts and boundaries

Capture native `hyprctl binds -j` and public key/handler/argument/flag declarations,
root modifier/application/path variable contracts, helper command interfaces and
private override precedence. Preserve current key combinations, descriptions,
repeat/release/locked/input behavior and callable desktop routes. The current
physical power/lid policy and bare-Super removal remain unchanged.

Hardware brightness keys use the independent shell IPC owner; media keys retain
existing native routes. Application launches stay UWSM-managed. Lock remains
loginctl lock-session. Preserve actual workspace1browser/2AI/3Discord/4Spotify/
5mail/6Brain/7editors and current personal app choices, AI full access and update
skipreview. Do not invoke power/lock/app/AI actions while recording contracts.

Delete inherited body before independently grouping keys into a fresh declarative
map and guarded composition using public Hyprland bind/dispatcher APIs. Use named
helpers only when they simplify the actual command/argument boundary; do not copy
old control structure, preset/header templates or unsupported flags. Public
combination/command names are behavior contracts, not implementation permission.
Historical/partial exposure is recorded honestly, no upstream ML4W/Caelestia body
consultation or legal clean-room claim. Other helper/routing/root origins separate.

## Verification and deployment

Actual Lua callback/dispatcher construction fixtures with safe fake owners should
verify combinations/arguments/flags/default helper variables without launching
apps, changing workspace/device/power state or terminating real processes. Compare
normalized native bind records after deployment, preserving readable descriptions
and avoiding duplicate combinations outside submaps. Existing conflict checker
covers private shortcut source as well as managed configs.

Full formatter/syntax/tests/native Hyprland, drift config plan/apply and strict
source/service/IPC/launcher/wallpaper/Escape gates required. Preserve private
preference/history hashes and busy worker identity. Relevant real owned temporary
input/focus/dismissal checks, not actual power/suspend/physical Fn probes. Restore
workspace/focus, stop only owned QA processes. Native callback IDs may change on
reload; compare meaningful binding behavior, not opaque function addresses.

A virtual key cannot establish physical Fn/Super switch behavior; retain that
limitation. SHA-bound origin/source/dependency review and exact-main CI before
finishing. No final license/notices removal until full current-tree/runtime review
and source comparison; public general keyboard/app choices follow originality.

## Captured contracts and authored composition

Native effective snapshot has101 bindings; managed target's safe declaration
capture has95 records, including7 resize-submap records. Public key/action/flag
declarations and constructor outputs exposed, no old/upstream implementation body
consulted. No target callback performs arbitrary logic: all95 actions are native
dispatcher constructors. Snapshot fixture is behavioral data, not reused source.

Deleted target before fresh declarative device/lifetime/workspace/directional/
resize/desktop/application groups and common constructor/registration helpers.
Seven focus+move workspace pairs and directional families generated from data;
95 key/action/argument/repeating/locked/mouse/submap contracts compare exactly,
ordering normalized. Existing private override load order unchanged.

Static literal-only conflict regex would miss generated bindings. Independent
Lua capture tool loads definitions in a restricted environment: no os/io/package/
require/dofile/process/native dispatch access. It records constructed metadata,
executes only define_submap declaration callbacks, never bound actions. Callable
binds are identified without invoking their bodies. Ten-second subprocess timeout
bounds malformed/infinite source. Lua required for this check; CI already installs
it. Current binding-defining sources captured across managed and shortcut files.
Checker normalizes modifier order and ignores separate submap scopes as before.
Generated-key/private-literal conflict and sandbox rejection cases tested.

Fixture preserves the observed contract, not authorship proof by itself. Actual
native parser/bind comparison/input checks and source/dependency review required.
Referenced app/window/AI helper bodies and private host override source remain
separate; no real action invoked to infer its behavior.

Reference: [Hyprland0.56 binding APIs](https://wiki.hypr.land/0.56.0/Configuring/Basics/Binds/).

The on-demand shortcut guide also depended on literal-call parsing. It now uses
the same deployed `binding-contracts.py/.lua` reader, with native bindings still
defining the active set. Captured metadata supplies descriptions and preserves
submap identity; scoped exit descriptions no longer collide with global resize
entry. Hardware brightness descriptions reflect current shell IPC commands.
The helper is shared with CI through a thin tools import bridge, not duplicated
or generated into a stale source manifest. Helper caller body was inspected for
integration and is not certified entirely original by this adjustment.
Config+shell deployment required so runtime guide/helper changes arrive together.
