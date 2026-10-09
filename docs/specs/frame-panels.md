# Nacre frame and panel system

Date: 2026-10-08. Next area of the active whole-desktop independent rewrite.
[Tracker](../nacre/PROVENANCE.md) · [Edge behavior](../features/edge-menus.md).

## Outcome

Replace inherited assembly, input-region and reserved-edge implementation under
modules/drawers with independently authored Nacre components. Preserve the layout,
current body-colored chrome, settings/preferences, opening routes and per-output
behavior. Audit newer frame geometry separately: retain proven independent work
rather than deleting it solely because it sits beside an inherited component.
This is a behavior rewrite; new artwork and a new visual identity follow later.

Use consumer contracts, deployed QObject/IPC observations, existing acceptance
tests and public Qt/Quickshell APIs. Do not consult upstream implementation or
copy target bodies. The earlier diagnosis already exposed Drawers/Panels and
FrameSurface source portions; record that exposure honestly. No legal clean-room
claim. Keep applicable notices pending the whole-tree audit.

## Ownership and composition

One desktop scope coordinates screen-local panel hosts. Each host assembles the
existing launcher, wallpaper picker, dashboard/settings, AI drawer, popouts, OSD,
session controls and notification presentation. It consumes existing state;
it must not create another notification server, wallpaper publisher, application
launcher or assistant backend. Public state/IPC paths and output recovery remain
compatible. Record observable sizes/properties before replacement; internal child
IDs and former helper structure are not mandatory implementation contracts.

Screen identity is stable by output name. Creation, removal, scale changes and
recovery must clear obsolete mappings without destroying shared backend state or
another output's drafts/preferences. Single-owner registration and cleanup must
be explicit. Never move application windows to make room for a transient panel.

## Geometry and rendering

Exterior bands, panel-joining backgrounds and the top bar share NacreTokens.body.
Respect NacreFrame header/edge dimensions and rounding, including individually
hidden edges and fractional scaling. Raised content uses its own tokens. Match
rendered frame openings and panel joins without seams, doubled backgrounds or
content bleeding outside the closing geometry. Rounded content clipping is
native Quickshell clipping where needed; avoid per-frame process work or polling.

Use bounded, interruptible transitions. Reversing an opening/closing transition
must target the latest state. Hidden content cannot remain floating mid-screen.
Reduced motion disables presentation transitions without changing logical state.
Reserve only persistent configured edge space; transient menus never retile apps.

## Input and focus

Passive hover panels remain nonmodal and do not acquire keyboard focus. Retain
precise immediate top-center/title activation and narrow side activation, existing
exit grace, held-button/fullscreen suppression and dismissed-edge rearming.
Explicit activation, pinned panels and keyboard routes keep their current focus
and dismissal behavior. AI opens unpinned; only an explicit pin action pins it.

Closing removes the interactive region immediately even while the visual panel
shrinks. Input hit regions must follow logical visibility and actual geometry,
not a stale animated rectangle. Chrome and other applications must receive clicks
normally after menu closure. Opening or closing a passive panel must not leave
an exclusive keyboard grab or invisible click-catching surface behind.

Escape and outside-click close explicit unpinned launcher/wallpaper/settings
panels according to existing behavior. Preserve the non-consuming global Escape
for passive panels. Pinned state, click-handle preference, hotkey OSD behavior and
notification suppression during expanded-panel transitions remain compatible.

## Acceptance

Extend actual Qt/Quickshell tests for geometry, latest-state transitions, teardown,
input-region release, passive versus explicit focus, rapid dismissal/reopening,
edge toggles and reduced motion. Preserve current launcher, wallpaper, chat,
settings, click-away, hover and output-recovery behavior tests. Fake service tests
cannot establish live compositor focus correctness.

After full source checks and Hyprland verification: inspect install plan, deploy
only reviewed components with rollback, validate source/IPC, actual launcher and
wallpaper Escape/click-away, top hover closure and subsequent application clicks,
output/scale behavior where test hardware permits, and configerrors. Do not
interrupt private AI workers or alter AI access/update policies. Label untested
physical/multi-monitor/cold-login behavior. Publish only verified changes, record
provenance and keep the goal active until every remaining area and audit is done.
