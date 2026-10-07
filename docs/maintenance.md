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

Super+A toggles Apps. Super by itself has no launcher binding, avoiding
accidental opens. Super+W opens Wallpaper directly. The bottom drawer has no
hover trigger.

The app browser always opens a compact Favorites view, including when empty.
All apps expands upward to six full rows when the screen has room;
other categories expand to the standard browsing height; the bottom search field
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

## Wallpaper library and layouts

Super+W remains a wallpaper-only drawer. Static/Dynamic filters distinguish still
images from local videos/animated GIFs. Carousel, Spotlight and Hexagons share
selection, arrow/scroll navigation and Escape/outside-click dismissal. Search
matches descriptive names and paths; Enter applies the current result. Add or
drop local files to import private copies into Pictures/Wallpapers. Original
files are preserved, and matching import names never overwrite existing files.

Media selection prepares a cached still poster before running the existing
palette pipeline; only after that succeeds is media identity published. Login,
Hyprlock and previews use the still poster. Video/GIF data and picker preferences
stay private; assets are not part of public Git or software rollback. Static CLI
palette operations remain compatible because the poster is the committed image.
Qt Multimedia with its FFmpeg backend and the ffmpeg utility provide local video
playback. Videos have no audio output and disable their audio track. Playback
pauses on lock/sleep, can pause behind tiled apps, and is shown inside the selected tile while the
picker is open for browsing. Switching to a static wallpaper destroys the player.

Output geometry or pixel-density changes can leave stale Qt/Wayland render
buffers after fractional-scale transitions. DisplayRecovery coalesces actual
screen changes and recreates only the desktop renderer after700ms settled.
Visible settings/drawer modes are restored; display confirmation stays available.
The sidebar backend, conversations, accounts and application windows are not
restarted. Only UI visibility flags are handed off, never draft or password text.

Wallpaper presentation: Carousel remains a compact bottom drawer with an odd
number of complete cards and centered controls. Spotlight and Hexagons use the
active screen's available panel area, with a dimmed wallpaper backdrop instead
of an oversized bottom-frame notch. Empty overlay space and Escape dismiss the picker; images and controls consume their own clicks.
The native Qt tests include card-bound checks. Reference screenshots prompted
this presentation; current caelestia-kde main/dev use a different compact QML
PathView, so these expanded views are maintained locally rather than relying on
another wallpaper manager or upstream plugin.

Expanded wallpaper tiles animate position/width; their decode size stays stable
to avoid reloading images during selection. The backdrop holds its previous
loaded buffer until the next is ready and coalesces changes during crossfade.
Closing clips fixed-height content rather than shrinking its internal anchors.

Wallpaper assets use shared private JPEG thumbnails (640px) and larger previews
(1600px), keyed by source path, size, modification time and cache format version.
Carousel, hexagons and Settings use thumbnails; Spotlight and its backdrop use
previews; the actual desktop retains the original wallpaper quality. A low
priority startup worker prepares palette results and per-wallpaper login blurs
without changing the active wallpaper/theme. Completed palette warm markers avoid
repeating the work on renderer recovery. Publication remains owned by the existing
palette bridge, with shell colors published before compatibility/login assets.
The normal carousel uses a bounded PathView with animated movement, complete odd
card count and two nearby cached delegates rather than swapping a row's images.

Prepared palette commits use the same publisher and palette lock as the CLI,
validate roles/mode/flavour, preserve CLI wallpaper identity and fall back to the
CLI for stale/missing caches or custom wallpaper hooks. `presentation.json`
carries the wallpaper poster and palette together. Native Colors waits for the
matching desktop image to be ready before presenting the new colors; late image
acknowledgements cannot activate an older selection. The desktop loads the
original image directly with bounded decode size, avoiding a thumbnail subprocess
for each background change. Cached small tiles decode immediately; Spotlight
uses them beneath its asynchronous large preview. These are event-driven changes,
with no periodic palette/image work; background warmers run once at low priority.
Automatic covered-app pausing stays enabled without a picker button/footer row.


## Session ownership and readable source

UWSM owns graphical environment setup through `uwsm/env` and `env-hyprland`.
Keep XDG session identity with UWSM; avoid forced SDL backends and deprecated
scaling/backend variables. Hypridle uses its distribution-supplied user service;
the enabled desktop service does not also need a Hyprland startup command.
`startup-apps.sh` invokes the existing idempotent startup helper. One shared
Updates service owns package checking regardless of monitor count.

Quickshell 0.3.1 uses `qs.` module imports; relative JavaScript and asset URLs stay
within the configuration root. `.qmlls.ini` is host-generated and ignored. Use
multiline code: `qmlformat -i` for QML and `ruff format --target-version py313`
for Python. Keep formatter-only changes separate and run checks before and after.
Fixture adapters remove complete QML objects rather than assuming one-line code.

`tools/check.py` also detects conflicting class-wide routing/floating rules,
including witnessed overlaps of literal alternations and case pairs. Different
extra selectors, such as dialog titles, are scoped separately. This static check
never executes configuration and is not a proof of arbitrary PCRE intersection;
the compositor parser and real application checks remain necessary.

Fish symlink migration requires explicit `--migrate-owned`, verified tracked file
hashes or a recognized source tree, and a private backup. It preserves personal
Fish configuration. The release transaction forwards the flag through preflight
and application and captures the previous link for rollback.

The live migration imported only the reviewed toolkit/cursor variables and tested
actual launcher inheritance. A complete new login, physical Fn-row behavior and
real 15-minute password unlock still require checks on the actual session; avoid
logging out active workers merely to claim those tests passed. See the
[overview](overview.md) and [optional boundary proposal](repository-boundaries.md).

Dynamic chooser tiles now show the selected local video or animated GIF rather
than just its still poster. Selection settles for 180 ms before a player starts;
rapid browsing cancels that work. Carousel, Spotlight and the masked hexagon
view share the same silent preview component. Only the selected tile decodes,
and the desktop motion pauses while the chooser is open, so this does not run
a video grid or add a second active desktop decoder. Closing, changing tabs or
manual pause destroys the preview player. Static thumbnails remain underneath
until a video frame arrives. Decoder errors retain the still preview.

## Appearance rotation and fixed palettes

Appearance groups the current wallpaper, rotation, desktop colors and a collapsed
collection grid. Rotation defaults to off, with a recommended 30-minute interval.
Presets offer 15, 30, 60 and 120 minutes; the custom interval accepts 5–1440 minutes.
The pool can include all, static or dynamic wallpapers. Shuffle walks through the
pool before repeating; ordered rotation follows the catalog. Manual selection
starts a fresh interval. Sleep, lock, the picker, Settings and an in-flight commit
pause the one-shot timer; returning starts a full interval without catch-up bursts.
There is one timer in the existing Wallpapers singleton, independent of monitor
count, and it uses the existing serialized commit queue. No polling worker or
second wallpaper manager is installed.

Thirty fixed palettes provide complete light/dark roles, including readable
foreground pairs. Vivid covers twelve saturated rainbow accents (including Super
Red and Cobalt Blue); Soft includes eighteen gentler choices, preserving the
original six. The page filters Vivid, Soft or All colors. Vivid accents preserve
saturation while ensuring header and button contrast; light mode uses deeper
accents for readable text. Regenerate the precomputed file with the maintained
runtime's Python and `siverteh/shell-tools/generate-palettes.py`; output lives in
`siverteh/shell-tools/palette-presets.json`. Match wallpaper restores image-derived
colors. Private picker preferences also hold rotation options, the fixed preset
and its chosen mode. `classic-state.py` resolves fixed colors inside the existing
publisher before updating shell presentation, frame, GTK, Qt, terminal, lock and
login assets. Wallpaper changes still publish the new poster together with the
chosen colors, preserving image/palette synchronization. The CLI remains the
scheme owner; fixed presets do not introduce a second scheme installation.

The temporary wallpaper tournament is separate from maintained desktop code.
Completed user results and archived originals remain private; its launcher,
shortcut, isolated worktree and scratch files can be removed after completion.

## Quick sound and connection controls

Clicking the Sound, Wi-Fi or Bluetooth top-bar icon opens and pins its native
quick popup; clicking the same icon again closes it. Escape and outside-click
use the existing drawer grab. Hover previews remain available. Sound offers
volume/mute, microphone volume/mute and output selection; Wi-Fi offers its
radio, refresh, connection status, nearby networks and disconnect; Bluetooth
shows power and connect/disconnect for already known devices. Lists have bounded
height and use the shared fast scroll. Error text is bounded inside the popup.

Each footer opens the matching built-in Settings page and dismisses the quick
popup through shared visibility/navigation state. Application audio streams,
connection profiles, pairing and trust controls remain in detailed Settings.
Password entry remains in NetworkManager's native prompt, and pairing stays in
the Bluetooth manager. Device actions reuse the bounded helper and existing
network/Bluetooth state owners; completion requests a fresh snapshot without a
polling timer. Wi-Fi disconnect accepts a validated interface name, while the
status helper selects only a connected Wi-Fi interface. Short SSIDs remain
visible. Native tests use fake devices, so routine validation does not change
the live connection or audio state.
