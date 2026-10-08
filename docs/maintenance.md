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
bar updater uses `paru -Syu --skipreview` so routine updates do not display every
AUR package file, including long licence documents. Package lists, installation
confirmation and checksum validation remain enabled. This also skips manual
inspection of community package scripts; use `paru -Syu --review` when desired.
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

## Complete releases and recovery

`./install.sh --apply` now uses a desktop release transaction. It snapshots only
owned software/runtime and managed static configuration, exercises the actual
Wayland launcher/Escape paths, then promotes the candidate. A failed gate restores
all captured components. Accounts, wallets, browser profiles, conversations and
personal preferences are outside these snapshots. Operating-system packages
remain owned by the distribution's package manager.

`~/.local/bin/siverteh-os doctor`, `profile`, `session`, `check`, and `rollback`
provide the same maintenance actions as the Settings page. Rollback refuses later
edits instead of silently overwriting them. The sidebar worker stays alive while
its renderer is replaced; code changes to that worker are activated after it is
idle. Before pressing Restart/Restore, allow any unsent draft to finish saving.

The session observer records actual login, before-sleep, resume and display-hotplug
checks in private state. A manual check is labelled manual and cannot establish
that cold boot or physical suspend/resume passed. Verify those paths on the real
hardware after saving work; review the recorded event/result in Maintenance.

Focused/Presentation/Minimal now accompany Meeting/Music/Docked. Use Personal
workflow setup to save current audio defaults, connected display geometry and
selected startup apps for a preset. Missing devices are skipped; microphone mute
is preserved. These choices remain private, and selecting a preset never closes
working apps or chats.

Sidebar drafts are stored per native conversation with private permissions.
Attach selects local files; image attachments use native Codex image input,
other files are provided as user-selected local paths. Screenshot requests area
selection and stores the result privately. Sending is explicit. Message/code copy
buttons use the clipboard only when clicked. Attachment controls become available
when the updated assistant backend advertises support.

## Feature documentation

Feature behavior lives in the [overview's feature index](overview.md#feature-guides).
Git history records changes. Keep this guide focused on checks, deployment,
rollback and recovery.

## Host overrides and dependency updates

The managed idle file sources `~/.config/siverteh-shell/hypridle.local.conf`.
Installation seeds the policy once from `tools/defaults/hypridle.conf`; later
changes belong in the private file. The one-time `tools/configure.py
--migrate-idle-override` plan/apply preserves a recognized existing idle policy
and manual power/wake addition in private files, backing up managed originals.
Other configuration drift is still refused. `host.lua` loads last for optional
host-specific Hyprland behavior.

Desktop binaries, native libraries and icon artwork are pacman-managed. Perform
normal full system updates, rather than partial Qt updates. Quickshell uses Qt
private APIs, so the distribution must rebuild it for matching Qt releases.
The palette Python environment and app-scoped Thunar style module remain local;
rebuild the latter with `install-thunar.py` after relevant GTK ABI changes.
Release rollback restores desktop code/configuration, not system package versions.
See [runtime ownership](features/runtime.md) for installation and migration.
