# Current reader-guide source review

Reviewed 2026-10-10 from `ce528d38575913d9a904aadaa600957e2edb099e` in
`nacre-documentation-source-audit`, following the
[documentation spec](../specs/documentation-source-audit.md).

This batch covers the root README, overview, architecture, maintenance, Brain and
login READMEs, three shell READMEs and sixteen edited feature guides. These are
maintenance/behavior prose, not implementation or a license decision. Current
full bodies, relevant local creation/change history and declared owners were
reviewed. Exact final hashes are recorded in the registry.

Overview, architecture and maintenance were locally authored with the maintained
source/deployment work (`ac96607`, `2fa3a95`). Feature guides were written with
local features and independent rewrite batches; earlier guides were extracted
from local maintenance prose in `9b0d88f`. Brain's guide starts at `e42b701`.
The root README started with the old dotfile tree (`e0ef6d7`); its current body
explains this project's own components and links. The former shell README
(`4874385`) described the reference-era implementation. Its obsolete body is
replaced here with current Nacre ownership and deployment instructions. These
history observations do not establish independent origin for any executable.

Corrections include native Arch/Qt/Lua CI, pacman-owned native dependencies,
initial Orient provisioning, clean committed release candidates, explicit AI
controller-only updates, managed configuration drift versus backed-up runtime
copies, and individually atomic palette outputs. Stale statements about unfinished
providers, popup rewrites and the removed fuzzysort library are corrected.
Wallpaper rotation deadlines now live in Appearance instead of Connections.

A separate read-only reader checked the guides against current sources and local
links. Its corrections distinguish conditional low-level QML parsing from required
pre-cutover tools, restart-safe Brain cookies from rotating bootstrap tokens,
private recovery drafts from excluded passwords/rendered messages, and the Logo
component required by login preview. Neither reader review nor tests establish
legal provenance or complete physical/visual acceptance.

No desktop implementation, installed source, user preferences, credentials or
worker lifecycle changes in this batch. The user-reported title, wallpaper,
right-control, connection/notification and motion/scroll regressions remain queued
for a separate cleanup goal after originality completion. Historical specs/audit
records, other pending guides, license texts, registry metadata and the final
whole-tree/upstream/runtime comparison remain outside this completed batch.
