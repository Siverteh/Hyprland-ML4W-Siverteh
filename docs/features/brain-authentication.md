# Brain browser authentication

Brain listens on loopback. Public health returns readiness only. Every other
`/api/` read and action requires the private browser cookie; Host checks and
same-origin JSON action checks remain in force.

The service creates a random startup bootstrap token in a 0600 file. Private
local HTML opens the authenticated URL without putting the token in launcher
arguments. That request sets an HttpOnly, SameSite=Strict cookie and redirects to
`/`, so the token is removed from the visible URL. HTTP request logging is disabled.
The cookie credential is separately retained in a private 0700 directory/0600
file, allowing an existing browser session to reconnect after server restarts
without losing its current page or capture dialog. Bootstrap tokens rotate on
each start, and old bootstrap URLs stop working.

The first upgrade of an already-open unauthenticated profile uses a small
non-focusing credential handoff which closes automatically. Later server restarts
reuse the authenticated session. Clearing browser cookies requires reopening Brain
through its native launcher. No password prompt or new account is introduced.

This protects network-facing access, including network-only apps. Processes with
full access to this user's filesystem already have access to the vault and these
private credentials; the feature does not change the deliberately full-access
Codex/Claude workflow. Auth files, browser profiles and conversations stay outside
Git and desktop source snapshots.
