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

## Detailed settings and lock-screen widgets

Settings remains inside the top-menu dashboard. Its navigation rail groups
Appearance, Desktop, Displays, Sound, Network, Bluetooth, Notifications,
Workflows, Lock screen, Siverteh AI and Maintenance. Search matches page names
and setting keywords. Only the active page is loaded while Settings is open.
Display scale/mode changes use the same20-second Keep/Revert safeguard as layouts.

Sound uses the existing PipeWire graph for device selection and application
volumes. Network password entry uses NetworkManager's native `nmcli --ask`
prompt in a terminal; no password is passed through shell IPC or arguments.
Advanced connection editing and Bluetooth discovery/pairing use the existing
native managers; known Bluetooth devices have inline connect/trust controls.

Hyprlock still owns PAM authentication and secure session locking. Generated
appearance adds weather, media artwork/playback controls, battery and retained
notification summaries. Notification message previews default off and can be
changed on the Lock screen page. Playback actions are an allowlist; none can
unlock the session. Weather retrieval is bounded HTTPS with a private cache;
failed refreshes retain their original timestamp and display a cached label.
Lock widget IPC/cache contains presentation data only, never authentication.

`siverteh-os-shell lock-preview` opens a clearly labelled layout preview with
Escape dismissal; it does not lock or authenticate. Changes take effect on the
next real lock. Source changes require actual Hyprlock render checks in an
isolated nested compositor, followed by the user's password-unlock check on the
real session. Do not unlock the live session through IPC for testing.

## Automatic travel timezone

The Date and time page separates NTP clock synchronization from local timezone
selection. Optional system integration is installed with administrator
authentication: `pkexec /usr/bin/python3 siverteh/shell-tools/timezone.py install`.
The root-owned helper lives in `/usr/local/libexec`, with a system timer checking
every15minutes and a NetworkManager dispatcher hook for connection changes.
The bounded HTTPS lookup accepts only valid IANA timezone names. Failed lookups
keep the current timezone. Root integration is separate from desktop release
rollback; installation backups are under `/var/lib/siverteh-os/timezone`.

Automatic mode follows public IP location, so a VPN may identify its exit
location. Manual timezone selection turns automatic mode off. Enabling it again
uses the same reviewed root-owned helper and normal administrator authentication.
No passwordless privilege rule or credential storage is installed. The existing
NTP service and UTC hardware-clock mode are preserved.

## Categorized bottom launcher

Tap and release either Super key to toggle Apps; Super+A remains an alias.
Hyprland's modifier-only release handling suppresses the tap binding after a
chord. Super+W opens Wallpaper directly. The bottom drawer has no hover trigger.

The app browser always opens a compact Favorites view, including when empty.
Selecting All apps or another category expands upward; the bottom search field
stays anchored. Typing also expands the results view. Categories come from desktop-entry metadata and empty categories are
omitted. Typing searches all visible apps; `>` searches built-in actions.
The heart toggles a favorite; right-click offers favorite/hide, and the hidden
apps button restores hidden entries. Ctrl+D toggles the selected app's favorite.
Tab moves into the category rail, arrows navigate and Enter launches; Escape
closes. Clicking outside dismisses the panel without activating the app behind
it. Power actions stay in the existing power menu.

Preferences are private atomic JSON in `~/.config/siverteh-shell/launcher.json`,
with mode0600 and locked read/modify/write operations. They are outside source
and desktop rollback, and malformed data is preserved rather than overwritten.
The browser loads only while open/closing and uses the shared fast scrolling.
