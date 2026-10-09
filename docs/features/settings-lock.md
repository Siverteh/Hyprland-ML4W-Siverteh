# Settings Lock

[System overview](../overview.md) · [Deployment and recovery](../maintenance.md)

## Detailed settings and lock-screen widgets

Settings remains inside the top-menu dashboard. Its navigation rail groups
Appearance, Desktop, Displays, Sound, Network, Bluetooth, Notifications,
Workflows, Lock screen, Nacre AI and Maintenance. Search matches page names
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

`nacre-shell lock-preview` opens a clearly labelled layout preview with
Escape dismissal; it does not lock or authenticate. Changes take effect on the
next real lock. Source changes require actual Hyprlock render checks in an
isolated nested compositor, followed by the user's password-unlock check on the
real session. Do not unlock the live session through IPC for testing.

## Prepared lock presentation

Both wallpaper publication and direct lock-layout refresh use `prepare_config`,
which reads actual output dimensions and retains the last known geometry if the
compositor query temporarily fails. Neither production writer may use the generic
1920px preview layout. Media controls and their card must share the same output.

The existing LockWidgets singleton prepares text and artwork on metadata,
notification, privacy, battery or palette events, coalescing bursts. Private ready
files have mode0600 inside a0700 directory. Hyprlock reads them with short `cat`
commands; no network requests, Python imports, font measuring or shell IPC happen
in its widget render path. Safe and detailed notification labels are separate;
current lock preferences select the safe file by default. Actions remain the
existing bounded Python media allowlist, with PAM authentication unchanged.

A transparent `sh-lock.png` uses the maintained SH geometry. The terminal's opaque
`sh.png` remains separate. The stable initial artwork file is updated atomically
before lock startup; live image reloads use identity-keyed paths. Album artwork
preserves its alpha channel, downloads are bounded, and the private artwork cache
retains at most12 prepared covers. No background polling worker is introduced.

## Single-tile dashboard

The lock screen follows the [Caelestia KDE reference](https://github.com/ladybug-me/caelestia-kde):
one centered 1440×810 design canvas with 42px outer corners and 26px inner corners.
Left cards show weather, system information and seven palette shades, then large
album artwork. The center shows a split 12-hour clock, date, rounded pentagonal
account picture, greeting and native password field. The right column shows CPU,
RAM and root-disk gauges plus grouped notifications. Your own wallpaper, desktop
palette and live metadata provide the content. `~/.face` or `~/.face.icon` supplies
the avatar; otherwise a properly contained SH logo is used.

Hyprlock owns the lock surfaces, password field, PAM authentication, failure
feedback and Enter-to-submit behavior. Media buttons call the existing allowlist;
the moon suspends while locked. The adjacent lock icon is a status indicator.
Notification groups display local app artwork, counts and timestamps; they do not
launch apps while locked. Detailed previews obey the existing privacy preference.
The KDE reference's session-switch/logout controls and expandable notification
interaction are not exposed by this Hyprlock implementation.

`lock-dashboard.py` prepares a bounded high-resolution PNG containing the blurred
wallpaper tile, cards, gauges and presentation text. It alpha-composites translucent
cards over the blurred texture, leaving the wallpaper outside the tile sharp.
Clock, password and playback controls remain native Hyprlock widgets. Both share
one normalized coordinate system, scaled to native output pixels independently of
compositor scale and rotation. The floating preview follows the output proportions and reads the same prepared
PNG; it never
accepts passwords or authenticates.

The existing event-coalesced lock writer updates the panel on palette, media,
weather, notification and resource changes. Resource sampling reuses the desktop's
existing timer; no polling daemon or per-second image renderer is added. Routine
palette config publication reads ready paths and does not rasterize the dashboard.
Output changes and privacy changes prepare a safe panel before publication. Private
identity-keyed image paths support native reloads and retain at most12 recent
panels (or three per monitor when that is larger). Lock startup only reads already
prepared files. Weather details include feels-like and daily high/low when provided.
Missing metadata shows an unavailable/empty state, never demonstration values.

## Physical power button

A desktop-session tap requests `loginctl lock-session` on the initial press,
including while locked. It does not merely disable DPMS. Hypridle owns starting
Hyprlock and its existing-instance guard. Mouse movement can wake the display
but cannot bypass authentication.

The managed user power-key inhibitor prevents logind's default short-press
shutdown from competing with the compositor binding. The previous private
release-time blanking binding is migrated with a backup; wake preferences and
idle timeout choices are preserved. The existing service name remains compatible.

Holding the physical button retains the machine's firmware emergency power-off;
this is not a new timed software shutdown command. Its timing is hardware-specific.
The OS does not prevent that hardware override. Actual shutdown is not performed
as a deployment check. See [systemd's inhibitor ownership documentation](https://systemd.io/INHIBITOR_LOCKS/).

## Independent dashboard assembly

NacreDashboardPanel lazily loads the selected top-menu page and clips fixed
internal geometry during dismissal. NacreDashboardNavigation changes the selected
label/underline immediately. Settings keeps pinned keyboard focus; choosing
another tab releases that pin. Hidden pages stop their declared update/active
contract and unload after closing. Page bodies remain separate rewrite batches;
existing personal settings and lock authentication ownership are preserved.

## Independent overview cards

The overview uses NacreOverview and its own weather, host, clock, calendar,
resource and media cards. Wide screens keep the established overview composition;
narrow screens arrange cards into readable rows and scroll instead of clipping.
The calendar follows the locale's week start and supports month navigation.
Host description/uptime use native asynchronous file reads; only an open card
refreshes uptime once per minute. Media progress samples once per second only
while visible and playing, with capability-aware controls and a circular cached
album preview. Existing service owners, user preferences and playback remain.

## Full Media and Performance pages

NacreMediaPage keeps native player selection/raise, guarded transport, seek/time
labels, and supported shuffle/repeat/volume controls. The seek control commits
once on pointer release and rejects player/track changes during a drag. Normal
progress redraw never seeks; hidden or paused pages stop sampling. A second
player-choice row appears only when multiple players are available. The old bongo
asset is removed. NacrePerformancePage consumes the shared system collector, with
paired own arc gauges, explicit unavailable GPU data, resource sizes and load/
kernel details. Neither page creates a new service or resource poller.

## Independent workspace overview

NacreWorkspacePage uses the configured seven labels/icons and live client metadata,
with bounded summaries, window counts and a current-workspace accent. Clicking
changes workspace through the existing compositor service and closes the menu.
Narrow layouts scroll. Verification preview mode cannot switch workspaces. There
are no automatic moves, app launches or changes to private workspace preferences.
