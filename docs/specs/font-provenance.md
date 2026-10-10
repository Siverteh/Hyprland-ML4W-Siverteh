# Independent font provenance, notices and user provisioning

Spec ready, 2026-10-10 UTC. Active fontconfig resolves IBM Plex Sans and Material
Symbols Rounded from ~/.local/share/fonts/caelestia, not pacman-owned files. This
folder also holds Rubik and associated IBM/Material/Rubik license files. No fonts
are tracked in the current source tree and no current provisioner references that
folder; do not call assets original or unlicensed from the directory label alone.

Verify each actual binary's metadata/version/hash against authoritative upstream
asset/release sources and inspect retained notices. IBM Plex official license is
OFL 1.1; Google Material Design repository has Apache 2.0, but exact font artifact
license/source must be proven separately. Initial attempted Google fonts paths
were 404, not evidence about asset licensing. Retrieve official public font bytes/
license files only, not Caelestia/ML4W implementation bodies. Properly licensed
third-party fonts remain allowed; no need to design replacement glyphs.

Preserve current typography, glyph mappings, sizing and palette behavior. Confirm
actual Rubik consumers before retaining/retiring anything. If existing assets can
be verified, retain their bytes with independent source/hash/license ownership;
otherwise use pinned verified upstream assets with compatibility/visual evidence.
No unreviewed font blobs or personal account pictures copied to Git. Maintain
license notices and source locations. Public installer should independently obtain
these assets through system packages or a small pinned per-user provisioner;
never unpack arbitrary native binaries or revive old private runtimes.

Canonical private font directory ~/.local/share/fonts/nacre. Migration may touch
only recognized assets with exact verified hashes; unknown files/edits are refused
or preserved. Stage copies, compare, atomically promote, retain private rollback
manifest and compatible lookup during transition. Rebuild fontconfig cache and
prove actual consumers resolve canonical independent assets. Do not delete a
custom font folder or trust merely its name. Avoid duplicate active copies that
make fontconfig select the obsolete path. Preserve loaded user apps/AI worker;
no forced logout or package privilege dialog unless system install required.

Acceptance: metadata/upstream hash/notice evidence, isolated install/idempotence/
collision/rollback fixtures, actual fontconfig results, native QML/Pillow/terminal/
lock rendering and visual compatibility. Full tests/Hyprland/source registry,
reviewed plan/apply/source/IPC/private hashes/worker checks for maintained runtime
changes; migration recorded separately as user asset operation. Exact-main CI.
No source-license cleanup or whole-tree completion claim from these fonts alone;
remaining implementations/assets/tests/packaging/full comparison still required.
