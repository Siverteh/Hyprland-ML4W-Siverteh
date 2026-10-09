# Independent bar controls and battery/calendar popouts

2026-10-09. Delete inherited/mixed ActiveWindow, Power, StatusIcons, Battery and
Calendar bodies before implementing Nacre equivalents. Public declarations,
TopBar caller geometry and popout route map, existing own services/primitives,
native observations and dependency APIs are the implementation references. Earlier
reviews exposed some provider/UI portions; no upstream source consulted and no
legal clean-room claim. Keep notices. TopBar/WorkspaceStrip, other popouts and the
shared popup assembly remain separate audit/rewrite areas.

## Bar contracts

Active title: native focused client's plain-text title, category icon and Desktop
fallback, mono font, bounded elision, caller-provided horizontal geometry/colour.
Retain the public monitor/horizontal/colour/child contracts; tolerate removed or
unavailable monitor/client. Wheel adjusts volume through the safe existing audio
owner in small bounded increments, never on ordinary hover. No title polling or
perpetual text animation.

Status: retain native speaker, Wi-Fi, Bluetooth, battery and notification targets
and public item handles used by hover hit-testing. Preserve vertical-column /
rotated horizontal-bar geometry with readable counter-rotated glyphs/text. Icons
react to shared state; retained notice count is bounded text. Battery percentage
is a fraction in native Quickshell; check readiness/laptop type/finite range before
formatting. Missing battery must not falsely report 0%. Keep palette roles and
status warning colours. No radio/audio/profile write when displayed.

Power: explicit accessible mouse/keyboard activation toggles the focused output's
session panel, dismissing competing transient menus. No lock/shutdown operation
occurs merely by opening the menu. Geometry stays circular with safe corner hit
regions from NacreInteraction.

## Popouts

Battery: bounded percentage/progress, AC/discharging/charging estimate in minutes
or hours, unknown estimates labelled rather than 0h. Profile buttons use native
PowerProfile enums, show active selection, reject unavailable Performance and
unknown enum values. User activation only; never write profile on load. Surface /
foreground roles preserve contrast and current compact footprint. Show degraded
performance reason when provided. Native UPower owns reads; no extra processes.

Calendar: plain local civil dates, locale week start/day headings, six rows,
previous/next month with year rollover, today highlight. Reuse Nacre's independent
calendar data helper, not CalendarGrid. No timezone or global clock writes.
Retain month/year/changeMonth public contracts with finite bounded navigation.
Remove CalendarGrid only after proving no other callers remain.

New Nacre names are used by maintained callers and dynamic popup routes. Small
old-name forwarders preserve compatibility. Actual Qt tests verify reactive state,
unknown data, geometry/counter-rotation, title removal/elision/wheel limits,
profile click guards and no writes on open, calendar rollover/leap/week order,
keyboard activation and safe power-menu toggling. Required full checks, native
Hyprland verification, plan/apply and real hover/click/Escape/source checks precede
publishing. QA never performs real lock/power/profile/radio/volume changes.

References: https://quickshell.org/docs/v0.2.1/types/Quickshell.Services.UPower/UPower/
https://quickshell.org/docs/v0.2.1/types/Quickshell.Services.UPower/UPowerDevice/
https://quickshell.org/docs/v0.2.1/types/Quickshell.Services.UPower/PowerProfiles/
https://quickshell.org/docs/v0.2.1/types/Quickshell.Services.UPower/PowerProfile/

## Dismissal regression found during live acceptance

Header-click Settings had no explicit initial keyboard focus; the prior fixture
forced it manually and therefore missed that path. NacreDashboardPanel now requests
Qt focus only for visible pinned Settings, including reopening, and the fixture
uses the real activation path. Passive dashboard hover does not request focus.
Explicit nacre close also releases dashboard/popout pins and edge-menu state;
otherwise a later hover could reopen a stale pinned Settings page. Retain selected
page/tab preferences. Focus diagnostics in barStatus are booleans only. Native
header Escape and subsequent passive closure must pass before promotion.

CI font fallback: status glyphs have fixed24×28 logical-pixel boxes with clipping /
elision, so absent Material Symbols cannot expand the rotated bar with long icon
names. Test deliberately substitutes an absent font while retaining native text
and strict geometry assertions. The font remains a documented runtime dependency;
this bound is layout protection, not a claim that a missing font renders icons.
