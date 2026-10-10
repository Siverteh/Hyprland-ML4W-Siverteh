# Integrated panel regression repairs

Restore the user's compact, joined desktop presentation using the independent
Nacre components. This is a behavior specification, not a vendor-source rewrite.

- Live notifications have a continuous body-colored background joining the top
  bar and right frame, with a short downward reveal. Notification history and
  transient-feedback retention policy remain under the existing notification owner.
- Brightness and keyboard sliders form the upper row; output and microphone form
  the lower row. Keep the columns close, remove unused upper-row mute space, and
  contain labels and mute controls. Opening controls never writes device values.
- Spotlight and hexagon galleries are overlays across the available desktop,
  without an enclosing application rectangle or inset wallpaper copy.
  Use a cached wallpaper backdrop across the entire viewport with a subtle scrim
  to conceal applications underneath. Keep the old image opaque during fades. Preserve outside-click, Escape,
  reduced motion, bounded image decoding and one selected video preview.
- Separate media-kind choices from gallery-layout choices with a visible divider;
  wrap these groups on small outputs.
- Browsing any wallpaper layout applies the chosen wallpaper while it remains
  open. Coalesce rapid navigation for 150 ms and serialize publication; the newest
  pending selection wins. Closing must not start a duplicate already-active apply.
  Diagnostic previews remain read-only, and palette/background synchronization
  remains owned by the existing presentation publisher.

Validation: native queue tests must prove publication before closure, pixel tests
must prove notification attachment and absence of full-gallery chrome, geometry
checks must bound slider gaps, and the installed compositor must show the gallery
and wallpaper changing while open. Preserve the starting wallpaper after QA.
