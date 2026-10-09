# Nacre dashboard and Settings rewrite

Date: 2026-10-09. Follows launcher and notification presentation verification.

## Scope and source boundary

Replace inherited dashboard assembly/navigation and the Dash/Media/Performance
pages, dash cards, maintained settings/workspace/control pages and their uncertain
helpers. One verified batch at a time; do not certify retained page bodies from
creation dates. Write from this spec, public declarations, dependency APIs and
live observations, not upstream or local inherited body copying. Keep notices.
Previously searched declarations/caller references are recorded source exposure;
no legal clean-room guarantee. Dependent data services remain separate tasks.

## First batch: panel assembly and navigation

Delete Tabs, Content and Wrapper. NacreDashboardPanel loads just one page at a
time and owns the fixed internal geometry and clipped open/close presentation.
NacreDashboardNavigation contains Dashboard, Media, Performance, Workspaces,
Settings in that order, matching the established dashboardTab 0–4 API. Clicking
switches immediately; selected text/icon and an underline respond without delay.
Settings remains in the top menu and uses the existing private settings routes.

Use the same body color as the top bar/frame. Preserve consumer visibilities,
parent viewport limits, wrapper sizing and keyboard/outside-click behavior owned
by the frame. Pages supply their intrinsic sizes; clamp panel size to the actual
output. Keep internal height fixed during closing, unload after settling, and
reverse safely when reopened. Retained pages are still explicitly pending origin
replacement, not duplicated or silently renamed. shouldUpdate/active is true only
while the selected page is actually open. Reduce motion settles immediately.

Settings uses pinned modal focus; other hover pages keep current passive focus.
Selecting Settings pins the dashboard; selecting a different tab releases that
Settings pin. Escape delegates to frame dismissal and private preferences remain
outside software rollback. Source/IPC route numbering must not change.

## Page batches

Dashboard preserves weather, host/user information, local clock/calendar,
resources and media controls, with content measured inside neutral backgrounds.
Media preserves active-player selection, art, metadata, seek/transport capability
checks and stopped/empty behavior; remove unlicensed bongo artwork. Performance
uses existing resource data without creating new idle polling. Workspaces keeps
native placement/actions and private workspace preferences. Settings keeps its
search/category organization, Appearance/rotation/fixed palettes/Harmony, devices,
notifications, lock, time, maintenance and AI/private permissions behavior.

Specify and replace each uncertain settings/helper body before marking the area
complete. Lock authentication remains Hyprlock/PAM; appearance must not take over
password handling. New code never modifies personal AI permission defaults,
accounts, workspaces, wallpaper choices or paru --skipreview.

## Acceptance

Test actual assembly/navigation with page contract fixtures: all five tabs and
required bindings, immediate selection/pinning, lazy load/closing/reversal,
viewport bounds, hidden-page update suppression and reduced motion. Later card
and page tests use actual replacements. Inspect native/live layout and every tab,
Settings search/navigation, Escape/off-click and code/source readiness. Full
checks, Hyprland verification, plan/apply/rollback and CI gate every publication.
One-output synthetic checks do not claim cold login or multiple physical outputs.
