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

Install with the release installer, or provision using
`python3 nacre/shell-tools/provision.py`. It tests a fresh environment before
atomically selecting it, retaining the prior runtime for recovery. Repository
installation/deployment belongs to `./install.sh`, not this CLI.

See [the engine spec](../../docs/specs/orient.md),
[feature behavior](../../docs/features/orient.md), [LICENSE](LICENSE) and retained
[attribution](NOTICE). Other Nacre areas still contain inherited implementation;
this component replacement does not establish a whole-project license change.
