# Orient and Nacre Colors

Open **Nacre Colors** in the launcher or run `nacre-colors [image]`. Settings →
Appearance has an entry point. Opening, browsing, hovering, picking, pinning and
comparing colors change only the preview. **Apply** changes the wallpaper and
palette through the existing locked publisher. Ctrl+Enter applies, Ctrl+F searches,
Ctrl+W/Escape closes. The normal window is resizable, and repeated launches focus
one instance. Closing does not stop an already requested Apply/export action.

## Personalities

| Mode | Intent |
|---|---|
| Natural (default) | Image pigments with their real sampled coverage; backgrounds use observed shadow/highlight families |
| Harmony | Neighboring hues around the main family, with lightness separation |
| Pop | A substantial, saturated minority becomes the accent; body stays calm |
| Mist | Soft, nearly neutral accents and body |
| Vivid | Stronger source chroma, bounded by gamut and readability |
| Pearl | Nacre's consistent pink/lilac/mint signature on neutral surfaces |
| Tide | Cooler daytime and warmer evening body tint; explicit preview hour, optional follow-time and light/dark |

Brightness/saturation and three pinned accent sources are remembered per wallpaper
on Apply. Drag a sampled swatch onto a role or use Pin color. Click a point in the
image to pick an accent. A highlight shows sampled source cells, not an AI object
label. Animated sources combine four fixed frame samples; overlays show their
combined spatial coverage. No extraction runs on every playback frame.

Favorites store dark and light versions and can be used with another wallpaper.
History keeps the last20 applications. The color filter uses prepared library
families; a cold library gradually gains families through the existing nice19
worker. Private choices, staged previews and artwork stay outside Git.

Tide's optional automatic mode uses local06:00–19:00 as daytime, not astronomical
sunrise/sunset. Following time reacts to the existing clock's hour signal; it adds
no polling process. Workspace colors are opt-in and color the numbered chips
without changing the entire desktop on workspace switches.

## Accessibility and fidelity

Studio previews a bar, window, terminal, notification and logo. Compare shows all
personalities. Accessibility provides a contrast grid and approximate full-severity
protanopia/deuteranopia/tritanopia simulations. The engine validates its documented
opaque text pairs at4.5:1 and essential outlines at3:1. Simulations are estimates;
labels and shapes remain necessary. Pinned/neutral colors may remain too close,
in which case the report explains the limitation rather than inventing source
colors or changing a pin. Transparency and arbitrary third-party app usage cannot
be guaranteed by an opaque palette alone.

Clustering uses perceptual OKLab distance with a chroma-adaptive tolerance. Center,
local detail and chroma affect bounded salience; true coverage is kept separate.
This is a heuristic, not semantic image recognition. Cropping and scene changes
can legitimately change a palette; a stable sampling policy/cache and regression
fixtures reduce unwanted flips, without claiming absolute crop invariance.

## Portable engine and format

`orient palette IMAGE --personality natural --mode dark` prints schema-version1
JSON. `orient analyze IMAGE`, `orient sample IMAGE X Y`, and
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

## Export and sharing

Export writes a new folder under `~/Documents/Nacre Colors`. It includes palette
JSON and original templates for VS Code, Firefox, Obsidian, Neovim, btop,
Kitty/Foot/Alacritty, GTK, rofi, Hyprland and optional Spotify/Discord adapters.
It never edits those applications or installs modifications. Firefox distribution
requires signing; Spotify needs optional Spicetify and Discord a user-theme client.
The generated README gives application instructions. Add `.in` templates under
`~/.config/nacre/colors-templates`; `{{primary}}` and other role tokens substitute
validated six-digit hex. Unknown tokens and replacing existing files are errors.
Palette cards include the image thumbnail/colors and “Made with Nacre”; cards are
private output files, with no automatic upload or publication.

Nacre's own GTK/Kitty/rofi/Hyprland outputs are templates too, rendered by Orient's
pure substitution helper inside the one existing publisher.

## Gallery and checks

`nacre/shell-tools/tests/orient-gallery` contains six CC0 procedural images, a
four-frame animation, its generator and all14personality/mode snapshots per image.
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
