# Nacre text and surface primitives

[System overview](../overview.md) · [Behavior spec](../specs/design-foundation.md) ·
[Provenance tracker](../nacre/PROVENANCE.md)

The first foundation batch independently implements four inherited widget bodies:
text, plain surfaces, rounded content clipping and hover/press interaction. Existing
`StyledRect`, `StyledText`, `StyledClippingRect` and `StateLayer` names are minimal
compatibility adapters to `NacreSurface`, `NacreText`, `NacreClip` and
`NacreInteraction`. Current layouts, richer Orient colors and IBM Plex Sans 12pt
remain the baseline; typography/corner overrides continue to work.

## Ownership and tokens

`widgets/NacreTokens.qml` supplies body/raised/frame colors, foreground/muted ink,
accent, outline, font and motion defaults. It reads the current palette and desktop
animation preference. The existing Colours/Appearance/settings providers remain
outside this replacement's ownership; those areas still need their own rewrite.
No primitive generates colors or starts processes.

Use `NacreSurface` for ordinary backgrounds. It defaults to transparent / radius 0;
callers set actual color and geometry. Color transitions are finite 200ms OutCubic
and configurable per instance. They skip initialization and respect animations
being disabled. Light/dark mode changes skip color tweening to keep foreground and
background readable together. Pending motion settles on disabling/hiding.

`NacreText` preserves native Qt text rendering, plain-text defaults, wrapping and
elision. Opt-in text changes retain the current scale 0→1 / 400ms compatibility defaults;
rapid changes cancel obsolete transitions, and hidden/reduced-motion updates settle.
Use explicit Qt text formats for rich text. Avoid resizing labels as they animate.

`NacreClip` delegates actual rounded clipping to Quickshell's native
ClippingRectangle. Reserve it for avatars/artwork; ordinary surfaces need no
clipping layer. Border/corner and contentItem behavior follow the dependency API.

## Interaction

`NacreInteraction` fills its parent and follows caller/parent rounding. Pointer
hit testing uses the rounded shape, so empty corners of circles/pills do not click.
Hover never acquires focus. Left release activates once inside the shape. Disabled
controls reject mouse/keyboard/accessibility activation and leave the tab chain.

Tab shows a rounded focus outline. Enter activates once; Space on release. Escape
and unrelated keys bubble to existing panel handlers. Pointer clicks hide the
keyboard-only focus ring. Held keys clear on cancellation, disable, hide or focus
loss. Motion callbacks guard against controls being destroyed during refresh.

Existing `function onClicked()` handlers remain valid; new consumers can use
`onActivated`. `accessibleName` can supply a human label; text/app-name labels are
inferred when available. Complete screen-reader labels for icon-only controls
belong to the following controls batch, not a claim made by this primitive layer.

## Validation and remaining work

Tests instantiate actual new primitives and a production ActionButton. They cover
layout/text metrics, clipping pixels, rounded clicks, disabled states, focus,
keyboard activation, Escape, motion preferences and teardown. Existing chat/audio
fixtures now include the actual interaction/token dependencies.

Quickshell offscreen mode selects the software scene graph unless RHI is requested.
Native rounded clipping needs the graphics path. The native capture test explicitly
uses the RHI OpenGL renderer, on an available X display or Xvfb; CI includes Mesa.
The offscreen platform's unsupported window-mask notice is distinct from in-scene
clipping, which is asserted against captured pixels. The ordinary input/text tests
remain headless Qt tests. No test draws a new window on the user's desktop.

The remaining shared controls, config/services, panel designs and icon/logo work
are separate batches. Applicable LICENSE/NOTICE files remain during the rewrite.

## Shared controls and Nacre names

The remaining foundation helpers are independently implemented as NacreTextField,
NacreSlider, NacreScrollBar, NacreWindow, NacreShortcut, NacreImage, NacreTint and
NacreIcon. Maintained panels use these names and the Nacre text/surface primitives;
old names remain only as freshly written compatibility adapters. Config providers
use NacreAppearance, NacreFrame, NacreBar, NacreDashboard, NacreLauncher,
NacreNotifications, NacreOsd and NacreSession. NacrePaths and NacreIcons resolve
XDG roots and desktop metadata. See the [controls spec](../specs/foundation-controls.md).

The exterior frame, drawer backgrounds and top bar share the body surface color.
Orient's brighter frame color is reserved as a decorative palette token. Raised
cards and input backgrounds keep their separate tones. Text selection now follows
the wallpaper accent, and narrow scrollbars keep a usable thumb. OSD sliders use
Qt's standard mouse/keyboard semantics with rounded track/focus geometry.

Image helpers retain existing pixels while a replacement is prepared, coalesce
resize requests and release obsolete thumbnail handles. Thumbnailer remains an
inherited service awaiting its own rewrite. Material Symbols remains a licensed
font dependency; the rewritten NacreIcon helper does not claim ownership of it.
The appearance provider keeps existing layout dimensions but supplies new bounded
easing curves and honors reduce motion. No foundation widget polls or animates idle.
