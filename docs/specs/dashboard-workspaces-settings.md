# Nacre workspace overview and Settings foundation

Date: 2026-10-09. Next dashboard batch after Media/Performance.

## Source boundary

Replace WorkspacePage, Settings and settings/{SettingsPage,SettingsSection,
SettingToggle} bodies without consulting those bodies. New names are NacreWorkspacePage,
NacreSettings, NacreSettingsPage/Section/Toggle. Contracts come from runtime views,
public declarations, consumer references and behavior tests; no upstream source
consulted. Own dashboard/foundation code may be reused. Keep notices and record
exposure honestly. DesktopControls and individual pages/providers remain pending.

## Workspace batch

Keep seven numbered workspace cards, configured names/icons and current accent,
application summaries/window counts and Empty state. Use service client/workspace
IDs, not guessed title matches or broad app rerouting. Left click switches to
that workspace and dismisses; secondary action preserves existing focused-window
move behavior. Scope commands to validated numeric workspace1–7 and the existing
Hyprland dispatch owner. Current workspace is highlighted. Bound long labels and
responsive layouts/scrolling without reordering user workspaces. No config writes,
app launching, polling, renaming or implicit window movement. Tests with a fixture
compositor verify dispatch; live tests restore original workspace/focus and never
move a real working window solely for verification.

## Settings navigation and shared controls batch

Keep Settings in top dashboard tab4, existing settingsView open/state IPC, twelve
routes: appearance, desktop, displays, sound, network, bluetooth, notifications,
workflows, lock, time, ai, maintenance. Plain Appearance label replaces the leaked
internal NacreAppearance type name. Search labels/descriptions/keywords with all
query words; results explicitly navigate to the route. Invalid routes fall back
safely. Reset page scroll on selection. Load only an active visible page; searching
and closing destroy page content, not saved preferences. Keep device/settings
shortcut routing and private Visibilities.settingsPage.

NacreSettingsPage exposes a default contents alias and measured intrinsic height.
NacreSettingsSection owns wrapped title/description, neutral surface, optional
collapse and measured child layout. NacreSettingToggle reads validated private
booleans and calls the existing DesktopSettings.set only upon user action, never
on construction/rendering. Preserve contents aliases/public title/description/
collapsible/expanded/label/setting/checked contracts; update callers to new names
rather than retaining derived old bodies. Shared fast scrolling, focus/checkbox
labels and reduced-motion policy remain. No new backend or reinterpretation of
AI permissions, account credentials or system update policy.

## Verification

Actual production UI fixtures: workspace counts/filtering/title fallbacks,
numeric command guards, pointer actions, long text/current/narrow views; Settings
routes/query/external navigation, lazy lifecycle, shared inertial scroll/page reset,
sections/contents/collapse and user-only checkbox writes. Keep existing page
behavior tests. Native render inspection and full checks, Hyprland validation,
plan/apply/source/IPC/live tab/Escape/offclick, CI before publishing each batch.
Preserve private settings, history/playback and busy assistants. One-output
synthetic tests do not claim cold login or physical multi-monitor acceptance.
