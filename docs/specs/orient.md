# Orient: independent wallpaper palette engine

Status: production implementation in progress. Date: 2026-10-08. Owner: Nacre.
The user explicitly requested direct production implementation on 2026-10-08,
superseding the separate prototype and pre-integration user-review milestones.
Synthetic tests, private wallpaper inspection, measurements and deployment gates
remain required; no standalone comparison product is being built.

[Rewrite plan and provenance](../nacre/PROVENANCE.md) ·
[Prototype specification](orient-comparison.md) · [System overview](../overview.md)

## Purpose and scope

Orient turns an image or an explicit color into a complete, readable light/dark
palette. Wallpaper accents should resemble the colors people see in the image:
red should not become pink merely because a decorative accent shares a text role.
The current red-to-pink report is a user observation, not a measured diagnosis.

The first replacement covers the inherited implementation in `nacre/shell-cli/`,
its palette dependencies, default scheme data and preset generation interface.
It preserves the existing desktop publisher, wallpaper library, poster generation,
rotation, synchronized rendering and caching behavior. Those helpers require
separate provenance review; retaining them does not certify their independence.

No new wallpaper daemon, idle polling, AI behavior, path migration, package update
policy or UI redesign belongs in this task. No license or NOTICE is removed here.

## Independent implementation process

Use this behavior specification, consumer contracts, tests and primary color
science references. Do not consult, copy, translate or restructure Caelestia or
ML4W implementation files when writing the replacement. Existing local derived
files count as inherited sources too. Reading their implementation is unnecessary.
Existing CLI help and generated output may be captured as black-box compatibility
fixtures. Keep the baseline executable separate from the new engine.

A spec-based rewrite is not by itself a provenance guarantee. Record each new
file's implementation origin and dependency licenses. Review behavior tests for
copied implementation detail; preserve useful assertions without copying old code.
Do not remove the working implementation until the candidate passes its gates.

## Color vocabulary

| Token family | Meaning | Requirement |
|---|---|---|
| Body | Background sheets, raised surfaces and their text | Restrained wallpaper tint; visible hierarchy in light and dark modes |
| Overtone | Recognizable main accent and interaction emphasis | Track the selected image color; distinguish decorative from readable text variants |
| Orient | Two or three related colors for future edges/gradients | Prefer real distinct image candidates; a single-color image need not invent extra hues |
| Semantic | Success, warning and error | Stable meaning, readable pairs, and non-color cues in UI consumers |

These describe palette roles, not a commitment to literal shell shapes, animated
shimmer, transparency or a final icon/font choice. Existing role names remain an
adapter boundary while inherited UI components are replaced.

## Input and extraction

- Accept local still images supported by the maintained image decoder. Videos/GIFs
  use the existing prepared poster; never extract continuously from playback.
- Normalize EXIF orientation and supported embedded color profiles to sRGB before
  sampling. Document handling of missing/invalid profiles and unsupported HDR;
  do not silently interpret every tagged image as untagged RGB.
- Bound decode size and sample count. Treat decompression-bomb warnings as errors.
  Transparent pixels contribute according to coverage; fully transparent pixels
  must not invent a dominant color. Do not stretch the image for sampling.
- Select a small set of perceptually distinct candidates using image coverage,
  saturation, lightness and spatial distribution. A tiny neon detail must not
  win solely because it is saturated; a dark background must not always win solely
  because it covers most pixels. Record why the chosen candidate wins.
- Proposed analysis space: OKLab/OKLCH, separating lightness, chroma (color strength)
  and hue (color family). The implementation settings below define the first release;
  subsequent tuning must retain fixtures and measured behavior.
- Return up to five useful candidates, ordered deterministically. Do not fabricate
  five distinct choices from a monochrome image. Near-neutral colors have no
  meaningful hue and must be treated accordingly.
- An explicit accent choice overrides automatic selection and is stable across
  modes. Selection belongs to the image identity/settings, not a fragile cluster
  index. Persisting choices in Settings is a later integration step.
- A grayscale image gets restrained neutral roles and a documented default accent;
  it must not produce random saturated colors. Invalid input returns an error and
  leaves active state untouched.

## Palette generation

1. Produce both light and dark palettes from the same selected source candidate.
2. Preserve its hue where possible. Map out-of-gamut colors into sRGB by reducing
   chroma before deliberately changing hue. Numerical hue preservation does not
   guarantee identical perceived hue, especially for some blues.
3. Separate rich decorative accents from text accents. Do not impose a text
   contrast requirement on every decorative swatch and wash the entire theme out.
4. Ensure normal text/background pairs reach at least 4.5:1 contrast and essential
   control/focus boundaries reach at least 3:1 against adjacent surfaces. Audit
   actual role use, including `primary` used as text against `surfaceContainer`;
   decorative tokens cannot bypass existing consumers' readability requirements.
5. Adjust foreground choice or role lightness first when needed; keep reported
   adjustments so a faithful color and an accessible text variant are explainable.
6. Provide subdued body surfaces and differentiated elevation roles. Avoid strong
   global color casts and arbitrary complementary colors on mostly single-hue art.
7. Supply every legacy role required by consumers through a documented mapping.
   Compatibility keys are an output format, not permission to recreate the old
   generation algorithm. Generate fixed palettes through the same engine.

Use relative sRGB luminance for contrast tests, not OKLCH lightness. For translucent
UI, test against effective composited backgrounds; the opaque palette alone
cannot establish contrast over arbitrary wallpapers. Consumers need an opaque or
stronger-backdrop fallback where necessary.

Hue/saturation tolerances are recorded in the implementation decisions below
and tested on saturated fixtures. A numerical test alone cannot
prove that the user's red wallpaper looks right.

## Compatibility boundary

The executable/package names remain `nacre_shell` for this first replacement.
Orient is the engine name; changing public commands is a separate decision.

Confirmed consumer contracts:

- `nacre_shell wallpaper -p PATH` emits one palette JSON document to stdout,
  without changing the current wallpaper or active theme. Diagnostics use stderr.
- JSON includes `name: "dynamic"`, `mode: "light" | "dark"`, `flavour`, `variant`
  and `colours`. Flavor and variant remain short identifier strings accepted by
  the publisher. Colors are six-digit sRGB hex strings; canonical output is
  lowercase without `#`, even though the publisher accepts either representation.
- Preserve the required role set consumed by `classic-state.py`, native QML and
  fixed presets. Capture the complete key list as a contract fixture before
  implementation; do not reuse the inherited default color values as new defaults.
- Preserve `scheme list/get/set` and wallpaper file/random/filter/smart-mode
  options used by maintained callers. Before replacement, inventory actual calls,
  capture their help/exit codes and verify behavior in an isolated fake home.
  Unsupported legacy flavor settings require an explicit mapping or clear error;
  do not silently discard saved preferences.
- Preserve private `scheme.json`, `scheme/current.txt` and wallpaper identity
  outputs expected by maintained consumers. Preserve `cli.json` configuration and
  existing post-hook behavior; hooks are never executed by read-only comparison.
- `presentation.json` stays owned by the existing publisher. Do not introduce a
  second publication path or bypass `palette-commit.lock`.
- Regenerate all thirty fixed presets in their existing schema with reproducibility
  tests. New palette values may change; preset identifiers and light/dark support
  remain stable. Replace `reference-style.json` values with an independent Nacre
  seed while preserving its required schema.

Contract capture must also enumerate real text/background pairs and adjacent
focus/control surfaces; a role-key list alone is not a readability audit. Record
current smart-mode decisions separately from proposed Orient thresholds. Preserve
saved explicit light/dark mode; any changed automatic-mode policy needs review.

Exact option semantics and complete role fixtures are a prototype preparation
gate, not an assertion that this document already enumerates every CLI behavior.

## Cache and publication

Key generated palettes by image content identity, normalization policy, engine
version, mode, accent choice and all generation settings. Fast file identity checks
may reuse a stored digest; unchanged selections must not rehash large videos.
Version the new cache separately so old Material results cannot masquerade as
Orient output. Fixed presets bypass image extraction.

Preserve the existing debounced, low-priority preparation worker and serialized
publisher. Read-only generation must not acquire a publication lock or change the
active theme. On cold cache, generate once; on warm cache, reuse validated results.
Corrupt caches are discarded and recomputed. Failed generation retains the last
good theme and image, with a useful error.

Publish poster identity and palette as the existing matched presentation. The shell
holds the old image until the new one is ready and begins both transitions in the
same rendering step. GTK/Qt/external apps may refresh asynchronously; do not promise
frame-perfect cross-process updates. Rapid A→B→C selections must not allow a late
A result to overwrite C. Preserve custom-hook handling and existing rollback.

## Performance and battery

- No periodic color extraction, per-frame analysis, GPU compute service or idle
  subprocess launches. Work happens on import, invalidation or selection.
- Compare engine-only time, preparation, publication and visible transition
  separately; one total cannot explain a slow result.
- Prototype targets on the current laptop: engine-only cold generation p95 below
  500 ms on bounded samples from the review set; warm palette lookup p95 below
  20 ms. These are targets, not measured promises. Report image decode and process
  startup separately, hardware details and repeat count.
- Bound worker concurrency to one and measure peak memory. Set a justified memory
  limit after measurement rather than claiming zero cost. Repeated warm selections
  must not launch extraction or regenerate lock/login images.

## Test and acceptance gates

Synthetic, redistributable fixtures cover red/orange/magenta distinction, saturated
blue and green, mixed-color area ratios, grayscale, near-black/white, transparent
images, orientation/profile handling and malformed/oversized input. Cover gamut
limits, all foreground pairs, deterministic output, candidate override, cache
invalidation, preset reproducibility and invalid-state preservation.

Private visual review uses at least twelve user-selected wallpapers with a recorded
reason for each, including problematic red images. Keep copyrighted wallpaper
files, paths, names and generated personal reports outside public Git.

Integration must retain prepared commits, fixed palette mode, rotation, dynamic
posters, rapid-selection ordering, cold-cache fallback and matched image/color
presentation. Inspect shell, Settings previews, GTK/Thunar, Qt, Kitty, Hyprland
borders, Hyprlock and prepared login assets for legibility and color consistency.
Do not restart SDDM or lock an unsaved session just to create a screenshot.

## Milestones and definition of done

1. **Contract capture:** fixture key list, CLI behavior matrix, selected private
   images and current engine baseline. No active state changes.
2. **Prototype:** independent extraction/generation and local comparison report;
   synthetic tests and measurements pass. The old engine remains active.
3. **Visual review:** user chooses/tunes results; freeze scoring settings, hue
   tolerances and independent seed. Record accepted/rejected candidate examples
   and surface samples, numeric tint limits, the contrast pair matrix, automatic
   mode policy and a measured memory ceiling. Performance targets become blocking
   integration gates unless a documented user-reviewed tradeoff changes them.
   Disagreements remain recorded, not hidden.
4. **Integration:** replace inherited palette implementation, adapt provisioning,
   preset generator/imports and cache fingerprinting, preserve publication owner.
   Audit removed sources and dependency notices.
5. **Deployment:** full checks, Hyprland verification, install plan then apply,
   native IPC/source checks and configerrors; keep a known-good release. Stop on a
   failed gate and report. A rollback must restore the old engine/cache reader too.

Done means reviewed results, all contracts/tests passing, successful live deployment
and a provenance entry with replacement commit and remaining attribution. It does
not mean that the rest of Nacre is independent or that its final license is chosen.

## References and unresolved choices

[W3C CSS Color 4](https://www.w3.org/TR/css-color-4/) documents OKLab/OKLCH,
color-profile handling and gamut mapping. Any adopted code/library requires its
own license review; citing a formula is not an implementation-origin record.
[WCAG contrast requirements](https://www.w3.org/TR/WCAG22/#contrast-minimum) inform
readability targets. These references do not prescribe Nacre's visual design.

Resolve through prototype review: candidate scoring, acceptable hue deviation,
surface tint strength, faithful versus softer option, default neutral accent,
automatic mode thresholds and whether an existing maintained color library or
small independently written conversion module best fits performance/maintenance.
No new Settings controls are authorized solely by this specification.

## Production decisions (2026-10-08)

The direct implementation supersedes the prototype workflow above, which remains
as planning history. No separate comparison UI or approval pause is required.

- Analysis: 128px longest edge; weighted RGB bins, up to 192 converted bins;
  merge related pigment families within 16° hue / 0.12 chroma / 0.36 lightness.
  Candidate minimum visible coverage 0.8%, chroma 0.025; distinct candidates
  separated by 24° hue. Coverage exponent 0.65 plus bounded chroma/lightness/spread
  factors. Lit pigment contributes more to its family's representative color, but
  not to its population. Neutral fallback retains a limited image tint.
- Body chroma is at most 0.016, hard flavor halves tint. Dark surfaces span
  OKLCH L=0.115–0.27. Rich dark pigment is lifted to L≥0.60 with relative chroma
  scaling capped at 1.8×; gamut mapping and contrast checks finish the adjustment.
- Saturated solid-fixture source/primary hue deviation below 2°; dark red primary
  HSV saturation above 0.65. Existing twelve Vivid/Soft counterpart saturation and
  all thirty preset contrast/reproducibility tests remain in force.
- Tests enumerate legacy role vocabulary in `tests/orient-roles.json` and audit
  primary/secondary/tertiary/onSurface/onSurfaceVariant against all representative
  body backgrounds, plus semantic/container pairs, inverse text and focus outline.
- Engine code fingerprint invalidates caches during patching. Normal cache keys
  use path/device/inode/size/mtime/ctime plus mode/variant/flavor/override; image
  content digest is recorded once during cold generation. Warm reads do not rehash.
- Existing saved palette mode wins. Image inference is light for weighted sampled
  OKLab lightness ≥0.68 only without saved/explicit mode; this is Nacre policy,
  not a claim to reproduce Material smart-mode algorithms.
- Historical expressive/fidelity/fruitsalad/rainbow/vibrant/tonalspot names map to
  the faithful policy. Neutral/content are softer; monochrome desaturates accents.
  Compatibility preserves names and saved settings, not inherited algorithms.
- Read-only queries skip publication. Per-image explicit accents are an optional
  CLI/config capability; Settings controls are unchanged.
- Current-library engine target: cold p95 <500ms, warm p95 <20ms; no idle worker or
  per-frame extraction. Input safety cap 50MP. Peak-process target for the current
  library is <256MiB; larger supported files remain subject to decoder cost.
- Runtime builds are fresh and immutable, tested before an atomic runtime link
  selection. Release capture backs up runtime bytes rather than only its link.

Complete production acceptance requires the deployment evidence recorded in the
provenance tracker; these decisions alone do not mark a live release verified.
