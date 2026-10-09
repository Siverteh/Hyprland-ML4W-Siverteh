# Nacre foundation controls and helpers

Date: 2026-10-08. Extends the text/surface foundation specification. Implement
from this contract, maintained consumers, deployed QObject observations and public
Qt/Quickshell APIs. Delete inherited bodies before writing their replacements;
retain repository notices until the overall provenance audit is complete.

## Shared controls

NacreTextField uses native Qt Quick Controls text editing, selection, clipboard,
validation, password modes and input methods. Keep IBM Plex Sans 12pt, plain
single-line editing, caller background/padding/height overrides and accepted/text
signals. Its default background and selection use Nacre tokens, never the system's
unrelated blue selection. Focus has a visible palette-aware outline; Escape and
navigation keys remain available to callers. Disabled and read-only follow Qt.

NacreSlider replaces the vertical OSD slider. Preserve Qt Slider's from/to/value,
stepSize, moved, pressed and keyboard API; default vertical range 0–1, live writes.
A rounded track fills from bottom to top, with an optional icon near the bottom.
Use a compact focus outline, no square outline around rounded controls, no idle
animation or background processes. External value updates must not emit moved.

NacreScrollBar is an attached Qt ScrollBar, supporting both orientations, policy,
size, position and active/pressed state. A narrow rounded thumb gains emphasis on
hover/drag; minimumSize is a useful fraction, not one (which fills the entire
track). No motion changes the scroll position. Scrolling remains owned by callers.

## Window, icon, image and shortcut helpers

NacreWindow is a transparent Quickshell PanelWindow, default nonexclusive,
nonfocusable; namespace `nacre-` plus caller name. Preserve screen, anchors,
margins, mask and WlrLayershell caller overrides. Never acquire keyboard focus
solely from showing a passive panel.

NacreShortcut uses Quickshell's supported global shortcut type; keep appid
`nacre_shell` so existing compositor binds continue working. Names, descriptions,
pressed/released remain the native API.

NacreIcon renders the currently installed licensed Material Symbols Rounded font
as a ligature through NacreText; default 20px, optional fill axis 0–1. This replaces
the helper implementation, not the third-party font or the final icon design.
New artwork/icon-set decisions remain separate, to avoid breaking existing labels.
NacreTint uses Qt MultiEffect colorization only, preserving the native source and
colorizationColor API, without global blur/shadow effects.

NacreImage accepts path and loadOriginal, asynchronously loads a thumbnail through
the existing Thumbnailer service, and retains the previous pixels during reload.
Coalesce dimension/path changes; destroy obsolete thumbnail handles and their
processes. Empty paths never spawn thumbnail work. Preserve Qt Image APIs and
fillMode PreserveAspectCrop. The service itself is not certified original here.

## Config and utility ownership

NacreAppearance owns the public geometry/type scale and finite motion defaults.
Preserve observed layout sizes and font metrics, but author new ordinary easing
curves rather than retaining inherited expressive curves. Existing animation and
reduce-motion preferences disable durations. Feature config providers are simple
QtObject data, keeping current consumer properties and observed sizing. They do
not launch processes or own user settings. NacreFrame reads current edge toggles,
frame size and rounding. Its chrome color is exactly NacreTokens.body, matching
the top bar; raised inner cards remain separate. NacreTokens.frame remains an
Orient decorative color, not the outer chrome background.

NacrePaths resolves current XDG config/state/cache roots and Pictures, exposes
file URLs used by existing consumers, and contains no legacy product directory.
NacreIcons looks up desktop entry metadata through Quickshell, maps categories,
network strength and weather codes into existing symbolic glyph names, returns
caller fallbacks for unknown values, and reads distribution name once. No polling.

Migrate maintained consumers to the Nacre names. Keep newly written tiny legacy
adapters for compatibility; these are not retained inherited bodies. Tests use
actual new controls with fake services, and exercise typing/selection/validation,
slider pointer/keyboard/disabled/moved semantics, attached scrollbar geometry,
image lifecycle and config/utility contracts. Native Quickshell checks cover window
namespace/passive focus and shell startup. Full checks, Hyprland verification,
install plan/apply and live source/IPC/Escape gates precede publishing.

References: [Qt TextField](https://doc.qt.io/qt-6/qml-qtquick-controls-textfield.html),
[Slider](https://doc.qt.io/qt-6/qml-qtquick-controls-slider.html),
[ScrollBar](https://doc.qt.io/qt-6/qml-qtquick-controls-scrollbar.html),
[MultiEffect](https://doc.qt.io/qt-6/qml-qtquick-effects-multieffect.html),
[Quickshell PanelWindow](https://quickshell.org/docs/v0.2.0/types/Quickshell/PanelWindow/),
[DesktopEntries](https://quickshell.org/docs/v0.2.0/types/Quickshell/DesktopEntries/).

2026-10-09 image dependency refinement: runtime inventory found no maintained
NacreImage/CachingImage users and only this adapter referenced Thumbnailer. The
[image/presentation spec](image-presentation-services.md) supersedes its thumbnail
handle contract: native Qt decode/cache/coalescing now backs the optional helper,
while the unused inherited service is retired. Prepared wallpaper caches unchanged.
