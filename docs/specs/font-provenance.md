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

## Verified asset records and implementation

Existing IBM Plex Sans 3.201 and Rubik 2.300 font Git blobs match official
google/fonts assets at pinned bd8f81ddb5c74d5c8897b36ad88b440266245103. Material
Symbols Rounded 2.973 matches official google/material-design-icons asset at
737e3324305806514d7909874fa1818ae1808232 (2026-10-02), not latest changed Oct 9
blob. Retrieved pinned bytes/notices and compared SHA256: all six exact. Old
directory name is packaging legacy, not modified Caelestia font source.

New own font-assets.json pins URLs/revisions/size/hash/family/license; font-setup.py
plans without mutation, stages all verified inputs, refuses edited known assets,
migrates only recognized files and records private backups/ownership. Canonical
lookup uses unchanged bytes/families. Rubik optional for fresh installation, but
retained/migrated when already present as user compatibility data. Unknown extra
legacy files remain. Private rollback checks later drift/backup integrity; cache
failure restores old assets. This is normal failure rollback, not a filesystem-wide
crash transaction. Full desktop installer invokes this owner before shell cutover.
Do not certify entire install.py from this single caller integration edit.
