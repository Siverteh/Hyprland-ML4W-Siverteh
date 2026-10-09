# Independent compositor shortcut composition

Spec ready, 2026-10-09. Target: `hypr/conf/keybinding.lua`; private/native
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
