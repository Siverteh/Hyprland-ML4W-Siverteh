# Application, clock and compositor state

NacreApps indexes native desktop entries, deduplicates IDs and applies the existing
hidden preferences. All/hidden views keep metadata; missing applications do not
rewrite favorites or hidden lists. Own ranking supports exact names, prefixes,
words, substrings, initials, subsequences, case and decomposed accents. All query
words must match a metadata field. Results are original desktop entries. Launch
rejects removed/hidden/foreign entries, passes parsed arguments/cwd through existing
AppLaunch and wraps terminal apps in kitty --. Installed themed commands remain
unchanged. Application and wallpaper search use Nacre's own ranking helper. The unused
fuzzysort library has been removed.

NacreTime uses one native SystemClock at minute precision for current date/clock
views. secondsEnabled enables seconds when needed. enabled pauses only this view
and never changes system time. Bar/calendar/lock preview share local civil time;
timezone/location/authentication policy is untouched.

NacreHyprland keeps stable NacreClient objects around the native window model.
Titles, metadata, focus and workspaces update without periodic subprocess polling.
Addresses are normalized to 0x-prefixed keys: native Quickshell and hyprctl differ
in representation on this host. Initial focus uses one generation-guarded read;
activewindowv2 then supplies changes, including empty desktop focus. A late initial
reply cannot replace a newer focus event. Metadata refresh waits for Lua mode and
debounces relevant events; workspace/monitor events refresh their native models.
Read-only cursor snapshots refresh at startup/explicit reload.

Positive legacy workspace commands convert into native Lua dispatcher expressions;
existing trusted hl.dsp expressions retain their path. Native Quickshell wraps the
Lua dispatch transport. Other native session modes keep legacy dispatch. Opening
views never moves/focuses windows; explicit user commands remain the only writers.
compositorState.state omits private window titles/classes/process IDs. Small old
service names forward to the new owners. Spec and acceptance boundaries:
[app/clock/compositor spec](../specs/app-clock-compositor-services.md).
