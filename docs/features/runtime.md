# Runtime ownership and compatibility

[System overview](../overview.md) · [Maintenance](../maintenance.md)

Pacman owns desktop executables and native dependencies, verifies package
signatures, and updates them with the system. Private unpacked packages bypassed
that lifecycle and could shadow newer Qt libraries. Quickshell relies on private
Qt APIs and needs a matching build after Qt releases:
[upstream packaging requirements](https://github.com/quickshell-mirror/quickshell/blob/master/BUILD.md).

Install these through the distribution before provisioning:

```sh
sudo pacman -Syu quickshell thunar xfconf exo libxfce4ui libgtop qt6-multimedia qt6-multimedia-ffmpeg qt6-imageformats papirus-icon-theme wtype ddcutil cpptrace libdwarf
python3 nacre/shell-tools/provision.py
python3 nacre/shell-tools/install-thunar.py
```

On mixed CachyOS/Arch repositories, ensure the selected Qt plugins and Quickshell
match the already installed Qt release; choose explicit repository packages when
necessary. Do not downgrade Qt plugins independently. Provisioning validates the
system packages and installs only the pinned palette engine in
`~/.local/share/nacre/palette-runtime/venv`. The Thunar installer compiles only
`thunar-style/nacre-thunar-theme.so`. Launchers remove private native library
and Qt plugin/import overrides; Thunar uses normal distribution Xfconf activation.

Before replacing a private runtime, retain a release snapshot, test system
Quickshell separately, and validate live shell IPC after deployment. Retire the
old unpacked `usr` tree and `thunar-runtime` only after that succeeds. Rollback
snapshots can restore code/configuration; pacman owns package-version recovery.

## Future path consolidation

The proposed canonical roots are `~/.config/nacre` for preferences,
`~/.local/state/nacre` for durable desktop state, and
`~/.cache/nacre` for disposable caches. Existing `nacre`,
`nacre_shell`, and `siverteh-native-shell` paths remain compatibility contracts
for current tools; this review does not move personal state.

A future migration should inventory each owner, stop only affected idle services,
copy to staged directories with verified hashes, atomically promote them, and
leave old names as compatibility links. Refuse differing existing destinations.
Record a versioned migration manifest and rollback paths, then update readers
before eventually retiring links. AI accounts, chats, the vault and credentials
are outside this desktop naming migration. The unused `shell.json` is retired;
`cli.json` remains the palette CLI's configuration.

## Distribution Qt mismatch recovery

The launcher checks Quickshell's reported build/runtime Qt versions before
starting; mismatches fail with a clear journal message. This can expose a lagging
distribution package even after a full update. Prefer a matching distribution
build. If unavailable, `tools/quickshell.PKGBUILD` builds the pinned upstream
release with the focused upstream Qt 6.12 compatibility backport
(`5d5d49873fe8cf1f99ddfd5006ceb2057c5c9b13`) as a local pacman package
against the installed Qt, with exact Qt version
dependencies. Build in a disposable directory as your ordinary user, then install
the artifact with `pacman -U`. Never run `cmake --install` directly as root.

This recovery package intentionally prevents a later unmatched Qt upgrade;
replace/rebuild it alongside Qt rather than bypassing dependency checks. Source
is pinned to the upstream Git commit; package installation tracks its files in
pacman, while a local build has no distribution package signature. Verify the
isolated build probe and live desktop release gates before retiring rollback code.

The folder overlay has a new versioned name when migrating to system artwork,
so an old cached overlay cannot keep symlinks into retired native icon copies.
Old private artwork/overlay directories are removed only when verified as owned;
custom user icon themes are preserved.

## Update visibility

Package updates retain `paru -Syu --skipreview`. Failures print their step and
exit code and wait for Enter. Preflight blocks a known local recovery build when
a Qt release change is pending for base, declarative or Wayland libraries, with rebuild instructions rather than an opaque
package-dependency failure. The update widget displays that status. Cached
repository archives can verify that a distribution Quickshell's build-time Qt
matches installed Qt; absent build metadata means compatibility is not assumed.
After updates the same Qt check as shell startup runs. Startup failure is shown
through Hyprland, so it remains visible without the shell notification server.

A package revision update such as `6.12.0-2` → `6.12.0-2.1` preserves the Qt
release and does not require a Quickshell rebuild. The preflight compares release
versions, including dependency epochs, rather than warning for every Qt package
revision. Actual release changes still retain the rebuild guard and the post-update
runtime/build check.

Orient runtime identity excludes formatter/test/build caches and generated egg
metadata, while tracking maintained source, package data and notices. Moving
to a fresh worktree or running Ruff does not rebuild an unchanged palette engine.
