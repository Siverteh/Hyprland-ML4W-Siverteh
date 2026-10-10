# Orient: Nacre palette engine

An independently implemented image-color engine for Nacre. It ranks related color
families by coverage, color strength, usable lightness and spatial spread, then
creates hue-preserving light/dark palettes with explicit readability checks.
Pillow handles images and ICC profiles; the engine does not use Material You.

The compatible executable remains `nacre_shell`. `wallpaper -p IMAGE` prints a
palette without changing the active desktop; `scheme set` and `wallpaper -f` update
private palette state. The existing native bridge remains the only theme publisher.
The JSON output retains consumer roles and adds `overtone`, `orient1/2/3` and source
candidate diagnostics. Warm caches are fingerprinted by engine code and image
identity/settings; no periodic extraction or per-video-frame work is introduced.

Provision the initial environment with
`python3 nacre/shell-tools/provision.py`; subsequent managed releases refresh it.
The provisioner tests a fresh environment before
atomically selecting it, retaining the prior runtime for recovery. Repository
installation/deployment belongs to `./install.sh`, not this CLI.

See [the engine spec](../../docs/specs/orient.md),
[feature behavior](../../docs/features/orient.md), [LICENSE](LICENSE) and retained
[attribution](NOTICE). The [final comparison](../../docs/nacre/FINAL-COMPARISON.md) joins complete
implementation/fixture, runtime and dependency evidence. Current project licensing
and historical attribution remain distinct from third-party licenses.

## Orient3 portable core

`src/orient` is the reusable image/palette library; `python -m orient` or the
`orient` entry point exposes analysis, palette, point-sampling and template export.
It has no desktop publication dependency. `src/nacre_shell` is the Nacre command
adapter retained for compatibility. Schema1 adds source bodies/regions/provenance
and accessibility diagnostics. See ../../docs/features/orient.md. Notices/licenses
remain retained; standalone extraction/publication is a later task.

Pop chooses a contrasting minority pigment family, while Natural keeps its varied
source accents. Background policy is independent: `--background-from-wallpaper`
uses sampled shadow/highlight families and `--no-background-from-wallpaper` uses
restrained accent tint. The retired Source personality is accepted by the legacy
adapter/library as Natural with sampled backgrounds; new CLI mode lists show seven.

Matugen color expressions are supported alongside Orient tokens. Render existing
files with `orient render palette.json template.css > theme.css`, optionally
`--companion light.json` and `--variables variables.json`. Roles, standard color
formats and mode/image/custom keywords are supported; filters/loops/includes and
HCT palette expressions are not. See the feature guide for the exact contract.
