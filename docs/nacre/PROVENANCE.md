# Nacre independent implementation tracker

Status: Orient, shared foundation, frame, launcher, notification presentation,
all dashboard/Settings views and Audio/Wi-Fi/Bluetooth, media,
notification ownership and resource services verified.
Whole rewrite unfinished, 2026-10-09.
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
| 2b | `shell/widgets/{StyledTextField,StyledWindow,MaterialIcon,Colouriser,CachingImage,VerticalSlider,StyledScrollBar,CustomShortcut}.qml` | verified | [Controls and helpers spec](../specs/foundation-controls.md); native contracts and compatibility adapters |
| 2 | `shell/config/{Appearance,BarConfig,DashboardConfig,LauncherConfig,NotifsConfig,OsdConfig,SessionConfig,BorderConfig}.qml`; `shell/utils/{Icons,Paths}.qml` | verified | Independent Nacre config/utility providers; final fonts/icons remain undecided |
| 3 | `shell/modules/launcher/{Content,ContentList,AppList,AppItem,Actions,ActionItem,WallpaperItem,WallpaperList}.qml` | verified | [Launcher spec](../specs/launcher.md); independent assembly and all app/wallpaper views |
| 4 | `shell/modules/notifications/{Notification,Content,Wrapper}.qml` | verified | [Notification spec](../specs/notifications.md); presentation replaced, service remains separate |
| 5 | `shell/modules/drawers/{Drawers,Interactions,Panels,Exclusions}.qml` | verified | [Frame/panel spec](../specs/frame-panels.md); ownership and live contracts next |
| 5 | `shell/modules/bar/popouts/{Battery,Content,Wrapper}.qml`; `bar/components/{ActiveWindow,Power,StatusIcons}.qml`; current `modules/topbar/` | audit pending | Verify maintained versus unused code before rewriting |
| 6 | `shell/modules/dashboard/{Tabs,Content,Dash,Wrapper,Media,Performance}.qml`; `dashboard/dash/{DateTime,Media,Resources,User,Weather}.qml` | verified | [Dashboard spec](../specs/dashboard.md); assembly, cards, pages and Settings replaced |
| 7 | `shell/services/{Colours,Hyprland,Players,SystemUsage,Bluetooth,Apps,Thumbnailer,Time,Network,Audio,Brightness,Notifs}.qml` | implementing | Audio/Network/Bluetooth verified; Players/SystemUsage/Notifs verified; remaining providers and helpers pending |
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
