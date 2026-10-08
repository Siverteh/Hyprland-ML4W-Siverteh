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
screen changes and recreates only the desktop renderer after700ms settled.
Visible settings/drawer modes are restored; display confirmation stays available.
The sidebar backend, conversations, accounts and application windows are not
restarted. Only UI visibility flags are handed off, never draft or password text.

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
The normal carousel uses a bounded PathView with animated movement, complete odd
card count and two nearby cached delegates rather than swapping a row's images.

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


