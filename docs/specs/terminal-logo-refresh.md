# Palette-driven terminal branding

The PNG publisher already follows Orient, but a rendered terminal image is a
snapshot. Redraw existing AI menu controllers launched through either their
managed symlink or resolved runtime path, including default/no-argument menus;
never notify AI workers or terminal servers.

For Fastfetch, reuse the managed render-logo.sh startup hook. Prepare a raw Kitty
packet with a unique image id and register the outer persistent terminal shell,
its Linux start time and its PTY's device/inode. Fastfetch loads that per-Kitty
window raw file with a bounded 36-column/16-row slot, preserving its information
layout. The normal palette publisher recolors the existing root frame only with
Kitty's frame-edit API, without creating a placement, moving the cursor, rerunning
Fastfetch, sending keyboard input or enabling animation. Closed/reused shells and
TTYs invalidate their private records. The registry is private, bounded per refresh,
and used only on palette events; no daemon or polling is introduced.

Protocol basis: [Kitty graphics protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/#transferring-animation-frame-data).
This implementation is independently authored against that documented interface;
no Kitty/Fastfetch implementation source is incorporated. Normal session buffers
are the supported path; images made before registration need one Fastfetch rerun.
TMUX/non-Kitty contexts retain text/native fallback behavior.

Acceptance: scoped menu path/default matching, PTY bytes are edit-only/quiet,
PID reuse and arbitrary-output rejection, native Kitty recolors after Fastfetch
exits with its prompt and layout intact, alpha retained. Full source checks,
Hyprland validation, plan/apply/live gates and exact-main CI.
