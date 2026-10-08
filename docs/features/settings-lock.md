# Settings Lock

[System overview](../overview.md) · [Deployment and recovery](../maintenance.md)

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
