# Independent root, visibility router, IPC and shortcuts

2026-10-09. Delete mixed shell.qml, modules/Shortcuts.qml and services/Visibilities.qml
bodies before fresh implementation. Public declarations/IPC schemas/shortcut names,
own view/provider contracts, caller registry/recovery payloads and tests are the
references. Prior exposure from debugging acknowledged, no upstream implementation
consulted/no legal clean-room claim. Retain notices and audit other helpers later.

NacrePanelState is sole UI visibility/router owner. Per-output screens/panels maps
remain writable for the owner-checked registry/recovery; shared hidden/reveal and
settingsPage retain contracts. Select focused output with existing first-output
fallback when unavailable. Commands validate menu/page/mode IDs and finite centre /
workspace/tab values. Opening modes closes competing transient views, leaves pinned
chat preference as specified, resets previewOnly appropriately and increments launcher
request for fresh search/favourites. Same named launcher toggles closed. Preview
routes never apply wallpaper/preferences. Device clicks route to sound/network/
Bluetooth Settings; left opens unpinned except explicit manual pin. No device, AI,
state-file or process action from a visibility read. Keep optional old mutable API
forwarder, without a second map owner.

Root composes one Background/Desktop/TopBar/EdgeHandles and one shortcut/IPC scope;
LockWidgets/DisplayRecovery remain one shared provider, ChatWindowTitle.scan remains
once on startup. Don't reinstall credentials/restart backend or change permission
and update policy. No duplicate GlobalShortcut or notification server.

NacreShellIpc preserves targets nacre and leftDrawer, all declared methods and state
schemas. State/readiness queries stay private/local. Gallery commands invoke actual
launcher methods/count/index. Closing clears transient pins/edge mode and invokes
current hover guard. Restore v2 routes through existing DisplayRecovery; legacy
view flags keep supported modes/page/left section but reject malformed/oversized
payloads safely. Restoring flags does not launch apps or write preferences.

NacreShellShortcuts keeps native appid=nacre_shell names dismissHoverEdges, session,
launcher, launcherInterrupt, and drawers toggle/list IPC. Nonconsuming Escape closes
only passive/unpinned views and uses hover policy; modal/pinned Escape belongs to
frame. Session toggle and named drawer commands use router. Launcher interruption
logic retains public key-chord behavior; no bare-Super Hyprland bind added. No new
keyboard permission/access restrictions. Root/hotkey APIs delegate to the same owner.

Tests instantiate actual router and bridge methods with safe fixtures, validate
multi-output/fallback, competing modes/pins/preview/query toggles, map forwarding,
state schemas/gallery/workspace/tab ranges/restore, no display actions, shortcut
press-release/interruption. Native launcher/Escape, Settings, chat manual pin, header
menus/app-return/recovery state/source and private hashes required. Tests do not
restart busy workers or change real settings/hardware. Full tools/check.py, native
Hyprland, plan/apply and exact-main CI precede publishing; goal remains unfinished
until remaining source/asset/dependency audit proves entire objective.
