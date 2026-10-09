# Independent colour and light services

2026-10-09. Delete Colours/Brightness/KeyboardLight provider bodies before fresh
Nacre-prefixed implementation from this spec/public contracts/tests/runtime and
primary Qt/kernel/brightnessctl/ddcutil APIs. No upstream implementation consulted;
prior declaration/default/schema exposure acknowledged, no legal clean-room claim.
Notices remain. Other theme/publisher/helpers/providers are separate audit tasks.

## Colours

Preserve independent Orient output, richer Natural default, optional Harmony,
private mode/preset/accent and matched ThemePresentation activation. Native QColor
roles built/validated before one immutable state assignment. Invalid/missing data
retains last good palette; fallback comes from own Orient Slate, not inherited
seed constants. Preserve m3 role aliases and named terminal accents. Publish all
colours/mode atomically and disable role tweening during publication so the first
frame matches the wallpaper. Presentation.active owns the committed source;
legacy scheme/current.txt is fallback only when presentation is unavailable.
No generator/wallpaper/GTK publisher duplication or interpreter polling. setMode
uses existing native CLI only after explicit valid light/dark/auto request.
Minimal Colours forwarder; maintained consumers use NacreColours.

## Display and keyboard brightness

One read-only hardware discovery owner for sysfs backlights/keyboard LED and
external connector-DDC mapping. Native FileView maximum/current; refresh at most
3seconds while controls are visible, stop when closed. DDC reads only on discovery
and explicit writes/refresh, never periodic. Identify external displays by DRM
connector/bus and EDID fingerprint, not ambiguous shared model name. Unsupported
or disconnected devices are unavailable; no guessing another display's control.

Own light channel validates finite fractions, range, device existence/maximum and
stale device generation. Latest-only slider write delay, one writer plus pending
newest value. Display lower bound1 avoids blanking; keyboard0 allowed. Explicit
read-back reconciles actual result, failures keep bounded error and restore current
state. No writes during discovery/mount/refresh. brightnessctl remains permission
owner; ddcutil uses validated argv/deadlines. No sudo/auth/permission migration.
Focused-screen brightness up/down5%; keyboard up cycles raw levels, down clamps0.
Keep existing brightness/keyboardLight IPC signatures and shortcut namespace.
NacreBacklight replaces typed nested Monitor at known call sites; old providers
forward state/methods. Indicator uses explicit adjusted events so initial reads
never reveal it. Existing keybindings and settings/device prefs remain unchanged.

## Acceptance

Actual new QML/JS with native fixtures: colour channels/aliases/mode/atomic update,
invalid rejection/matched authority, publication animation gate; light discovery/
read-only mount/missing devices/stale generation/write coalescing/step and failure
read-back, closed timers and no DDC polling. Helper tests use temporary sysfs/fake
processes, validate keyboard class/max/min/argv/fingerprint and failed commands.
Full checks/Hyprland/native parse, plan/apply strict release gates, exact source/IPC,
actual Settings/indicator/launcher/Escape/offclick and palette-role comparison.
Use brightnessctl pretend/fixtures for writes; real keys not necessary when they
change hardware. Real display/LED values and private hashes unchanged by QA.
External physical hotplug/DDC writes/cold login/battery measurements remain separate.
Final provenance/source/asset audit still required before notice removal.
