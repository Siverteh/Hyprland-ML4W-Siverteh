# Nacre development

This repository owns the current Hyprland Lua configuration, Quickshell desktop,
palette engine, Brain, AI workflow and optional SDDM appearance. See
`docs/architecture.md` for ownership and `docs/maintenance.md` for deployment.

- Start independent changes in an isolated Git worktree. Preserve other checkouts,
  user edits, active assistant workers and browser profiles.
- Read `ai/AGENTS.md` before changing the AI workflow. The private brain and account
  state are external to this repository and must never be committed.
- Source is deployed as copies. Host overrides, generated palettes, wallpaper
  images, credentials and conversations stay outside Git.
- Do not revive retired desktop installers or introduce a second owner for bars,
  notifications, wallpaper, display settings or palette publication.
- Run `python3 tools/check.py` before publishing. It checks syntax, retired paths,
  configuration migration, AI, Brain, shell tools and native Qt tests when present.
- Use `Hyprland --verify-config --config "$PWD/hypr/hyprland.lua"` on the target
  host. Parse QML before deployment and require live IPC/source validation after.
- `./install.sh` prints a plan; `--apply` executes selected components. Configuration
  drift must be reconciled, not overwritten. Do not reinstall AI credentials or
  restart a busy sidebar backend as part of routine UI deployment.
- Retain applicable LICENSE/NOTICE files for adapted code. Old releases remain in
  Git history; the current tree contains only maintained components.

Prefer readable multiline Python and QML over compressed statements. Use Ruff
for Python and qmlformat for QML, keep formatting-only changes separate, and run
the same checks before and after formatting. Generated host language-server
configuration belongs outside Git.

When adding or retiring a component, update `docs/overview.md` and
`docs/architecture.md`. Put feature behavior in that feature's doc, not in
`maintenance.md`. Git history is the changelog.
