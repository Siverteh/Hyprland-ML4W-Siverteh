# Travel Timezone

[System overview](../overview.md) · [Deployment and recovery](../maintenance.md)

## Automatic travel timezone

The Date and time page separates NTP clock synchronization from local timezone
selection. Optional system integration is installed with administrator
authentication: `pkexec /usr/bin/python3 nacre/shell-tools/timezone.py install`.
The root-owned helper lives in `/usr/local/libexec`, with a system timer checking
every 15 minutes and a NetworkManager dispatcher hook for connection changes.
The device-location lookup accepts only fresh, sufficiently accurate fixes and
valid IANA timezone names. Failed or imprecise fixes retain the last trustworthy
or user-confirmed timezone. Root integration is separate from desktop release
rollback; installation backups are under `/var/lib/nacre/timezone`.

Automatic mode uses the installed GeoClue GPS/Wi-Fi positioning service instead
of public IP location. Mobile roaming and VPN gateways therefore cannot directly
force their timezone. GeoClue may consult its configured Wi-Fi location provider;
only the resulting timezone, coarse city and accuracy are retained, never precise
coordinates. Offline libgweather maps an uncertainty envelope to a nearest-city
timezone, rejecting differing-zone results near boundaries. This is conservative
city-based mapping, not a guarantee of exact timezone-boundary geometry.

The root-only `nacre-timezone` client permission and desktop identity are
installed explicitly, without impersonating a GNOME app. Device requests are
bounded to 12 seconds and stop after lookup; fixes older than five minutes or
coarser than 5 km are rejected. If a trustworthy fix is unavailable, the helper
keeps the last confirmed/trusted zone and reports that fallback in Settings.
Confirm current timezone updates this fallback while keeping automatic mode;
manual selection disables automatic updates. Check device location forces a new
attempt, and network-change events bypass the ordinary five-minute throttling.
Root actions share a lock so an in-flight automatic lookup cannot overwrite a
manual correction. Existing helper/config/GeoClue registration files are backed
up before privileged upgrades. Enabling/installing uses the reviewed root helper
and normal administrator authentication.
No passwordless privilege rule or credential storage is installed. The existing
NTP service and UTC hardware-clock mode are preserved.

