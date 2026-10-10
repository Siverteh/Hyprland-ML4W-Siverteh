# Orient 3 and Nacre Colors

User request, 2026-10-10: make wallpaper-derived colors a strong reusable engine,
then expose read-only exploration, comparison and deliberate Apply in an app.
This supersedes Orient 2's poster-only extraction and deferred-app scope.

## Engine contract

`orient` is a plain Python library and CLI, with no Quickshell, Hyprland, Nacre
configuration or publication dependency. The `nacre_shell` package remains a
compatibility/desktop adapter. Keep existing role names, commands, private user
choices, publisher lock, atomic runtime cutover and release rollback.

Extraction uses bounded normalized images and deterministic weighted OKLab
clusters. Coverage stays true pixel area; salience is separately reported from
center weighting, local detail and chroma (heuristics, not object recognition).
Each cluster records coverage, source coordinates, a coarse spatial density map
and salience. Dark/light body pigments come from observed dark/bright populations,
independent of the chosen accent. Crop/frame stability is measured, never claimed
absolutely. Animated inputs aggregate a small fixed frame sample; no frame-time
worker. Unsupported video decoding returns a useful error.

2026-10-10 preference correction: Natural keeps the original diverse observed
accents and restrained accent-tinted surfaces. Source preserves the newer observed
shadow/highlight body policy as a separate explicit choice. Rank aggregated pigment
families, retaining fine clusters and their summed provenance, so brightness shades
do not split one pigment into competing populations. Supporting accents reserve
different real families; pins remain authoritative and neutral scenes invent no hues.

Personalities: Natural default, Source (observed bodies), Harmony (neighboring hues), Pop (salient minority),
Mist, Vivid, Pearl (fixed signature hues), Tide (explicit hour input, optional
mode inference). Overrides and brightness/chroma nudges go through the same
contrast/gamut policy. Format version 1 records engine fingerprint, settings,
source provenance, body sources, roles and a contrast/distinction report.
Preserve semantic terminal red/green; report color-vision simulation results,
with clear labels and warnings when faithful/neutral colors cannot be distinct.
Do not manufacture three 'real' colors from a grayscale wallpaper or claim
simulation guarantees recognition for all people. Guarantee documented opaque
text pairs >=4.5:1; outlines >=3:1. Translucent UI remains consumer-owned.

Use original code and public mathematical specifications, not upstream shell
implementations. References: https://bottosson.github.io/posts/oklab/ ,
https://www.w3.org/TR/WCAG22/ and the published Machado/Oliveira/Fernandes 2009
color-vision model. Retain all current licenses/notices; adding an export interface
is not permission to remove existing attribution or publish a new repository.

## Application

A lazy normal Quickshell window called Nacre Colors uses the existing shell
service, own three-dot glyph under the common shell lip and launcher/CLI entry.
Image/library left, candidate desktop preview right; a compact toolbar selects
personality/mode and Apply. Preview requests never change theme, wallpaper,
preferences, app icons or login artwork. Async responses are generation checked;
newer requests win, previous good preview stays while loading.

Show sampled colors/coverage, highlight coarse source cells on hover, point-pick
an accent, choose/lock main/second/third roles, brightness/chroma controls and
side-by-side personalities. Preview includes bar, window, terminal, notification
and logo, with contrast/vision diagnostics. Favorites/history and per-wallpaper
choices remain private. Export templates generate files into a chosen export
folder; do not edit external applications or install third-party modifications.
Ship example templates for VS Code, Firefox, Obsidian, Neovim, btop, Spotify,
Discord and terminal/desktop formats with documented application requirements.
Palette cards are private output images; never commit user wallpaper payloads.
Browse the library by extracted color. Tide scheduling/workspace presentation
must be opt-in, bounded and use existing state/time/publication owners.

## Verification and release

Own reproducible synthetic artwork/gallery, snapshots and full role diagnostics;
private real-wallpaper visual comparisons, dark/light and every personality,
source/contrast/crop/animated/cache/read-only tests and export format validation.
Gallery changes are explicit reviewed diffs. Native app request/Apply/lifecycle/
resize/input tests; visually inspect real windows. Full tools/check.py,
Hyprland verification, install plan/apply, exact source/IPC/configerrors, preserved
AI worker, managed rollback and exact CI success. Record remaining limitations
rather than promise automatic third-party installation or perfect color vision.
