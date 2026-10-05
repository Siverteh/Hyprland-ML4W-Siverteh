# Shell deployment

`provision.py` prepares the user-local runtime and maintained CLI dependencies. `install.py` installs the source, configuration, helpers and session service. Neither replaces the user's OS checkout or AI authentication.

```sh
python3 siverteh/shell-tools/provision.py
python3 siverteh/shell-tools/install.py
python3 siverteh/shell-tools/install.py --code-only
```

Deployment backups are private under `~/.local/state/siverteh-native-shell/backups`. The installer preserves later edits during restore. Code-only deployment preserves user configuration and restarts only the desktop shell. The independent persistent brain service remains running.

The classic QML expects palette text and wallpaper-path files under `~/.local/state/siverteh_shell`. `classic-state.py` bridges the maintained CLI output to that format. Theme changes use the CLI bridge; package updates use the existing Siverteh updater.

Configuration ownership and rollout are documented in [maintenance](../../docs/maintenance.md). Current source is authoritative; historical desktops remain in Git history only.
