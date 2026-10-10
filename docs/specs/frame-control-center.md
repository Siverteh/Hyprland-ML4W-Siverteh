# Nacre frame lips and control center

Keep the full top dashboard, approved logo, wallpaper palette and persistent AI
workflow. Establish the first visual identity slice using the existing shared
panel state and device/notification providers.

Three flat edge handles mark top-center, left-center and right-center. They
follow their panel edges throughout opening/closing without changing application
allocation. Their current shape, rim and motion follow [iridescent frame](iridescent-frame.md),
which supersedes the earlier domed size/tint trials. Keep wider208px top and144px
side hover regions and the full bar above the top target up to the screen edge.
Hover opens only marked targets without taking keyboard focus; clicks open
explicitly. Click-only, fullscreen/held-button guards, dismissal rearm, Escape,
outside click, explicit-only AI pinning and reduced motion remain supported.

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
