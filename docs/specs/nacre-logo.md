# Nacre shell logo integration

2026-10-10. User selected and authorized deployment of the shell/pearl artwork
in Downloads/nacre-logo.zip, replacing SH everywhere. Archive SHA-256:
81f0e0426b9b448c1858461b33d32d633d204970adf24631bb637dca3e5b1293.
User reports creating it; source-method/license provenance beyond that report
is not independently certified. Preserve its actual chamber and pearl geometry.

One master SVG owns geometry, gradients and role placeholders. Derive symbolic
and compact renditions from its eight base chamber paths and pearl-body circle;
those match the supplied symbolic rendition exactly. No traced/redrawn substitute.
Primary/secondary/tertiary fill the chambers, highlight uses the existing bright
Orient role in dark mode and a readable accent in light mode. Small symbolic
output can be palette-primary; colored compact output keeps the chamber roles
without tiny gloss overlays. Larger outputs retain the supplied shading and pearl.
Keep transparent lock/logo corners. Updated after actual user screenshots: terminal
PNG also retains alpha; a baked surface color leaves a rectangle over translucent Kitty.
Square geometry gets square layout bounds without optical H hacks/stretching.

The AI application has an additive variant: independently drawn A/I paths in
`ai-label.svg.in` occupy the open lower-right space under the shell's overhang.
A uses primary, I secondary; lift toward foreground only when needed for 4.5:1
contrast against the frame. Keep the approved shell and pearl paths untouched.
Generate full/compact/symbolic AI SVGs, transparent AI PNG and a text fallback
through the same publisher. The launcher tile and sidebar use `BrandLogo.ai`;
the AI terminal controller reads nacre-ai.png. Ordinary Fastfetch, lock/login,
Brain and desktop branding retain the unlabelled shell. No new polling or
worker/session restart. The base geometry remains suitable for future apps.

Extend the current branding.py owner, not a separate publisher. Canonical
published names are nacre.svg, nacre.png and nacre-lock.png, plus symbolic/compact
assets and a geometry-derived text fallback. Replace repository sh.json/sh.svg,
generated bar/sidebar/settings/overview widget, login Logo.qml, Brain web symbol,
Fastfetch paths/ASCII, terminal AI menu graphic/fallback and all lock fallbacks.
Visible AI and Brain names use Nacre; compatibility commands/account paths remain
unchanged to preserve users and busy workers. Legacy published sh.* may be copies
of the new mark temporarily so already-open old controllers cannot show SH.

Color changes only follow palette publication/bindings. No idle animation or
new polling. Preserve exact scoped terminal redraw behavior. Login appearance
publishes all required color roles; root-owned theme code updated only after
reviewed native preview/tests. Authentication/PAM/autologin are untouched and
SDDM is not restarted. Keep current private palette/wallpaper choices, credentials,
vault, host overrides and personal full-access assistant permissions unchanged.

Acceptance: reproducible build/no home writes, PNG transparency and no stretch,
symbolic geometry equivalence, color-slot/contrast tests, actual Qt SVG and QML
rendering at 16/26/30/256/512 in dark/light/neutral contexts, native terminal/menu
render/redraw, lock raster and safe login preview, Brain web appearance. Reassess
changed SHA-bound source reviews explicitly. Full checks, native Hyprland, plan/
apply/strict source/IPC, configerrors, private/worker checks, exact-main CI. Preserve
the other chat's work through rebasing/normal fast-forward integration; deployment
uses the existing common release lock. User explicitly approved this deployment;
administrator authentication may still be needed for the root-owned login files.
