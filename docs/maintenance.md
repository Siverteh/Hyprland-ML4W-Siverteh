# Maintenance and deployment

This is the maintained source for a CachyOS/Arch desktop using Hyprland's Lua API.
It is not an installer for an arbitrary Linux distribution. Install OS packages
through the distribution's package manager, then provision the isolated shell
runtime with `python3 siverteh/shell-tools/provision.py`. Package archives are
checked against the SHA-256 values in the local package database before extraction;
the palette engine's tested Python dependency versions are pinned.

The target host needs Hyprland with Lua support, UWSM, Hypridle/Hyprlock, Kitty,
Python 3.13+, PipeWire/WirePlumber, NetworkManager, wl-clipboard/cliphist, jq,
brightnessctl, polkit's graphical agent and fonts used by the shell. Package update
checking uses `checkupdates` from pacman-contrib and optionally paru/yay. The
Brain needs Chrome/Chromium and Node.js, or the installed `siverteh-ai-tools node`
wrapper. Its local semantic model is optional. Qt's QML parser/test runner provide
the target-host UI checks; skipped checks are reported explicitly.

## Review a change

```sh
python3 tools/check.py
Hyprland --verify-config --config "$PWD/hypr/hyprland.lua"
./install.sh
```

The first check covers configuration ownership, the AI workflow, Brain and native
shell regressions. CI runs the portable checks; compositor parsing, Qt behavior
and live shell IPC still require the target host. Changes to display behavior
also require real connected displays, not just a unit test.

## Apply a reviewed plan

```sh
./install.sh --apply
./install.sh --apply --component shell
./install.sh --apply --component brain
```

On an older repository-linked installation, add `--migrate-owned` to the initial
application. This converts only recognized source-linked configuration directories
into installed copies, saves the original content privately, and preserves the
host's monitor configuration as a private override. Retired repository-linked
desktop configuration is backed up and removed. Unrecognized links and subsequent
local edits cause a refusal before configuration writes.

`tools/configure.py` tracks deployed file hashes in
`~/.local/state/siverteh-os/configuration.json`. Routine updates replace files
only when they still match the previous deployment. Edit host preferences through
the native settings UI or private override files; source changes belong in Git.
AI workflow deployment is an explicit `--component ai` operation and preserves
authentication. SDDM installation has its own documented administrator step.

## Validate and recover

Shell deployment parses QML before cutover, requires native IPC readiness and
verifies the deployed source against the candidate. The supervisor can restore
`source.good` after a startup failure; `source.previous` retains the preceding
deployment. Configuration migration backups include a manifest under
`~/.local/state/siverteh-os/backups`. Brain deployment keeps a private source backup
and does not terminate the browser profile or other assistants.

After applying, check `systemctl --user is-active siverteh-os-shell.service
siverteh-sidebar-ai.service siverteh-observatory-brain.service` and
`hyprctl configerrors`. Preserve the original source revision and private backup
until actual next-login startup has been checked. A health check cannot establish
that every physical device or cold-boot path works.

Publishing uses ordinary fast-forward pushes after checks. Repository renames
preserve GitHub history and redirects; update local remotes to the new URL as
recommended by [GitHub](https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository).

For launcher focus changes, also run the opt-in target-host check:
`python3 tools/check-overlays.py --keyboard /path/to/wtype` with shell panels closed.
It tests the launcher routes and real Wayland Escape events. Offscreen Qt tests
cannot detect layer-surface/focus-grab conflicts in the running compositor.
