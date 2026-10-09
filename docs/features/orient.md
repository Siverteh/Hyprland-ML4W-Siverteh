# Orient wallpaper colors

[System overview](../overview.md) · [Implementation spec](../specs/orient.md)

Orient is Nacre's independently implemented wallpaper color engine. Its name
refers to the iridescent play of colors in nacreous pearls:
[GIA pearl quality factors](https://www.gia.edu/pearl-quality-factor).

## How colors are chosen

Images are orientation/profile normalized to sRGB and sampled at a maximum 128px
edge. All color bins within that bounded sample are considered, so minority hues
are not discarded by a popularity cutoff. Related lit/shadow shades form color families. Coverage, chroma, lightness
and spatial spread rank those families; tiny saturated pixels cannot win purely
by being bright. Up to five distinct source candidates are recorded in the palette
JSON. Broad hue families get priority before close variations; subtle colors are
kept separate rather than merged into one gray family. Transparent pixels are coverage-weighted; fully transparent input is rejected.
Neutral photographs retain a restrained warm/cool tint rather than inventing color.

The main decorative `overtone` retains the selected source color. Text/UI accents
change lightness only as needed for readability, preserving hue with OKLCH gamut
mapping. Very dark pigments retain relative color strength when lifted. Body
surfaces have restrained tint, with a dedicated more visible wallpaper-colored
frame role. Normal wallpaper button accents have a comfortable chroma ceiling;
explicit Vivid presets retain their intensity. Subtle real image hues are gently
strengthened so supporting hues stay recognizable. The primary accent leads:
secondary is limited to about 55% of its perceptual chroma, tertiary to 65%.
Their distinct image hues remain, with less visual competition. These limits
also cover dim, container and fixed supporting roles. Bright image highlights
are restrained in supporting fills; readable text still meets
its contrast target. Raw `orient1/2/3` colors remain available for colorful brand
artwork and gradients. ANSI/semantic colors keep their recognizable
meaning. Normal role pairs meet 4.5:1; essential outlines target 3:1. Actual
translucent surfaces still need a contrasting backdrop in their UI implementation.

## Existing controls and optional overrides

Appearance has a **From this wallpaper** row with up to five named color directions.
Each tile previews its main/supporting accents and frame tint. Selection switches
to wallpaper colors and remembers that accent for this image; Match wallpaper
restores automatic selection. Moving to another image uses that image's saved
choice or automatic selection. The fixed-palette section stays separate and its
status explicitly says that colors remain fixed across scene changes.

Appearance's wallpaper/fixed palette choice and light/dark control remain available.
The thirty Soft/Vivid presets are generated through Orient; IDs/preferences remain
stable. Legacy variant names are accepted: neutral/content use a softer policy,
monochrome desaturates the accent, and the other historical names share Orient's
faithful policy. Their names preserve saved configurations, not Material algorithms.
`hard` reduces surface tint; it does not use inherited scheme data.

Advanced optional commands:

```sh
nacre-shell wallpaper -p /path/to/image.png
nacre-shell scheme set --accent ff3030
nacre-shell scheme set --auto-accent
```

The print command reports colors and candidates without applying them. An explicit
accent is saved per resolved poster/image path in private `cli.json` and survives
mode changes; auto-accent removes that override. The same per-image choices are available in Appearance.
Saved explicit light/dark mode wins over automatic image mode. Without a saved
mode, automatic mode uses weighted sampled lightness (light at 0.68 or above).
GIF/video colors come from the prepared poster and remain stable during playback.

## Caching, publication and recovery

Versioned caches include image file identity, engine-code fingerprint, mode,
variant/flavor and accent settings. Warm reads skip decoding/extraction. Prepared
wallpaper cache keys also include these settings and the installed build identity;
mode/variant/override changes trigger existing debounced preparation. There are
no idle timers or independent wallpaper/theme processes.

The existing locked publisher updates matched image/palette presentation, GTK/Qt,
terminal, borders and lock/login assets. Shell image/colors begin together when the
new image is ready; other processes can refresh asynchronously. Query commands
no longer invoke publication. Unsupported/invalid images leave the active theme
untouched and report a useful error.

Provisioning selects a freshly tested, immutable environment under private
`palette-engines/` through `palette-runtime`. Old environments are retained; release
snapshots copy runtime bytes so rollback does not depend on an old symlink target.
Do not delete historical environments until recovery references have been reviewed.
Image assets and palette caches remain private, outside Git/release snapshots.

Only the palette implementation is replaced. Existing GPL/notices remain pending
review of the rest of the desktop; other inherited shell code is unchanged.

## Validation measurements

On the current laptop, the 2026-10-08 private audit covered all twenty library
wallpapers/posters. Across 240 repeated uncached extraction/generation operations
(including decoding, warm OS file cache), median was 74.84ms and nearest-rank p95
92.98ms. Across 240 cached reads, median was 0.30ms and p95 0.34ms. The audit
process peaked at 122.4MiB including its inspection sheet on an ASUS UX3405CA
with Intel Core Ultra 7 255H; these figures are not
end-to-end desktop publication latency or a guarantee for larger inputs. Synthetic
fixtures check hue distinction, transparency/profile handling, safety limits,
cache invalidation, all required roles, contrast and read-only behavior.
