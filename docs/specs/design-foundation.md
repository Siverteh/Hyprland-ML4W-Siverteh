# Nacre design foundation: text and surfaces

Date: 2026-10-08. Scope: first foundation batch, following the completed Orient
rewrite. [Provenance](../nacre/PROVENANCE.md) · [System overview](../overview.md).

## Purpose and design boundaries

Own the shared text, surface, rounded clipping and interaction primitives that
panels compose. Preserve the current layouts, typography and user-chosen richer
Orient palette. This batch establishes reusable implementation and semantic tokens;
it does not choose new logo art, fonts, icons or a different panel design.

Appearance is anchored in the existing wallpaper: body surfaces, raised sheets,
foreground ink, muted ink, accent and frame. Corners follow each caller's geometry.
Hover/press feedback uses a quiet translucent ink layer, not new saturated fills.
Keyboard focus has a clear rounded outline, without moving content. Animation is
finite, triggered by actual changes and disabled with the existing animations
preference or an explicit reduce-motion override. No sweep or idle animation.

## Independent implementation and compatibility

Implement from this specification, public Qt/Quickshell APIs, consumer call sites
and black-box runtime behavior. Do not consult or copy Caelestia/ML4W source bodies
(including local inherited bodies). Generic Qt properties and compatibility names
are contracts, not an inherited implementation. Existing copyright notices remain.

New types: `NacreSurface`, `NacreText`, `NacreClip`, `NacreInteraction`, plus the
independent `NacreTokens` singleton. Retain `StyledRect`, `StyledText`,
`StyledClippingRect` and `StateLayer` as newly written minimal adapters so existing
panels do not require a simultaneous rewrite. Delete inherited bodies before writing
replacements. The larger Appearance/Colours/settings implementations remain legacy
providers behind this batch's token boundary; they are not certified original here.

## Contract and defaults

Observed through deployed QObject properties, not source-body inspection:

| Component | Required contract |
|---|---|
| Surface | Standard Rectangle sizing, color, gradient, border, corner radii and child layout. Transparent by default; radius0. Explicit caller color/geometry wins. |
| Text | Standard Qt Text API; current default IBM Plex Sans,12pt, normal weight, foreground ink. Preserve caller font, wrapping, elision, text format and metrics. |
| Clipped surface | Standard Quickshell ClippingRectangle API: transparent background, radius0, rounded content clipping, border/corner properties; contentInsideBorder true and contentUnderBorder false by default. |
| Interaction | Fill parent by default, adopt parent radius when available, caller overrides supported; color, disabled, hovered and pressed properties; virtual `onClicked` callback used by existing callers. |

Text compatibility includes `animate`, `animateProp`, `animateFrom`, `animateTo`
and `animateDuration`; existing consumers only enable `animate`. Observed defaults
are false, scale,0,1,400ms. Replacement supports this contract with a new finite
PropertyAnimation; it must cancel obsolete animations during rapid updates and
settle immediately when motion is disabled or the item becomes hidden. Initial
text must be visible without a delayed startup animation.

Internal QObject/child trees are not compatibility APIs. In particular interaction
root opacity can differ if its visible idle/hover/pressed result is equivalent.
The ink overlay and keyboard-focus outline need separate opacity so keyboard focus
is not accidentally faded with hover feedback.

## Interaction behavior

- Left click activates once on release inside the control. Pointer positions in
  rounded corner cutouts must not activate. Use an analytic rounded-rectangle
  containment test with clamped radii; avoid per-control Shape tessellation solely
  for hit testing. Explicit per-corner geometry is supported.
- Hover only changes appearance; it does not activate or acquire focus. Hover and
  pressed states clear on leave, cancellation, hiding and disabling.
- Disabled controls never activate through mouse or keyboard and show no active
  feedback. Preserve ancestor enabled/visible semantics.
- Enter/Return activates once; Space activates on release. Ignore key autorepeat.
  Escape and unrelated keys propagate to existing panel dismissal/navigation.
- Tab focuses the interaction and shows its rounded outline. Pointer clicks do
  not leave a keyboard-only ring visible. Losing focus clears held-key state.
- Existing `function onClicked()` consumers work; new callers may subscribe to
  `activated`. Touch remains handled by Qt's normal synthesized pointer delivery.
- Signals and input handling are scoped to the control. No new layer surfaces,
  global shortcuts, compositor focus grabs or popup ownership.

## Rendering and motion

Plain surfaces use Rectangle. Rounded content clipping uses Quickshell's native
ClippingRectangle only where content needs it. Keep image crop behavior, avatar
roundness and cover placement. Do not add offscreen effects to every surface.

Text and color/state transitions are bounded and use standard Qt easing, without
inherited animation helpers. Override color animation duration per instance when
needed; allow zero duration. Theme publication remains owned by existing matched
presentation; foundation widgets must not generate or publish colors.

The token boundary reads the existing palette/settings only. It exposes font,
color, radius, spacing and motion defaults for the new primitives. No polling,
processes or backend writes. Match existing IBM Plex Sans12pt metrics and Qt text
rendering defaults. Respect existing per-consumer typography overrides.

## Test and deployment gates

Test actual new components, not substitutes: text sizing/wrapping/elision/theme
updates, rapid/hidden/reduced-motion text transitions, transparent/default/explicit
surface colors, pointer hit regions, disabled/keyboard/cancel behavior and focus
outline geometry. Verify rounded clipping using real Quickshell rendering and a
captured private test image; do not claim a rectangular test substitute proves
native clipping. Ensure surfaces stop animating after settling.

Exercise a production ActionButton with the replacements to verify one activation,
disabled behavior and current sizing. Run existing launcher, wallpaper, Settings,
chat and other native regressions. Parse/format QML, full tools/check.py and
Hyprland verification, install plan/apply, actual native source/IPC and Escape gates,
then configerrors. Preserve busy AI workers and known-good release snapshots.

Review a private component sheet in dark/light and multiple wallpaper accents.
The sheet is a validation artifact, not a new desktop application or prototype
product. Record implementation references, replaced files, tests and deployment
in the provenance tracker. Other foundation controls/config/services remain pending.

## Primary implementation references

- [Qt Text](https://doc.qt.io/qt-6/qml-qtquick-text.html)
- [Qt MouseArea](https://doc.qt.io/qt-6/qml-qtquick-mousearea.html)
- [Qt PropertyAnimation](https://doc.qt.io/qt-6/qml-qtquick-propertyanimation.html)
- [Quickshell ClippingRectangle](https://quickshell.org/docs/v0.2.0/types/Quickshell.Widgets/ClippingRectangle/)

These are dependency APIs, not a claim to authorship of Qt/Quickshell internals.
