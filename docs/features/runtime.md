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
python3 siverteh/shell-tools/provision.py
python3 siverteh/shell-tools/install-thunar.py
```

On mixed CachyOS/Arch repositories, ensure the selected Qt plugins and Quickshell
match the already installed Qt release; choose explicit repository packages when
necessary. Do not downgrade Qt plugins independently. Provisioning validates the
system packages and installs only the pinned palette engine in
`~/.local/share/siverteh-ai/shell-runtime/venv`. The Thunar installer compiles only
`thunar-style/siverteh-thunar-theme.so`. Launchers remove private native library
and Qt plugin/import overrides; Thunar uses normal distribution Xfconf activation.

Before replacing a private runtime, retain a release snapshot, test system
Quickshell separately, and validate live shell IPC after deployment. Retire the
old unpacked `usr` tree and `thunar-runtime` only after that succeeds. Rollback
snapshots can restore code/configuration; pacman owns package-version recovery.

## Future path consolidation

The proposed canonical roots are `~/.config/siverteh-os` for preferences,
`~/.local/state/siverteh-os` for durable desktop state, and
`~/.cache/siverteh-os` for disposable caches. Existing `siverteh-shell`,
`siverteh_shell`, and `siverteh-native-shell` paths remain compatibility contracts
for current tools; this review does not move personal state.

A future migration should inventory each owner, stop only affected idle services,
copy to staged directories with verified hashes, atomically promote them, and
leave old names as compatibility links. Refuse differing existing destinations.
Record a versioned migration manifest and rollback paths, then update readers
before eventually retiring links. AI accounts, chats, the vault and credentials
are outside this desktop naming migration. The unused `shell.json` is retired;
`cli.json` remains the palette CLI's configuration.
