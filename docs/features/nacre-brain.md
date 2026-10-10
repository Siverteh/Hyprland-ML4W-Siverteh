# Nacre Brain

Launch **Nacre Brain** from the app launcher, press Super+B, or run `nacre-brain`.
The shell mark has a small two-tone brain beneath its right overhang. Its two
lobes use primary and secondary colors, with contrasting folds. The launcher
icon and web header follow the palette; no idle animation or polling is added.

`nacre-brain search WORDS`, `note`, `path` and the existing vault commands retain
their behavior. `nacre-brain-maintain` manages checks/backups and
`nacre-brain-sync` performs the existing three-way private sync. The knowledge
service is `nacre-brain.service`; sync/check timers use the same prefix.

Canonical paths:

- Vault: `~/Documents/Nacre-Brain`
- Runtime code: `~/.local/share/nacre/brain`
- Private state and browser authentication: `~/.local/state/nacre/brain`
- Dedicated browser profile: `~/.local/share/nacre/brain-browser`
- Sync configuration: `~/.config/nacre/brain-sync.json`

Deployment reviews the namespace plan before writing. The existing migration
helper journals moves and refuses conflicting destinations or edited legacy
units. Notes are moved intact rather than rewritten. Obsidian's registration is
updated with a backup, preserving its vault ID and unknown fields. The old paths,
commands and unit names remain compatibility aliases for existing conversations
and browser windows. New callers use the Nacre names. An explicit `NACRE_BRAIN`
setting takes precedence; existing `SIVERTEH_BRAIN` overrides remain supported.
Older remote sync hosts keep their legacy exchange command until migrated.

The service stops for code cutover; the browser profile and other assistant
workers stay running. Existing cookie state moves with the private state, keeping
browser authentication intact. No passwords, vault content or browser data enters
Git or desktop release snapshots. Keyring lookups accept legacy stored secrets;
new secret references use `secret-service://nacre-brain/NAME`.

Inspect and deploy with the usual checks and `./install.sh` plan/apply. Existing
repository-linked vault helpers may need `--migrate-owned`; the plan must recognize
their source ownership. Namespace journals live under the private
`~/.local/state/nacre-name-migration` directory. `brain/migrate.py` exposes
`rollback(journal)` for reversing a reviewed move, including Obsidian registration,
while refusing later edits. See [maintenance](../maintenance.md).
