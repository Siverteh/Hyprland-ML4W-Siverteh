# Nacre dashboard overview cards

Date: 2026-10-09. Implements the next batch of dashboard.md.

## Origin boundary and contract

Delete dashboard/Dash.qml and dash/{Weather,User,DateTime,Calendar,Resources,Media}
without consulting their bodies. Author NacreOverview and six own card components
from live overview observations, public property declarations and existing service
consumer contracts. No upstream implementations consulted; public declarations and
reference searches are recorded exposure, not a legal clean-room guarantee. Keep
all applicable notices. CalendarGrid is a separate inherited helper: the new
calendar must not depend on it; remaining bar callers require a later replacement.
The larger Media/Performance/Workspace/Settings pages and data services remain
separate pending areas.

## Layout and appearance

Keep the established overview: weather and host at the top left, tall media on
the right, vertical clock/calendar/resource gauges below. Preferred content about
874×488 logical pixels, twelve-pixel gaps, neutral wallpaper-tinted surfaces,
IBM Plex text, primary/secondary/tertiary resource accents and existing own logo.
Bound text and images inside surfaces. On narrow outputs arrange cards vertically
and scroll rather than crushing date labels or clipping controls. Shared fast
scrolling and reduced-motion policy apply. No new identity redesign or artwork.

## Card behavior

Weather uses existing temperature/unit/location/description/stale/error fields.
Missing data is explicit; retain valid cached temperature when stale. Clock uses
local date/time from Time with no separate clock process. Calendar has six weeks,
locale weekday start, selected month navigation and correct leap-year/year-boundary
behavior. Today is highlighted only when the actual local day matches. Calendar
arithmetic constructs local civil dates, not repeated 24-hour timestamp increments.

Host card reads OS description and uptime through asynchronous FileView; username
comes from session environment and compositor label is Hyprland. Uptime reloads
at most once per minute and only while open; no interpreter/subprocess polling.
Existing BrandLogo/geometry is retained and not certified newly original here.

Resources consume SystemUsage fractions (0–1 as confirmed by LockWidgets/render
consumer), with clamping and unavailable-value handling. No new data collector.
Media consumes Players.active and documented native MPRIS properties/methods.
Respect canControl/canGoPrevious/canTogglePlaying/canGoNext; empty/missing metadata
and artwork have useful fallbacks. Only visible playing media samples position,
at most once per second, without subprocesses or forcing global positionChanged.
Length/position capability checks and invalid/zero duration guard progress. Closing,
player removal and track changes stop/reset sampling. No implicit playback changes.

## Verification

Production JS and QML tests cover civil calendar boundaries/localized week order,
responsive card bounds, clock rollover, missing/stale weather, clamped gauges,
long host/track text, guarded media buttons, removal/track progress, hidden timers
and loading/error artwork. Native Quickshell rendering checks actual round album
clipping; inspect representative overview screens. Full checks/Hyprland validation,
plan/apply, native source/IPC and live opening/tab/close gates before publication.
Preserve private history/preferences/AI workers and existing playback; use a fake
player to verify transport rather than skipping the user's real track. Record
remaining inherited services/assets/helpers explicitly.

Implementation references: [Quickshell FileView](https://quickshell.org/docs/v0.3.1/types/Quickshell.Io/FileView/)
for asynchronous native reads and
[MprisPlayer](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Mpris/MprisPlayer/)
for supported transport/position capabilities and seconds-based position. Calendar
uses standard JavaScript civil-date constructors and Qt locale/date formatting.
