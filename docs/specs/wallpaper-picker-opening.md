# Open on the active wallpaper

Opening the picker should reveal the current wallpaper already centered. Treat
initial loading, catalogue reconciliation and reopening as selection snapshots,
not navigation gestures. Complete any old travel animation, disable travel's
Behavior for reconciliation, then set its target directly to the selected index.
Enable smooth travel only for deliberate browsing. Late current-path data should
update the initial selection, but never override a user's subsequent navigation.
Do not write a new wallpaper or preferences merely to initialize the view.

Acceptance: first construction at a nonzero index has travel equal to that index;
reopening during unfinished movement snapshots the new current path; a late
catalogue/current path also snaps correctly. Existing carousel/spotlight tests
must still observe intermediate navigation positions. Native QML, full source
checks, Hyprland, plan/apply and live keyboard/source gates remain required.
