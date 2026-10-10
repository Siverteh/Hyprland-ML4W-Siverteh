# Toolkit palette companions and fallback theme

Spec ready, 2026-10-10 UTC. Next publication dependencies: rofi.rasi,
file-icons.py, kde-palette.py and their relevant file-manager tests. Keep the
independently reviewed publisher/Orient and current preferred appearance. Trace
Rofi origin e42b701 and own control update 3c1b16d; icon overlay origin 5611be5,
Dolphin integration 86bebe6 and system-runtime corrections 47b06d4/79916a3;
KDE publisher first 86bebe6, with namespace migration 548f0b4 distinguished from
new authoring. Investigate copy ancestry and data/templates before certifying.

Do not presume these files inherited or independent by name or date. Review
traced own code. For inherited/uncertain portions, capture public caller/output
contracts, delete body, freshly implement from this spec and public Rofi/GTK/KDE/
icon-theme APIs without consulting upstream bodies while writing replacements.
Record prior source exposure; retain notices, no legal clean-room or whole-license
claim. Mechanical comparison supplements real origin evidence.

Public calls: file-icons.family(color), theme(home,primary,mode); KDE save/read
helpers and publish(home,colors,icon_theme). Rofi template supplies bg/raised/text/
muted/accent/border tokens for the publisher. Confirm actual consumers before
retiring anything; no theme/UI defaults changed solely because an application
is currently closed. Source icon artwork belongs to the installed licensed theme;
keep its provenance/credits and do not commit private generated overlays.

Preserve chosen icon size/family and appearance, no stale private-runtime links,
valid theme inheritance/index metadata, user unrelated settings and config drift.
KDE/Qt output must retain current palette roles and react without restarting
user applications. Missing native theme sources should fail/fallback clearly,
not fabricate success or remove custom icon themes. One palette publication
owner remains; no polling/extra app/AI/package/power actions.

Acceptance: relevant actual isolated output/settings/icon-link/schema fixtures,
parent artwork/license dependency evidence, native parsers where available,
full formatting/tests/Hyprland and provenance integrity. Runtime changes require
reviewed plan/apply/source/IPC/live appearance and private state/worker checks;
audit-only records retain proven installed bytes instead of pointless cutover.
Use owned temporary previews, not user windows/accounts/vault or new wallpaper
choices. Exact-main CI. Branding/lock/login/Thunar module and other generators
remain separately scoped; whole originality goal/notices remain until complete.
