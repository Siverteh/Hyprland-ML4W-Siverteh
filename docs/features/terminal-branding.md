# Terminal Branding

[System overview](../overview.md) · [Deployment and recovery](../maintenance.md)

## Terminal workspace logo refresh

The terminal Nacre AI workspace menu displays a palette-generated Kitty PNG.
Its input loop normally waits for a key, so updating the file alone can leave
that graphic stale while terminal text colors have already changed. The existing
palette publisher now creates the brand assets immediately after presentation
publication and notifies only same-user Python controllers running the exact
managed `siverteh-ai dashboard` command. A stable Linux process handle and argv
recheck keep that notification scoped. Ncurses' normal resize/redraw event wakes
the idle menu and retransmits the logo while retaining selection and query.
Kitty servers, assistant workers and unrelated processes are excluded. No polling
loop, keyboard injection, menu restart or second brand producer is added. Native
pseudo-terminal tests verify a new graphics packet without sending a key.
The Qt sidebar uses live SVG palette bindings and is a separate rendering path.



## Independent terminal defaults

Kitty's static configuration is now a small Nacre-owned baseline. It retains the
current font, geometry, scrollback and cursor settings, then loads the private
palette and optional custom.conf. The optional file uses globinclude, so absence
is quiet; private colour publication still owns opacity/selection colours.

Fastfetch uses an independent plain Nacre information layout and the existing
private palette-coloured logo. Filesystem age validates root birth time and shows
Unknown for unsupported/future dates; it is not labelled OS installation age.
The logo generator and helpers have separate completed source reviews.

`python3 nacre/shell-tools/branding.py --build` regenerates repository SVG, QML
and the shared web symbol only. It uses the current NacreColours provider and
native formatter; running it twice should produce no diff. Live logo publication
is a separate default invocation or the palette publisher's publish() call.
The user-approved shell master lives in `nacre/shell/branding/nacre-master.svg`.
Colored, compact, symbolic, QML/web, PNG and text outputs derive from that one
source. Compact bar/sidebar marks retain the chamber colors without tiny gloss
overlays; larger marks retain the pearl shading. Palette bindings and publication
change colors only when needed. Lock and terminal PNGs both keep alpha so Kitty can supply its own
background and transparency. Native librsvg rasterizes static PNGs during publication.
Legacy private sh.* files contain the new shell only for already-open controllers.

Open the AI menu with `nacre-ai`. Desktop actions use that public entry point; it
executes the existing controller so scoped logo refresh and ongoing sessions keep
working. The legacy command is still accepted.
