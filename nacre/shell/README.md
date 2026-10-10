# Nacre desktop shell

The maintained Quickshell UI lives here: bar/frame, dashboard and twelve Settings
pages, launcher, wallpaper views, notifications, level controls and AI sidebar.
Shared primitives/tokens live in `widgets/`, native state providers in `services/`,
and panel composition in `modules/`. The [system overview](../../docs/overview.md)
and [ownership guide](../../docs/architecture.md) explain the boundaries.

The installed renderer runs a validated copy, not an upstream checkout/submodule.
Native Quickshell/Qt and licensed fonts/icons are dependencies; Nacre source-origin
records live in the [provenance tracker](../../docs/nacre/PROVENANCE.md). Historical
credits and the current project license are scoped in the final comparison.

After source checks and native Hyprland verification, commit the candidate and
review/apply the managed release plan from the repository root:

```sh
./install.sh --component shell
./install.sh --apply --component shell
```

See [maintenance](../../docs/maintenance.md) for drift protection, backups, recovery
and live input gates. The renderer is separate from the persistent sidebar worker;
UI deployment preserves running conversations.

Super+A opens the app launcher; Super+W opens wallpapers; Super+X opens the power
menu. Escape/outside-click dismissal, hover policy, manual pinning and motion are
owned by the frame/panel controllers. Exact preferred visual/animation acceptance
is separate from functional tests and is queued for the next cleanup pass.
