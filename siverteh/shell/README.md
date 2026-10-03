# Siverteh OS reference shell

The desktop source is maintained here, inside Siverteh OS. This baseline uses the actual reference-period components: workspace indicators, tray, clock, status icons, red power button, animated dashboard, surrounding frame, media and right-side controls. The bar is horizontal and the unlabelled center hover area opens the dashboard.

- Appearance and sizes: `config/Appearance.qml`, `config/BarConfig.qml`, `config/BorderConfig.qml`.
- Horizontal arrangement: `modules/topbar/TopBar.qml`.
- Dashboard and frame: `modules/dashboard/` and `modules/drawers/`.
- System/audio services: `services/`.
- Source edits deploy with `python3 siverteh/shell-tools/install.py --code-only` from the OS repository.

The installed desktop is a deployed copy of this source. No separate upstream checkout, submodule or update process owns it. License and adapted-code attribution are in LICENSE and NOTICE.

Reference artwork is kept privately in the user's wallpaper folder; it is not included in public Git. The initial static wallpaper is extracted from the supplied demo's clean background region. Live values, host information, applications and monitor proportions differ from the recording; the interface uses the reference's real source. Custom background/color behavior is deferred.

Super+A and clicking the Arch icon open the same bottom launcher. Type to search apps, use Up/Down and Enter to choose, and Escape to close. Normal notification popups expire after five seconds by default; hovering pauses expiry.

## Unified controls

- Super+A: app launcher at the bottom.
- Super+W: wallpaper browser in that launcher.
- Super+X or red power icon: the native side session menu.
- Super+Z: hide/show the bar and complete frame.
- Super+O: dashboard; Super+Shift+O: scheme commands in the launcher.
- Hover Wi-Fi, Bluetooth or battery for its native dropdown.
- The power menu suppresses the audio/brightness OSD.

Legacy window/clipboard pickers use the reference palette rather than the old blue theme. Hardware sound and brightness keys operate the system controls directly and use the shell's native OSD.
