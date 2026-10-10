# Desktop helpers and deployment

These helpers own wallpaper/cache publication, companion theming, settings/device
actions, startup, update checks, lock/login preparation and UI recovery. Shared
native providers remain in `nacre/shell/services`; the persistent AI backend and
Brain have separate owners.

`provision.py` checks system packages and builds/tests the isolated Orient Python
environment. Pacman owns native binaries/plugins/icons. `install.py` copies the
renderer/tools and configures its service; `--code-only` preserves user settings.
Use the managed release path from the repository root for ordinary deployment:

```sh
./install.sh --component shell
./install.sh --apply --component shell
```

[Maintenance](../../docs/maintenance.md) describes prerequisites, clean committed
candidates, validation, backups and rollback. Installed runtime code is backed up;
managed configuration has hash-based drift protection. Accounts, conversations,
wallpapers and preferences are external private data.

`classic-state.py` is the companion palette publisher behind the shared commit
lock. Prepared poster/palette records coordinate shell presentation; toolkit files
are replaced individually. Package updates retain `paru -Syu --skipreview` and
visible failure/Qt-match recovery. See [runtime ownership](../../docs/features/runtime.md)
and [Appearance](../../docs/features/appearance.md).
