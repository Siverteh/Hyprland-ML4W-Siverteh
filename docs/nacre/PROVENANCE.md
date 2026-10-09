# Nacre independent implementation tracker

Status: Orient and first text/surface foundation batch verified, 2026-10-08.
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
| 1 | All `nacre/shell-cli/`; generator imports in `shell-tools/generate-palettes.py`; inherited seed values in `reference-style.json` | verified | [Orient](../specs/orient.md), [comparison](../specs/orient-comparison.md); contract capture/prototype/review precede replacement |
| 2a | `shell/widgets/{StyledRect,StyledText,StyledClippingRect,StateLayer}.qml` | verified | [Design foundation spec](../specs/design-foundation.md); independent Nacre implementations plus compatibility adapters |
| 2b | `shell/widgets/{StyledTextField,StyledWindow,MaterialIcon,Colouriser,CachingImage,VerticalSlider,StyledScrollBar,CustomShortcut}.qml` | audit pending | Remaining controls, media/window and icon batches |
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

## Orient replacement record

- Scope: all inherited implementation/data under `nacre/shell-cli/src/nacre_shell`
  deleted without opening those sources during replacement. Newly authored engine,
  image analysis, role policy, storage and CLI modules implement the behavior spec.
- Contracts: installed CLI help/output, consumer call sites and legacy output role
  names (`nacre/shell-tools/tests/orient-roles.json`); no inherited color values or
  algorithm used. Existing preset IDs/seeds from our preset UI are retained; all
  mode colors and the default seed file are independently generated through Orient.
- References: Björn Ottosson's public-domain OKLab equations, W3C color standards,
  Pillow image/profile API. Pillow 12.3.0 is the only runtime dependency; Material
  You is absent from the new environment. Existing LICENSE/NOTICE retained.
- Integration: publisher retained, query bridge narrowed, complete cache identity,
  mode/variant/override watcher invalidation, immutable environment activation and
  byte-backed runtime rollback. Publisher/helpers are not certified original here.
- The separate prototype/user-review gate was explicitly superseded by the user's
  request for direct production implementation. Synthetic fixtures, private visual
  inspection, full checks and live release gates remain acceptance requirements.
- Replacement commit: `5ecf556`; public command bridge correction follows in the
  same area branch. Source checks passed 303 tests before initial deployment;
  an additional regression covers the corrected public entry points.
- Private audit: all twenty library wallpapers/posters visually inspected; 240
  uncached extraction+generation operations p95 92.98ms; 240 warm reads p95 0.34ms;
  audit-process peak 122.4MiB on ASUS UX3405CA, Intel Core Ultra 7 255H.
- Initial shell-only deployment promoted release `20261009T011237458253Z`; native
  source/IPC and real launcher/wallpaper Escape gates passed. Active runtime
  contains only Orient, Pillow and pip, with no Material You. Current scheme is
  dynamic/dark, with source diagnostics and identical matched presentation colors.
  Hyprland configerrors empty; shell/power/session services active; no failed units.
- The old black-box compatibility test inherited real XDG roots despite a temporary
  HOME. It changed scheme state to default/light; live validation caught this and
  restored the previously recorded dynamic/dark choice through the locked publisher.
  Production tests explicitly isolate HOME and all three XDG roots. Public routing
  is now regression-tested so queries do not open panels or republish palettes.
- Scope of verification: engine/contracts/cache/contrast and live shell operation,
  generated theme files and publication pairing. Physical next-login, full visual
  inspection of every external toolkit app and a secure lock/unlock cycle are not
  established by these checks. Other inherited areas remain audit pending.

## Foundation text/surface replacement record

- Spec: [design foundation](../specs/design-foundation.md), authored before source
  replacement in this area branch. Four inherited bodies deleted and recreated
  as thin adapters to independently authored primitives and NacreTokens.
- Contract basis: current consumer usage, deployed QObject property inspection
  and behavior measurements. No target implementation bodies opened during this
  replacement; preliminary broad search exposed a couple of public declarations
  before target paths were excluded. No upstream implementation sources consulted.
- References: public Qt Text/MouseArea/PropertyAnimation and Quickshell
  ClippingRectangle APIs. Clipping internals remain third-party dependency code.
- Legacy dependencies retained: Colours, Appearance, desktop settings, fonts/icons
  and other widgets/services/config. This is not completion of the whole foundation
  or authority to remove any shared NOTICE/LICENSE.
- Validation: real new primitives and ActionButton under Qt; actual Quickshell RHI
  clipped-circle pixels; private native component sheet inspected. Chat and quick
  controls fixtures use the actual new interaction/token dependencies.
- Spec commit `64e0dcd`, implementation `cb07776`. All 311 checks passed, including
  native Qt input/text and actual Quickshell RHI clipping pixels; Hyprland config
  verification passed. CI adds Mesa for the graphics capture under Xvfb.
- Shell-only deployment promoted good release `20261009T032125352245Z`; installed
  primitive bytes match the candidate, native IPC/source checks and actual
  launcher/wallpaper Escape gates passed. No new-widget runtime errors or failed
  user units found; configerrors empty. Approved richer Orient engine unchanged.
- Remaining acceptance: physical cold login/lock and complete assistive-technology
  coverage are not established. Icon-only labels, shared controls and config/provider
  replacements remain their own batches. No license/notice removed.
