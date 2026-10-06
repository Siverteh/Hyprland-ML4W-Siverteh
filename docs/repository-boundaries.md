# Optional repository boundaries

Keep the current repository while improving its documented interfaces. The
renderer, AI worker and Brain already run separately, and routine desktop changes
preserve account state and active workers. Separate Git repositories would make
release ownership clearer, but would also add version coordination and installers.

A practical later split would proceed in this order:

1. Define versioned sidebar/Brain capability and data contracts. The desktop must
   remain usable when either service is absent, starting or unavailable. Give each
   component its own health gates instead of requiring all services for every
   desktop-only release.
2. Move `ai/` and its owned commands into an AI-workflow repository; move `brain/`
   into a Brain repository. Keep the shell, palette, compositor and terminal
   configuration here. The private vault, credentials and conversations stay
   outside every repository.
3. Pin compatible releases, transfer installer ownership manifests and preserve
   existing command aliases and profile paths. Test fresh installs, independent
   updates, unavailable backends and rollback before changing the live installation.
4. Publish the split only after those checks, with a migration guide and a rollback
   revision for each component. Moving files alone would not establish isolation.

## Historical artwork

The current source tree excludes personal wallpaper payloads. Previous public
commits still contain artwork that was removed during cleanup. Removing those
objects would require a coordinated history rewrite and force-push: affected
commit IDs change, clones/worktrees must be reconciled, and old source references
and review links need care. Rewriting does not retract copies already downloaded.

There is no operational need to rewrite this small repository during a desktop
maintenance pass. Document the distinction now; if a later rewrite is desired,
prepare a private repository backup, inventory all active worktrees and references,
review exactly which historical paths are removed, and schedule the coordinated
cutover separately.
