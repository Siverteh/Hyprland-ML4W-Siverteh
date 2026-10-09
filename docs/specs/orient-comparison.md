# Orient palette comparison prototype

Status: specification; tool not implemented. [Engine spec](orient.md).

## Deliverable

A local, read-only report comparing the current installed engine with independent
Orient results. No hosted service, new desktop daemon or tournament is required.
Use a standalone HTML report with local relative assets, accessible keyboard
controls and a JSON measurement sidecar. It must work offline, without analytics,
remote fonts, CDNs or publishing any user wallpaper.

## Preparation

Capture current CLI help and generated-output contracts as black-box evidence.
Run the baseline in an isolated fake home and verify that print mode has no active
state side effects. Use a separately installed baseline executable; the candidate
must not import the old package or call it to implement its own colors.

Choose at least twelve private examples: two visibly red/problematic wallpapers,
one orange, one magenta, saturated blue, green, grayscale, very dark, very light,
mixed-color art and two dynamic posters. One image may cover multiple categories,
but the total remains twelve. Ask for feedback on the actual images rather than
assuming titles identify their dominant colors. Artwork and reports stay in a
private local directory. Public test fixtures are synthetic or clearly licensed.

## Report layout and controls

Show the same wallpaper thumbnail above current and proposed palettes, in both
light and dark mode. Include a miniature surface/text/button/focus sample, raw
swatches, selected source color, alternative candidates, extraction rationale,
contrast failures and generation timing. Label the baseline engine/version.

Candidate selection changes only the proposed preview. Keep a reset-to-automatic
control. Compare decorative accents with text accents separately. Feedback records
image identity, chosen candidate, preferred result and a plain-language reason.
Do not change system settings, write active palette paths or run custom hooks.

All report images stay beneath its output directory; copy only bounded previews,
not wallpaper originals. Do not embed absolute personal paths in distributable
fixtures. Escape filenames/labels in HTML; reject remote input URLs. Write outputs
to a chosen new directory, refuse accidental overwrites and never delete originals.

## Measurements and tests

Measure normalization/decode, extraction, generation, baseline subprocess startup
and warm lookup separately using a monotonic clock. Record CPU/hardware, image
sizes, engine versions, sample limits and at least twenty measured repetitions
per representative category after warm-up. Cold generation means no prepared
palette cache but an already available local input; distinguish OS page cache
and decoder warm-up from palette cache state. Warm lookup uses a validated
prepared entry. State whether each sample includes process startup, and calculate
p95 by nearest rank (sorted sample at ceil(0.95 × count)). Report medians/p95, peak memory and
missing measurements honestly. No actual desktop transition latency is measured
by this report; live presentation testing belongs to integration.

Test output determinism, supported mode/candidate controls, path and label safety,
no network dependencies, no active-state writes and contrast reporting. Read-only
comparison failures must be visible per image, without disguising them as a
fallback success. A baseline failure must not prevent viewing candidate results.

## Exit gate

The report explains whether red-to-pink comes from source selection, role conversion
or both, with image-specific evidence. The user reviews the actual comparison and
selects the desired direction. Record scoring/tint decisions and numeric fixture
tolerances in the engine spec before integration. Until then, the existing desktop
continues using its current engine and no production palette files are replaced.
