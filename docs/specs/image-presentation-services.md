# Native images and matched presentation ownership

2026-10-09. Runtime inventory finds Thumbnailer referenced only by NacreImage;
NacreImage has only its CachingImage adapter and tests as callers. Maintained
wallpaper/album/notification views use prepared wallpaper assets or native Image.
Do not introduce another file-thumbnail pipeline for a dead service.

## Source boundary

Retire inherited Thumbnailer without reading its body; replace the already-owned
NacreImage thumbnail dependency with native Qt Image behavior. Keep CachingImage
as a thin own compatibility alias. Delete ThemePresentation body before fresh
NacrePresentation from public accept/activate/pending/active contract, existing
consumer/runtime/tests and publisher JSON schema. Prior turns inspected the small
provider schema/body; no upstream source consulted, no clean-room legal claim.
Applicable notices remain and actual wallpaper cache/producer provenance is separate.

## Images

Native asynchronous Image with retained pixels during valid loading, native cache,
DPI-sized decoding, original-size option, and50ms coalesced resize/path requests.
Accept local paths/file URLs and native image/qrc/HTTP sources without turning
remote URLs into file paths. No new downloads/commands/cache directories or jobs.
Clearing/failed requests remove obsolete pixels and expose bounded error state.
Current source/dimensions, no stale destroyed thumbnail handles. Old ready/path/
loadOriginal/image contracts remain where maintained; obsolete Thumbnailer and
handle-specific tests are removed, replaced by actual image decode/error/resize
checks. Prepared wallpaper caches remain unchanged.

## Presentation

One native watched presentation.json reader. Validate mode, canonical local poster,
complete hex role schema and optional metadata before changing pending/active.
Deep-copy accepted JSON to prevent later caller mutation. Invalid or malformed
file keeps last valid state with bounded diagnostic error, no file overwrite.
First record and same-poster colour changes commit immediately as before. A new
poster is pending until the actual wallpaper reports ready via activate(poster).
Only the current pending poster can activate; stale readiness cannot change state.
Canonicalize file URLs without corrupting literal percent characters in raw paths.
Preserve paletteOptions/selectedAccent/changedAtMs and other compatible metadata;
never treat photo timestamp as an ordering token for colour-only changes. No new
palette generator, wallpaper writer/rotation/filter/selection owner or polling.
Keep ThemePresentation as own forwarding adapter; maintained callers use
NacrePresentation. Native read-only diagnostics omit image paths/artwork/metadata.

## Acceptance

Retained actual wallpaper/layout/cache/rotation/palette/foundation tests. New native
Qt image decode/clearing/failure/coalescing/size/original tests and presentation
mode/schema/clone/bootstrap/same-poster/pending/stale-readiness/URL/error tests.
Native read-only probe/current pair comparison, full checks/target Hyprland,
plan/apply strict release/source/IPC/Escape gates, actual picker and Settings
preview/indicator/tab input. Native image-error warnings handled narrowly in
fixtures, never suppress other runtime faults. Keep actual wallpaper/preferences/
history/device/accounts unchanged; do not create another thumbnail directory or
change artwork. Public release/license/other providers/helper audit remain pending.
