# Font source and ownership

IBM Plex Sans and Material Symbols Rounded retain the current typography.
The font manifest pins official upstream revisions, file lengths and SHA-256
checksums, including accompanying notices. IBM Plex and optional Rubik use OFL
1.1; Google's Material Symbols asset uses Apache 2.0. These are third-party fonts,
not original Nacre artwork.

Run `python3 nacre/shell-tools/font-setup.py` to review the plan, then `--apply`.
Desktop installation calls the same owner. Fresh installs include Plex and
Material; Rubik is preserved when already present for compatibility. No font blobs
are stored in Git, and already verified installed files need no network request.

Canonical assets live in `~/.local/share/fonts/nacre`. Only manifest-recognized
legacy files with exact hashes migrate. Unknown extra files and edited known files
are preserved/refused; this is not a blanket folder deletion. Family names and
font bytes stay unchanged. Fontconfig cache rebuild establishes canonical lookup
without logging out or restarting user applications.

Private ownership/backup records live in `~/.local/state/nacre/fonts`. Use
`--rollback TRANSACTION_ID` to restore a reviewed asset operation; later edits or
corrupt backup data cause refusal before writes. A normal cache-refresh failure
restores the previous files. This is not a filesystem-wide crash transaction or
an OS package rollback. Keep user asset rollback records separate from code release
snapshots.

Source/license evidence is in `font-assets.json` and the font provenance spec.
The prior Caelestia-labelled folder was a packaging location: all six existing
font/notice files matched official upstream bytes. Moving the folder alone would
not have established that provenance. Applicable project notices stay until the
whole source/asset audit completes.
