# Independent compositor entry point and extension provenance

Spec ready, 2026-10-09. Review `hypr/hyprland.lua`, `hypr/conf/brain.lua` and
`nacre/shell-tools/shortcuts.lua` as the remaining compositor entry/extension area.
The root Lua file was introduced during dotfile conversion `f3290a5`. Brain routing
origin `e42b701` is a local feature; private shortcut origin must follow across the
Nacre rename rather than treating rename commit `548f0b4` as authoring proof.
Do not blindly rewrite already independently authored behavior.

## Capture and preserve

Inventory root public globals/default declarations/module load order and private
loader contracts. Preserve monitor → palette → desktop → shortcuts → host private
load order and contained errors. A bad private file must not prevent later files
from loading. Managed root has one deployment owner; no helper may edit loader
blocks. No user override bodies, account state or live private data copied to Git.

Retain current public globals consumed by other files, standard seed and safe
fallback behavior only after their origin is traced. New independent defaults from
Orient/native contracts replace any inherited seed/template data. Do not confuse
common scalar preferences or interface names with inherited algorithms.

Audit Brain and shortcut declarations against authoring history/specs and current
behavior: Brain6/editor7, Brain/capture keys, native palette/key-guide/left-drawer
routes and passive non-consuming Escape dismissal. Preserve full-access AI policy,
startup ownership, brightness/media/power/lid behavior, bare-Super removal and
private host override precedence. Routing/binding conflict checks remain effective.

## Implementation boundary

Where inherited root/body/data remains, delete before fresh readable entry-point
composition from spec/public contracts/platform APIs. Keep previously verified
independent loader/control behavior, with explicit source evidence. No upstream
ML4W/Caelestia implementation consultation; prior exposed code recorded honestly,
no legal clean-room/final license claim. A name/header/translation alone never
certifies independent origin. Review own extension files rather than inventing a
need to replace them, and record exact hashes only after evidence supports it.

## Acceptance

Safe actual Lua root/load-order/global/private-error fixtures with fake config,
command/notification/dependency owners and isolated file paths; no user startup,
credential/power/application/AI action. Existing broken-private-loader regression
retained and relevant contract coverage extended. Full formatting/tests/native
Hyprland, reviewed config/shell deployment only where content changed, strict
source/service/IPC/launcher/wallpaper/Escape and owned temporary input gates.

Compare native options/bind/routing behavior and private preference/history/worker
identity; exact installed source, configerrors empty, exact-main CI. Actual cold
login/private host/fresh-session curve registry remain explicit runtime limits;
never force logout of busy sessions. Remaining provider/helper/UI/assets/tests/
AI+Brain/packaging and full provenance comparison still required. Retain notices;
public extraction and new visual identity follow the complete originality audit.
