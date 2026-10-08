# Terminal Branding

[System overview](../overview.md) · [Deployment and recovery](../maintenance.md)

## Terminal workspace logo refresh

The terminal Siverteh AI workspace menu displays a palette-generated Kitty PNG.
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


