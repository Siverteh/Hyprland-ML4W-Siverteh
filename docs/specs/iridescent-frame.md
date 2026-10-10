# Nacre iridescent frame

User approved the research recommendation on2026-10-10: flatter handles,
primary-to-secondary color along their length, a quiet continuous inner rim and
one short interaction highlight. This supersedes the earlier domed-lip trials;
it is local Nacre design work, not a copy of another shell's implementation.

## Material and geometry

Keep the existing dark body and Orient roles. New semantic tokens expose the
secondary accent and a softly lifted primary highlight. Top handle artwork is
160px long, sides104px; the middle is straight with eased shoulders. Preserve
6px top/5px side visible depth and wider208px/144px existing hover regions.
Palette changes apply directly, without an additional color transition.

The shared frame/panel owner computes the union of enabled reserved edges,
painted panel rectangles and the handles' central ridges. Extract exposed
orthogonal boundaries, remove collinear vertices, then round corners. Special
handle corners use shallow asymmetric shoulder cuts. Body and rim derive from
the same contour, so overlaps and attachments create no internal seam. Zero
edges, zero-size closing panels, overlapping panels and disconnected regions
must produce finite closed body paths. The rim excludes the monitor's external
boundary and traces only the exposed desktop-facing contour.

Use native Qt Shapes with a1px primary/highlight/secondary gradient stroke.
Qt6.12 introduces strokeGradient and is required for this visual slice. Keep one
per-output Wayland surface; the header stays above chrome and panels. The rim
is passive and carries no input mask. Fullscreen-gallery presentation suppresses only the faint rim. Handles remain
visible in galleries, launchers and modal settings; visibility is independent of
passive hover eligibility. A deliberate handle click can switch the active panel.
Disabled edges and the master hide still hide their handles. No extra exclusive window space.

## State and motion

The rim rests at16% opacity and reaches25% with an open panel. Appearance →
Desktop frame → Frame sheen can disable it while retaining the new handles.
Changing/opening this preference writes no device state. It uses the existing
validated desktop preference owner; old files without the key default to enabled.

Handle enamel flows along its length from primary to secondary:72% idle strength,
92% hover/open. A240ms pearly sweep runs once on hover/open, only while visible.
No looping timer or idle animation. Reduce motion or disabled animations stops
sweeps immediately and settles strength/rim transitions. No new process, shader,
wallpaper decoding or palette extraction owner.

## Preserved behavior and evidence

Keep fast hover, click-only mode, held-button/fullscreen guards, dismissal rearm,
Escape/outside click, full-width header hold for an open dashboard and explicit-only
AI pinning. All panel motion continues to use actual animated dimensions. Input
regions release on logical closing independently of painted exit.

Use actual QML-engine geometry tests (not browser-only JS), native rendered
closed/open/overlap/dark/light/quiet frames, reduced-motion/finite sweep checks,
and real tiled-workspace hover/open/close/app-click/typing checks. Inspect the
real result before accepting polish. Measure idle and transition costs on the
host; do not infer battery performance from absence of a timer. Follow the normal
full check, Hyprland verification, plan/apply, source and CI gates. Preserve busy
workers, user preferences and parallel Brain work.
