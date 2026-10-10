# Nacre independent implementation tracker

Status: Orient, foundation/frame/launcher/notices/dashboard/Settings, initial
services and presentation/wallpaper/weather providers, all bar/popups, OSD/session/
background and topbar/hover verified. Root/shortcuts/panel-state also verified. Other state/helpers/extras/config/assets and whole-tree audit remain;
2026-10-09.
[Orient specification](../specs/orient.md) is the first ready spec.

See the [whole-current-tree audit](CURRENT-TREE-AUDIT.md) for repeatable coverage
and explicit pending reviews beyond this initial list.

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
| 2b | `shell/widgets/{StyledTextField,StyledWindow,MaterialIcon,Colouriser,CachingImage,VerticalSlider,StyledScrollBar,CustomShortcut}.qml` | verified | [Controls and helpers spec](../specs/foundation-controls.md); native contracts and compatibility adapters |
| 2 | `shell/config/{Appearance,BarConfig,DashboardConfig,LauncherConfig,NotifsConfig,OsdConfig,SessionConfig,BorderConfig}.qml`; `shell/utils/{Icons,Paths}.qml` | verified | Independent Nacre config/utility providers; final fonts/icons remain undecided |
| 3 | `shell/modules/launcher/{Content,ContentList,AppList,AppItem,Actions,ActionItem,WallpaperItem,WallpaperList}.qml` | verified | [Launcher spec](../specs/launcher.md); independent assembly and all app/wallpaper views |
| 4 | `shell/modules/notifications/{Notification,Content,Wrapper}.qml` | verified | [Notification spec](../specs/notifications.md); presentation replaced, service remains separate |
| 5 | `shell/modules/drawers/{Drawers,Interactions,Panels,Exclusions}.qml` | verified | [Frame/panel spec](../specs/frame-panels.md); ownership and live contracts next |
| 5a | `bar/components/{ActiveWindow,Power,StatusIcons}.qml`; `bar/popouts/{Battery,Calendar}.qml` | verified | [Bar spec](../specs/bar-controls.md); CalendarGrid retired |
| 5b | `bar/popouts/{Audio,Network,Bluetooth,Notifications,QuickList,QuickSlider,Content,Wrapper}.qml` | verified | [Quick popup spec](../specs/quick-popups.md); native routes/lifecycle accepted |
| 5c | `modules/topbar/`; `services/HoverIntent.qml` | verified | [Top bar/hover spec](../specs/topbar-hover.md); independent assembly/policy and old-name adapters |
| 6 | `shell/modules/dashboard/{Tabs,Content,Dash,Wrapper,Media,Performance}.qml`; `dashboard/dash/{DateTime,Media,Resources,User,Weather}.qml` | verified | [Dashboard spec](../specs/dashboard.md); assembly, cards, pages and Settings replaced |
| 7 | `shell/services/{Colours,Hyprland,Players,SystemUsage,Bluetooth,Apps,Thumbnailer,Time,Network,Audio,Brightness,Notifs}.qml` | verified | Eleven listed providers replaced; unused Thumbnailer retired. Other mixed providers/helpers and whole-tree audit remain |
| 7a | `modules/osd/`, `modules/session/`, `modules/background/` wrapper/control/renderer bodies | verified | [Desktop wrapper spec](../specs/desktop-wrappers.md); native controls/media/lifecycle verified |
| 7b | `modules/Shortcuts.qml`; root shell, shared playback/state helpers | audit pending | Keep data/input ownership and private behavior; full-body audit/replacement required |
| 8 | `shell/assets/bongocat.gif`, `shell/utils/scripts/fuzzysort.js`, Material Symbols, `shell-tools/reference-style.json` | partly verified | Bongocat/fuzzysort retired; independent seed in Orient. Stock font/icon license audit remains |
| 8 | `kitty/kitty.conf`, `fastfetch/config.jsonc`, `hypr/conf/{misc,decoration,nacre}.lua` | verified | [Configuration spec](../specs/config-defaults.md); live baseline preserved and unused inherited rules retired |
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

## Foundation controls/config replacement record

- Spec commit `124c496`, authored before deleting the eight inherited widget bodies,
  eight config bodies and Icons/Paths helpers. New implementations use native Qt
  controls/effects and Quickshell window/shortcut/desktop entry APIs. Public property
  values/layout sizes were observed through deployed QObject contracts and callers.
- No upstream sources consulted. BorderConfig's body was read for the frame-color
  diagnosis before replacement; this is recorded rather than claiming a legal
  clean-room process. Other target bodies were deleted without opening them during
  replacement. Existing third-party notices/fonts/services remain.
- Maintained callers use Nacre names; newly written legacy adapters contain no
  former implementation. Mechanical caller/test renaming is not itself a rewrite
  of the surrounding inherited panels/services.
- New native tests exercise editing, validation, selection, Escape, slider writes,
  attached scrollbar geometry, config/motion/chrome binding and image handle cleanup.
  The window contract was also probed through a hidden native Wayland window;
  passive focus and `nacre-` namespace are retained. Live deployment verified below.
- Candidate validation: 311 repository tests passed, including sixteen native
  foundation test functions and actual RHI clipping capture. Hyprland config
  verification passed; install plan selects only the shell component. Runtime
  deployment evidence will be recorded after promotion.

- Implementation `9a3b9a7` deployed as good release `20261009T034459081314Z`.
  Native IPC reports frame/body agreement, window layers retain `nacre-` namespaces,
  installed Nacre providers/primitives match source bytes, launcher/wallpaper stay
  open until actual Escape and configerrors are empty. The old hover-visibility
  binding-loop warnings predate this replacement; full panel redesign remains
  separate. Physical cold login/secure lock and every external app are not verified.

## Orient harmony refinement

The independent engine now offers optional supporting-color Harmony (Natural is
still the richer default), fuller dark container tint, monochrome role correction
and persistent accent handling through smart-mode generation. No Material You
algorithm/dependency was added. Ranking/coverage and OKLCH role policies are
specified in [Orient harmony](../specs/orient-harmony.md). Licensed sampled fixture
records retain their attribution; source artwork and native comparison renders
remain private QA artifacts. All 318 repository checks passed before deployment,
including native Settings selection and cache/preference/contrast regressions.

- Harmony implementation `9c9089f` deployed as good release
  `20261009T035722984127Z` (Orient `orient-2.0.0-69aec8b65d70`). Full 318 checks,
  Hyprland verification, native source/IPC and actual launcher/wallpaper Escape
  gates passed. Live IPC toggled Harmony on/off, preserving the active wallpaper
  and selected accent and matching published primary/secondary/body colors. Natural
  was restored afterwards. configerrors empty; no failed user units. Native dark
  and light comparison sheets inspected for four licensed illustrations. Cold
  login and full external-toolkit visual checks remain outside this evidence.


## Frame/panel implementation record (candidate)

- Spec b0dd275 preceded replacement. Five old drawers files removed, including
  the uncertain newer FrameSurface rather than certifying its origin from Git
  creation alone. Fresh NacreDesktop/Screen/PanelHost/Input/Mask/ReservedEdges/Chrome
  and registry.js implement the contracts using public Qt/QS APIs. The separate
  LeftHotspot surface is removed; its read-only leftEdge IPC remains compatible.
- Prior source exposure to Drawers/Panels/FrameSurface portions is acknowledged.
  No upstream sources or target bodies opened during this replacement. Consumer
  contracts, observed namespace/layer/IPC behavior and geometry tests establish
  behavior. OSD helper and composed wrapper/service bodies remain inherited or
  mixed pending their own rewrites; their APIs were consulted as consumers.
- Actual Qt input tests cover click-away, closed-geometry release, pinning, hidden
  masks, coordinate updates, passive child input and hover dismissal. Native RHI
  capture checks actual frame/joins, palette updates, disabled edges and Regions;
  ownership tests prove older teardown cannot remove newer/other output objects.
  A hidden native Wayland window probe verifies None/Exclusive/None policy values;
  that property test does not establish actual compositor focus or application input.
- Candidate/live deployment gates remain required. Repository notices retained.

- Candidate checks: 320 repository tests passed (31 tools, 96 AI, 35 Brain,
  158 shell); all QML parsed/formatted and native geometry/input/registry tests
  passed. Hyprland verification and the shell-only install plan passed.

- Frame live acceptance completed at `7f71503`: all321 checks and Hyprland verification
  passed; installed frame/header bytes match, configerrors empty. Real Wayland
  launcher/wallpaper open/remain/Escape gates passed. A private persistent-pointer
  test app on an unused workspace passed six lower-header→title open/close cycles,
  post-hover application clicks/keyboard, launcher off-click then application input,
  and wallpaper off-click on the separate top bar. Workspace/focus/cursor restored.
- Directly teleporting from a previous Escape-blocked title point into that same
  guarded band did not open it; diagnostics proved pointer delivery, no fullscreen
  or held button and a blocked dismissal flag. Entering the lower bar re-arms it.
  The acceptance route now follows this physical path; no assertion that all
  synthetic teleports or physical multi-monitor/cold-login cases are validated.
- Unnecessary modal HyprlandFocusGrab candidate239af3a failed activation and rolled
  back automatically. Final implementation uses no such grab. High-z top-bar
  PointHandler is visible only during explicit modal interaction; regular hover
  and existing child clicks remain available. The direct press observer must be
  in front to observe child MouseArea presses. Read-only header-OUTPUT diagnostics
  provide current coordinates/guard/modal state, without polling or mutation.


## Launcher assembly replacement record (candidate)

- Spec47ce572 preceded deletion of the inherited Wrapper, Content, ContentList,
  AppList, AppItem, Actions, ActionItem, WallpaperList and WallpaperItem bodies.
  NacreLauncherPanel is a fresh mode loader/finite clipping wrapper;
  NacreSearchPanel replaces the legacy query/action path using current backend APIs.
- Prior wrapper public contracts were read during frame work. Target bodies were
  not opened/copied during replacement, and no upstream sources consulted. Qt
  Loader/NumberAnimation and current service consumers/tests define contracts.
- Actual replacement tests cover lazy open/close/reversal/unload, all mode routing,
  gallery metrics/navigation and legacy search/known actions/Enter/Escape/empty
  results. Data/page providers are isolated; these tests do not certify existing
  AppGrid/WallpaperGallery implementation origin or every native focus behavior.
- Newer local view bodies and launcher.js remain audit/replacement pending. Frame
  host now composes NacreLauncherPanel. Repository notices stay until final audit.


## Launcher and wallpaper view replacement record (candidate)

- In addition to the removed reference-era stack, all six maintained local view/
  helper bodies (AppGrid, launcher.js, WallpaperGallery/Hex/Backdrop/MotionPreview)
  were deleted and independently recreated as NacreAppBrowser, app-browser.js,
  NacreWallpaperPicker/Hex/Backdrop/Motion. Creation metadata was insufficient to
  certify independence, so no uncertain body was retained for expediency.
- Contract basis: established behavior docs, source consumers, public declarations
  and actual UI tests. Existing app/wallpaper tests retain semantics and now load
  actual replacements. Source bodies were not opened during replacement; public
  declarations of the local app/gallery were searched for assembly sizing/contracts.
  No upstream implementation consulted; notices retained until whole-tree audit.
- Preserved favorites/categories/search/context/prefs/keyboard/6rows, all wallpaper
  filters/layouts/navigation/import/dynamic preview and per-output frame APIs.
  Owned code centralizes category metadata, finite geometry/wraparound, cache decode
  bounds, polygon containment, native clipping and buffer-ready presentation.
- Native rendering sheets inspected using generated art and fake service data;
  missing headless icon-theme assets are distinguishable from normal app metadata.
  Real native pixel regression checks hex corners and actual NacreClip pixels.
  Existing catalogue/services/extra modes and their underlying bodies remain pending
  independent areas. Full candidate checks/live deployment still required.

Candidate acceptance additions (2026-10-09): native generated GIF and MP4
previews produced distinct decoded frames and fully stopped on disable. Icon
lookup uses the documented checked-icon API with a palette-aware fallback.
Preview-only navigation cannot apply/commit a wallpaper. Native test processes
explicitly enable their completion-marker logging instead of inheriting the
host's `*.debug=false`; pixel and interaction assertions remain unchanged.

Launcher verification milestone (2026-10-09): `bc7c7e2` deployed as good
release `20261009T114301541106Z`; all 323 repository tests, native Qt parsing/
formatting, Hyprland verification and real compositor startup/Escape gates pass.
Additional live checks cover compact Favorites/reset, All apps six-row height,
modal outside click, and static/dynamic navigation plus normal-mode Escape for
Carousel, Spotlight and Hexagons. Preview-only navigation preserves the selected
wallpaper; original picker kind/layout restored. Installed QML matches source;
configerrors empty. Testing used one physical output and synthetic input, not a
cold-login or multi-monitor claim. Services/extra modes/history providers remain
separate pending areas. Notices remain until whole-tree audit.

## Notification presentation replacement record (candidate)

- Deleted inherited modules/notifications/{Notification,Content,Wrapper}.qml
  bodies without opening them. Fresh NacreNotice and NacreNotificationStack
  implement the documented data/consumer contracts and own measured layouts,
  drag/dismiss/expand/action/keyboard behavior and bounded popup scrolling.
- Source exposure: public property declarations and caller references searched;
  no upstream body consulted. Existing Notifs, policy/history helpers, bar history
  container and settings remain separate pending areas. No licensing removal.
- References: Qt Quick layout/input/text APIs and Quickshell NotificationAction
  invoke plus checked iconPath APIs. No new dependencies/assets.
- Actual production UI tests cover long-text bounds/plain text, close/right-click,
  expansion, current default versus unrelated/frozen actions, keyboard and drag,
  burst cap/suppression/hover release. Native rendering of compact/expanded cards
  with synthetic messages reviewed. Full checks/live acceptance still pending.

Notification presentation acceptance (2026-10-09): code `e869927`, good release
`20261009T115152687966Z`. All 324 checks, QML formatting/parsing, Hyprland
validation and compositor launcher/Escape gates pass. Real transient notification
hover pauses expiry; dashboard suppression releases hover without deleting the
popup, expiry resumes afterward, and exact-ID close removes the fixture. Private
history count remained 44. Installed presentation matches source and configerrors
are empty. Synthetic native visual review and one-output virtual pointer checks
do not establish physical multi-output/cold-login behavior. Existing providers
remain explicitly pending; no license/notice retired.

## Dashboard assembly batch (verified; page bodies pending)

- Deleted inherited Tabs/Content/Wrapper bodies without opening them; fresh
  NacreDashboardPanel and NacreDashboardNavigation implement page loading,
  measured viewport/clipping, immediate selection, Settings pin and closing
  teardown. Page bodies and settings/helpers remain pending, not certified.
- Contract basis: public required property/import declarations, frame/service
  callers, live five-tab observation and dimension measurements. No upstream
  implementation consulted. Body color comes from NacreTokens, not a copied
  reference theme. Native Qt/Quickshell dependencies and notices retained.
- Actual replacement tests cover all pages/required bindings, clicked immediate
  underline/pinning, lazy lifecycle, fixed closing geometry, reopen, hidden
  updates, Escape, viewport bounds and reduced motion. Full/live checks pending.

Dashboard assembly verification (2026-10-09): implementation `1cd6ab7`, all
325 checks, QML formatting/parsing, target Hyprland validation and actual release
launcher/Escape gates passed. Live pointer clicks switched all five tabs; only
Settings acquired modal focus. Appearance page routing, real Settings Escape and
outside click passed. Dashboard native capture visually reviewed, page geometry
within output bounds, installed source matched and configerrors empty. Retained
page/card/settings/service bodies are still pending; this verifies assembly only.
No license/notice removed and physical multi-monitor/cold login remain untested.

## Dashboard overview cards (verified; services/larger pages pending)

- Deleted dashboard/Dash.qml and dash/{Weather,User,DateTime,Calendar,Resources,
  Media}.qml without opening their bodies. New NacreOverview and overview/
  Nacre{Weather,Host,Clock,Calendar,Resource,Media}Card plus NacreOverviewCard and
  overview.js implement the behavior spec from scratch. No inherited CalendarGrid
  dependency remains in the overview; the existing bar still uses that helper.
- Source exposure: public target/service property declarations and caller-reference
  searches, plus existing independently maintained LockWidgets/lock-dashboard
  consumer contracts for data fields/units. Existing own BrandLogo body was read
  and retained. No upstream implementation consulted; no legal certainty claimed.
- References/dependencies: Qt Quick/Shapes/date/locale and documented Quickshell
  FileView and MPRIS interfaces. Existing foundation controls, logo and services
  retained. No new artwork, package or notification/media/data owner.
- Behavior: preferred overview composition preserved with responsive scrolling;
  independent civil-date calendar/month navigation, asynchronous host reads,
  bounded gauges, missing/cached weather, metadata/action capability guards,
  circular album clipping and visible-only one-second media progress samples.
- Production Qt fixtures cover leap years, week starts/year/date rollover, geometry
  and overlap at 300/508/699/700/874/1200px, clock/weather/host fallbacks, fraction
  bounds, actual pointer transport, capabilities/removal/track changes and hidden
  sampling. Native Quickshell pixel checks verify the actual album circle and
  rounded-card corners; generated-art overview render inspected.
- Full checks/live acceptance pending. Larger dashboard pages/settings, shared
  CalendarGrid, bongo asset, data services and whole-tree audit remain pending.
  Notices retained and private preferences/credentials unchanged.

Candidate refinement: explicit viewport intersection stops host/media sampling
when narrow-layout cards scroll offscreen. Artwork follows the current player
only while visible, keeps loaded pixels during asynchronous replacement and
falls back after failure/removal. Actual scroll tests cover these transitions.

Overview acceptance (2026-10-09): implementation `0a2b8a2`, good release
`20261009T124333312676Z` (exact release manifest remains private). All 328 tests,
Qt parsing/formatting, Hyprland validation and native launcher/Escape/source
release gates passed. Real pointer month navigation visibly changed October2026
→ November2026 → October2026 (isolated label OCR verified); live overview918×604
inspected. All five dashboard tabs still load, only Settings is modal, Appearance
navigation/Escape/outside click pass. Installed overview files match candidate,
configerrors empty and shell active. Transport checks use a fixture player and
never skip the user's real track. One-output synthetic checks do not establish
physical multi-output/cold-login or measured battery consumption. Services, other
pages/shared helpers/assets and final provenance audit remain pending; notices kept.

## Full Media and Performance replacement (verified; providers pending)

- Deleted dashboard/Media.qml and Performance.qml bodies without opening them;
  fresh NacreMediaPage/NacrePerformancePage and media/ helpers from the behavior
  spec, runtime screenshots, public declarations and dependency APIs.
- Prior exposure: public import/property/function declarations and bongo caller
  reference line; no upstream body consulted. Own overview/foundation code was
  reused only as contract/test support. Players/SystemUsage still pending.
- Removed assets/bongocat.gif after confirming its only maintained caller was the
  replaced Media page; no replacement artwork or persistent animation added.
- Actual QML tests cover pointer/keyboard seek, no rendering writes, single-release
  commits, stale track/player/capability cancellation, native capability guards,
  selection/raise, repeat/shuffle/volume, missing data, resource units and sizing.
  Native generated-art renders and actual album-mask pixels inspected across wide
  and compact layouts. Full/live acceptance remains pending. Notices retained.

Live data refinement: the retained collector uses0 as missing GPU temperature
when usage is unavailable. The page treats that combination as unknown, while
retaining genuine0 readings with available GPU data and nonzero sensor readings.
A regression covers the sentinel. Hidden single-player choices do not add blank
scroll range; only visible controls contribute to the page's intrinsic height.

Page acceptance (2026-10-09): final implementation `3a8f60a`, good release
`20261009T131245568097Z`. All329 repository tests, Qt parsing/formatting, target Hyprland
verification, install plan/apply and native release/Escape/source gates passed.
All five tabs load; live Media810×500 and Performance879×458 inspected, Settings
Appearance/Escape/offclick passed. Missing GPU sentinel displays unknown correctly;
source files match installed source and bongo absent. No real track transport or
seek changed; fixture players verify commands. Configerrors empty, shell active.
One-output synthetic input does not establish multi-output/cold-login/battery
measurements. Services and remaining workspace/settings/bar/helpers/config/assets
audit remain pending; notices retained.

## Workspace overview replacement (verified; provider pending)

- Deleted WorkspacePage.qml without opening its body. Fresh NacreWorkspacePage
  from live seven-card layout, configured labels/icons, public service declarations
  and dispatch contract. No new move/rename/app-route action or data owner.
- Exposure: public declarations/API identifiers and dispatch literal prefix were
  searched; no upstream body consulted. Hyprland/NacreIcons providers retained.
- Actual Qt tests cover numeric/object workspace IDs, distinct app summaries,
  counts/empty/title fallbacks, real pointer dispatch/dismiss, hidden/preview/invalid
  guards and settled grid geometry at300/508/796px. Names/private config preserved.
  Source/legal notices remain; full/live acceptance pending.

Workspace acceptance: implementation `ed8f1e1`, good release `20261009T132723356647Z`, all330
checks, Qt/Hyprland validation and actual release/source/Escape gates pass. Real
card click switched to workspace1 and dismissed; original workspace/application
focus restored. First release attempt rolled back after a concurrent verification
preview closed the wallpaper gate; unchanged candidate passed an interference-free
retry. Initial command chaining published before live acceptance, corrected by
this completed verified deployment. Configerrors empty; private labels unchanged.
Single-output synthetic input does not prove physical multi-output/cold login.

## Settings navigation and shared controls (verified; page bodies pending)

- Deleted Settings.qml and settings/{SettingsPage,SettingsSection,SettingToggle}
  bodies without opening them. Fresh NacreSettings/catalog and NacreSettingsPage/
  Section/Toggle from route/consumer declarations, runtime UI and existing tests.
- Exposure: public declarations/aliases/API identifiers and existing integration
  tests; no upstream source consulted. Caller type names migrated mechanically,
  but page bodies/DesktopControls/providers remain pending, not certified.
- Twelve independently described routes, plain Appearance label, all-word search,
  result navigation, external settingsView open/state, lazy loading/unload/scroll
  reset; measured wrapped sections, default content aliases, collapse and user-only
  preference toggles. Own foundation interaction used in production UI fixtures.
- Existing palette/device/lock/maintenance tests retained; extra tests cover invalid
  routes, external page signals, labels/search/narrow bounds and section/click writes.
  Full/live/source acceptance pending. No private settings or AI policy changes.

Settings foundation acceptance (2026-10-09): implementation `19083bd`, good
release `20261009T133432459671Z`, all330 checks/Qt formatting/parsing/Hyprland validation and
actual source/Escape release gates pass. Native twelve-page IPC routing, real
keyboard search microphone→Enter→Sound, Appearance routing, Settings Escape and
outside click, five tabs and native layout inspection pass. Installed new files
match; retired bodies absent; configerrors empty. No preference/hardware/account
write during live verification. Page bodies/DesktopControls/services remain
pending; notices kept. One output/synthetic inputs do not prove cold login or
physical multi-output.

## Appearance page replacement (verified; owners pending)

- Deleted AppearancePage body without opening it; own NacreAppearancePage,
  palette tile and styled number control from spec/runtime/test/owner contracts.
  Existing preset data/Orient and wallpaper/desktop owners retained.
- Preserved scene preview/picker, motion, timed rotation/pool/order/interval,
  image accents/fixed palettes, light/dark, Natural/Harmony, native scheme style/
  contrast and private frame/edge preferences. Scheme state is a native watched
  file, with no interpreter poll; only explicit input writes.
- Existing palette/harmony/tile/scroll tests remain and now run actual fresh page.
  Palette width uses integer pixel sizes to avoid floating-point flow wrap.
  Providers/helpers and other settings pages still pending; notices retained.
  Full/native/live acceptance pending.

Appearance acceptance: software `c230d36`, good release `20261009T135430795014Z`, all330
tests, Qt/Hyprland/source/native release gates passed. Native page inspected;
opening it preserved all wallpaper/palette/motion/rotation preference values.
New files match installed source; retired page absent; configerrors empty.
Fixture numeric/palette/interval/scroll tests verify writes without changing
real preferences. Other Settings pages/providers/audit remain; notices retained.

## Desktop/display/workflow/maintenance pages (verified; owners pending)

- Deleted DesktopControls body without opening it. Four fresh own pages replace
  its overloaded page branches through the existing Settings routes. Public
  declarations/API references, live screenshots and existing backend validation/
  command schemas are contract exposure; no upstream body consulted.
- Retained only existing backend owners; numeric/boolean preferences user-only,
  connected-monitor/pending display guards and20-second Keep/Revert backend,
  explicit opt-in workflow save/startup and maintenance recovery requests. No
  new preference writer, collector, timer or automatic system action.
- Actual page tests cover user-only numeric callbacks, display argument tuples,
  disconnected/pending guards, workflow role serialization and maintenance busy
  blocking, alongside existing all-route/palette/device/lock tests.
- Helper/service provenance and other settings bodies still pending; applicable
  notices kept. Full/live/source validation pending.

Desktop-page acceptance: software `cbef0e4`, good release `20261009T140346123880Z`, all330
checks/Qt parsing/formatting/Hyprland/source/native release gates passed. Four
actual pages inspected and desktop preference file bytes unchanged by opening;
twelve routes, keyboard search, five tabs and Settings Escape/offclick passed.
Installed sources match; DesktopControls absent; configerrors empty. Display/
workflow/recovery commands verified against fixture owners, not by disrupting
real monitors/devices/services. Other pages/providers/final audit remain pending;
notices retained. Single-output synthetic input is not cold-login/multi-output
or measured battery acceptance.

## Final seven Settings page bodies (verified; providers pending)

- Deleted Sound/Network/Bluetooth/Notification/Lock/Time/Ai page bodies before
  fresh implementation. Own Nacre-prefixed pages and NacreAudioNode implement the
  committed specification; existing backend owners remain.
- Exposure: public identifiers/declarations, quoted contract keys, provider API
  schemas, existing tests/runtime screenshots and official Quickshell PipeWire
  documentation. No upstream source used; no legal clean-room claim.
- User-only audio/default/mute, readiness/membership/stale-drag guards; native
  credential/device actions; explicit history clear confirmation; preserved lock
  privacy/timezone fallback/assistant accounts and full-access policy.
- Actual page tests add fake native audio and connection guards, history/card
  bounds and explicit time/weather/assistant writes. No new polling or state owner.
- Settings assembly and all page bodies now have independent replacements.
  Backend services/shared helper provenance and final audit remain pending.
  Applicable notices retained.

Device-page acceptance (2026-10-09): software `b770506`, good release
`20261009T143249123504Z`. All330 tests, Qt parsing/formatting, Hyprland validation
and strict source/native launcher/keyboard release gates passed. Seven actual
page screenshots inspected; all12 routes, keyboard search, five tabs, Settings
Escape and outside click passed. Default speaker/microphone volume and mute and
saved desktop/wallpaper/assistant preference hashes remained unchanged. Installed
Nacre sources match, seven retired files absent, service active and configerrors
empty; no new QML error/binding-loop diagnostics. Notification history remained
44 entries. Destructive/device/time/provider actions tested through fixtures; no
physical reconnect, authentication, sleep/cold-login or multi-output claims.
Backend services/bar/wrappers/config/helpers/assets/final audit remain; notices kept.

## Default audio, Wi-Fi and Bluetooth services (verified; other services pending)

- Deleted three inherited provider bodies before fresh NacreAudio/Network/Bluetooth
  implementation. Old names are new minimal forwarders; maintained consumers use
  Nacre names. Presentation bodies changed only at service-reference/refresh hooks.
- Exposure: public declarations/consumer identifiers, existing tests, device
  schema references inspected in earlier Settings work and official native
  Quickshell/NetworkManager docs. No upstream source consulted, no legal clean-room
  claim. Applicable notices retained.
- Native tracked PipeWire defaults/readiness/safe explicit writes; native BlueZ
  event-driven device views; own bounded read-only escaped NetworkManager snapshot
  helper, active-first grouping, debounced monitor/busy coalescing/backoff/errors.
  No successful-state polling or new device/configuration writer.
- Real new QML service code tested with fake native models/processes; Python
  snapshots test malformed/escaped/hidden data, deadlines and read-only commands.
  Existing real Settings/quick-control UI regressions retained with new names.
- Other services, UI popouts/wrappers, DeviceActions/shared helpers/config/assets
  and whole-tree audit remain pending.

Device-service acceptance (2026-10-09): software `f1ef99a`, good release
`20261009T145142156616Z`. All340 tests, Qt parsing/formatting, target Hyprland and
strict source/startup/native launcher/Escape gates passed. Isolated actual
Quickshell models bound the output/microphone and Bluetooth adapter/three known
devices. Actual twelve Settings routes, keyboard search, five tabs, Settings
Escape/offclick and real header hover on all three quick popups passed.
NetworkManager monitor stayed healthy with no extra snapshots during a measured
five-second quiet interval; explicit read-only refresh settled with the connected
row intact. Saved desktop/wallpaper/assistant preference hashes, output/input
volume/mute and native connection/adapter status unchanged. New installed owners,
forwarders and helper match source; shell active, configerrors empty, no new
QML error/binding-loop diagnostics. Initial IPC-only popup probe auto-dismissed
without header hover; real hover verification passed unchanged software. Physical
roaming/reconnect/hotplug/cold login and battery drain are not measured. Other
services/UI/config/helpers/assets/final audit remain, notices kept.

## Media, notification and resource services (verified; other providers pending)

- Deleted Players/SystemUsage/Notifs bodies before fresh Nacre-prefixed providers
  and NacreNotificationEntry/resource-data.js/resource-state.py. Old names are own
  forwarding adapters, maintained callers migrated mechanically. Existing private
  history helper/policy remain contracts, with separate helper provenance pending.
- Source exposure: public declarations/schema/IPC signatures, consumer APIs,
  existing behavior tests/runtime, helper/policy sources and primary Quickshell/
  kernel docs. No upstream implementation consulted; no legal clean-room claim.
- Native capability-guarded MPRIS selection; async native proc sampling only on
  visible overview/performance, slow read-only sysfs/disk helper, unknown sensors/
  large real-valued KiB; single native notification server/entry lifecycle, safe
  history merge/load failure/save coalescing, feedback/transient filtering and
  native close/action/expiry/hover/geometry-suppression handling. Clean history
  loading and transient feedback do not rewrite the file. Reload restores display
  snapshots; closed native action handles are never persisted or revived.
- Actual new services tested with fake native models/processes/files plus retained
  real UI tests. A formatter issue in the fake notification ID property was
  corrected; no production behavior changed by that fixture adjustment.
- Notices kept. Other services, bar/wrappers/config/helpers/assets/final audit remain.

State-service acceptance (2026-10-09): software `f7cc3b1`, good release
`20261009T161543593745Z`. All346 tests, QML format/parse and target Hyprland
validation passed, including the final installer rerun. Strict source/startup/
launcher/wallpaper/Escape gates passed. Native FileView counter probe returned
valid CPU/memory/kernel data. Actual media/performance screenshots inspected;
valid resource values and unsupported GPU state truthful. Twelve Settings routes,
real search, five tabs and Escape/offclick passed. Real transient notice received,
hover paused expiry, dashboard suppression released hover/paused expiry through
geometry, close resumed timing and native close removed it.44 retained messages
and byte hashes of history/desktop/wallpaper/assistant preferences unchanged.
Fast/slow resource counters stopped during the measured2.2-second closed interval;
installed providers/entry/forwarders/helpers match source. Read-only MPRIS IPC and
all five Nacre shortcut registrations verified; real transport/seek/volume writes
were not exercised. Shell active, configerrors empty and no QML runtime error/
binding-loop diagnostics. No physical/cold-login/battery measurement or whole-tree
license conclusion. Remaining providers/bar/wrappers/config/helpers/assets/audit
still pending; notices retained.

## App discovery, clock and compositor providers (verified; other providers pending)

- Deleted Apps/Time/Hyprland bodies before fresh NacreApps/Time/Hyprland, NacreClient
  and app-search.js. Minimal old-name forwarders preserve current API callers;
  consumer changes are mechanical service-name migrations, not proof of those
  other bodies' originality. Wallpaper fuzzy helper remains a separate task.
- Exposure: public declarations/consumer/launch interfaces, prior schemas, runtime
  UI/tests and official native APIs. No upstream implementation consulted; no
  legal clean-room assertion. Notices remain.
- Own native catalog/ranker and guarded parsed-command launch; native civil clock
  at minute precision with opt-in seconds; stable native client views, event
  metadata coalescing, canonical addresses and generation-guarded focus bootstrap,
  existing Lua dispatch paths and no periodic client/focus interpreter polling.
- Native probe caught premature metadata queries and unprefixed addresses/missing
  activated handles. Fixes now match actual focused workspace/window. Full-check
  fixture missed a service path migration; corrected without runtime suppression.
- Other providers, palette/brightness, bar/wrappers/config/helpers/assets and final
  audit remain pending. Full/live acceptance follows.

Platform acceptance (2026-10-09): software `0e1d0fc`, good release
`20261009T170213071183Z`. All349 tests, native QML format/parse, Hyprland and
final installer rerun/strict source/startup/launcher/wallpaper/Escape gates pass.
Read-only native probe matched68 desktop entries,6 clients, focused window and
workspace2 after canonical-address/Lua-bootstrap fixes. Actual launcher keyboard
search, favorites reset, six-row All apps, Escape/offclick and shared local clock
agreement passed. Real workspace card switched to1/dismissed and original
workspace/application focus restored. Twelve Settings routes/search/five tabs
passed; six real hover-close/synthetic application click/key cycles and modal
outside dismissal returned input correctly. Installed providers/client/helper/
adapters match; private desktop/wallpaper/launcher/assistant/history hashes
unchanged. Shell active, configerrors empty, no QML error/binding-loop diagnostics.
No actual app launch/device/time writes or physical multi-output/cold-login/battery
claims. Palette/brightness/thumbnail/other providers, UI bar/wrappers, configuration,
helpers/assets and whole-tree provenance audit remain. Notices retained.

## Colours and display/keyboard light providers (verified; other providers pending)

- Deleted Colours/Brightness/KeyboardLight bodies before own Nacre-prefixed
  providers, colour-data.js, NacreLightChannel/Backlight and light-devices.py.
  Fallback role data derives from own Orient Slate, not former seed literals.
- Public declarations/schema/default exposure, producer/helper contracts, tests
  and primary Qt/kernel/ddcutil/brightnessctl docs are acknowledged. No upstream
  implementation used; no legal clean-room claim. Notices remain.
- Complete typed colour snapshot/mode publication, matched-presentation authority
  and invalid rejection; shared read-only discovery, native maximum/current and
  visible-only reads, explicit adjusted indicators, coalesced guarded commands/
  read-back/errors, connector/fingerprint DDC safety and no DDC polling.
- Actual QML fixture tests and temporary sysfs/fake process tests cover role and
  device semantics. Native read-only probe sees existing palette/panel/keyboard
  state; brightnessctl pretend parses existing device commands without writes.
- Other providers, thumbnails, publisher/helper provenance, UI bar/wrappers,
  configuration/assets and final audit remain. Full/live acceptance pending.

Colour/light acceptance (2026-10-09): software `9331f6a`, good release
`20261009T175336163608Z` (following validated `02b2bda`; follow-up bounds error text).
All359 tests, QML parsing/formatting, Hyprland and final installer rerun passed.
Strict source/startup/launcher/wallpaper/Escape gates passed. Read-only native
probe and actual paletteState roles match current presentation, including mode
and foreground. Panel/keyboard availability/native values correct; brightnessctl
pretend mode accepted both device commands without writes. Actual indicator
screenshot inspected, twelve Settings/search/five tabs/Escape/offclick checks
passed. Native controls closed/visible state correct; private preference/history
hashes and physical requested/max brightness unchanged before/after QA. New
providers/channel/own fallback/helper/forwarders match source; service active,
configerrors empty, no QML error/binding-loop diagnostics. User writes and DDC
identity/range/failure semantics verified through fixture/temp sysfs tests; no
real brightness keys/writes/external DDC/hotplug/cold-login/battery measurement
claims. Matched presentation/publisher and other providers/helpers/UI/config/
assets/final provenance audit remain; notices retained.

Light mapping follow-up acceptance (2026-10-09): software `4f8e178`, good release
`20261009T175754261291Z`. A lone external screen with unavailable DDC now stays
unavailable instead of controlling an internal laptop backlight. Regression case,
all359 checks and strict source/native release gates passed. Actual internal panel/
keyboard/colour comparison and indicator inspection reran successfully; private
preferences/history/hardware values remain unchanged. Installed source matches,
configerrors empty and no runtime QML diagnostics. Earlier accepted colour/light
results remain valid; final publishing uses this guarded source.

## Thumbnail retirement and matched presentation (verified; other providers pending)

- Runtime inventory: Thumbnailer.go only in NacreImage; NacreImage only in its
  CachingImage alias/tests. Maintained views use native images/prepared caches.
  Deleted inherited Thumbnailer without opening its body; optional own image
  helper now native, with meaningful decode/resize/clear/error checks.
- Deleted ThemePresentation body before fresh NacrePresentation with own role/
  poster/schema validation, copied immutable state, staged readiness and safe
  errors. Old name an own forwarder. Other callers mechanically renamed; their
  bodies and actual cache/producer/helper provenance remain separate tasks.
- Exposure: declarations/current caller and producer JSON schema, existing
  tests/runtime and earlier turns' provider inspection; primary Qt/Quickshell
  image/file APIs. No upstream implementation consulted; no legal clean-room
  claim. Retain notices.
- Twelve initially listed services addressed: eleven replaced, one retired.
  Remaining mixed providers/UI/config/helpers/assets/final audit unfinished.

Image/presentation acceptance (2026-10-09): software `08641a8`, good release
`20261009T181234632592Z`. All360 tests, Qt format/parse, Hyprland and final installer
rerun/strict source/startup/launcher/wallpaper/Escape gates passed. Native read-only
probe and installed state report matching valid wallpaper/palette with no errors.
Producer's null accent contract retained. Real picker/Appearance preview/Escape,
twelve Settings/search/five tabs/offclick passed; screenshot inspected. Current
wallpaper selection and exact private desktop/wallpaper/launcher/assistant/history
hashes unchanged. Installed owner/forwarder/native image helper match; Thumbnailer
absent and no runtime references. Service active, configerrors empty, no QML error/
binding-loop diagnostics. Native Qt image-error warning handled narrowly in test;
other warnings remain failures. No new thumbnail cache/conversion jobs introduced.
No cold-login/physical multi-output/battery or whole-tree license completion claim.
Actual producer/cache helper, mixed providers, UI/config/assets/final audit remain;
notices retained.

## Wallpaper and weather providers (verified)

Deleted mixed Wallpapers/Weather bodies before implementing NacreWallpapers and
NacreWeather from callers, public declarations, producer schemas, existing tests
and primary Quickshell Process/FileView APIs. Earlier provider/helper exposure is
acknowledged; no upstream body consulted and no legal clean-room claim. Existing
producer/cache/playback helpers remain separate audit tasks. Current callers use
new names; old names are small independently written forwarders. Removed unused
fuzzy-prepared model and third-party fuzzysort after reference inventory.

Native tests exercise catalogue validation/retention/search, latest-selection
queue, failed commit/retry, serial confirmed preference writes, import cancellation,
matched display versus preview, cached weather/units/unknown/stale state and
coalesced refresh with old-city rejection. Existing rotation tests retain native
production timer/deadline/shuffle assertions. Notices retained; whole goal remains
unfinished.

Provider acceptance (2026-10-09): software `28707f7`, good release `20261009T182743644453Z`.
All362 tests (31 tools, 96 AI, 35 Brain, 200 shell), native QML format/parse,
Hyprland and final installer rerun/strict startup/source/launcher/wallpaper/Escape
gates passed. Live catalogue retains20 entries, actual picker/Appearance/lock
settings work; valid matching poster/palette, native watcher running and weather
fresh/available with no error. Appearance screenshot inspected. Twelve Settings
routes/search and five dashboard tabs/offclick checked. Current selected/applied
wallpaper and private desktop/wallpaper/launcher/AI/history byte hashes unchanged.
Installed providers/forwarders exactly match; fuzzysort absent. Service active,
configerrors empty and no QML runtime error/binding-loop diagnostics. User writes,
publication failures and queues exercised through native fixtures, not applied to
private state. No physical suspend/cold-login/multi-output/battery or whole-tree
provenance completion claim. Remaining playback/helper/UI/config/assets and final
audit still required; notices retained.

## Bar controls and battery/calendar popouts (verified)

Deleted inherited/mixed ActiveWindow/Power/StatusIcons/Battery/Calendar bodies
before NacreActiveTitle/NacrePowerButton/NacreStatusIcons/NacreBatteryPopup/
NacreCalendarPopup implementations. Public declarations, layout declarations,
TopBar caller and dynamic route map, own service/primitives/calendar data, native
power API probe, dependency documentation and actual Qt tests informed the code.
Prior source exposure acknowledged; no upstream body consulted/no legal clean-room
claim. Maintained callers/routes use new names; old names minimal forwarders.
Retired inherited CalendarGrid without opening its body after no remaining runtime
or fixture callers. Stock icon/font dependencies and notices retained.

Tests cover title elision/plain text/removal and bounded wheel writes; five
counter-rotated target positions/reactivity; native battery readiness and truthful
unknown readings; estimates; profile availability/invalid-enum/user-only writes;
calendar leap/year/local-day behavior; keyboard activation of the session menu.
TopBar, other popouts and shared wrappers/services remain separate audit areas.

Bar acceptance (2026-10-09): software `96c83f4`, good release `20261009T185728917153Z`.
All363 checks, native QML format/parse, target Hyprland and final installer rerun /
strict source/startup/launcher/wallpaper/Escape gates passed. Real five status
hover targets and actual Battery/Calendar popouts captured/inspected. Sound,
Network and Bluetooth header clicks open the correct Settings page and Escape
closes each; power-menu opening/Escape passed without a power action. Six native
hover/close/application-click/keyboard cycles plus launcher/wallpaper offclick
passed. Profiles, volume and exact private preference/history hashes unchanged;
installed owners match and CalendarGrid absent. Shell active, configerrors empty,
no QML runtime error/binding-loop diagnostics. One physical output; cold-login,
other output/rotation/profile-write/hardware/battery measurements not claimed.

Live acceptance found existing explicit Settings focus and stale pin weaknesses:
prior fixture injected focus manually. Own NacreDashboardPanel now requests it
only for visible pinned Settings; fixture no longer injects it. Explicit root
close resets dashboard/popout pins and edge-menu flags. Root shell/TopBar bodies
remain separate audit tasks; small fixes/renamed callers do not certify those
whole files as independent. Added read-only focus/target diagnostics omit titles
and identities. powerprofilesctl works with system Python; this chat's palette
venv PATH lacks GI, so live profile checks used native D-Bus. No package mutation.
Notices retained; full goal still active and unfinished.

Font-bound follow-up acceptance (2026-10-09): software `dc01bf9`, good release
`20261009T190606699900Z`. CI37977172512 identified font-dependent rotated geometry when
Material Symbols was absent. Added fixed24×28 logical-pixel clipped/elided glyph
boxes and a deliberate missing-font test; kept geometry assertions/native text.
All363 local checks, native Hyprland and installer gates passed again. Five actual
hover popouts/three header Settings routes/Escape/power-menu Escape and full frame
click/keyboard checks reran successfully; live capture inspected without clipped
normal glyphs. Profiles/volume/private hashes unchanged; no runtime diagnostics.
Final CI is required for the follow-up before reporting verified publishing.

## Remaining quick popups and shared assembly (verified)

Deleted eight mixed/inherited bodies before NacreSoundPopup/NetworkPopup/
BluetoothPopup/HistoryPopup/QuickList/QuickSlider/PopupContent/PopupPanel. Public
contracts, current caller routing/input, producer/service schemas, own primitives,
existing tests and Qt/Quickshell dependency APIs informed implementations. Earlier
view/assembly exposure recorded; no upstream source/no legal clean-room claim.
Maintained frame host uses NacrePopupPanel; old names minimal own forwarders.

Preserved tests now instantiate actual new views/assembly, covering six routes,
close retention/unload/reversal, reduced motion, pin/Escape, stale row guards,
backend-vs-user slider changes and no display writes. Native tests found JS row
identity copies; resolve Wi-Fi/Bluetooth identifiers to current rows before action.
Synchronous Loader sizing is outside presentation bindings to prevent binding
loops; pin focus waits for actual visibility. Existing Nacre notice rendering,
services, native dependency licenses and notices retained. TopBar/root/other
wrappers/helpers and final provenance audit remain independent tasks.

Quick popup acceptance (2026-10-09): software `ada8f42`, good release
`20261009T194324519952Z`. All363 checks, QML format/parse, target Hyprland and final
installer rerun/strict source/startup/launcher/wallpaper/Escape gates passed.
Actual five hover targets and six-route assembly, header device Settings links,
notification pin/Escape/offclick and full application-click/key return passed.
Device/history captures inspected; long output names middle-elided to retain port
identifiers. Native source matches; profile/volume/radios/count and exact private
preference/history hashes unchanged. No runtime QML errors/binding loops; shell
active and configerrors empty. No writes to real devices/history during QA.

Live pinned notification checks required the enclosing frame's Escape policy;
removed duplicated popup key handling. A header MouseArea can lose hover while
modal surfaces occlude it. Existing HoverIntent now also checks recorded header
geometry before rearming on actual exit, without timers/polling. Added native Qt
regression and tested real pointer held over the same icon. TopBar/HoverIntent/
Shortcuts bodies inspected for diagnosis; whole-file originality remains pending,
and small fixes do not certify them. Notices retained; physical multi-output/
cold-login/battery and whole-tree provenance completion not claimed.

## OSD/session/background wrappers (verified)

Deleted eight mixed/inherited wrapper/control/media bodies before new NacreOsd
Panel/Controls/Events, NacreSessionPanel/Controls, NacreBackground/WallpaperScene/
DesktopVideo implementations. Public signatures/IPC schema/model data, current
caller contracts, own services/primitives, existing tests and primary Qt native
media/window APIs used. Earlier provider/renderer exposure acknowledged; no
upstream source/no legal clean-room claim. Maintained root/host call new names;
old names minimal own adapters. Small root caller renames do not certify root
shell or shared playback policy; those remain separate tasks. Notices retained.

Actual Qt tests cover no display writes/startup OSD, explicit fixture actions,
availability/focus/hover/expiry, session allowlist and closing geometry/reduced
motion, latest-ready poster/palette activation, opaque underlayer, rapid requests
and percent-containing filenames, motion policy. Native Quickshell video test
uses generated footage with an audio track to prove first-frame playback, pause
and disabled audio route/track. No private wallpaper or device mutation by tests.

Desktop wrapper acceptance (2026-10-09): software `d1d9a1e`, good release
`20261009T200834703779Z`. All365 checks (31 tools,96 AI,35 Brain,203 shell), QML format/
parse, native Hyprland, plan/apply and final installer rerun/strict source/startup/
launcher/wallpaper/Escape gates passed. Actual matched poster/palette with no error,
no unsolicited startup OSD, indicator preview/capture and session Escape passed.
Five hover/popout/history pin/offclick, six native application click/key-return
cycles passed. Exact source, private preference/history byte hashes, radio/volume
and requested hardware light values unchanged. Shell active, configerrors empty,
no runtime QML errors/binding loops. Session actions tested in fixtures only; native
video generated with an audio track proves first-frame/pause/disabled-audio state.
No real lock/power/brightness/audio/wallpaper writes by QA. No physical cold-login/
hotplug/multi-output/battery measurement or whole-tree provenance completion claim.

Live session checks required explicit post-visibility Qt focus; Escape still uses
frame ownership. Added a late-palette regression and revision-driven retry so an
already-ready poster is acknowledged when matching metadata arrives later. Opaque
old poster stays under new fade; literal percent/space path tested. Native data /
playback policy, root shell, shortcuts/topbar/helpers/config/assets/final audit
remain separate work. Notices retained and the full goal stays active.

## Top bar/workspaces/hover policy (verified)

Deleted mixed TopBar/WorkspaceStrip/HoverIntent bodies before own NacreTopBar/
Header/WorkspaceRow/HeaderTrigger/HeaderForwarder and NacreHoverIntent. Public
layout/declarations/caller contracts, existing tests and own bar controls/native
APIs informed the code. Prior complete/partial exposure from live fixes recorded;
no upstream implementation consulted/no legal clean-room claim. Root and maintained
consumers use Nacre names; old names minimal own adapters. Actual new helper and
component tests replace old substring-extraction fixtures, preserve native frame
and hover scenarios, and add invalid input/map ownership/read-only/routing cases.
Root/Shortcuts/helper bodies only receive caller renames, not provenance certification.
Notices retained; whole-tree audit still required.

Top bar acceptance (2026-10-09): software `7c8f3a6`, good release
`20261009T202533391123Z`. All366 checks, QML format/parse, native Hyprland and final
installer rerun/strict source/startup/launcher/wallpaper/Escape gates passed.
Actual title lower-header approach/open/exit, five hover targets, header Settings
links, pinned history/Escape/offclick and power-menu Escape passed. Real workspace1
click selected correct workspace and restored original workspace/window. Six native
application click/key-return cycles passed. Full bar capture inspected; private
preference/history hashes and volume/radio/profile values unchanged. Source matches,
shell active, configerrors empty, no runtime QML error/binding-loop diagnostics.

Header teardown now releases its captured registered output name, checking owner
identity so old output destruction cannot erase new state; screen-change/map cases
verified in Qt fixtures. New helper policy validates finite inputs and does not add
polling, process/update instances or focus grabs. Physical multi-output/hotplug/
cold-login/battery are not claimed. Root shell/Shortcuts/shared providers/helpers,
ML4W configs/assets/generators/tests and final audit remain. Notices retained.

## Root shell, shortcuts and visibility owner (verified)

Deleted mixed shell.qml/Shortcuts/Visibilities before independently composing root
and NacreShellIpc/NacreShellShortcuts/NacrePanelState. Public contracts/IPC schema,
shortcut names, current registry/recovery payloads, own views/services and tests
were references. Prior full/partial source exposure acknowledged; no upstream
implementation/no legal clean-room claim. Existing callers/fixtures renamed;
small writable compatibility adapter forwards one owner. Recovery/assistant/
device/palette providers remain separate audits and are not rewritten by renaming.

Qt tests exercise actual router/bridge/shortcut methods with safe owners, multi-
output/fallback, competing views, explicit pin/preview/query/reset, malformed/
legacy/v2 restore, gallery/state/ranges, global press/release/interruption and
passive dismissal. Registry maps and compatibility assignment share ownership;
no settings/device/process action from display. Applicable notices retained.

Root/state acceptance (2026-10-09): software `5da1132`, good release
`20261009T203918928229Z`. All367 checks, QML format/parse, native Hyprland and final
installer rerun/strict source/startup/launcher/wallpaper/Escape gates passed.
Actual menus/Settings links/history pin/Escape/offclick/power-menu Escape, six
application click/key-return cycles and unpinned sidebar/explicit close passed.
Native v2 closed-view flag restoration passed without renderer/worker restart;
empty UI patch does not modify drafts/scroll fields. Exact new source and private
preference/history byte hashes unchanged; radio/volume/profile values unchanged.
Service active/configerrors empty/no runtime QML error/binding-loop diagnostics.

Shortcut press/release/interruption and multi-output router/map forwarding covered
in Qt fixtures; physical Super/chord/hotplug/cold login and populated-draft recovery
are not claimed. No real app/workspace/device/power/settings/AI action by route QA.
Other state/playback/helpers/extras/widgets/ML4W configs/assets/generators/tests
and final audit remain; notices retained and goal stays active.

## ML4W-era compositor/terminal defaults (verified)

Deleted misc/decoration/nacre Lua, Kitty and Fastfetch config bodies before fresh
Nacre defaults from public declarations/native values/maintained helper calls and
platform APIs. Prior exposure acknowledged; no upstream ML4W source/no legal
clean-room claim. Native snapshot includes20 compositor options and parsed Kitty
values. Shadow base matches current black-alpha40, private overrides retain final
load order. Generated palette controls current0.98 opacity/selection colours.

Current fallback tools/share picker/PiP/native controls retained with own named
rules; actual Nacre preview title fixes stale matching. Newelle/old hub/nwg/old
floating/sidepad/calculator inherited rules retired. nwg tools are installed but
unreferenced by current source/startup, not claimed uninstalled. Fastfetch layout
fresh without inherited box/glyph macros/arithmetic; own filesystem-age helper
validates birth time/future/unknown rather than claiming OS installation date.
Native Kitty effective options identical and parser passes; Fastfetch native data
mode parsed (render-only Colors module has no JSON representation). Whole related
logo/generator/helper/config audit remains, notices retained.

Config acceptance (2026-10-09): software `00fbe78`, good release `20261009T211555804785Z`.
All368 checks (32 tools,96 AI,35 Brain,205 shell), QML/syntax/native Hyprland and
config transaction/strict launcher/wallpaper/Escape gates passed. All20 native
compositor options identical before/after; all6 installed files exact source.
Native Kitty parser has no bad options, all non-colour effective settings identical;
selection RGB naturally changed via user's rotating private palette, not static
config. Native Fastfetch data modules parse (render-only Colors has no JSON value).
Normal graphic terminal preview inspected after removing QA-only NO_COLOR env;
user environment/packages were unchanged. Age tests cover valid/zero/future/invalid
birth timestamps. Actual temporary mixer/controls/PiP/preview windows match float/
pin/size rules; original focus/workspace restored and only owned windows terminated.
Six application click/key-return cycles passed, shell active/configerrors empty.
No private host overrides/generator/logo assets or accounts changed. Empty custom
Kitty override stays quiet. Related helpers/other configs/whole provenance and
physical cold-login/hardware behavior remain; notices retained, goal active.

## Unused thumbnail helper retirement

The full tracked-tree reference check found no maintained caller of
`nacre/shell/utils/thumbnail.py` after Thumbnailer retirement. Deleted without
reading/reusing its body; Qt native images and prepared wallpaper posters remain
the only maintained preview paths. The installer copies the whole shell tree,
so the dead file was still deployed. [Retirement spec](../specs/retired-thumbnail-helper.md)
and the retired-path integrity guard cover the source boundary. Applicable
notices remain; this does not certify unrelated thumbnail/publisher helpers.

Retirement acceptance (2026-10-09): source `3544a59`, good release
`20261009T214342269080Z`. All373 checks (37 tools,96 AI,35 Brain,205 shell),
QML/native Hyprland and shell-only plan/apply transaction passed. Exact236-file
active shell matches source and contains no retired helper. Actual wallpaper
chooser/Appearance preview/Escape, matched palette/poster readiness, six
application click/key-return cycles and outside dismissal passed; preview visually
inspected.20 private wallpapers and recorded private preference/history hashes
unchanged; busy assistant worker not restarted. Shell active/configerrors empty.
Whole-tree registry covers614 current artifacts and records rewrite-change pointers
for327; final review remains explicit pending, not a license/originality conclusion.
Current reference inventory also finds Cava/Spectrum/beat utility isolated from
maintained views; validate that dead group next, then mixed providers/helpers.

## Unreachable audio visualizer retirement

[Retirement spec](../specs/retired-audio-visualizer.md): inherited Cava service and
adjacent unused local Spectrum/beat/test paths removed without reading/reusing
their bodies. Full tracked references isolate the group, no maintained consumer
or registration remains and no native Cava process was running. Current Nacre
media/provider tests and Brain JavaScript check stay; only the obsolete beat test
is retired. System packages, playback and private state are unchanged. Notices
remain until the full-source/dependency audit, not just dead-code cleanup, passes.

Audio retirement acceptance (2026-10-09): source `76101df`, good release
`20261009T215717801922Z`. All374 checks/QML/native Hyprland and reviewed shell-only
plan/apply passed. Exact233-file active source contains no Cava/Spectrum/beat or
retired thumbnail helper. Actual Overview/Media previews/Escape and current player
controls, wallpaper/Appearance previews and six application input/dismissal cycles
passed; Media screenshot visually inspected. Sidebar PID/start identity and eight
private preference-file hashes unchanged, no native Cava process or runtime QML
errors, shell active/configerrors empty. No playback/hardware/account action.

The first wallpaper check crossed the existing automatic rotation deadline and
correctly rejected its old selected/applied snapshot. Diagnosis: unchanged30-minute
rotation preferences, original deadline16:58:22.680, new presentation published
518ms later and new deadline advanced30minutes+701ms. Only generated palette.lua
changed; preference bytes remained equal. Short-window checks against the new
scheduled wallpaper then passed. The test baseline distinguishes generated theme
state from preferences rather than disabling rotation or hiding a failure.

[Orient exact-file review](ORIENT-SOURCE-AUDIT.md) read all eight current modules
and package metadata, followed replacement/local correction history and reviewed
imports/math/dependency boundaries. Nine SHA-bound independent implementation
reviews now recorded; native eight installed modules match and runtime contains
Orient/Pillow/pip only. All374 checks and native Hyprland passed for this metadata
batch; config plan0 changes, no redundant runtime cutover. Compatible output names
are distinguished from inherited algorithms. No upstream bodies consulted, no
final similarity/legal clean-room/license conclusion; retained notices and remaining
publisher/helper/config/test/asset/full-runtime audit stay required.

## Session input and placement default replacement

[Spec](../specs/session-defaults.md): six keyboard/cursor-behavior/cursor/layout/
monitor/window Lua bodies deleted before fresh Nacre declarations and startup
cursor adapter. Native21-option snapshot and public option/gesture/monitor/caller
contracts retain current behavior; private output/desktop/palette/host overrides
remain last. Cursor arguments are session-owned and safely quoted; callback tests
cover malformed data/space/quote/substitution text without executing commands.
Prior declaration/call-site exposure acknowledged, no upstream bodies consulted
or legal clean-room claim. This does not audit the root/global seed, animation/
keybinding/startup/routing/helper sources or establish a final license change.

Session-default acceptance (2026-10-09): source `0ffb982`, good release
`20261009T221018243410Z`. All376 checks (40 tools,96 AI,35 Brain,205 shell),
QML/native Hyprland and six-file config-only plan/apply transaction passed.
All21 captured native options exactly equal, connected display geometry/scale and
keyboard layouts/cursor environment equal, all6 installed configs exact source.
Eight private preference-file hashes, busy worker PID/start identity and233-file
native shell source unchanged. Six native application click/key-return cycles
and launcher/wallpaper outside dismissal/Escape gates passed; shell active and
configerrors empty. No actual device/power/input preference or account action.

Six exact-file independent origin reviews now tied to SHA/spec/replacement commit.
Scalar preference preservation/API vocabulary are distinguished from inherited
implementation; native behavior alone is not authorship proof. Root/global seed/
private override/other config/helper/test provenance remains separate. Startup
cursor callback argument handling covered with actual Lua callback tests and
config parsing; cold-login execution, physical touchpad/gesture/Fn/cursor appearance
over every toolkit and external-output behavior are not established by this gate.
Retained notices, final source comparison and all remaining scope stay required.

## Compositor motion default replacement

[Spec](../specs/motion-defaults.md): deleted inherited animation.lua before fresh
curve registry/transition-family loops. Native35-node/15-curve observation and
public declarations preserve current shape/duration/style data under4 Nacre IDs;
9 unreferenced custom curves retired. Eleven leaves explicit, child/global/internal
inheritance and platform default/linear curves retained; no angle loop added.
Private override identifier checks found no old-curve consumer and use no private
implementation body. Prior declaration/source exposure recorded; no upstream
consultation/legal clean-room/final-license claim. Underlying private profile
helper/root/startup/binding/routing/test/assets remain separate audits.

Motion acceptance (2026-10-09): source `427a889`, good release
`20261009T222133697056Z`. All377 checks (41 tools,96 AI,35 Brain,205 shell),
QML/native Hyprland and one-file config plan/apply strict transaction gates passed.
All35 animation nodes exactly equal after4 ID mappings; four new shapes/default/
linear match, no active leaf refers to old IDs. Installed file matches source,
eight private preference hashes/worker identity and233-file shell source unchanged.
Actual owned window opening/render filmstrip inspected and six app click/key-return
cycles/menu outside dismissal passed. Capture timestamps include IPC/tool overhead,
not a duration benchmark; graph values establish unchanged configured durations.

Initial fresh-registry expectation failed: Hyprland0.56.2 retains registered curves
on reload, leaving prior15+new4 exactly. Native Lua has no remove_curve/delete_curve
API. The check now verifies that exact union and separately rejects old active
references; no internal-memory manipulation or disruptive restart. Nine unused
registrations retired in source, not falsely claimed removed from live memory.
Fresh compositor-session registry check remains a final runtime-audit follow-up.
Notices retained; larger source/helper/config/tests/assets and comparison remain.

## Graphical-session startup composition replacement

[Spec](../specs/session-startup.md): deleted current autostart.lua before own
argument-list/ordered submission composition and literal POSIX argument quoting.
Public startup commands/service ownership/native state are behavior contracts;
current file was already narrowed by local maintenance, not all commands presumed
inherited. Actual Lua fixture proves no load/reload launch, then verifies five
startup tasks/wallet scope/argument boundaries without real execution. Private
helper/credential/app idempotence behavior stays with existing owners and is not
certified original here. Prior declaration/exposure acknowledged; no upstream
implementation/no legal clean-room/final license claim.

Startup acceptance (2026-10-09): source `e90cf66`, good release
`20261009T223650641342Z`. All379 checks (43 tools,96 AI,35 Brain,205 shell),
QML/native Hyprland and one-file config plan/apply strict transaction passed.
Four service PID/start identities, six application windows and recorded private
preference hashes unchanged before/after reload and six app input/dismissal cycles.
Installed startup file exact source,233-file shell unchanged, shell active and
configerrors empty. No real startup task/credential/device/power action by QA.
Actual Lua fixture proves load doesn't launch and startup callback emits correct
ordered argv; native cold-login/PAM readiness/completion timing not established.
Source review tied to SHA/spec/replacement, helper provenance remains separate.

Startup tracing found active UWSM low-battery scope with helper origin `989022d`
(explicit ML4W file import). This is remaining active inherited implementation,
not merely a dead name; capture its public notification policy and replace next.
Startup-apps Python origin `b0632b9` is a local Brain/startup feature; do not presume
it inherited from its filename. Existing notices/permissions/palette/update policy
stay; full current-tree/source/runtime comparison and cold-session follow-ups open.

## Native battery alert replacement

[Spec](../specs/battery-alerts.md): inherited low-battery.sh deleted before own
Qt policy/native UPower observer. Captured20%/15% thresholds/messages/urgency/rearm
contract preserved; highest successful severity suppresses downgraded repeats.
Root singleton/file-backed restart state, actual ready/state validation, no
periodic processes, bounded delivery/watchdog failure retries. Actual Qt owner/
policy tests isolate native dependencies and private storage/notification delivery.
Startup task retired/review reassessed; existing notification server retained.
No private/upstream implementation reused, declarations/predicates and prior
exposure acknowledged; no legal clean-room/whole-license/source comparison claim.

Battery acceptance (2026-10-09): initial software `36c35e0`, good release
`20261009T225551979064Z`; late-cycle fix `ba39132`, good release
`20261009T230054327373Z`. All380 checks (43 tools,96 AI,35 Brain,206 shell),
QML/native Hyprland and reviewed config+shell and follow-up shell-only strict
transaction/source/service/launcher/wallpaper/Escape gates passed. Installed
235-file shell matches source; startup exact source and old managed script absent.
Native owner ready/present100%/not discharging, no process/warning/error at idle.
Private preference/history hashes and busy worker PID/start unchanged before/after
six native app input/dismissal cycles. No real notifications or hardware/power
changes by QA, configerrors empty/shell active. Existing notification server used.

Positively identified old UWSM scope was checked against captured control-group/
active identity and stopped only after native owner readiness; no old active scope
remains. Source/active inherited dependency is removed, inactive release backup
retained. Two cat commands+sleep per60s formerly imply4320 external launches per
24h uptime; estimate from declared loop, not a measured battery/CPU benchmark.
New policy uses shared cached UPower and no periodic timer/process. Real warning
delivery and physical threshold/AC cycles aren't claimed by safe fixtures.

Initial existing startup contract test expected the retired fifth task; corrected
to intentional4-task ownership. Additional actual-owner regression reproduced a
late failed reply after charging leaving stale diagnostics; `ba39132` rejects old
epoch replies/clears rearmed delivery error, then full/live checks repeated.
Native policy/owner/source hashes recorded as own implementation from contracts/
public APIs; remaining whole-tree/helper/assets/tests/final comparison and fresh
compositor-session old-curve-registry follow-up stay open. Notices retained.

## Compositor shortcut composition replacement

[Spec](../specs/keybindings.md): target deleted before own grouped map/constructor/
workspace+direction families.95 public declarative key/action/argument/flag/submap
contracts recorded with fake native constructors and no action invocation; matched
new restricted capture. Native101 effective bindings separately captured. Public
declarations/earlier exposure acknowledged, no upstream/inherited implementation
body used/no clean-room or final license claim. External helpers/private shortcuts/
root/host source provenance separate. Static duplicate checker strengthened to
restricted Lua construction capture so generated key families remain covered.

Shortcut-guide caller integration: current source-reading parser would lose
generated binding descriptions. Shared restricted helper deployed with shell
tools, tools checker imports the same implementation, guide labels use
(submap,key) identity and native active-set data. Generated guide/resize exit and
brightness label regression added. This edits a caller, not a whole desktop-extras
provenance certificate; prior caller-body exposure acknowledged.

Shortcut acceptance (2026-10-09): source `9a435c3`, good release
`20261009T232643353196Z`. All384 checks (46 tools,96 AI,35 Brain,207 shell),
QML/native Hyprland and reviewed config+shell strict transaction gates passed.
All95 safe constructed action/argument/flag/submap contracts match baseline.
All101 actual native binding records match after ignoring only opaque Lua callback
IDs. Native guide has101 rows, generated brightness and scoped resize-exit labels
verified; actual guide/Escape and six owned app input/dismissal cycles passed.
Guide screenshot visually inspected, installed source/helpers exact, private
preference/history hashes and worker identity unchanged. Shell active/configerrors
empty/no new QML errors. No real bound power/app/AI/device action by capture/tests.

Guide integration regression was initially placed below unittest's main guard and
not discovered; count inspection caught it, moved into its test class, actual six
extras cases verified and full suite rerun before deploy. Live probe initially
queried nonexistent extras.state; corrected to the observed extras.counts API.
These were test/probe errors, not hidden runtime failures. No physical Fn/Super
proof or whole-helper/root/routing/source/asset/license conclusion. Four own source
reviews (keybinding/capture Lua+Python/tool bridge) tied to SHA/spec/replacement;
caller edits retained as separate helper audits. Notices and full goal remain.

## Application route composition replacement

[Spec](../specs/window-routing.md): deleted windowrule.lua before own ordered
named route map/emitter and explicit Thunar popup. All11 public named match/action
contracts captured with safe declaration owner and preserved. Scoped mail/Brain/
other appearance owners unchanged. Shared restricted capture gains rule mode;
route/float checker covers generated tables as well as literal declarations.
Existing binding reader source reviews reassessed and semantic tests retained.
Public declarations and prior exposure acknowledged; no upstream/old body reused
or legal clean-room/whole-license claim. Helper/private/root audits remain.

Routing acceptance (2026-10-09): source `e944518`, good release
`20261009T233814657408Z`. All387 checks (49 tools,96 AI,35 Brain,207 shell),
QML/native Hyprland and reviewed config+shell strict transaction gates passed.
All11 captured named match/actions exactly equal; generated routing/float conflict
regressions and prior95-binding contracts pass. Ten actual owned temporary class
windows match before/after workspace/float/pin/observed geometry and silent routing;
real user sessions untouched. AI/Brain class fixtures avoided to protect singleton
workers, behavior covered by declarations. Initial fake Thunar size assertion
failed on unchanged baseline because Kitty requested950x500; corrected to actual
before/after comparison, no claim real GTK application size verified.

Installed routing/helpers and235-file shell exact source; private preference/
history hashes and worker identity unchanged, six app click/key-return/dismissal
cycles pass, shell active/configerrors empty. No new actor/app/AI/hardware/power
action; fake classes do not prove real app cold login. One own route-source review
added, shared capture reviews reassessed; root/Brain/private-shortcut/helper/UI/
assets/tests/packaging and final comparison/fresh-session checks remain. Notices
retained, whole originality goal active.

## Compositor entry point and local extension review

[Spec](../specs/compositor-entrypoint.md): inherited root composition deleted
before writing a fresh ordered module entry point from its public contracts.
Preserves fourteen module loads and neutral border fallback scalars, which are
interface/default data rather than an inherited palette algorithm. Five private
overrides retain their order, missing-file tolerance and independently authored
contained-error behavior (bcdbd69). Actual isolated Lua tests cover complete module
order, all missing files, precedence and failure in every override. Prior exposure
to public declarations and the local error helper is acknowledged; no upstream
implementation consulted and no legal clean-room or final-license claim.

Brain extension is locally authored: e42b701 introduced the Observatory routing
and Brain/capture actions; 2fa3a95/9a9cebe removed old appearance and conflicting
routes. Current authenticated-window/handoff rules trace to local Brain changes
3f4132d/de8222b/69aad30. Extra shortcuts originate in local native desktop tools
007d020, with passive Escape added 63162dc, managed Thunar-rule move 85f31ab and
namespace rename 548f0b4. These two verified local files are retained, not rewritten
solely because they travelled through a rename/conversion. Current SHA-bound
reviews cover those declarations; called helpers/Brain server remain separate
audit items. Applicable notices remain pending the whole-tree conclusion.

Existing helper loader markers are preserved as public validation contracts;
removing them would falsely reject working Settings/palette/shortcut installation.
A regression checks all three markers in the independently composed root.

Entry-point acceptance (2026-10-09): source d3b5f5f, good configuration release
20261009T234951485679Z. All 391 tests (53 tools, 96 AI, 35 Brain, 207 shell),
formatting, Qt parsing and native Hyprland validation passed. Reviewed plan
changed one managed file; configuration transaction and live IPC gates passed.
All 101 native bindings and nine sampled appearance/input options match baseline.
Nine private preference/history files and AI worker PID/start identity unchanged.
Managed root/local extensions match installed bytes; all 235 shell files match.
Six owned temporary-app hover/dismiss/click/key-return cycles plus launcher and
wallpaper outside dismissal passed. No configuration errors or forced logout.
Cold login, real hardware events and fresh-session dormant curve registry remain
explicit follow-ups. Three SHA-bound source reviews added; whole-tree review and
remaining helper/assets/test provenance still open. This is not a license-clearance
claim. Notices retained and complete originality goal remains active.

## Update provider and runtime guard review

[Spec](../specs/update-runtime-audit.md): traced maintained Updates.qml, updates.py,
updates.sh, qt-check.sh and test_updates.py through local authoring, consolidation
and rename, rather than presuming either inheritance or independence by location.

Update/cache functionality originates in local 2fa3a95; singleton owner added
7a05033. The former per-monitor cache declaration is attributed to 2fa3a95, and
the new singleton adds its own cache reader. Python query/error/compatibility
changes trace through 21ef4e2, 0fb1f9f, 6f88e53 and 0f3bd08. Runner uses local
2fa3a95 orchestration, eb4941d skipreview policy and ac8be46 failure/readability
work. Shared guard traces to independently added inline launch check a1e6926,
then extraction/recovery in ac8be46. Namespace-only migration is 548f0b4.
Launcher outside this guard remains a separate audit area.

Compared first-authored bodies mechanically against four retired pre-consolidation
ML4W-era update/installupdate scripts, without displaying or using those bodies to
write a replacement. Python has zero matching non-comment lines; other pairs only
have isolated short/common syntax (no three-line contiguous blocks). This is
supplementary evidence, not a similarity-based originality certificate. History,
feature-specific producer/caller contracts and actual current implementations
support retaining these locally authored files. No runtime rewrite was needed.
Source exposure limited to these own files, own tests/callers, public history
metadata and mechanical predecessor comparison; no legal clean-room claim.

Tests originate in local 21ef4e2, with failure/preflight additions 2c4595a and
release-policy tests 0f3bd08. Seven isolated cases pass under discovery. The
unittest main guard was before the later classes, so direct execution ran only
three cases; moved it to the end and verified all seven directly. No production
behavior changes, package upgrade or private preference migration. SHA-bound
reviews cover these five current files only. Full source/dependency comparison
and remaining runtime/helper/asset/test audits remain required; notices retained.

Update audit acceptance (2026-10-09): audit/test correction 0d31cbd. All 391
tests, formatting/QML parsing, native Hyprland and source-registry checks pass.
Install plan reports zero configuration changes and no source-link migrations.
No production source changed, so no renderer/service cutover: active runtime
retained and all 235 shell source files plus three deployed helpers verified byte
for byte. Live shared Qt check passes: runtime/build Qt both 6.12.0. Private
preference/history and worker identity remain unchanged against the prior live
baseline; all 101 bindings and nine sampled native options still match.
Bar screenshot shows the same 33 updates as the live cache, with no rebuild
warning; cache reports rebuildNeeded=false, distributionReady=false. Read-only
checks only, not a real update/recovery-build/physical multi-monitor test.
Five current file reviews complete this bounded area, not the whole tree;
launcher/provisioning/publisher/remaining helper/asset and dependency audits remain.

## Shell and session environment composition

[Spec](../specs/shell-session-defaults.md): UWSM exports previously moved from
compositor configuration in 85316eb; later cursor ownership corrections d0bf508
and c0816b6 retained. Deleted both migrated UWSM files before independently
composing grouped toolkit/cursor defaults from isolated POSIX export contracts
and live user-service observations. All ten variable names/values retained,
including HYPRCURSOR_SIZE following XCURSOR_SIZE; no obsolete session/toolkit
or private native-library overrides introduced. These are public API preferences,
not an inherited palette/launch algorithm. Prior scalar exposure acknowledged,
no upstream body copied or legal clean-room/final-license claim.

Fish fragment is locally introduced in 2fa3a95 with no preceding managed Fish
tree, then target namespace changed 548f0b4. Its two aliases are own routes, not
a startup greeting: siverteh-update forwards to nacre-shell updates; ascii to
figlet. Retain the fragment and private alias compatibility, do not migrate
personal Fish settings. Initial probe incorrectly expected Fastfetch; it failed
before any code/deploy change, corrected to actual alias contracts. Actual Fish
tests with isolated HOME/fake executables prove no startup app invocation and
argument forwarding in both interactive and noninteractive modes, including
arguments containing spaces. Actual POSIX tests assert exact exports/absence of
retired variables. Added Fish to CI packages so these native cases run there too.

Four SHA-bound reviews cover the two composed defaults, own retained Fish fragment
and new tests. Workflow dependency edit is a caller change, not a provenance
certificate for the complete CI workflow. Personal config/state and next-login
propagation remain separate. Whole-tree notices/audits remain active.

Session acceptance (2026-10-09 local / 2026-10-10 UTC): software c550bba,
good config release 20261010T000438103610Z. All 393 tests (55 tools, 96 AI,
35 Brain, 207 shell), formatting/QML/native Hyprland and reviewed two-file
config transaction passed. Ten isolated exports exactly match before/after and
actual user-service environment, sampled through owned temporary units. Three
installed environment/Fish files match source. Fish aliases preserve argument
boundaries and invoke nothing on startup. Native 101 bindings, nine sampled
options, private preference/history hashes and AI worker identity unchanged.
All 235 shell files exact, live IPC healthy, configerrors empty; launcher and
wallpaper transaction gates receive Escape. No logout, package update or AI
restart. Fresh login propagation remains a separate observation, although values
are unchanged. Initial incorrect Fish probe and unstaged-test registry rejection
were resolved before deployment; neither protection was bypassed. Four current
file reviews added; full-tree notices/audits remain.

## Base defaults current source review

[Audit spec](../specs/base-config-source-audit.md) consolidates seven current
file reviews for the independently composed replacement in 3bf8870. Current
Kitty, misc/decoration/nacre Lua and new age helper bytes are unchanged since that
replacement. Fastfetch layout correction 00fbe78 is independently authored.
Original inherited target bodies were deleted before fresh composition from
public contracts, native measurements and platform APIs; earlier source exposure
was recorded, no upstream body reused or legal clean-room/final-license claim.
Private palette/custom/host precedence, logo assets and helper dependencies remain
separate owners/audits. Age tests also first authored 3bf8870, using isolated
stat/date executables rather than inherited implementation fixtures.

Current native follow-up found a documentation overclaim: original candidate
Fastfetch JSON and current JSON both report DE: No DE found, as well as Colors
unsupported in JSON. Earlier wording that all data modules succeeded was too broad.
The DE detector is redundant on this Hyprland setup; removing it preserves the
Nacre identity and compositor rows and removes a misleading error. Corrected
native JSON now has 13 modules, no data errors, with
only render-only Colors unsupported. No private logo/palette change. Kitty actual
parser reports no bad lines, size 12/padding 10/opacity 0.98/scrollback 2000; all 20
sampled compositor options match original live replacement baseline. Current
source/history evidence plus behavior tests support these bounded SHA reviews,
not a whole-tree certification. Notices remain and complete goal stays active.

Base audit acceptance (2026-10-10 UTC): software 7809e2c, good config release
20261010T001641734907Z. All 393 tests (55 tools, 96 AI, 35 Brain, 207 shell),
formatting/QML/native Hyprland, reviewed one-file config deployment and actual
launcher/wallpaper Escape gates passed. Six installed base files exact source.
Native Kitty parser has zero bad lines and 19 effective fields match installed
config; 20 native compositor options equal the replacement baseline. Installed
Fastfetch now yields 13 modules, no data errors, only render-only Colors unavailable
in JSON. Prior live private hashes/worker identity, 101 bindings/nine sampled
options unchanged; all 235 shell files exact, live IPC healthy/configerrors empty.
No other preferences, logo assets, packages or user terminals changed. Seven
SHA reviews added; separate publisher/generator/helper/assets/tests and whole-tree
comparison remain. Notices retained and full goal active.

## Palette publication source and boundary review

[Spec](../specs/palette-publication.md): local initial synchronization script
4874385, structured publisher/shared writes 8afd305, prepared validation 81827c1,
contrast 2b16add, later own toolkit/rotation/branding/Orient changes traced through
current source. Formatting 83b3531 and rename 548f0b4 are not authoring proof.
Mechanically compared first and current bodies against initial peers/predecessors
without displaying upstream bodies; no five-line contiguous matches. This is
supplemental evidence, not the sole originality test. Current own implementation
and local feature/caller history reviewed; retain public role/formatting contracts
and own rendering code rather than rewrite locally authored work unnecessarily.
Current body exposure acknowledged; no legal clean-room/final-license claim.
Referenced rofi template, branding/icon/KDE/lock/login helpers, reference/preset
data and private assets remain separately scoped audits/dependencies.

Actual new boundary tests demonstrate two baseline failures: missing onPrimary
starts output then fails with KeyError; direct apply ignores the held palette lock.
Shared reentrant publication guard now handles direct/prepared/CLI callers, checks
marker plus actual descriptor9 identity before borrowing the CLI lock and leaves
that owner's lock held. Stale marker without descriptor acquires its own lock.
Complete role/mode/metadata validation precedes consumer publication and fixed
preset scheme mutation. Real subprocess/flock tests, actual prepared re-entry and
CLI inherited-descriptor no-deadlock tests pass. A competing real flock is
rejected after the publisher exits while the owning CLI shell remains alive,
proving the publisher retains that parent lock. Existing shared write primitive
for sidebar/history/settings untouched; no extra polling or fsync on chat writes.

Dark/light/fixed-preset isolated valid output manifests match baseline byte content,
permissions and links (273/273/274 artifacts), ignoring only coordination lock and
normalizing isolated HOME prefixes. This does not prove every future input or
filesystem failure atomicity. Guarantees are serialized normal publication and
per-file replacement, not filesystem-wide crash rollback. Own palette fixtures
trace to 8afd305 and subsequent local feature tests; current color fixtures use
independently replaced Orient reference/preset data. Two SHA reviews added after
current source/test review. Full dependency/asset/whole-tree comparison remains;
notices and complete goal retained.

Publication acceptance (2026-10-10 UTC): software 3e494c0, good shell release
20261010T004000215343Z. All 397 tests (55 tools, 96 AI, 35 Brain, 211 shell),
formatting/QML/native Hyprland and reviewed shell transaction/live menu gates pass.
Thirteen palette tests include demonstrated baseline failures, real lock blocking,
CLI parent-lock retention and actual prepared re-entry. Read-only validation of
current live scheme accepts all 126 roles. Installer applied the current palette
through the new direct path; no duplicate manual publication or wallpaper choice.
Actual palette/poster/deadline/scheme records equal pre-deploy snapshot, native
palette/presentation IPC coherent, installed helper and all 235 shell files exact.
Nine private preference/history hashes and AI worker PID/start identity unchanged.
Six owned app hover/dismiss/click/key-return cycles plus launcher/wallpaper outside
dismissal pass; configerrors empty. No package upgrade/account/power change or AI
restart. Two current source reviews added; templates/branding/icons/KDE/lock/login/
remaining helpers/assets/tests/dependencies and full comparison remain open.
Cold-login/hardware/all-file crash behavior not established. Notices and full
originality goal retained.

## Toolkit palette companion source review

[Spec](../specs/toolkit-palette-companions.md): Rofi template locally introduced
e42b701 before the Caelestia integration, later own styling 3c1b16d; icon helper
introduced 5611be5, own KDE/Dolphin integration 86bebe6 and system source/version
corrections 47b06d4/79916a3; KDE writer first 86bebe6. Current companion bodies
and own file-manager tests reviewed after origin investigation. Initial bodies
compared mechanically to predecessor/peer files, no five-line contiguous matches;
this supplements history/feature evidence rather than certifying by similarity.
Rename 548f0b4 and formatting/test cleanup are not new authorship. Prior own body
exposure acknowledged, no upstream implementation reused or legal clean-room
claim. Confirmed active Rofi fallback callers in clipboard/window/Wi-Fi helpers;
retained template rather than retiring it based on lack of open windows.

Two baseline regressions reproduced: cached generated index bypasses stale link
repair; KDE still emits Siverteh scheme identity. Helper now compares known index
content before touching generated cache, repairs links atomically against current
source, preserves regular SVG/custom indexes and keeps valid index timestamps.
KDE active identity/file now Nacre, with role values/unrelated settings retained.
Unknown/private legacy scheme files are not deleted. Four actual isolated helper
tests pass, including stale cache/custom artwork and private legacy scheme cases;
publisher's thirteen process/role/rotation tests pass too.

Rofi standalone validator is not passing: installed 2.0.0 crashes with exit 139
even on a minimal valid theme; actual native -no-config -theme FILE -dump-theme
succeeds and parses our 25-line theme. Upstream issue
[2320](https://github.com/davatorium/rofi/issues/2320) describes matching cleanup
failure. First piped validator probe obscured exit status; corrected by direct
status checks and minimal comparison, not suppressing the failure. No package
patch or false validator-pass claim.

Papirus source artwork remains third-party, installed package 20260801-1 reports
GPL-3.0 and upstream [LICENSE](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/blob/master/LICENSE)
retains GPL3. No artwork committed; overlays link to source package. Absence of
local common-license directory is not a claim of absent upstream license. Source
code/template reviews do not certify icon art or other publisher dependencies.
Whole remaining source/assets/tests/dependency comparison/notices/goal stay open.

Rofi issue 2320 is closed with an upstream fix; this does not change the measured
installed 2.0.0 failure. Native dump/render/Escape checks are separate positive
evidence, not a fabricated standalone-validator pass. Four SHA-bound companion
reviews complete this bounded area, not remaining generators/packaging/whole tree.

Companion acceptance (2026-10-10 UTC): software fa202f0, good shell release
20261010T005925365321Z. All 399 tests (55 tools, 96 AI, 35 Brain, 213 shell),
formatting/QML/native Hyprland and reviewed shell source/live menu gates pass.
Installed helper/template and all 235 shell files exact. Native KDE scheme is
Nacre, color roles match, 243 generated icon links resolve; private legacy scheme
retained. Owned Rofi fallback view opens and cancels with Escape without action.
Standalone validator still fails on minimal theme as documented; native dump/view
checks are positive evidence rather than suppression of that failure.

Initial unchanged-palette live comparison correctly failed: enabled 30-minute
rotation fired 428ms after its deadline, before the release transaction snapshot.
Legacy scheme was recolored by the old publisher at the same pre-deploy event,
verified by generated-file mtime and matching new palette roles. Source-copy mtimes
are preserved and unsuitable to infer install order; used transaction timestamps
instead. Retained original baseline/event evidence and refreshed only expected
post-rotation palette/legacy hash after verification. New comparison passes with
rotated poster/palette/deadline unchanged, nine private preference/history hashes
and AI worker PID/start unchanged, native palette coherent/configerrors empty.
No rotation disabling, new wallpaper preference or manual selection for QA.
Four current source reviews added; third-party art credit retained and all other
source/assets/tests/generator/dependency/full comparison requirements stay open.

## Branding source and asset review

[Spec](../specs/branding-source-audit.md): local generator/geometry/SVG introduced
b0632b9, compact correction 772e23b, idle terminal refresh 8ad6532, transparency
8ff30bc, qs import/native formatter 14a55db/dfecaf0, call-time home bb46dd6 and
namespace 548f0b4 traced. Current generated BrandLogo body supersedes earlier
pre-generator widget, with independent NacreColours owner integration 02b2bda.
Own current source reviewed; first-source peer/predecessor comparison shows no
five-line copies, supplementing local history rather than sole certification.
Prior body exposure acknowledged; no upstream code consulted/reused or legal
clean-room claim. JSON contains explicit letter polygons/outlines/stroke/viewbox;
SVG and generated components derive from these coordinates, not a font outline
or imported logo asset. Existing look kept, new Nacre identity design later.

Actual regression fails on baseline: --build proceeds to private home publication
after generation. Emitter also writes stale Colours alias rather than current
NacreColours. Fixed provider emission and build-only CLI branch; default live
publish unchanged. Empty-home actual subprocess build/rebuild passes without
home writes and produces stable output; real worktree regeneration produces no
tracked SVG/BrandLogo/login/Brain-symbol diff. Login Logo.qml included in review,
whole login/Brain HTML excluded from certification by association.

Own PNG tests verify transparent lock corners, separate red/blue role pixels and
opaque terminal background; existing exact-controller pidfd and actual idle PTY
image-refresh tests pass. Native Qt 6.12 SVG rendering inspected at 30/96/300px
with layered silhouettes/colors unchanged. Six SHA reviews cover generator,
geometry, SVG, bar/login components and own tests; Pillow/Qt public dependencies
remain allowed. Other assets/helpers/generators/tests/whole comparison and full
notices/goal remain open.

Branding acceptance (2026-10-10 UTC): software d2aad25, good shell release
20261010T011551231922Z. All 401 tests (55 tools, 96 AI, 35 Brain, 215 shell),
formatting/QML/native Hyprland and reviewed shell transaction/live menu gates pass.
Four branding tests include real idle PTY redraw, exact controller signals,
empty-home build/rebuild and PNG alpha/role checks. Tracked SVG/BrandLogo/login/
web symbol unchanged after regeneration; no Brain or AI workflow edit. Native
Qt SVG render inspected at three sizes. Actual live logo PNG/lock PNG/SVG hashes
unchanged, palette/poster/deadline equal baseline; nine private files and AI
worker PID/start unchanged. Installed helper and all 235 shell files exact,
native palette ready/configerrors empty. No terminal/worker restart or wallpaper
choice for QA. Six current source/asset reviews added; remaining helpers/login/
lock/Thunar/data/assets/tests/packaging/AI+Brain/full comparison and cold-login
checks remain. Notices and complete originality goal retained.

## Lock appearance pipeline source review

[Spec](../specs/lock-appearance-pipeline.md): config/info helpers locally authored
a0090ce, own geometry/plain text/cached layout corrections 80a23f2/8ff30bc,
dashboard/preparation 55fbe20, call-time home/namespace changes traced. Current
own helper/test bodies inspected after origin investigation. Mechanical initial
comparisons supplement history; shared dashboard scale block matches own local
config helper, not a vendor body. Visual reference is acknowledged, not a
code-origin certificate. Fonts/icons/Pillow/native services are separate inputs.
Earlier template e42b701 has five-line ancestry in imported hyprlock config;
current template read during audit then deleted and fresh composition written
from public effective backdrop/empty-input settings. No old/upstream body used
while composing; previous exposure honest, no legal clean-room or final claim.

Actual baseline regressions: future cache timestamp retains stale private
notifications; local artwork is fully read before 4 MB rejection. Require nonnegative
age below 2 seconds and read at most 4000001 bytes before decode, with existing
fallback/actions unchanged. Decorative label now nacrefetch.sh. All 19 relevant
actual lock tests pass, covering hidden content, Pango escaping, long labels,
media/monitor geometry, alpha/preload, ready-file permissions, concurrent raster
publication and cache retention. Synthetic 2880x1620 panel inspected; four generated
config output/rotation cases retain one native password field, balanced blocks,
resolved tokens and no unlock action. No actual auth/lock/power action for QA.
Native Hyprlock help has no validation-only flag; no invented parser-pass claim.

Asset boundary remains explicit: current fontconfig resolves IBM Plex Sans and
Material Symbols Rounded from unowned private fonts/caelestia files. IBM upstream
[license](https://github.com/IBM/plex/blob/master/LICENSE.txt) is OFL 1.1; Google
Material Design repo [license](https://github.com/google/material-design-icons/blob/master/LICENSE)
is Apache 2.0. Exact font binary/version provenance and independent installation/
notice ownership remain pending, not certified from family names or directory
labels. No font assets committed or silently replaced here. Other font/art/
helpers/assets/dependency/whole-tree comparison and notices/goal stay open.

Lock appearance acceptance (2026-10-10 UTC): software 70de26f, good shell release
20261010T013242678025Z. All 403 tests (55 tools, 96 AI, 35 Brain, 217 shell),
formatting/QML/native Hyprland and reviewed shell transaction/live menu gates pass.
Nineteen lock cases include demonstrated future-cache/local-read failures, privacy,
ready-file/geometry/concurrency checks. Synthetic image and four generated monitor
configs inspected; no actual locker/authentication/session/power invocation.
Live ready panel and stable initial images decode, private panel mode 0600, native
password field/tokens valid, no unlock action. Five installed helpers/template and
all 235 shell files exact, palette/poster/deadline equal baseline, nine private
preference/history hashes and worker PID/start unchanged. Sleep-hook file hash
unchanged, native palette ready/configerrors empty. Eight current source/template/
test reviews added; active font asset origin/ownership/migration remains explicit
next work, as do all other source/assets/tests/packaging/full comparison requirements.
Physical authentication/sleep/cold-login/fresh-session curves remain unverified.
Notices and complete originality goal retained.

## Font asset provenance and independent provisioning

[Spec](../specs/font-provenance.md): parsed actual TTF names/versions and Git blob
identities, then fetched official pinned files/notices and compared SHA-256. All
six existing files match exactly: Plex 3.201/Rubik 2.300 in google/fonts revision
bd8f81ddb5c74d5c8897b36ad88b440266245103, Material Rounded 2.973 in Google icons
revision 737e3324305806514d7909874fa1818ae1808232 (Oct 2), not latest changed Oct 9
asset. Plex/Rubik OFL 1.1 and Material Apache 2.0 notices also exact. Directory label
was legacy packaging, not evidence of font modifications or project authorship.
No font blobs committed, no Caelestia/ML4W body consulted for new code.

New own manifest/provisioner/tests authored from this spec and public fontconfig/
file/network APIs. Check all bytes before promotion, exact ownership/drift guards,
private backups and rollback, serialized setup, fc-cache refresh. Preserve unknown
files/custom edits; Rubik optional on fresh install but existing asset retained.
Tests cover recognized migration/no network/idempotence/custom file, drift refusal,
bad download, cache failure rollback and later-edit rollback refusal. Installer
caller invokes this owner before UI cutover; this edit is not a certificate for
the whole installer. Font installation remains separate from code snapshot
rollback; normal failures recover files, no filesystem crash-atomicity claim.
Properly licensed third-party fonts remain dependencies, not Nacre-original art.
Whole remaining sources/assets/tests/dependencies and notices/goal stay open.

Font acceptance (2026-10-10 UTC): source 59c7202, good shell release
20261010T014950447260Z. All 407 tests (55 tools, 96 AI, 35 Brain, 221 shell),
formatting/QML/native Hyprland and reviewed shell transaction/live gates passed.
Detailed six-file migration plan verified before apply. Official font/notice
bytes exact, migrated to canonical user directory; actual fc-match for Plex,
Material and compatibility Rubik resolves there. Native font hashes and Pillow
text/glyph pixel hashes equal before for all three families. Six manifest assets
and installed owner/manifest plus all 235 shell files exact; legacy recognized
directory now empty/retired. Reapply is no-op without network/cache rebuild.
Private asset backup/transaction retained separately from code release; tests
prove rollback/collision/checksum failures, no crash-transaction guarantee.
Nine private preference/history hashes, AI worker PID/start and palette/poster/
deadline unchanged, configerrors empty. No user app logout/restart/package/admin
action or typography change. Three current source/manifest/test reviews added;
whole installer remains separately audited. Remaining source/assets/tests/
packaging/dependencies and final comparison still open, notices/full goal retained.

## Shared foundation current-source review

[Source table](FOUNDATION-SOURCE-AUDIT.md) records 51 exact current files under
widgets/config/utils (BrandLogo already separately reviewed). Actual full bodies
reviewed against independent replacement specs/boundaries cb07776/9a3b9a7, with
02b2bda native owners and eea01b9 optional native image refinement. Compatibility
classes are new adapters; public scalar preferences/API names are preserved
contracts, not old implementation. Mixed ActionButton/edge/scroll/view-state/
rotation/Wi-Fi helpers trace their own local feature introductions. Mechanical
first-body comparisons supplement history; the only five-line shared edge block
traces to own Overview 007d020, with formatter changes distinguished. Prior own
source exposure acknowledged, no legal clean-room/whole-license claim.

Actual native Qt state fixture fails on baseline: readOnly TextEdit is serialized
and an older snapshot overwrites its live binding. Added exclusion to both
capture/restore; fixed test preserves editable draft/selection/scroll and password
exclusion while read-only live binding updates normally. One own state-test review
added; other fixture/test/dependency scopes remain explicit, not certified by
association. No panel/typography/palette/motion/input redesign, new polling or
user preference reset. Third-party native APIs/fonts retain their proper source
and notices. Full remaining tree/comparison requirements and goal remain open.

Foundation audit acceptance (2026-10-10 UTC): source d3751e8, good shell release
20261010T020551162650Z. All 407 tests (55 tools, 96 AI, 35 Brain, 221 shell),
formatting/QML/native Hyprland and reviewed source/live transaction gates passed.
Actual native controls/rounded clipping/edge/rotation/Wi-Fi/state fixtures retained;
read-only serialization/binding regression fails baseline and passes correction.
Only state utility runtime changed; 51 source hashes individually reviewed, plus
one native fixture origin. Draft table count/history labels corrected against
actual path inventory and post-replacement commits, not guessed percentages.
All 51 reviewed installed files and 235 shell files exact; private preference/
history hashes and AI worker PID/start unchanged, palette/poster/deadline equal
baseline, native palette ready/configerrors empty. Six owned app hover/dismiss/
click/key-return cycles plus launcher/wallpaper outside dismissal pass. No real
DPI/display change, account/power action, user preference reset or AI restart.
Other fixtures/dependencies/source areas/full comparison remain separately scoped;
notices and complete originality goal retained.

## Current services and provider source review

[Table](SERVICES-SOURCE-AUDIT.md) records 54 current service/JS hashes/bases after
full body review. Completed Audio/BlueZ/Network/app/time/compositor/media/resource/
color/light/notification/presentation/wallpaper/weather/hover/panel replacements
and own compatibility adapters retained. Thirteen local launch/settings/recovery/
lock/sidebar/workflow helpers have separate feature histories/caller contracts.
Initial peer/predecessor comparison only shared initial native import/singleton/
root-id setup; no substantive five-line implementation block, supplementary
evidence rather than sole originality test. Earlier/current body exposure honest,
no upstream implementation consulted for local correction or legal clean-room
claim. Referenced Python helpers/assets/test bodies and native packages separately
scoped; three already reviewed battery/update services excluded.

Actual sidebar native fixture exposed unsupported Object.fromEntries, so current
attachment result failed in Qt. First fixture lacked attachment-support setup,
corrected before attributing failure. Supported Map merge alone passes current
composer but reproduces stale response leaking into changed composer. Captured
request context now gates queued/in-flight additions; stale files/pick/screenshot
jobs/results discarded, legitimate current results accepted. Old draft saves/load
revision guards/backend permissions unchanged. One independently authored actual
QML service fixture review added with fake processes/IPC; no real picker/account/
message/network/hardware action for QA. Remaining tree/dependencies/fixtures/full
comparison and notices/goal remain open.

Service audit acceptance (2026-10-10 UTC): source ecbedfb, good shell release
20261010T022459621470Z. All 408 tests (55 tools, 96 AI, 35 Brain, 222 shell),
formatting/QML/native Hyprland and reviewed shell transaction/live gates pass.
Actual SidebarChat fixture demonstrates Qt fromEntries unsupported, supported
merge-only stale-result failure, then current/stale/queued context success. No
real picker/account/send/attachment action by fixture. Native device/resource/
notification/presentation/panel/provider fixtures retained. All 54 reviewed source
files and 235 shell files exact installed bytes; eleven read-only provider IPC
snapshots return data, palette/presentation ready. Private preference/history
hashes and AI worker PID/start unchanged, palette/poster/deadline same baseline.
Six owned app hover/dismiss/click/key-return cycles plus launcher/wallpaper outside
dismissal pass, configerrors empty. No physical device/power/account/auth action,
AI restart or user preference reset. 55 reviews added (54 source and one native
fixture); helpers/assets/other fixture/packaging/source/final comparison and
physical/cold-login/fresh-session requirements remain. Notices/full goal active.

## Core presentation current source review

[Table](CORE-PRESENTATION-SOURCE-AUDIT.md) records 62 current root/frame/bar/popup/
header/background/OSD/session source hashes and authoring/replacement bases. Full
bodies inspected against completed spec/deletion/independent construction
boundaries 609a1e4/239af3a/ce69bc0/28db63f/966ae9e/216f23a/5da1132 and actual
later meaningful fixes. Old names are owned adapters, public data/API defaults
are contracts; Qt/Quickshell/fonts/stock icons separate dependencies. Prior source
exposure acknowledged, no old/upstream bodies consulted for local corrections
or legal clean-room/final-license claim. Other referenced panel/helper/assets/
fixtures/source areas not certified by association.

Actual native DND test fixture formerly mocked missing DesktopSettings.change,
hiding production undefined-method failure. Fixture now exposes real set contract;
baseline fails, popup corrected to set passes. Own harness origins 51eb6e1 and later
local provider/popup/root changes reviewed; shared fixture bodies remain separate.
Read-only live bar 100% vs lock payload 1, new actual LockWidgets fake-provider
fixture reproduces fraction conversion error. Convert valid native fraction to
0-100 percent, unavailable to null; existing service review/table SHA reassessed
with explicit correction evidence. No actual preference/battery/power change.
Two native test source reviews added; all remaining source/assets/tests/dependency/
packaging/full comparison and notices/goal remain open.

Core presentation acceptance (2026-10-10 UTC): source fca10e6, good shell release
20261010T024332978047Z. All 409 tests (55 tools, 96 AI, 35 Brain, 223 shell),
formatting/QML/native Hyprland and reviewed source/live transaction gates passed.
DND actual native fixture now mirrors producer API, demonstrates old handler
failure then success; no real DND preference toggled. Battery actual snapshot
fraction/percent failure corrected, live bar/lock payload agree. 62 current
presentation sources individually reviewed/hash-bound, one existing service
review reassessed, two test-source reviews added. All 62 installed files and
235 shell files exact, palette/provider/frame ready/configerrors empty. Nine
private preference/history hashes and AI worker PID/start unchanged; palette/
poster/deadline equal baseline. Six owned application hover/dismiss/click/key-return
cycles plus launcher/wallpaper outside dismissal pass. No physical auth/device/
power/account/message action or AI restart. Remaining application panels/extras/
helpers/assets/fixtures/tests/packaging/AI+Brain/full comparison and cold-login/
fresh-session curve limits separately open; notices/full goal retained.

## Application panels current-source review

2026-10-10 UTC. [Spec](../specs/application-panels-source-audit.md) and
[per-file source table](APPLICATION-PANELS-SOURCE-AUDIT.md) cover 58 individually
read current bodies: dashboard/Settings/media/overview 39, launcher 8,
notifications 2, extras 8 and lock preview 1. Explicit independent replacement
boundaries and subsequent history traced; mixed locally authored extras/preview
received a separate first-source peer/predecessor comparison. Only shared
five-line block was public per-screen Quickshell Variants/Scope scaffolding.
Caelestia-inspired lock appearance and previous exposure are acknowledged, without
a legal clean-room/final-license claim. Retain current independent implementations;
this batch changes audit records only, not runtime behavior or private preferences.

All 409 tests pass (55 tools, 96 AI, 35 Brain, 223 shell), including native Qt
panels and actual Quickshell overview rendering. The synthetic overview capture
was visually inspected: bounded cards, calendar, circular art and readable text.
QML parsing/formatting, registry integrity and native Hyprland verification pass.
Shell plan reviewed; configuration plan reports zero files and zero migrations.
All 58 reviewed files and the complete 235-file installed shell match source;
native palette/frame IPC ready, services active and configerrors empty. Private
state, busy worker and palette/poster/deadline unchanged during the read-only
live check. No code cutover is needed for documentation/source-review changes;
the previous good deployed release remains active. No real notification, device,
power, account, AI message or user preference action performed for this audit.

Registry now has 656 tracked artifacts, 397 rewrite-change pointers, 295 explicit
reviews and 361 pending. These are audit counts, not an originality percentage.
Only run.fish remains pending in the shell-source category; separate desktop
helpers, login, workflow, packaging, fixtures and final comparison remain open.
Applicable notices and the complete originality goal remain in place.

## Retired unused shell launcher

2026-10-10 UTC. [Spec](../specs/retire-legacy-shell-runner.md): removed
`nacre/shell/run.fish`, imported in 4874385 and renamed in 548f0b4. No maintained
caller used it. Actual installed service/control/supervisor/Qt-wrapper copies
match the supported startup chain. No replacement copied its warning-filtering
pipeline; prior discovery exposure is recorded. The retired-path check rejects
reintroduction. Overview and architecture explain the single startup owner.

Source 8ec9023 deployed in good release 20261010T030303577778Z after all 409 tests,
native QML/Hyprland checks and reviewed shell plan. Deployment reran checks and
passed launcher/wallpaper real Escape gates. All 234 current and good shell files
match source, with the old wrapper absent. Six owned application hover/dismiss/
click/keyboard-return cycles and launcher/wallpaper outside dismissal pass.
Private state, busy worker and palette/poster/deadline unchanged; live native
IPC/services ready and configerrors empty. Historical rollback snapshots stay.
No actual hardware/authentication/power/AI-message action was used for proof.

All 231 current shell-source artifacts now have explicit source reviews. This
does not certify the whole project: 50 desktop helper/data files, 10 other
desktop configuration/helpers, 4 login artifacts, 44 AI/Brain workflow files,
15 packaging/maintenance files, 129 fixtures/tests, 102 documentation artifacts
and 7 license notices remain pending. Those pending files are not necessarily
inherited. Final whole-tree comparison and applicable notices remain open.

## Desktop startup and installer source review

2026-10-10 UTC. [Spec](../specs/desktop-startup-source-audit.md) and
[individual source table](DESKTOP-STARTUP-SOURCE-AUDIT.md) cover the complete
control, launch, supervisor, installer, shortcut installer, provisioner and two
service bodies. Local authoring history and later native/Orient/font integration
traced. The current control path was added during rename; the prior path was
explicitly followed. Git's shell-unit copy detection traces standard systemd
scaffolding to the locally authored Brain unit, not a vendor implementation.
First-source five-line peer comparisons in the mixed import/authoring snapshots
found no copies; they supplement actual body/contracts/history review rather
than certify origin alone. Prior exposure acknowledged; final upstream/licensing
comparison and called helper/test/asset ownership remain separate.

Retained these eight independent implementations unchanged. Existing recovery
tests reject bad QML before source activation and preserve preferences/rejected
code during fallback. Orient promotion tests cover failed link replacement and
preserved prior runtime. All 409 tests, native QML/formatting, Hyprland and registry
checks pass. Plan reviewed; configuration plan has zero files/migrations. Actual
Qt-checked launch.sh --version succeeds with native Quickshell. Eight installed
helper/unit copies and public launcher wrappers match source; all 234 shell files
exact, native IPC/services healthy and configerrors empty. Private state, worker
and palette/poster/deadline unchanged in read-only checks. No runtime cutover for
source-review/documentation changes; good release 20261010T030303577778Z remains.
No actual account/device/power/auth/AI-message action or busy worker restart.

Registry: 658 artifacts, 397 change pointers, 303 explicit reviews and 355 pending.
Counts describe audit coverage, not originality percentages. Remaining helper/
data/login/workflow/packaging/test/documentation/license and final comparison
requirements remain open; notices and the complete goal are retained.

## Palette data and fallback generation review

2026-10-10 UTC. [Spec](../specs/palette-data-source-audit.md) and
[source/data table](PALETTE-DATA-SOURCE-AUDIT.md) cover seven helper/data artifacts
and the actual generated-palette test. Bridge/generator/test histories traced;
all 30 own fixed palettes and 60 modes reproduce exactly from the independent
Orient engine. The empty cli.json has real preference consumers and is retained
as non-implementation data. Locally curated catalogue/downloader refer to pinned
third-party artwork URLs; no art is bundled/fetched here or licensed by this audit.
Prior exposure/public output vocabulary acknowledged; no vendor body consulted
for the correction, legal clean-room or final-license claim.

Actual drift: reference-style had five earlier container roles and engine ID.
The new boot-policy test fails that artifact. Source 790b508 makes the own
generator emit both fixed presets and complete current default palette; two
new tests cover boot policy and real isolated generator/no HOME writes. Fixed
presets unchanged; five container/text pairs now measure 8.95–9.45:1 contrast.
All 411 tests pass (55 tools, 96 AI, 35 Brain, 225 shell), with native QML,
formatting/registry/Hyprland and reviewed plan checks. Configuration plan has
zero files/migrations. Deployed source b2dd526 in good release
20261010T032245545200Z; repeated checks and launcher/wallpaper Escape gates pass.

Seven installed data/helpers and public bridge exact; all 234 current/good shell
files match. Private hashes, worker, active scheme bytes and palette/poster/
deadline unchanged. Native IPC/services healthy/configerrors empty; six owned
app hover/dismiss/click/key-return cycles and both outside dismissals pass.
No real account/device/power/auth/AI-send or user palette selection action.
Registry: 660 artifacts, 397 change pointers, 311 reviews, 349 pending; audit
counts only. Remaining helper/login/workflow/packaging/fixture/documentation/
license/final comparison and physical cold-login limits remain open. Notices
and complete originality goal retained.

## Login and Files current-source review

2026-10-10 UTC. [Spec](../specs/login-files-source-audit.md) and
[individual table](LOGIN-FILES-SOURCE-AUDIT.md) cover nine maintained login/
configuration/helper/Thunar bodies and six specific test sources. Local login
authoring cb36d47 and Files integration 338417c traced through current changes.
The earlier thunar-trial.py rename is explicitly followed. First-source peer
matches in the trial installer are shared only with own earlier Yazi/Dolphin
trial installers; current native replacement 47b06d4 retired extraction. Other
peer comparisons found no copies. History/body/native API review supplements
those metrics; no legal clean-room or final-license claim. Stock SDDM/GTK/Thunar,
fonts and icon assets retain their separate dependency boundaries.

Retired unused login/issue from ML4W import 989022d in source 7a524e7, without
reading/copying its body to reproduce it. No active caller or installation entry
exists; the actual system banner differs and stays unchanged. Added retired-path
guard and ownership documentation. New actual Main/Logo Qt fixture uses fake
SDDM models/proxy for submission/busy/model guards, retry/clearing and palette
fallback. Existing image-publication fixture now uses temporary HOME for cache.
Actual native GTK test parses CSS and recolors the same widget after replacement.

All 412 tests pass (55 tools, 96 AI, 35 Brain, 226 shell), with native QML,
formatting/registry/Hyprland and reviewed plan. Configuration plan has zero files/
migrations. Deployed source 5c1dc59 in good release 20261010T034510937315Z;
repeated checks and actual launcher/wallpaper Escape gates pass. Four installed
root theme files and six helper copies exact; the compiled Thunar style is
byte-identical to a fresh build of the current source. Root theme/banner, Thunar
preferences, MIME association, private history/preferences, AI worker and displayed
palette/poster/deadline unchanged. All 234 current/good shell files exact;
native IPC/services healthy and configerrors empty. Six owned hover/dismiss/
click/key-return cycles and both outside dismissals pass. No real auth, device,
power, account or AI message action used for verification; no busy backend restart.

The initial strict scheme-file byte assertion detected the CLI reapply's trailing
newline. Original baseline retained: serializing the current JSON without that
newline reproduces its exact captured SHA, proving the entire parsed data and
metadata unchanged. The corrected probe accepts only that single byte difference,
not arbitrary changes or a fresh unchecked baseline. No publisher behavior change.

Registry: 663 artifacts, 397 change pointers, 326 reviews and 337 pending; audit
counts, not an originality percentage. Current login and shell-source categories
now fully reviewed. Other desktop helpers/configuration/workflow/packaging/
fixtures/docs/notices and final whole-tree comparison remain open. Notices and
full goal retained; synthetic tests do not establish a physical cold login.

## Device and session helper source review

2026-10-10 UTC. [Spec](../specs/device-session-source-audit.md) and
[individual table](DEVICE-SESSION-SOURCE-AUDIT.md) cover 17 complete current
helpers/units and 11 specific Python test sources. Independent light/network/
resource replacements and local desktop/device/location/timezone/weather/power/
idle/session/process/startup/title/workflow authoring traced. Renamed added
service paths explicitly followed through the old local names. First-source
peer comparisons share only standard native command/query sequences with own
earlier helpers; actual history/body/interface review supplements those metrics.
Prior exposure acknowledged; no legal clean-room or final-license claim.

Source fd2c9ff corrects SSID validation from character count to UTF-8 byte count,
matching the existing network producer and native protocol boundary. Pure command
regression fails old oversized multibyte values, then passes exact 32-byte ASCII/
two-byte/four-byte boundaries and existing control rejection. No connection,
scan, location lookup or real device/power operation performed. Other 16 helper
bodies and personal AI permission/skipreview behavior retained unchanged.

All 414 tests pass (55 tools, 96 AI, 35 Brain, 228 shell), with native QML,
formatting/registry/Hyprland and reviewed plan. Configuration plan has zero files/
migrations. Deployed source 8a8c5e3 in good release 20261010T040526861019Z;
repeated checks and real launcher/wallpaper Escape gates pass. All 17 installed
helpers/units and two root timezone/location copies exact; installed pure command
boundary test passes without nmcli execution. Power/session/idle/shell/AI services
active, native IPC ready and configerrors empty. All 234 current/good shell files
exact. Private/system policy hashes, Thunar state, worker and palette/scheme data
preserved. No real account/auth/AI-send action or busy backend restart.

Supplementary input probe initially stopped because its owned temporary window
was fullscreen. Its finally block terminated that window and restored focus;
no production desktop setting changed. Fixture setup now launches directly in
an owned empty workspace; six hover/dismiss/click/key-return cycles and both
outside dismissals pass. A one-output synthetic fixture does not establish every
fullscreen/hardware/cold-login case.

Registry now has 666 tracked artifacts, 354 explicit reviews and 312 pending;
these are audit counts. Twelve desktop helpers/data remain, alongside other
configuration/workflow/packaging/fixtures/documentation/notices and the final
whole-tree comparison. Applicable notices and the complete goal remain open.

Follow-up observation after that initial post-deploy preservation check: one
notification arrived from Kitty. Reconstructing the current history's first 44
entries reproduces the original captured SHA, proving the earlier history exact;
the new entry is retained normally. No message contents were exposed for QA.
The wallpaper also changed while the supplementary normal input probe was active,
before the scheduled rotation deadline. Attribution is unresolved; the current
selection was left intact and user clarification requested. A separate preview
probe preserved the new palette/scheme but did not provide normal outside-dismissal
semantics, so it is not treated as a substitute for the earlier normal tests.
Current source/installed copies, system policies, preferences, worker and palette
coherence still pass. This follow-up limits any broader claim that every input
probe preserves wallpaper choices; it does not alter or close the full goal.

## Remaining desktop persistence helper source review

2026-10-10 UTC. [Spec](../specs/persistence-helpers-source-audit.md) and
[individual table](PERSISTENCE-SOURCE-AUDIT.md) cover twelve complete helper/data
bodies and eight specific Python test sources. Local composer/extras/settings/
recovery/preferences/maintenance/history/sidebar/media/watcher authoring and
current independent engine/native owner integration traced. First-source peer
comparison found no implementation copies; history/body/interface review
supplements those metrics, not a legal clean-room/final-license claim. Public
native schemas/flags and private compatibility names remain contracts. Callee/
workflow/packaging/other fixture/dependency origins stay separately scoped.

Actual defect: Docked reset lock/privacy and weather fields despite their exclusion
from preset snapshots. New temp-home actual main() regression fails Docked and
subsequent Normal on the old body. Source 2636534 removes those overrides, retaining
Docked's desktop DND setting and current private choices. Existing preset fixtures
now isolate HOME before nested workflow lookup. Source 428abbe isolates media test
default paths and native watcher child HOME, avoiding user caches/config observation.
No real preset, message, clipboard/history clearing or device/power/auth action used.
Busy AI backend source and full-access/skip-permissions/skipreview policy unchanged.

All 415 tests pass (55 tools, 96 AI, 35 Brain, 229 shell), with native QML,
formatting/registry/Hyprland and reviewed shell plan. Configuration plan reports
zero files/migrations. Deployed source 731b923 in good release
20261010T043451241210Z; repeated checks and normal launcher/wallpaper Escape gates
pass. All twelve helper copies/Fish title and 234 current/good shell files exact.
Current task baseline's private/system/Thunar hashes, worker, palette/scheme,
wallpaper selection and deadline preserved; IPC/services healthy/configerrors empty.
The earlier unattributed wallpaper event remains separate/open, not overwritten
with this new task baseline. No supplementary normal live gallery probe repeated.

Registry: 668 artifacts, 374 reviews and 294 pending; audit counts only. All 68
desktop helper/data, 231 shell-source and four login-theme artifacts now have
explicit reviews. Other configuration/workflow/packaging/fixtures/docs/notices and
final whole-tree comparison remain. Applicable notices and full goal retained;
synthetic tests do not prove physical cold-login/auth or every device path.

## Remaining terminal and compositor helper review

2026-10-10 UTC. [Spec](../specs/config-helper-source-audit.md),
[hide contract](../specs/window-hide.md), [Matrix contract](../specs/matrix-rest.md)
and [source table](CONFIG-HELPER-SOURCE-AUDIT.md) cover ten targets, new hide helper
and four own test sources. Verified local ANSI art/cache, Lua bridge, Matrix wrapper,
close/trash and complete native Hypridle/startup authoring boundaries retained.
Earlier exposure/metrics supplement body/history/public API review; no legal
clean-room/final-license claim. Other dependencies/fixtures/packaging remain scoped.

Uncertain imported minimize body was not opened/copied. Isolated namespace/fake
compositor capture established ledger/restore semantics, then body deleted and
fresh helper/shim authored in 6c8f06d. Old positive numeric records remain compatible;
private locked atomic records, validation and failed-restore preservation tested.
Actual native owned-window test passes hide/both restores with isolated ledger;
no user window target or real notification. Older history/state untouched.

Earlier Matrix peer matches included old calendar/imported ML4W helper fragments.
Whole Python body discarded and independently replaced in 2a977c4 after recording
prior exposure, retaining effect/palette/10fps/exit behavior from spec. Canonical
colors now control all roles, with no legacy Rofi/Matugen dependency. Deterministic
bounds/resize and owned PTY key/signal exit restore termios/cursor/colors/screen.
Active own Fish ANSI compatibility hook retained; cache branding uses Nacre.

Deployment source enumeration wrongly included test-generated pyc/cache files.
New source-map regression failed baseline. cbea2ea excludes bytecode/cache/QML
metadata while existing owned-only backup/removal and drift refusal remain tested.
Plan reduced from seven to five intended files; no owned old caches existed on
this host, no arbitrary cache deletion. Complete configure.py origin remains in
packaging audit, not certified from this narrow edit.

All 428 tests pass (68 tools, 96 AI, 35 Brain, 229 shell), native QML,
formatting/registry/Hyprland and reviewed configs+shell plan/apply. Source fbf9f6b
deployed in good release 20261010T050335224627Z, repeated checks and normal overlay
Escape gates pass. All desired config copies and 234 current/good shell files
exact; generated artifacts excluded, ledgers/private policy/history/Thunar/worker
preserved, IPC/services healthy/configerrors empty. Installed owned hide test passes.
Follow-up plan zero files/migrations. Scheduled rotation at 05:02:07.152 UTC
published at 05:02:07.548 (396ms late), before transaction creation; original
baseline retained and current scheme/poster/timer coherence validated. No palette
rollback or silent rebaseline. Earlier unrelated probe attribution remains open.

Registry: 677 artifacts, 389 reviews, 288 pending; current desktop configuration/
helper, desktop helper/data, shell/login/engine source categories fully reviewed.
Packaging, AI/Brain workflow, remaining fixtures/docs/notices and final whole-tree
comparison remain. Applicable notices and the complete goal stay active.

## Deployment and packaging source review

2026-10-10 UTC. [Spec](../specs/packaging-source-audit.md) and
[complete artifact table](PACKAGING-SOURCE-AUDIT.md) cover fifteen full target
files, new native NOTICE/licence and eight specific test sources. Local complete
deployment/configuration/check/release/migration/inventory/conflict authoring
boundaries/current interfaces traced. Current four-line install wrapper was fully
authored in 2fa3a95, not certified from initial import history. Ignore/credit
metadata is non-implementation; native source/licence explicitly third-party.
Peer metrics supplement body/history/API review, with prior exposure and no legal
clean-room/final-license claim. Other workflow/fixture/doc origins stay open.

Uncertain initial-import idle fallback discarded without viewing/copying its
body. Source 0106a03 freshly defines public native sleep-lock hooks/no default
idle listener for historical source-only wrapper adoption; existing private policy
preserved and current managed config bypasses that branch. Actual seed/temp tree
fixture verifies it; no real lock/sleep/system policy change.

Release candidate path enumeration included generated bytecode despite the config
owner exclusion. New regression fails baseline; 0106a03 uses that shared map and
ships configure.py with the installed controller. Another candidate-only mapping
regression fails sibling-only owner selection; 4ac764e prefers the reviewed
candidate's owner, using the sibling only for minimal fixture trees. Older managed
entries remain captured for retirement rollback. Existing allowlist/drift/retention/
snapshot/private preservation tests pass, without actual rollback or migration.

Quickshell patch verification: all fifteen source-file additions/removals exactly
match pinned upstream 5d5d498; only changelog omitted. Author/source/native LGPL v3
credits and verbatim pinned licence retained in tools/NOTICE/licenses, incorporated
GPL root text retained. Local package recipe remains public native integration;
no claim of original Nacre native code, package rebuild/root install or relicensing.

All 432 tests pass (72 tools, 96 AI, 35 Brain, 229 shell), native QML,
formatting/registry/Hyprland and reviewed shell plan/apply. Config plan zero files/
migrations. Good deployed source f66960d, release 20261010T052720074615Z;
repeated checks/normal overlay Escape gates pass. Three installed controller files
exact and actual installed candidate map runs. Generated candidate bytecode excluded,
private account/vault roots not snapshot targets, 234 current/good shell files exact.
Original policy/history/Thunar/ledger hashes, busy worker and task palette/scheme
preserved; IPC/services active/configerrors empty. No real rollback, root migration,
device/power/auth/AI-send or busy backend restart. Earlier probe attribution remains
separately open; no normal gallery pointer probe repeated.

Registry: 683 artifacts, 414 reviews and 269 pending; audit counts only. Complete
packaging and maintained desktop source categories now reviewed, with native
dependency exceptions/credits explicit. AI/Brain workflow, remaining tests/docs/
notices and full whole-tree comparison/licensing conclusion still required.
Applicable notices and the entire originality goal remain active.

## AI bootstrap and support source review

2026-10-10 UTC. [Spec](../specs/ai-bootstrap-source-audit.md) and
[23-file source table](AI-BOOTSTRAP-SOURCE-AUDIT.md) record complete current-body
and local authoring/change-history review. Retained independent integrations and
native declarative data; no account/runtime implementation changes. Codex/Claude/
Obsidian/KDE and downloaded skill sources remain licensed external dependencies.
No live AI installer, login, wallet change, remote worker or credential copy.
Large AI/vault commands, Brain, remaining fixtures/docs and final full-source
comparison remain required. All applicable notices retained.

## Knowledge helper source review

2026-10-10 UTC. [Spec](../specs/knowledge-helper-source-audit.md) and
[eight-file source table](KNOWLEDGE-HELPER-SOURCE-AUDIT.md) cover six locally
authored context/memory/usage/vault/maintenance/sync helpers and two own fixture
sources. Full current bodies, local authoring and normalized change diffs reviewed.
No runtime source/state changes or real remote/credential actions for QA. Remaining
chat controllers, Brain, fixtures/docs and whole-tree comparison/licensing stay
open; notices and complete originality goal remain active.

## AI controller source review and policy correction

2026-10-10 UTC. [Spec](../specs/ai-controller-source-audit.md) and
[source table](AI-CONTROLLER-SOURCE-AUDIT.md) cover complete current launcher,
Codex transport and Claude adapter plus installer correction and two own fixtures.
Local workflow authoring retained; provider/native libraries remain external.
Fake-launcher regression fails missing terminal Claude full-access flag; 0f31dd9
restores the already authorized policy for new/resumed terminal workers. Code-only
helper update preserves existing accounts, peers and private state, with backup.
No whole-upstream/legal clean-room/final-license claim; Brain and remaining
fixtures/docs/notices/comparison remain required.

## Brain authentication and native integration review

2026-10-10 UTC. [Spec](../specs/brain-integration-source-audit.md) and
[nine-file table](BRAIN-INTEGRATION-SOURCE-AUDIT.md) record full current body and
local history review for eight integrations/HTML and the own auth fixture. Native
model libraries/weights remain external; no download/inference/private token
inspection or live browser/service restart. No runtime implementation changed.
Larger control/discovery/web application/style bodies, remaining fixtures/docs/
notices and final source/dependency/licensing comparison remain required.
