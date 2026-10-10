# Native QML and functional data fixture source audit

2026-10-10 UTC. All 47 QML bodies, one qmldir and four JSON datasets were read
completely (blank display lines omitted, comments retained), with individual
local creation/rename/change histories traced. These are locally authored tests,
minimal native/provider doubles, rendering scenes and captured functional data.
Retained own fixtures; no implementation replacement or runtime change here.

Native tests instantiate current Nacre primitives/providers/pages/panels and
check pointer/keyboard behavior, lifecycle, readonly mounting, stale requests,
recovery, visibility, bounded geometry, palette/scene pairing and rotation.
Reviewed driver wiring shows production source copied into temporary imports
with native services/processes replaced by fake counters/data; fixtures do not
reimplement the production algorithm they assert. Foundation uses real widgets;
frame captures real Quickshell clipping/input masks; device cases use current
provider logic. The remaining Python-driver full-source audit is separate.

Earlier local fixtures first authored for custom sidebar, categorized launcher,
settings, click-away and wallpapers; subsequent name/import changes are traced,
not taken as origin proof. Minimal old-name stubs expose public consumer fields
and native Rectangle/Text/TextField behavior, not copied inherited widget bodies.
Current full bodies were assessed independently of that history. QtTest and
Quickshell native APIs retain their own dependency licences. No legal clean-room
or final whole-upstream comparison claim; prior exposure acknowledged and notices
remain pending the complete review.

The JSON role list is captured API vocabulary, without old palette values or
color algorithm. Binding/window-route JSON records native functional commands,
selectors and flags, checked through restricted capture rather than execution.
Orient scenes contain our numeric image-analysis results and source attribution,
not images or creative compositions. The pinned [Pop!_OS README](https://github.com/pop-os/wallpapers/blob/20a9fdd1ed86aadfbbfcd55dc3d2d9eb8ae28e15/README.md)
confirms Nick Nazzaro's four referenced illustrations are CC BY-SA 4.0. Artist,
licence and immutable source links are retained; no artwork downloaded/bundled
or claimed as original Nacre art in this audit. Those external art rights remain.

Coverage limits: functional native checks are not full visual acceptance. Header
size/ownership tests do not assert title centering, and wrapper tests do not assert
the requested right-side 2x2 arrangement. Notification tests do not measure its
wheel speed. These specific gaps belong to the user's queued visual cleanup goal,
which follows actual originality completion. Do not confuse passing lifecycle
checks with proof of every preferred layout or animation quality.

| Current fixture | Own creation basis/path | Later changes | Disposition | Current SHA-256 |
|---|---|---|---|---|
| `nacre/login/tests/tst_login.qml` | `cb36d47` / `siverteh/login/tests/tst_login.qml` | 548f0b4, 2c1d2ca, 83b3531 | independent | `4b1d13649e2a1171c99d9423d2350cb3a853c0859654ffa81b4c97c85dd45692` |
| `nacre/shell-tools/tests/bar-qml/tst_bar.qml` | `ce69bc0` / `nacre/shell-tools/tests/bar-qml/tst_bar.qml` | 5da1132, dc01bf9 | independent | `ff5ccd4f1d15640af4f5c83e81a95de9fd5925e0ac3f8fe3d7051aa1f1ad93e5` |
| `nacre/shell-tools/tests/battery-qml/tst_battery.qml` | `36c35e0` / `nacre/shell-tools/tests/battery-qml/tst_battery.qml` | ba39132 | independent | `19717eef27b0324c0fbd32d5578153e71756c136d2aed8b89d8627389e302060` |
| `nacre/shell-tools/tests/click-away-qml/tst_click_away.qml` | `6e91ab0` / `siverteh/shell-tools/tests/click-away-qml/tst_click_away.qml` | 966ae9e, 7bca77d, ea5653e, 609a1e4, 548f0b4, 2c1d2ca, d47f151, 63162dc, 6fb4d5a, 83b3531 | independent | `90185aa9b152203d1d79dc1d9c6ac589b00a950ca44370637639c3b7f4da40a0` |
| `nacre/shell-tools/tests/dashboard-qml/tst_dashboard.qml` | `1cd6ab7` / `nacre/shell-tools/tests/dashboard-qml/tst_dashboard.qml` | 96c83f4, 19083bd, ed8f1e1, e82a4e6, 0a2b8a2 | independent | `073c4dec7aceb5ef992a83df7a74aceb04808a4f3617bfd39403f2680294f849` |
| `nacre/shell-tools/tests/device-qml/tst_NacreApps.qml` | `3d93b32` / `nacre/shell-tools/tests/device-qml/tst_NacreApps.qml` | none | independent | `ef3632f8f19a718a3604f2d6f3448d39c54a7068f6c4d02210acba67fcf68f58` |
| `nacre/shell-tools/tests/device-qml/tst_NacreAudio.qml` | `2f9300f` / `nacre/shell-tools/tests/device-qml/tst_NacreAudio.qml` | none | independent | `c44f6fb84fdc751bbf4b72ea5ba259a854f9c8e178648da9c0fa7b87f59c7b0b` |
| `nacre/shell-tools/tests/device-qml/tst_NacreBluetooth.qml` | `d4a82bb` / `nacre/shell-tools/tests/device-qml/tst_NacreBluetooth.qml` | none | independent | `6e59ebfa5232fa5b4079aaad866566906b4d847fe8283d12b0210926c817569d` |
| `nacre/shell-tools/tests/device-qml/tst_NacreBrightness.qml` | `02b2bda` / `nacre/shell-tools/tests/device-qml/tst_NacreBrightness.qml` | 5da1132, 4f8e178 | independent | `186eaa9bca12f585f5ea310a86cf9774a1e8e21bcdb5c7dac4c68121ec7120c2` |
| `nacre/shell-tools/tests/device-qml/tst_NacreColours.qml` | `02b2bda` / `nacre/shell-tools/tests/device-qml/tst_NacreColours.qml` | eea01b9 | independent | `b4b891105efbe6b602c27752d438dc6968c3c5981c3bf03f6d702cf98c657d22` |
| `nacre/shell-tools/tests/device-qml/tst_NacreHyprland.qml` | `ea5653e` / `nacre/shell-tools/tests/device-qml/tst_NacreHyprland.qml` | 98108af | independent | `49b52081afe71e6f79e19484ddf06c67b2eb55cd54f2eb11b5ed5fb9234627d6` |
| `nacre/shell-tools/tests/device-qml/tst_NacreKeyboardLight.qml` | `02b2bda` / `nacre/shell-tools/tests/device-qml/tst_NacreKeyboardLight.qml` | none | independent | `613e9a844744468dc1d0767031d716fb237effab64c69ebc235ed212dc846b0b` |
| `nacre/shell-tools/tests/device-qml/tst_NacreLightChannel.qml` | `02b2bda` / `nacre/shell-tools/tests/device-qml/tst_NacreLightChannel.qml` | none | independent | `16cd5ab4edcf0122d2817558f17b5dae62ccbc22007e905d70651c36975142fc` |
| `nacre/shell-tools/tests/device-qml/tst_NacreNetwork.qml` | `977f628` / `nacre/shell-tools/tests/device-qml/tst_NacreNetwork.qml` | none | independent | `ea2c760b097f53a6599a8f94c0781305bcd4179c1818846245f2511a1e9c692a` |
| `nacre/shell-tools/tests/device-qml/tst_NacreNotifs.qml` | `e4d2474` / `nacre/shell-tools/tests/device-qml/tst_NacreNotifs.qml` | 5da1132, 22a4ad1 | independent | `a35bc5b53e52d00894ce71efcbb10445c059d268c8d26c5f33f3e477de8253e9` |
| `nacre/shell-tools/tests/device-qml/tst_NacrePlayers.qml` | `13701fc` / `nacre/shell-tools/tests/device-qml/tst_NacrePlayers.qml` | none | independent | `946593cc928b9e9ef55e235c698d41e2f1326e0e63a9b867b5892f66f3b9a1a0` |
| `nacre/shell-tools/tests/device-qml/tst_NacrePresentation.qml` | `eea01b9` / `nacre/shell-tools/tests/device-qml/tst_NacrePresentation.qml` | 08641a8 | independent | `b32352228d4821e83f3d61ffefe61bff8cd9895bee0e428b452c054a51e2811a` |
| `nacre/shell-tools/tests/device-qml/tst_NacreSystemUsage.qml` | `18d8aab` / `nacre/shell-tools/tests/device-qml/tst_NacreSystemUsage.qml` | 5da1132 | independent | `c528d6f129265007b4c2028476d097c79647d5a89e3433186901cb596df26f49` |
| `nacre/shell-tools/tests/device-qml/tst_NacreTime.qml` | `a492dc6` / `nacre/shell-tools/tests/device-qml/tst_NacreTime.qml` | none | independent | `1671aaa8697fdbafe233b853537186b8a7dbaef343c18fbc6fb941d8b7db7105` |
| `nacre/shell-tools/tests/device-qml/tst_NacreWallpapers.qml` | `28707f7` / `nacre/shell-tools/tests/device-qml/tst_NacreWallpapers.qml` | 5da1132 | independent | `9cd8d87c3a9e79e2b1ff4656f09a39041dac3d24014a3ecfa5b4cd26385528e4` |
| `nacre/shell-tools/tests/device-qml/tst_NacreWeather.qml` | `28707f7` / `nacre/shell-tools/tests/device-qml/tst_NacreWeather.qml` | none | independent | `3409a0b70f74256a5bc81ce6236bbb321187411eda948831e03ac6e504657ce3` |
| `nacre/shell-tools/tests/fixtures/orient-scenes.json` | `9c9089f` / `nacre/shell-tools/tests/fixtures/orient-scenes.json` | none | non-implementation | `4fbc5cd186c86977ac014049b610740fc172c84eed6ec8d43598dfd861afb895` |
| `nacre/shell-tools/tests/foundation-qml/render.qml` | `cb07776` / `nacre/shell-tools/tests/foundation-qml/render.qml` | 9a3b9a7 | independent | `9d1a3bfb004e3dcd2bba525a867ec204b035b40c5d66e81f9895b1241757b1be` |
| `nacre/shell-tools/tests/foundation-qml/tst_foundation.qml` | `cb07776` / `nacre/shell-tools/tests/foundation-qml/tst_foundation.qml` | eea01b9, 02b2bda, 9a3b9a7 | independent | `c2237eedb13b0aedd16c67185efe99a430f8b8169cdfaeba422387c1de89e579` |
| `nacre/shell-tools/tests/frame-qml/render.qml` | `609a1e4` / `nacre/shell-tools/tests/frame-qml/render.qml` | 02b2bda | independent | `d6958d313d99bfcf6fc087ed7478915f563dcc9e184e7834bd9d4c27a35d1c54` |
| `nacre/shell-tools/tests/frame-qml/tst_registry.qml` | `609a1e4` / `nacre/shell-tools/tests/frame-qml/tst_registry.qml` | 239af3a | independent | `0908b5884819796b455370398e5fa2d2d2a7b6ac18fda274e949288b6475b468` |
| `nacre/shell-tools/tests/header-qml/tst_header.qml` | `966ae9e` / `nacre/shell-tools/tests/header-qml/tst_header.qml` | 5da1132, 7c8f3a6 | independent | `e42e076bdfdde1dfd033dc633296fb5855d35d044f7e94b537ddd07791abe9e9` |
| `nacre/shell-tools/tests/launcher-qml/tst_launcher.qml` | `a3e2420` / `siverteh/shell-tools/tests/launcher-qml/tst_launcher.qml` | bc7c7e2, 548f0b4, 2c1d2ca, 83b3531, 0c00c16, a8fe3ca, fedfa0c, 7ed920d | independent | `2e5ca31bdf4485f0b1478b7498f2ff597a04073e441cc116d83211443bbdf447` |
| `nacre/shell-tools/tests/launcher-qml/tst_panel.qml` | `7b53c65` / `nacre/shell-tools/tests/launcher-qml/tst_panel.qml` | 28707f7, 3d93b32 | independent | `7b3025b212b1bdeb32f0414e2e2217480b704750c11c4690bd365a8872a3bc5d` |
| `nacre/shell-tools/tests/media-performance-qml/tst_pages.qml` | `e82a4e6` / `nacre/shell-tools/tests/media-performance-qml/tst_pages.qml` | 13701fc, 3a8f60a | independent | `d475b439cd3aca16c168630bef8b2a4e9d31f83fb072683ac020524722f5e0f8` |
| `nacre/shell-tools/tests/notification-qml/tst_notifications.qml` | `e869927` / `nacre/shell-tools/tests/notification-qml/tst_notifications.qml` | e4d2474 | independent | `111d6f597215a6582f573ed84720a90136b290b7296794ededba2a61814f4526` |
| `nacre/shell-tools/tests/orient-roles.json` | `5ecf556` / `nacre/shell-tools/tests/orient-roles.json` | none | non-implementation | `97850a5d1300d3cc3685acb7136d30a8bba57de8daed0c2a3f0549b0b6eb894f` |
| `nacre/shell-tools/tests/overview-qml/tst_overview.qml` | `0a2b8a2` / `nacre/shell-tools/tests/overview-qml/tst_overview.qml` | 28707f7, a492dc6, 18d8aab | independent | `6c282bedbc3da359e38e415f11e19eb723104a15e84b996ee68710fbaeb92354` |
| `nacre/shell-tools/tests/qml/fixtures/ActionButton.qml` | `ddb0066` / `siverteh/shell-tools/tests/qml/fixtures/ActionButton.qml` | 548f0b4, 2c1d2ca, 83b3531 | independent | `96020cb36cba79ca49ab40daea5bd3119e15aa374227b75a59eeba20b33e2a63` |
| `nacre/shell-tools/tests/qml/fixtures/FastScroll.qml` | `ddb0066` / `siverteh/shell-tools/tests/qml/fixtures/FastScroll.qml` | 548f0b4, 2c1d2ca, 83b3531 | independent | `520c81336eeee94af18397cfbf7a956b2c7a1256bc38bd26cd07457635becffe` |
| `nacre/shell-tools/tests/qml/fixtures/NacreAppearance.qml` | `5c3cd84` / `siverteh/shell-tools/tests/qml/fixtures/Appearance.qml` | 9a3b9a7, 548f0b4, 2c1d2ca, 287d527, 83b3531 | independent | `0551c20670f420e615e49ab4f5dfcd828138e5000fcf67b0f3a1a3f783fe3bf5` |
| `nacre/shell-tools/tests/qml/fixtures/NacreColours.qml` | `ddb0066` / `siverteh/shell-tools/tests/qml/fixtures/Colours.qml` | 02b2bda, cb07776, 548f0b4, 2c1d2ca, 83b3531, a0090ce, 36dc0ba | independent | `f7863a9456521871787714207cebdb7804bf0b7dd225a05bdb5478dd2da78cb0` |
| `nacre/shell-tools/tests/qml/fixtures/NacreSurface.qml` | `ddb0066` / `siverteh/shell-tools/tests/qml/fixtures/StyledRect.qml` | 9a3b9a7, 548f0b4, 83b3531 | independent | `3a4f7426d2c38dd4bd70fb178ad599c1791980a7d2ab9a430358b1ea33da55f2` |
| `nacre/shell-tools/tests/qml/fixtures/NacreText.qml` | `ddb0066` / `siverteh/shell-tools/tests/qml/fixtures/StyledText.qml` | 9a3b9a7, 548f0b4, 83b3531 | independent | `e511b8e23ab3e2e3e5f0e35070a01b2b6c7e862a98492c34d44fbc7f87e93e4f` |
| `nacre/shell-tools/tests/qml/fixtures/NacreTextField.qml` | `ddb0066` / `siverteh/shell-tools/tests/qml/fixtures/StyledTextField.qml` | 9a3b9a7, 548f0b4, 83b3531 | independent | `675a927c1aaf333ccbc9424ba89b74caadd4c2ada1a8640c79668932581fea34` |
| `nacre/shell-tools/tests/qml/fixtures/SidebarChat.qml` | `ddb0066` / `siverteh/shell-tools/tests/qml/fixtures/SidebarChat.qml` | 548f0b4, 2c1d2ca, 83b3531, a0090ce, 8bd5e65, 973e0a4, 5c3cd84 | independent | `8b0dff1e6e66b2912cdb835e0f1ce256e0be4c52223fcf5eb82f247b44b887c7` |
| `nacre/shell-tools/tests/qml/fixtures/qmldir` | `ddb0066` / `siverteh/shell-tools/tests/qml/fixtures/qmldir` | 02b2bda, 9a3b9a7, 548f0b4, 5c3cd84 | non-implementation | `f26810e351f34bb57bdf11afb4dfb79a2978a9cf06e1577afc6dca810730324d` |
| `nacre/shell-tools/tests/qml/tst_chatpane.qml` | `ddb0066` / `siverteh/shell-tools/tests/qml/tst_chatpane.qml` | 9a3b9a7, 548f0b4, 2c1d2ca, 83b3531, 36dc0ba, e83d56f, 973e0a4, 5c3cd84, a7495cb | independent | `bb30fae1a3772a762a1605613b03cd22bcf07c597d18384309a379175bd72e04` |
| `nacre/shell-tools/tests/qml/tst_quick_controls.qml` | `51eb6e1` / `siverteh/shell-tools/tests/qml/tst_quick_controls.qml` | 5da1132, 490d457, 6e09600, 28db63f, 2f9300f, 548f0b4, 2c1d2ca, d2e2e40, c2bb50a | independent | `e5a05954d0e99f85f0aa6f4a96a7fedeac5ea94a74db71f85a46fdf39da9125c` |
| `nacre/shell-tools/tests/qml/tst_settings.qml` | `36dc0ba` / `siverteh/shell-tools/tests/qml/tst_settings.qml` | 5da1132, 28707f7, e4d2474, 977f628, d4a82bb, b770506, cbef0e4, c230d36, 19083bd, 9c9089f, 372fe77, 548f0b4, 807f257, 2c1d2ca, 5f22a11, 4ea19d5, 83b3531, 9dd732a, 4e411a5, a0090ce | independent | `5b904019fd1b3f582ae43b573b534b197a71a2fec7d15ba39a523cebee99d8e0` |
| `nacre/shell-tools/tests/qml/tst_wallpaper_rotation.qml` | `4ea19d5` / `siverteh/shell-tools/tests/qml/tst_wallpaper_rotation.qml` | 5da1132, eea01b9, 548f0b4, 2c1d2ca, aee7ec3 | independent | `0c8aba925a244eabb9f4fa797c5700b34a0f0626e2b213106b622319134af9cf` |
| `nacre/shell-tools/tests/state-qml/tst_state.qml` | `5da1132` / `nacre/shell-tools/tests/state-qml/tst_state.qml` | none | independent | `19644475f8b3dc78042431672d4ed794c9d30ec436e62fb73ca8810aa44f09e1` |
| `nacre/shell-tools/tests/wallpaper-qml/tst_wallpapers.qml` | `06ffaf4` / `siverteh/shell-tools/tests/wallpaper-qml/tst_wallpapers.qml` | 28707f7, eea01b9, bc7c7e2, 548f0b4, 1bee816, 83b3531, 4b142ae, 81827c1, 09f9ceb, 0eda691, ee6eeae, e336713 | independent | `ac6fd73b32a96012768824515a5ea8845f1ec2cba651c057fa9b027b998c58e7` |
| `nacre/shell-tools/tests/workspace-qml/tst_workspace.qml` | `ed8f1e1` / `nacre/shell-tools/tests/workspace-qml/tst_workspace.qml` | ea5653e | independent | `a3b091c247c342faf0d77b70f5c95fc6606f62ec633f5884689bbadae66db46c` |
| `nacre/shell-tools/tests/wrappers-qml/tst_wrappers.qml` | `216f23a` / `nacre/shell-tools/tests/wrappers-qml/tst_wrappers.qml` | 5da1132, d1d9a1e | independent | `695c3a507c1e94f68f5c02e19733d345e4383c52f153dc0706c98a4f6504ad1b` |
| `tools/tests/fixtures/keybindings-contract.json` | `9a435c3` / `tools/tests/fixtures/keybindings-contract.json` | none | non-implementation | `58ef6e31683b1764ee3487cd80be7b40b441fb70aa088530a72cc2f88412fbe3` |
| `tools/tests/fixtures/window-routing-contract.json` | `e944518` / `tools/tests/fixtures/window-routing-contract.json` | none | non-implementation | `c0f5936fbfc111ac849efde236198de39ad0b5254569410e730559e730729d70` |

Validation: all 434 tests passed (72 tooling, 98 AI, 35 Brain, 229 shell), native
QML/Lua parsing, Ruff, palette CLI and JavaScript checks. Native Hyprland
verification passed. Reviewed shell plan; config plan zero files/migrations.
Installed shell/current/good and eight Brain source/assets remain byte-exact;
busy backend PID/start time unchanged, services and frame/palette IPC healthy,
no compositor errors. No runtime diff, so no redundant apply/restart. Full
fixture-driver/docs/notices and source/runtime/dependency comparison remain open.
