# Wallpapers

[System overview](../overview.md) · [Deployment and recovery](../maintenance.md)

## Wallpaper library and layouts

Super+W remains a wallpaper-only drawer. Static/Dynamic filters distinguish still
images from local videos/animated GIFs. Carousel, Spotlight and Hexagons share
selection, arrow/scroll navigation and Escape/outside-click dismissal. Search
matches descriptive names and paths; Enter applies the current result. Add or
drop local files to import private copies into Pictures/Wallpapers. Original
files are preserved, and matching import names never overwrite existing files.

Media selection prepares a cached still poster before running the existing
palette pipeline; only after that succeeds is media identity published. Login,
Hyprlock and previews use the still poster. Video/GIF data and picker preferences
stay private; assets are not part of public Git or software rollback. Static CLI
palette operations remain compatible because the poster is the committed image.
Qt Multimedia with its FFmpeg backend and the ffmpeg utility provide local video
playback. Videos have no audio output and disable their audio track. Playback
pauses on lock/sleep, can pause behind tiled apps, and is shown inside the selected tile while the
picker is open for browsing. Switching to a static wallpaper destroys the player.

Output geometry or pixel-density changes can leave stale Qt/Wayland render
buffers after fractional-scale transitions. DisplayRecovery coalesces actual
screen changes and recreates only the desktop renderer after 700 ms settled.
Visible settings/drawer modes are restored; display confirmation stays available.
The sidebar backend, conversations, accounts and application windows are not
restarted. Recovery carries panel flags, selections, scroll positions and editable drafts
through private state. Password controls and rendered note/message bodies are
excluded. The fallback uses stdin and a private runtime file, not arguments.

Wallpaper presentation: Carousel remains a compact bottom drawer with an odd
number of complete cards and centered controls. Spotlight and Hexagons use the
active screen's available panel area, with a dimmed wallpaper backdrop instead
of an oversized bottom-frame notch. Empty overlay space and Escape dismiss the picker; images and controls consume their own clicks.
The native Qt tests include card-bound checks. Reference screenshots prompted
this presentation; current caelestia-kde main/dev use a different compact QML
PathView, so these expanded views are maintained locally rather than relying on
another wallpaper manager or upstream plugin.

Expanded wallpaper tiles animate position/width; their decode size stays stable
to avoid reloading images during selection. The backdrop holds its previous
loaded buffer until the next is ready and coalesces changes during crossfade.
Closing clips fixed-height content rather than shrinking its internal anchors.

Wallpaper assets use shared private JPEG thumbnails (640px) and larger previews
(1600px), keyed by source path, size, modification time and cache format version.
Carousel, hexagons and Settings use thumbnails; Spotlight and its backdrop use
previews; the actual desktop retains the original wallpaper quality. A low
priority startup worker prepares palette results and per-wallpaper login blurs
without changing the active wallpaper/theme. Completed palette warm markers avoid
repeating the work on renderer recovery. Publication remains owned by the existing
palette bridge, with shell colors published before compatibility/login assets.
The normal carousel uses bounded circular offsets with animated movement and a
complete odd card count. Only visible cards and nearby cached delegates decode.

Prepared palette commits use the same publisher and palette lock as the CLI,
validate roles/mode/flavour, preserve CLI wallpaper identity and fall back to the
CLI for stale/missing caches or custom wallpaper hooks. `presentation.json`
carries the wallpaper poster and palette together. Native Colors waits for the
matching desktop image to be ready before presenting the new colors; late image
acknowledgements cannot activate an older selection. The desktop loads the
original image directly with bounded decode size, avoiding a thumbnail subprocess
for each background change. Cached small tiles decode immediately; Spotlight
uses them beneath its asynchronous large preview. These are event-driven changes,
with no periodic palette/image work; background warmers run once at low priority.
Automatic covered-app pausing stays enabled without a picker button/footer row.



## Quiet preparation and motion policy

One native inotify watcher observes completed writes, moves and removals in the
wallpaper library, plus palette flavour/engine changes. Events are debounced and
queue preparation after catalogue refresh. There is no repeated idle warm-up
process. File identity and the installed engine invalidate prepared palettes.
Hexagon previews retain a viewport buffer rather than decoding distant rows.

Appearance offers Full motion (default), Still on battery and Always still.
The latter two reuse the scene's cached poster and retain its colors, unloading
the desktop video/GIF decoder when motion is disabled. Picker previews remain
available. Covered, locked and sleeping playback guards remain active.


## Independent presentation

NacreWallpaperPicker, NacreWallpaperBackdrop, NacreWallpaperHex and
NacreWallpaperMotion replace the former local view bodies, including mixed/uncertain
implementation rather than certifying it from first creation. The shared backend,
private catalogue, poster/cache/palette publisher and motion preferences keep
ownership. Tests cover smooth intermediate carousel/spotlight positions, layout
switches, filtering/selection, decode cancellation, image-ready retention and
polygon hit areas. Native Quickshell RHI captures assert actual hexagon/rounded
image corner pixels; ordinary Qt geometry fixtures alone do not prove clipping.

A circular travel target keeps carousel wraparound short. Decode sources are
bounded to nearby cards and visible buffered hexagons; ordinary carousel avoids
large backdrop decoding. Silent preview starts only after 180 ms settled selection
and unloads on close/selection changes. Palette-matched motion preferences remain
separate from preview presentation. Backdrop swaps defer to the next event step
and retain old pixels until replacement readiness, including previously cached
buffers whose source URL does not change. Reduced motion skips geometry/crossfade.

## Independent catalogue and selection owner

NacreWallpapers owns the catalogue, browse/commit queues and rotation schedule.
The old Wallpapers name is a compatibility forwarder. Opening the picker or
Appearance reads prepared assets; it does not apply a selection or save a setting.
The catalogue and last poster/media files use native event reads. Invalid refreshes
keep the last usable list. Selection requests coalesce for 150 ms; an already
running publication finishes before the latest queued selection is applied.
Preferences run serially through the existing helper and only confirmed results
update the controls. Errors remain available for retry. Rotation uses the same
queue and preserves its saved deadline across temporary pauses.

Search reuses Nacre's own ranking helper; the unused fuzzysort dependency has been
removed. Wallpaper/cache/palette producer helpers and playback are separate
owners with separate completed source reviews. See the
[provider specification](../specs/wallpaper-weather-services.md).

## Independent desktop background presentation

NacreBackground/WallpaperScene/DesktopVideo replace the remaining background
wrappers and media renderer. Two native poster buffers keep the old image opaque
under the new fade, and only the latest ready image acknowledges the matched
palette record. Native file URLs preserve percent/space names; output size/DPR
sets decode size. Video stays silent and retains its poster until a real frame
arrives; GIF/video follow the existing sleep/lock/battery/coverage/picker policy.
No new palette publisher or polling is added. The shared WallpaperPlayback policy
and helpers have separate source reviews. Old names are small forwarders.

## Visual acceptance

The behavior above describes the implemented contracts and fixture coverage.
The user has reported layout, scrolling and animation regressions after the
rewrite. Those require a separate live visual cleanup after the final originality
audit; these source reviews do not establish that the preferred appearance is
restored.

## Picker spacing and continuous travel

The compact chooser uses a shorter 320px content area and a centered complete
odd-card strip. During movement, partial edge cards remain visible inside the
strip's clip instead of disappearing early. Visible and destination buffers retain
thumbnail sources during rapid travel. Spotlight centers its toolbar, wide gallery
and navigation as one measured group; the hero keeps a broad aspect ratio.
Continuous circular travel drives both position and width, including wraparound.
Wheel packets accumulate before changing selection; empty packets do not move it.
The current output's viewport is supplied by the launcher, avoiding first-output
sizing on other displays. The hexagon grid keeps its existing masked tiles and
uses the shared faster scrolling. Full-screen galleries use a cached wallpaper backdrop and scrim across the entire
viewport, concealing applications without an inset wallpaper rectangle or enclosing
panel. The previous image stays opaque under the incoming fade. Static/Dynamic and layout controls are separated visually and wrap as
groups on narrow outputs. Browsing publishes the selected wallpaper while the
picker stays open through the existing 150ms coalesced, serialized queue; closing
never repeats an already-running selection. Diagnostic preview mode remains
read-only. See the [integration specification](../specs/panel-integration.md).
