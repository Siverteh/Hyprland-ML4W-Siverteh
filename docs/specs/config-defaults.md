# Independent compositor and terminal defaults

2026-10-09. Delete remaining inherited hypr/conf/{misc,decoration,nacre}.lua,
kitty/kitty.conf and fastfetch/config.jsonc bodies before fresh implementation.
References: public option/value and rule declarations, recorded native effective
values, maintained app/helper call sites, native config parsers and official
Hyprland/Kitty/Fastfetch APIs. Earlier source exposure acknowledged, no upstream
ML4W source consulted/no legal clean-room claim. Retain notices until whole audit.

Preserve current live appearance: rounding10, full opacity, blur enabled3px/2passes,
optimized/ignore opacity/no xray, shadow enabled20range/3power/current black-alpha40.
Keep splash/logo off, initial workspace tracking1, focus under fullscreen1, session
lock restoration and zero XWayland scaling. Private monitor/palette/desktop/shortcut/
host overrides continue to load last; no load-order/permission/update-policy change.

Nacre rules retain shell glass namespaces excluding wallpaper/input surfaces,
lock-preview float/centre70%, desktop fallback mixer700x600/pinned, Bluetooth
manager800x600, network editor800x700, share picker600x400/pinned and browser
Picture-in-Picture float/pin/centre. Use own anchored rules/names and current Nacre
preview title. Retire unreferenced Newelle/old hub/nwg/theme/display/old dotfiles
utility rules and uninstalled calculator. Installed nwg tools may still be opened
manually; no evidence of current use by source/startup, so don't call them uninstalled.
Keep the maintained native control route720x500. No workspace map/app-startup edits.

Kitty preserves existing font12, geometry950x500, padding10, scrollback2000, quiet
bell, borderless/dynamic opacity/no-close prompt, cursor timing/trail and private
palette include. Native parser baseline records effective values; generated palette
continues to supply0.98 opacity/selection colours. Own fallback uses0.98. Optional
private custom.conf uses documented globinclude so missing override is quiet.
Do not reload/terminate busy user terminals or alter default shortcuts/shell.

Fastfetch fresh plain Nacre info layout, current palette-coloured private logo,
user/host/root disk/OS/kernel/WM/DE/terminal/shell/CPU/memory/uptime/colour info.
Remove inherited decorative box/glyph/colour macros and shell arithmetic command.
Show filesystem-age through a small own helper with validated root birth time,
truthful unknown/future timestamp handling; don't claim filesystem age is OS install
age. No account/host inventory or static/generated wallpaper colours committed.
Existing logo helpers remain separate provenance audit, not certified by config.

Full tools/check.py/native Hyprland/parser/plan/apply/configerrors/source/live gates
required. Compare recorded appearance and native Kitty effective options before /
after. Validate rules with temporary matching windows and preview without invoking
real network/power/account actions. Configuration drift refuses writes; new terminal
preview may run Fastfetch, never close user's terminal. Generated/private files and
existing preferences unchanged. Exact main CI required; whole goal unfinished.

References: https://sw.kovidgoyal.net/kitty/conf/
https://github.com/fastfetch-cli/fastfetch/wiki/Configuration
Installed Hyprland Lua API/native getoption and --verify-config are target authority.
