# Shell deployment

`provision.py` prepares the user-local runtime and maintained CLI dependencies. `install.py` installs the source, configuration, helpers and session service. Neither replaces the user's OS checkout or AI authentication.

```sh
python3 siverteh/shell-tools/provision.py
python3 siverteh/shell-tools/install.py
python3 siverteh/shell-tools/install.py --code-only
```

Deployment backups are private under `~/.local/state/siverteh-native-shell/backups`. The installer preserves later edits during restore. Code-only deployment preserves user configuration and restarts only the desktop shell. The independent persistent brain service remains running.

The classic QML expects palette text and wallpaper-path files under `~/.local/state/siverteh_shell`. `classic-state.py` bridges the maintained CLI output to that format. Theme changes use the CLI bridge; package updates use the existing Siverteh updater.

The completed universe desktop code is preserved on GitHub in `rice/observatory-snapshot-2026-10-03` at `f3290a5`. Its private desktop deployment snapshot remains available. This shell's source is independent and can be customized normally in Siverteh OS.

The baseline artwork can be prepared privately with `python3 siverteh/shell-tools/prepare-reference.py`. The palette seed is `reference-style.json`; user artwork and screenshots are excluded from public source. The background is static and the active song, applications, clock and sensors naturally reflect this host.
