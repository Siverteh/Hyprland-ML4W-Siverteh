# Control center

The right-center frame lip opens the control center. Click a status icon to open
its Audio, Wi-Fi, Bluetooth, Power or Notifications section directly. The full
Settings view remains in the top dashboard for this identity slice.

Horizontal output/microphone levels and explicit mute buttons appear first.
Available display and keyboard brightness controls follow. Opening the panel
never writes levels, powers radios, scans, connects, pairs or starts an AI worker.
Native providers and existing guarded write helpers remain the device owners.

Quick tiles expose connections, power profiles, DND and optional Night light.
Frame, panels and header share one overlay surface, with the header drawn last.
Opening menus or changing keyboard focus cannot raise the frame over the bar. They hide over fullscreen content until a panel is
explicitly opened; passive lips remain blocked there. Detailed connection lists reuse the existing native quick controls and refresh
read-only state on entry. Settings remains available for advanced pairing and
configuration. Notification history has its own bounded fast scroll. Controls
can scroll independently on short outputs, with visible scrollbar hints. Empty,
unsupported, busy and failed-device states are represented explicitly.

Capture, Clipboard, Colors and Picker use existing desktop tools. Capture/Picker
close the menu and wait 320ms before launching the interactive tool, so the panel
is not captured. Clipboard/palette selection use the existing launcher. Optional
binaries are discovered once at startup and on opening, without idle polling.

Night light uses the system hyprsunset service only after explicit activation.
An invocation identifier tracks service ownership; PID reuse cannot claim another
controller. Existing private Hyprsunset configuration or a running unmanaged
socket is treated as external ownership. A failed initial temperature request
stops only the invocation started by Nacre. The private 0600 control-tools record
holds the last successful manual state, not a secret or a system configuration.
External schedule/controller changes are respected rather than overwritten.
Power-profile controls require the system powerprofilesctl/daemon package.

Automatic volume, microphone and brightness changes show a small, short-lived
noninteractive level indicator on the focused output. They never open the full
control center; adjustments inside the open center suppress duplicate feedback.
Its window has an empty input mask and no keyboard focus. Sysfs reads remain
limited to visible controls/indicators, with no periodic DDC monitor reads.

`nacre-shell controls [home|audio|network|bluetooth|battery|notifications]` opens the
same view. The existing right-menu `osd` state name is a compatibility identifier;
the former OSD types only forward to the new control components.
