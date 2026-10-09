# Nacre independent implementation tracker

Status: planning inventory, 2026-10-08. No replacement has been completed here.
[Orient specification](../specs/orient.md) is the first ready spec.

## Goal and evidence

Replace implementation derived from Caelestia shell/CLI and ML4W dotfiles before
extracting the general public Nacre version. Quickshell, Qt and properly licensed
libraries remain legitimate dependencies. Existing notices stay during transition.
A rename, formatting pass, rewritten spec or low line-similarity score is not proof
that an implementation is independent. Final licensing needs a complete source,
asset and dependency review; this tracker does not authorize removing notices.

The initial inventory below comes from the user's review list and the current
source tree. Its inheritance claims and percentages have not been independently
reproduced. Include mixed/uncertain files in the audit rather than certifying them
by omission. No upstream implementation was consulted to draft these specs.

## Workflow

One area per isolated branch and commit series. Write the behavioral spec first,
implement independently, keep relevant behavior tests, and deploy only after checks
and review. Use small foundation batches rather than one all-widget cutover.

States: **audit pending → spec ready → implementing → replaced → verified**.
Verified requires origin records, dependency/asset notices, tests and live evidence.
For every replacement record: exact paths, prior inheritance evidence, spec link,
replacement commit, implementation references, dependencies/licenses, test evidence,
live gate and any remaining derived adapters. Preserve rollback until proven.

## Initial areas and proposed order

| Order | Area / current paths | Status | Spec and remaining work |
|---|---|---|---|
| 1 | All `nacre/shell-cli/`; generator imports in `shell-tools/generate-palettes.py`; inherited seed values in `reference-style.json` | spec ready | [Orient](../specs/orient.md), [comparison](../specs/orient-comparison.md); contract capture/prototype/review precede replacement |
| 2 | `shell/widgets/{StyledRect,StyledText,StyledTextField,StyledClippingRect,StyledWindow,StateLayer,MaterialIcon,Colouriser,CachingImage,VerticalSlider,StyledScrollBar,CustomShortcut}.qml` | audit pending | Separate surfaces/text, interaction/input, and media/window batches |
| 2 | `shell/config/{Appearance,BarConfig,DashboardConfig,LauncherConfig,NotifsConfig,OsdConfig,SessionConfig,BorderConfig}.qml`; `shell/utils/{Icons,Paths}.qml` | audit pending | Design tokens and compatibility boundaries; final fonts/icons remain undecided |
| 3 | `shell/modules/launcher/{Content,ContentList,AppList,AppItem,Actions,ActionItem,WallpaperItem,WallpaperList}.qml` | audit pending | Include imports/helpers and current categories/favorites behavior |
| 4 | `shell/modules/notifications/{Notification,Content,Wrapper}.qml` | audit pending | Popups/history/filtering/accessibility |
| 5 | `shell/modules/drawers/{Drawers,Interactions,Panels,Exclusions}.qml` | audit pending | Frame, layer surfaces, focus and edge intent; inspect newer `FrameSurface` integration too |
| 5 | `shell/modules/bar/popouts/{Battery,Content,Wrapper}.qml`; `bar/components/{ActiveWindow,Power,StatusIcons}.qml`; current `modules/topbar/` | audit pending | Verify maintained versus unused code before rewriting |
| 6 | `shell/modules/dashboard/{Tabs,Content,Dash,Wrapper,Media,Performance}.qml`; `dashboard/dash/{DateTime,Media,Resources,User,Weather}.qml` | audit pending | Include current Settings and lock presentation dependencies; one page/group at a time |
| 7 | `shell/services/{Colours,Hyprland,Players,SystemUsage,Bluetooth,Apps,Thumbnailer,Time,Network,Audio,Brightness}.qml` | audit pending | One service per task; advance a service if a preceding UI area needs it |
| 7 | `shell/modules/osd/{Wrapper,Interactions}.qml`; `session/Wrapper.qml`; `background/Background.qml`; `modules/Shortcuts.qml` | audit pending | Small wrappers plus runtime import/dependency audit |
| 8 | `shell/assets/bongocat.gif`, `shell/utils/scripts/fuzzysort.js`, Material Symbols, `shell-tools/reference-style.json` | audit pending | Remove unused/unclear artwork; replace search or retain correct MIT attribution; independent seed in Orient task |
| 8 | `kitty/kitty.conf`, `fastfetch/config.jsonc`, `hypr/conf/{misc,decoration,nacre}.lua` | audit pending | Independent minimal defaults, unused app rules and stale headers; confirm actual renamed paths |
| Final | Remaining QML/JS/Python/Lua, assets, tests, generated files and packaging | audit pending | Review beyond the supplied list; document dependencies and perform provenance comparison |

Paths beginning `shell/` or `shell-tools/` above are under `nacre/`. Brace notation
lists separate files; it is not a shell command. The review's old
`hypr/conf/siverteh.lua` is now `hypr/conf/nacre.lua` (confirmed in the current tree). Do not remove app rules based solely on the review's assumptions.

## Per-area completion record

Use this template when an area starts:

- Area, exact files and inheritance evidence:
- Spec and contract/test fixtures:
- Independent implementation references and new dependency licenses:
- Replacement commits and deleted inherited paths:
- Required checks and visual/device acceptance:
- Deployment/recovery evidence and remaining limitations:
- Retained derived code, assets or adapters:
- Reviewer and verified date:

The general public extraction, host/personal-data separation and final license
choice follow this rewrite and final audit. No public repository transfer or
runtime path consolidation is part of these documentation changes.
