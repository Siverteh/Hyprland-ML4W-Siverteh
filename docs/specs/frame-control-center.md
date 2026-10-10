# Nacre frame lips and control center

Keep the full top dashboard, approved logo, wallpaper palette and persistent AI
workflow. Establish the first visual identity slice using the existing shared
panel state and device/notification providers.

Three permanent shallow curved lips mark top-center, left-center and right-center.
They overlay current reserved edges; they never change application geometry.
Hover opens only marked targets, without keyboard focus; click opens deliberately.
Click-only preference, held-button/fullscreen guards, explicit dismissal rearming,
Escape, outside-click, explicit-only AI pinning and reduced motion remain supported.
The lips are shallow smooth curves, unoutlined, with no seam or frame ring:
5px beyond the side frame and 6px beneath the bar. The top shape overlaps the
bar by1px; cubic control points are chosen so side tips reach the stated depth. They follow their panel
edges throughout opening and closing without changing application allocation. The top
activation column spans its 208px visual length all the way to the screen edge;
bar and lip hover sources combine so moving between them keeps the menu open.

Right-center opens a bounded 400–440px control center, adapting to small outputs.
Horizontal volume/mic and display/keyboard controls remain immediately accessible.
Mute is explicit; unsupported brightness controls hide. Wi-Fi, Bluetooth, power,
DND and available night-light tools expose actual existing state/actions. Device
icons open the matching control-center section on click; hover shows a tooltip.
Notifications have their own bounded fast scroll, separate from primary controls.
Screenshot/color-pick actions dismiss before capturing; clipboard/appearance route
through the existing launcher/settings. Detailed Settings remains in the current
top dashboard in this slice.

Automatic audio/brightness feedback is a separate noninteractive short indicator,
never the full control center. Opening controls never changes hardware, scans,
connects or launches AI. Optional tools are capability-aware. Night light uses the
packaged hyprsunset service only on explicit action and respects external ownership.
No idle motion, permanent polling or extra video decoding is added.

Validation includes real service/state and native UI tests, rapid reversal,
small/fractional viewports, input release during closing, masked lip hit targets,
held-button/fullscreen guards, device absence, scroll isolation and no writes on
opening. Complete source checks, Hyprland verification, plan/apply and live
compositor input/source gates precede publishing; preserve worker identity.

The header and panels must be children of the same per-output surface, with the
header drawn above frame chrome and included in the shared input mask. A second
bar layer surface is forbidden: compositor focus can raise same-layer windows.
Verify the actual tiled workspace through modal transitions, not only a separate
floating validation window.

For discoverability, tint only the protrusion from body at the join to primary
at its outer tip. Keep geometry/masks and frame pixels unchanged. Hover/open may
strengthen the accent with a finite reduced-motion-aware transition, never an
idle animation or palette-publication delay.
