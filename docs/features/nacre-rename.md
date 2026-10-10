# Nacre name migration

Nacre is the desktop previously maintained as Siverteh OS. This change renames
its source folder, desktop commands, services, palette Python package, user
preferences and runtime paths. It does not rewrite the inherited implementation,
change the Linux username, replace the underlying CachyOS identity, or move AI
accounts, conversations, credentials or the private knowledge vault.

## Canonical locations

| Component | Canonical path |
| --- | --- |
| Project source | `~/nacre`; old checkout name remains a compatibility link |
| Preferences and private Lua overrides | `~/.config/nacre` |
| Palette and desktop state | `~/.local/state/nacre` |
| Renderer backups and drafts | `~/.local/state/nacre/shell` |
| Palette/image caches | `~/.cache/nacre` |
| Deployed desktop source | `~/.local/share/nacre/shell` |
| Palette Python environment | `~/.local/share/nacre/palette-runtime` |
| Generated branding | `~/.local/share/nacre/branding` |
| Maintenance controller | `~/.local/share/nacre/control` |
| App-scoped Thunar module | `~/.local/share/nacre/thunar-style` |

The current monogram is retained as artwork pending the separate Nacre logo
work. The renderer component is now named `BrandLogo`; copyright holders and
historical attribution in LICENSE/NOTICE are retained.

## Compatibility and recovery

`tools/nacre_migration.py plan` inventories the namespace migration. `apply`
preflights every destination, preserves files and permissions, merges only
non-conflicting entries, journals moves privately, and leaves old directories as
forwarding links. A conflicting destination or modified service causes refusal
before changes. `rollback MANIFEST` reverses the namespace operations; subsequent
data changes are retained rather than replaced with old preferences. The private
journal remains outside either moved root at `~/.local/state/nacre-name-migration`.

The ordinary install plan reports these operations. Installation migrates the
namespace before the existing release transaction snapshots/cuts over source.
During the initial name migration, the renamed palette package was installed
alongside its legacy package for old releases. The independent Orient replacement
now uses a fresh environment; historical packages remain only in recovery data.
Legacy desktop commands forward to the new
commands; the renderer/observer services have backward aliases. Power-key service
retirement requires a confirmed replacement logind inhibitor lease first.

`nacre` replaces the `siverteh-os` maintenance command; `nacre-shell` replaces
`siverteh-os-shell`, and `nacre-app` replaces `siverteh-os-app`. Private AI and
vault commands keep their personal compatibility identifiers. Their visible
product labels use the Nacre desktop branding; their account state is unchanged.

The initial migration requires the configs and shell components together. Keep
private migration journals and the previous validated release until the next
physical login/suspend checks. Release recovery recognizes old service names and
retains enablement when restoring an older snapshot.

## System-owned appearance and timezone

After the user deployment is validated, `pkexec /usr/bin/python3
 tools/nacre_system_migration.py` installs the reviewed root-owned name migration.
It moves the owned greeter/timezone state with compatibility links, retains root
backups and the exact automatic-timezone preference, updates the greeter's Theme
entry, and installs the renamed helper/timer. It does not change PAM, autologin,
login sessions or the current timezone deliberately, and never restarts SDDM.
Until that operation succeeds, user presentation/status can use the old system
integration. Root migration recovery is separate from desktop source rollback.
