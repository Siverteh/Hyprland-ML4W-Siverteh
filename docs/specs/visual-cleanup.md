# Post-rewrite layout, scrolling and motion cleanup

User scope: centered top title; restore right controls as two above/two below;
cleaner wallpaper chooser, especially Spotlight; cleaner sound/Wi-Fi/Bluetooth
and notifications; faster scrolling and smoother wallpaper/menu transitions.
Complete all reported areas, not only the first two fixes. Independent source
baseline is main `1366c0d57e9b4b90e6a44af2f88139cf3eda4b09`.

## Design plan and critique

Use existing wallpaper-derived NacreTokens. The current sample is body #121113,
raised #1a191b, input #201f21, accent #c7b4e1, ink #eceaee and muted #b2b0b4.
These illustrate roles, not new fixed colors. Keep IBM Plex Sans for controls,
existing mono title/data and licensed Material icons. Preserve Natural/Harmony,
fixed palettes, mode and user preferences. No logo/font/public-identity redesign.

Center the actual title/icon group on the physical header, bounded to avoid both
side groups. Use a balanced 2×2 level layout: screen/keyboard above, speaker/mic
below, with clear mute controls. Keep popup padding and headings compact and
consistent; avoid new decorative cards around every row. Wallpaper content is
primary: compact complete carousel cards; large measured Spotlight hero with
balanced neighboring previews and centered search/navigation; real hexagon bounds.

Motion answers selection/open/close; no idle decoration. Keep the user's immediate
title-band hover trigger and existing exit grace. Entrance should feel smooth
rather than abrupt; closing releases input immediately while clipped fixed content
settles. Wheel momentum must respond promptly and continue briefly after release,
coalesce bursts, stop on touch/drag/teardown and honor reduce motion. All background
work remains bounded/event-driven; no extra interpreter/device polling.

Brief review: the existing palette/type/pills are deliberate user preferences, not
an invitation to replace the style with a generic new design. Improvements should
come from alignment, hierarchy, spacing, responsiveness and motion. Retain useful
labels; remove redundant decoration or wasted side boxes rather than adding effects.

## Demonstrated initial causes

NacreHeader centers the title component, but NacreActiveTitle's inner Row spans the
entire allotted width while its short caption remains left aligned. Measure the
painted title/icon group, not just the outer component center.
NacreOsdControls explicitly uses one Row for all four controls; the 260×220 wrapper
also assumes that arrangement. Restore both composition and panel/input geometry.
Existing quick-list wheel policy uses 72px/160ms; other scroll owners need their
own event/geometry inspection, rather than assuming one constant fixes everything.
Spotlight directly advances on each wheel event; inspect pixel deltas/coalescing,
travel/decode/source readiness and boundaries before selecting final motion policy.

## Behavior and safety invariants

- Preserve device write owners, current volume/mute/default selection, known radio
  state and native credential/pairing UI. Opening controls or QA must not write them.
- Preserve Super+A/W, favorites default, Escape/outside-click, pin-only-on-explicit
  AI pin and hover/fullscreen/drag/rearm guards. No bare Super binding or power row.
- Retained notifications keep messages, assistant completion and errors, with
  transient screenshot/window feedback excluded and lock-preview privacy intact.
- Preserve wallpapers/search/rotation deadlines, matched image/palette publication,
  prepared caches, silent selected dynamic preview and battery/lock/sleep policies.
- Preserve editable drafts and scroll recovery, busy workers, full-access Codex/
  Claude and paru --skipreview. No provider/account/vault or real network QA action.
- New layout/motion is independently authored. Earlier screenshots/accepted layouts
  are visual references; do not copy inherited implementation to restore the look.

## Verification and completion

Capture/review actual renders, including short/long titles, responsive/DPR geometry,
level grid, popups and chooser modes. Add meaningful native input/geometry/render
regressions for demonstrated issues. Probe rapid wheel/selection, repeated open/
close/reopen, interruption, clipping, empty/failed media and reduce motion. Use
synthetic/fake device/notification data when testing writes/privacy; real launcher/
Escape/click/focus gates run on the target only at a controlled time.

Format and run full tools/check.py, native Hyprland verification, reviewed install
plan/apply, live exact source/service/IPC/configerrors and exact-main CI. Update
provenance only after reassessing changed/new own source; completion metadata gate
must pass. Update feature/ownership docs and private checkpoints. Preserve rollback
and other sessions. Record physical multi-output/scale/login limitations honestly.
Goal stays active until every reported area is polished and verified; do not claim
full cleanup from a title/grid patch or merely passing headless fixtures.
