# Orient and Nacre Colors

Open **Nacre Colors** in the launcher or run `nacre-colors [image]`. Settings →
Appearance has an entry point. Opening, browsing, hovering, picking, pinning and
comparing colors change only the preview. **Apply** changes the wallpaper and
palette through the existing locked publisher. Ctrl+Enter applies, Ctrl+F searches,
Ctrl+W/Escape closes. The normal window is resizable, and repeated launches focus
one instance. Its header has no window-control buttons; use Super+Q for the desktop
window action or Ctrl+W/Escape to close. Closing does not stop an already requested
Apply/export action.

## Personalities

| Mode | Intent |
|---|---|
| Natural (default) | Distinct real image families; restrained backgrounds tinted toward the chosen accent, as in the original Natural |
| Harmony | Neighboring hues around the main family, with lightness separation |
| Pop | A small, contrasting pigment family becomes the main accent: the striking detail |
| Mist | Soft, nearly neutral accents and body |
| Vivid | Stronger source chroma, bounded by gamut and readability |
| Pearl | Nacre's consistent pink/lilac/mint signature on neutral surfaces |
| Tide | Cooler daytime and warmer evening body tint; explicit preview hour, optional follow-time and light/dark |

**Background from wallpaper** is a separate preview switch. On uses sampled shadow
and highlight tones; off uses a restrained accent tint. It does not choose new
accent sources. Pearl always keeps neutral signature surfaces; Tide keeps its
time-based body tint. The switch is remembered per wallpaper on Apply and included
in cache identities, saved choices, history and published metadata. Old Source
choices normalize to Natural with the switch on; old snapshots/favorites keep
their captured colors. Natural defaults off; older other-mode choices retain their
previous sampled-background policy unless explicitly changed.

Pop selects from aggregated families, with at least48° hue separation from the
Natural main pigment, 0.4–15% coverage, and at most65% of the main family’s coverage.
Bounded salience, chroma and hue contrast rank eligible details. A broad desert
background cannot beat a small sign merely by its area. Pinned accents win; if no
suitable contrasting detail exists, Pop retains the main source rather than
inventing a new hue.

Brightness/saturation and three pinned accent sources are remembered per wallpaper
on Apply. Drag a sampled swatch onto a role or use Pin color. Click a point in the
image to pick an accent. A highlight shows sampled source cells, not an AI object
label. Animated sources combine four fixed frame samples; overlays show their
combined spatial coverage. No extraction runs on every playback frame. Scheme
refreshes and managed runtime deployments resolve a cached poster back to its
current animation source, so the live palette agrees with the multi-frame preview.

Favorites store dark and light versions and can be used with another wallpaper.
History keeps the last20 applications. The color filter uses prepared library
families; a cold library gradually gains families through the existing nice19
worker. Private choices, staged previews and artwork stay outside Git.

Tide's optional automatic mode uses local06:00–19:00 as daytime, not astronomical
sunrise/sunset. Following time reacts to the existing clock's hour signal; it adds
no polling process. Workspace colors are opt-in and color the numbered chips
without changing the entire desktop on workspace switches.

## Accessibility and fidelity

Light-mode UI accents start in a middle-lightness band (OKLab L0.52–0.58),
retaining source hue/chroma before gamut and contrast correction. Pale yellow,
peach and cream accents receive a bounded chroma boost so their middle tones keep
more warmth; source colors remain untouched. Shadow pigments
no longer stay near black. Neutral accents use three spaced gray levels. The
source colors/provenance remain original; audited colored text still meets4.5:1,
so especially luminous hues can require a darker final tone. Light backgrounds
and dark-mode role colors are unchanged by this correction. Light-mode color-vision
diagnostics report close chromatic pairs instead of progressively darkening them.

Color personalities and Light/Dark appear on separate toolbar rows with a divider.
Studio previews a bar, window, terminal, notification and logo. Compare shows all
personalities. Accessibility provides a contrast grid and approximate full-severity
protanopia/deuteranopia/tritanopia simulations. The engine validates its documented
opaque text pairs at4.5:1 and essential outlines at3:1. Simulations are estimates;
labels and shapes remain necessary. Pinned/neutral colors may remain too close,
in which case the report explains the limitation rather than inventing source
colors or changing a pin. Transparency and arbitrary third-party app usage cannot
be guaranteed by an opaque palette alone.

Fine shade clusters are aggregated into pigment families before ranking, so shaded
rock counts as one population rather than losing to an unfragmented sky. Family
coverage and spatial maps sum the original clusters; representatives favor lit
pigment. Candidate options reserve room for different families before nearby hues.
Natural retains real supporting families rather than filling roles with shades of
the main color. Single-family/neutral images still use tonal fallbacks.

Clustering uses perceptual OKLab distance with a chroma-adaptive tolerance. Center,
local detail and chroma affect bounded salience; true coverage is kept separate.
This is a heuristic, not semantic image recognition. Cropping and scene changes
can legitimately change a palette; a stable sampling policy/cache and regression
fixtures reduce unwanted flips, without claiming absolute crop invariance.

## Portable engine and format

`orient palette IMAGE --personality natural --mode dark` prints schema-version1
JSON. Add `--background-from-wallpaper` or `--no-background-from-wallpaper` to
choose body policy independently. `orient analyze IMAGE`, `orient sample IMAGE X Y`, and
`orient export PALETTE_JSON OUTPUT_DIR [--templates DIR]` are read-only commands.
The library under `nacre/shell-cli/src/orient` imports no Nacre, Qt or Hyprland
publisher. The legacy `nacre_shell` package is a desktop adapter. A later standalone
repository/package can extract the core, templates, tests, chosen license and
attribution; this task does not publish that new package or remove notices.

Palette JSON includes `formatVersion`, engine fingerprint, `input`, `colours`,
source candidates/body populations, coverage/location/regions, per-role provenance
and accessibility results. Existing compatibility role names/variant fields remain
stable. Generated contrast colors explicitly have no sampled original; semantic
terminal colors preserve their roles. Cache identities include source stat,
normalization/engine policy and settings. Palette and analysis caches are separate.

## Matugen color-template compatibility

Orient reads its own `{{primary}}` tokens and Matugen expressions such as
`{{ colors.primary.default.hex }}` and `{{ colors.on_surface.light.rgb }}`.
Snake-case role names map to Orient roles; `source_color` maps to the source accent.
Supported formats: hex, hex_stripped, hex_alpha, rgb, rgba, hsl, hsla, red, green, blue, alpha,
hue, saturation and lightness. CSS rgba/hsla uses opaque alpha1.0, numeric alpha255.
`mode`, `is_dark_mode`, `image` and flat `custom.NAME` keywords are available.
An escaped `\{{ token }}` stays literal. Older `colors.ROLE.FORMAT` uses the active
scheme. Explicit light/dark tokens use the requested scheme, never the active one
as a silent substitute. For image palettes from the current engine, an unchanged source can prepare the
opposite mode on demand; supplied companions and captured favorite modes take
precedence. No additional extraction runs while idle.

```sh
orient render palette.json existing-template.css > theme.css
orient render palette.json existing-template.conf --companion light.json --variables variables.json
```

The render command accepts ordinary template filenames without renaming to `.in`.
Colors custom export templates still live in `~/.config/nacre/colors-templates`
with `.in` suffix. Built-in Orient tokens and exports retain their existing behavior.
Map loops and chained filters work with existing templates:

```text
<* for name, value in colors *>
--{{name | replace: "_", "-"}}: {{value.default.hex}};
<* endfor *>
{{colors.primary.default.rgba | set_alpha: 0.2}}
{{colors.secondary.default.hex | lighten: 10 | saturate: 15, "hsl"}}
```

The loop emits the supplied UI roles in stable snake-case order, including
`source_color`, excluding Orient's terminal/toolkit aliases. Loop variable names
are freely chosen, scoped, and can request explicit dark/light companion colors.
Filters: `set_alpha` sets opacity (0–1) for rgba/hsla/hex_alpha; `lighten` adds HSL
lightness percentage points (negative darkens); `auto_lightness` adds on dark
colors and subtracts on light ones. `saturate` adds saturation percentage points
in HSL (default) or HSV; quoted and bare hsl/hsv selectors work. `replace` replaces
all literal matches with a quoted string. Filter chains retain alpha and output
format; channels clamp to their legal range. `set_lightness` is also accepted and
sets absolute HSL lightness (0–100), following the current public Matugen contract.
`hex_alpha` uses eight hex digits including opacity. String literals and quoted
commas/pipes in filter arguments are supported without evaluating code.

Comma-safe JSON loops use `loop.last` or `loop.first` boolean conditions:

```text
[<* for name, value in colors *>"{{value.default.hex}}"<* if {{loop.last}} *><* else *>,<* endif *><* endfor *>]
```

`if`/`else`/`endif` accept boolean loop metadata or `is_dark_mode`; nested loops
restore the outer loop's metadata. Map loops also work over `palettes`, `base16`
and maps bound by an outer loop. `palettes` exports six Orient hue/chroma families
(primary, secondary, tertiary, neutral, neutral_variant, error), each with `_0`
through `_100` shades from Orient's existing OKLCH gamut mapper. These shades are
Orient lightness steps, not Matugen HCT tones. `base16.base00` through `base0f`
map existing surfaces/foreground and semantic red/orange/yellow/green/cyan/blue/
purple roles to the public Base16 meanings, with small foreground interpolations.
Each base16 value has genuine default/dark/light context just like UI colors.
The desktop palette and extraction engine do not change. Extra maps generate
only when a template requests them, without idle processing or publication.

This is template-format compatibility, not the full Matugen script runtime.
Includes, numeric ranges, arithmetic, custom color objects and arbitrary
expressions still fail clearly. Input is bounded to 1 MiB, output to 8 MiB and
expansion to 100000 operations/four nested loops/sixteen block levels. No hooks,
external commands or Matugen configuration output paths run. Unsupported templates
fail before export creates files. Isolated filter comparisons on2026-10-10 matched
77 expressions byte-for-byte against Matugen4.2.0. All68 template files containing
expressions in the [official collection](https://github.com/InioX/matugen-themes)
at707c7b7d3550c9c21c0a8d72186748b1d205b88b now render, including the complete
Quickshell JSON (validated) and Neovim base16 template. This measures rendering,
not application reload support or bit-identical color generation. Upstream
templates/binary were private test inputs, not copied into Orient source.
References: [tokens](https://github.com/InioX/matugen/wiki/Configuration),
[grammar](https://github.com/InioX/matugen/wiki/Templates),
[filter reference](https://github.com/InioX/matugen/wiki/Filters) and
[Base16 roles](https://github.com/chriskempson/base16/blob/main/styling.md).

## Export and sharing

Export writes a new folder under `~/Documents/Nacre Colors`. It includes palette
JSON and original templates for VS Code, Firefox, Obsidian, Neovim, btop,
Kitty/Foot/Alacritty, GTK, rofi, Hyprland and optional Spotify/Discord adapters.
It never edits those applications or installs modifications. Firefox distribution
requires signing; Spotify needs optional Spicetify and Discord a user-theme client.
The generated README gives application instructions. Add `.in` templates under
`~/.config/nacre/colors-templates`; `{{primary}}` and other role tokens substitute
validated six-digit hex. Unknown tokens and replacing existing files are errors. Matugen color expressions
work in these templates too.
Palette cards include the image thumbnail/colors and “Made with Nacre”; cards are
private output files, with no automatic upload or publication.

Nacre's own GTK/Kitty/rofi/Hyprland outputs are templates too, rendered by Orient's
pure substitution helper inside the one existing publisher.

## Gallery and checks

`nacre/shell-tools/tests/orient-gallery` contains six CC0 procedural images, a
four-frame animation, its generator and all14personality/mode snapshots plus both Natural sampled-background snapshots
per image.
Regenerate explicitly with `generate.py` and `snapshot.py`; changing snapshots is
a reviewed palette change. The generator does not use private commercial artwork.
Before/after rendered sheets and real-wallpaper screenshots stay in temporary QA
paths, not shipped assets. Tests cover full contrast, source bodies/provenance,
subtle families, small crops, frames, exports, read-only previews, stale rejection,
favorites, fake-home Apply and the newline worker protocol/native view.

References: [OKLab definition](https://bottosson.github.io/posts/oklab/),
[WCAG contrast](https://www.w3.org/TR/WCAG22/#contrast-minimum),
[use of color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html),
[Machado/Oliveira/Fernandes model](https://profs.ic.uff.br/~laffernandes/content/publications/journal/2009_tvcg_15%286%29/machado_oliveira_fernandes-tvcg-15%286%29-2009-corrected.pdf),
[VS Code themes](https://code.visualstudio.com/api/extension-guides/color-theme),
[Firefox theme format](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/theme).
