# Independent graphical-session startup composition

The five-task capture below is historical. Current autostart has four tasks;
the retired battery watcher is superseded by NacreBatteryAlerts.

Implemented and natively deployed, 2026-10-09. Cold-login/PAM acceptance remains separate. Target: `hypr/conf/autostart.lua`; app keybindings and
window routing follow in separate branches. The Lua introduction in `f3290a5`
coincides with old dotfile edits; translating old startup config is not originality.
Identify locally added services and keep the original exposure record honest.

## Behavior and ownership

Capture public startup event/command declarations, referenced helper interfaces,
service enabled/active state and startup application's existing idempotence contract.
Use these as behavior data; do not open/copy the old implementation body or
upstream ML4W/Caelestia source. Delete the body before implementing fresh startup
composition from this spec and official Hyprland/UWSM/systemd APIs.

Only the actual `hyprland.start` event performs startup launches. Verification and
ordinary config reload must not launch apps, duplicate Brain windows or restart
workers. UWSM owns session environment/application scopes; enabled systemd user
services own their own startup. Preserve KWallet/PAM initialization contract,
existing app/Brain workspace routing and host override order. Do not commit private
wallet/account/browser state or substitute credentials into command lines.

Retain current necessary polkit/clipboard/session/app/helper actions after tracing
owners; remove unreferenced legacy startup only with evidence. Preserve startup
command dependencies/order and current AI full-access/updates skipreview choices.
No competing wallpaper/notification/display/power/lock owner, no new background
polling or synchronous long startup work. Private host-specific behavior stays
external. This stage does not create general public-release app choices.

## Acceptance

Safe Lua fixture invokes the registered real startup callback with fake process/
service owners, checking startup-only execution/order/argument boundaries without
launching real apps or touching preferences. Native config verification, full
checks, drift-protected config plan/apply and source/service/IPC/launcher/wallpaper/
Escape gates remain required. Compare private preferences and worker identity;
ordinary apply must not trigger app launches. Native owned temporary input/focus
checks must leave the original workspace/application intact.

A callback fixture and reload cannot prove cold-login timing/PAM authentication or
physical session recovery. Preserve these as explicit final live follow-ups without
logging out the user or terminating active assistants. Keep rollback/notices, trace
helper provenance separately, record SHA-bound source review after implementation
and require exact-main CI. Whole-tree/runtime/source comparison remains part of the
full originality goal.

## Recorded startup contract and source origin

Current public declaration inventory is one startup event and five command
submissions: PAM wallet initialization explicitly in a UWSM scope; polkit agent;
wl-paste watching cliphist store; battery watcher; existing startup-apps helper.
Current shell/hypridle/Brain services are enabled and active; sidebar service is
static and active. No redundant service launch is added to this config.

Deleted target body before fresh task-argument list/ordered submission loop and
POSIX single-argument quoting were written. Wallet task remains first with its
explicit scope; default scope/service selection for other tasks stays UWSM-owned.
HOME expansion now produces literal absolute helper arguments rather than relying
on shell tilde interpretation. Submission order does not establish asynchronous
completion/readiness order; existing helpers retain their own idempotence contract.

Public command/event declarations and historical exposure were acknowledged; no
upstream/old implementation body consulted for replacement/no legal clean-room
claim. The old current file was already narrowed by earlier local work; do not
label every retained command as inherited or claim this audits the helper bodies.
Safe fixture loads the actual file with a failing launch owner, proving no launch
on load, then invokes the captured startup callback against a fake command owner.
Checks cover wallet scope, five tasks/order/argv and literal space/quote/substitution
text in HOME. No services/apps/credentials are touched by fixtures.

References: [Hyprland startup event](https://wiki.hypr.land/0.55.0/Configuring/Basics/Autostart/)
and [UWSM application scopes](https://github.com/Vladimir-csp/uwsm).
