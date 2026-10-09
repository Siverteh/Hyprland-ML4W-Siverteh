# Retire the unused file-thumbnail helper

2026-10-09. The whole-tree inventory finds `nacre/shell/utils/thumbnail.py`
remaining after the unused Thumbnailer service was retired. Current tracked source,
installer command declarations and maintained tests contain no invocation or import
of this path. Native Qt image decoding and prepared wallpaper/poster assets own
maintained previews. The shell installer copies its entire source tree, so this
unused Python file is still unnecessarily present in the active runtime.

Delete the helper without opening or reusing its implementation. There is no
replacement command or compatibility alias because there are no maintained callers.
The existing native image/presentation/wallpaper tests remain behavior authority.
Add the retired path to the repository guard so it cannot silently return. Prior
broader thumbnail-system exposure is acknowledged; no legal clean-room claim.

Run full checks and native compositor verification, deploy the reviewed shell-only
plan through the release transaction, and confirm the exact active source no longer
contains the helper. Open the wallpaper chooser and Appearance Settings, verify
native presentation/palette readiness and Escape, and preserve existing private
preferences/library and busy assistant workers. Previous releases remain rollback
backups; they are not removed or mistaken for active runtime dependencies. No asset,
license, palette policy or visual redesign is part of this retirement.
