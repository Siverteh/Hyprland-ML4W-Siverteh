# Remaining Python fixture current-source audit

2026-10-10 UTC. All forty scoped Python bodies read completely, including embedded
native QML/Lua/shell fixtures, with individual local creation/change histories and
producer/native contracts traced. Locally authored tests/harnesses retained; no
inherited implementation replacement required in this group. Dates/renames are
supporting history, not the source assessment. Current complete bodies reviewed
separately; prior source exposure acknowledged, no final whole-upstream/legal
clean-room or licensing claim. Applicable notices remain.

Tests exercise current production source staged into disposable native imports,
with minimal dummy providers/process counters, synthetic images/audio/video,
restricted Lua captures and temporary filesystem/CLI state. Qt/RHI renderers are
explicitly offscreen, optionally using Xvfb for GL; no real radio/power/device
operation is performed. Numeric/color/API expectations are functional contracts,
not inherited palette or widget implementations. Native tools/frameworks remain
separately licensed dependencies. Synthetic one-pixel/solid images are test data,
not bundled third-party artwork.

Found a demonstrated isolation gap: mocking the launcher child did not prevent its
parent from creating a launcher log in caller HOME. Disposable-host probe left
.local/state/siverteh-ai/launcher.log; some local-worker cases could also inherit
caller account preferences. The workflow test classes now create temporary homes,
isolate XDG roots and clear provider/vault/registry/settings overrides. Regression
runs representative mocked cases against a disposable caller with a nondefault
account and verifies its files/settings unchanged. Baseline host-home probe failed;
corrected probe leaves no files, all 37 workflow tests pass. Production account
policy, credentials and runtime code are unchanged.

The shared QML adaptation helper only replaces dependency boundaries or removes
native IPC/shortcut objects for plain Qt runners. Tests read actual current Nacre
components/helpers from the repository. Control/display lifecycle tests are distinct
from complete real-device/visual acceptance. Captured command fixtures do not execute
commands; browser/device/provider workflows remain fake or opt-in separately.
The queued visual cleanup still needs centering/2x2/notification-scroll and richer
animation acceptance checks; this audit does not claim those requests are fixed.

| Current fixture | Own creation basis/path | Later changes | Current SHA-256 |
|---|---|---|---|
| `ai/tests/test_chat_titles.py` | `4c2ae49` / `ai/tests/test_chat_titles.py` | 83b3531, 3121dad, be81bf0, 1bcce9d | `b14b847582bd659a746fd26972e2c6e2a670af1a3d5dfad6b46c6d567a1b719d` |
| `ai/tests/test_obsidian_install.py` | `bcce02f` / `ai/tests/test_obsidian_install.py` | 83b3531 | `0f4179cfc0f631ae5b70cd17efdbe46f5b6689b5dff1c4becca2f74566cb316a` |
| `ai/tests/test_shared_skills.py` | `fc33e68` / `ai/tests/test_shared_skills.py` | 83b3531 | `0c9431f64ecb6f73f5009abad49275a186b55180a293b6ef12d522f8d459b9b7` |
| `ai/tests/test_workflow.py` | `bcce02f` / `ai/tests/test_workflow.py` | 72d0c7a, 7bdf0e7, bb46dd6, 83b3531, be81bf0, 1bcce9d, 4c2ae49 | `70e5db0871e457e75183ea95413f32f67af8043d4cd13fcc82e2c882243f8dbf` |
| `nacre/shell-tools/tests/qml_source.py` | `5d0028f` / `siverteh/shell-tools/tests/qml_source.py` | 9a3b9a7, cb07776, 548f0b4, 83b3531 | `d8bece116efb9012de5d3c33b176a3fb8cc03cc92d9a56a1e90f1145fdf38055` |
| `nacre/shell-tools/tests/test_bar_controls.py` | `ce69bc0` / `nacre/shell-tools/tests/test_bar_controls.py` | 5da1132 | `d4863fb57dee4949a594c208fb2db1a1a9b87a3d5e52cddb2e43660b4e81bcee` |
| `nacre/shell-tools/tests/test_battery_alerts.py` | `36c35e0` / `nacre/shell-tools/tests/test_battery_alerts.py` | none | `37531c58e2f3ca05afde84c46be9c5245cf673363618517f2fd83e3972a23312` |
| `nacre/shell-tools/tests/test_chatpane_ui.py` | `ddb0066` / `siverteh/shell-tools/tests/test_chatpane_ui.py` | 9a3b9a7, cb07776, 548f0b4, 2c1d2ca, 4ea19d5, 83b3531, 5d0028f, 36dc0ba, 973e0a4, 5c3cd84 | `aba92e05b9da4a2dbd57b602c52c17c8f9e0c82a2521c94fea86d9b22b2dfd53` |
| `nacre/shell-tools/tests/test_click_away.py` | `6e91ab0` / `siverteh/shell-tools/tests/test_click_away.py` | 5da1132, 966ae9e, ea5653e, 609a1e4, 9a3b9a7, 548f0b4, 63162dc, 83b3531, 5d0028f | `3b0b5ac577994c9dfddf91ba67d5cd1a41f659a11fc88d9787405b1c8f24831f` |
| `nacre/shell-tools/tests/test_dashboard_assembly.py` | `1cd6ab7` / `nacre/shell-tools/tests/test_dashboard_assembly.py` | 19083bd, ed8f1e1, e82a4e6, 0a2b8a2 | `61751bd3ba72ddd6fb9fb9999dcf8a4646fa98adf62df5d2a68339fe3d42706d` |
| `nacre/shell-tools/tests/test_desktop_wrappers.py` | `216f23a` / `nacre/shell-tools/tests/test_desktop_wrappers.py` | 5da1132, d1d9a1e | `b7350fa52559cfc132f28ec56d9f2565fcd78b787884a9f71a947a5dbe6c383a` |
| `nacre/shell-tools/tests/test_device_services.py` | `2f9300f` / `nacre/shell-tools/tests/test_device_services.py` | 5da1132, 28707f7, eea01b9, 02b2bda, ea5653e, a492dc6, 3d93b32, 22a4ad1, e4d2474, 18d8aab, 13701fc, 977f628, d4a82bb | `90cd3c3ee41a1925f4ece97c25cc880bb963f671f2c53aa01cbd48ad570f6ac5` |
| `nacre/shell-tools/tests/test_edge_handle.py` | `6fb4d5a` / `siverteh/shell-tools/tests/test_edge_handle.py` | 9a3b9a7, 548f0b4 | `874f0bd94b8908f6eb28acc3f896b193df3b66fcd5a3d2f7879d0f7611fb816e` |
| `nacre/shell-tools/tests/test_foundation.py` | `cb07776` / `nacre/shell-tools/tests/test_foundation.py` | eea01b9, 02b2bda, bc7c7e2, 9a3b9a7 | `cb54408d176652db12b166a6c38706f6980df7a4ed7f7ac3a93a1ed0d62a3f01` |
| `nacre/shell-tools/tests/test_frame.py` | `609a1e4` / `nacre/shell-tools/tests/test_frame.py` | 5da1132, 966ae9e, 02b2bda, 98108af, bc7c7e2, 2b21f0d, 8d96a29, 239af3a | `fc12b62b10f3e9faac154e74209d2d476d4ccc4957e2ddfbeae6a356b0c7886c` |
| `nacre/shell-tools/tests/test_header_widgets.py` | `966ae9e` / `nacre/shell-tools/tests/test_header_widgets.py` | 5da1132 | `658d717ec7c9a99e7caedb20bfde5648de0a1068d92fb7f7d72a096272395fc7` |
| `nacre/shell-tools/tests/test_launcher_panel.py` | `7b53c65` / `nacre/shell-tools/tests/test_launcher_panel.py` | 28707f7, 02b2bda, 3d93b32, bc7c7e2 | `dc577a4e45eddda7a17700a1abd44eb904075c73771f8aa92f9e451c23e087ce` |
| `nacre/shell-tools/tests/test_launcher_ui.py` | `a3e2420` / `siverteh/shell-tools/tests/test_launcher_ui.py` | 02b2bda, 3d93b32, bc7c7e2, 9a3b9a7, 548f0b4, 83b3531, 5d0028f, 7ed920d | `eaaac2829e86f37a0f8eb1c996571e1ea67facb449e6e31a862c27baef3d24aa` |
| `nacre/shell-tools/tests/test_media_performance_ui.py` | `e82a4e6` / `nacre/shell-tools/tests/test_media_performance_ui.py` | 18d8aab | `d0ce13cd801140ee26d51f4117f06f83d07bbb53104f78deed51e9784ba1fe51` |
| `nacre/shell-tools/tests/test_notifications_ui.py` | `e869927` / `nacre/shell-tools/tests/test_notifications_ui.py` | e4d2474 | `66225efb24017dd536f5aa4fd29e03913f060fce1289c22c476feec860036cdf` |
| `nacre/shell-tools/tests/test_orient.py` | `5ecf556` / `nacre/shell-tools/tests/test_orient.py` | 9c9089f, 06632c9, bd17192, 372fe77, 401f63a, 1488f68 | `aa7729bf6d3e5d8462e9d0c5720c00670820b07e939965c5a09e46f76cdfb5bf` |
| `nacre/shell-tools/tests/test_orient_provision.py` | `5ecf556` / `nacre/shell-tools/tests/test_orient_provision.py` | 0573f6b | `b22ade8f17739a86ff6764e20d6d89ad7c3c9ffef01ffe0700276d5885c7bee1` |
| `nacre/shell-tools/tests/test_overview_native.py` | `0a2b8a2` / `nacre/shell-tools/tests/test_overview_native.py` | 28707f7, 02b2bda, a492dc6, 18d8aab | `11cf6b983cd350ee77d72176f711669a16ed779f769b1c4c3227b3c79349b300` |
| `nacre/shell-tools/tests/test_overview_ui.py` | `0a2b8a2` / `nacre/shell-tools/tests/test_overview_ui.py` | 28707f7, a492dc6, 18d8aab | `997b8eb1d83816ae87b1727b3fcb4269ef6d18a4d03eb950597f5f836e04f7cf` |
| `nacre/shell-tools/tests/test_settings_ui.py` | `36dc0ba` / `siverteh/shell-tools/tests/test_settings_ui.py` | 5da1132, 28707f7, a492dc6, e4d2474, f1ef99a, 977f628, d4a82bb, b770506, cbef0e4, c230d36, 19083bd, 9a3b9a7, 372fe77, 548f0b4, 807f257, 3369d3d, aee7ec3, d2e2e40, 51eb6e1, e16d354, 4ea19d5, 83b3531, 5d0028f, 09f9ceb, 06ffaf4, 9dd732a, 4e411a5, a0090ce | `c5319deff4882aa4396689b0bfa9cf647e7be49fcffa7328b0c3815c3da658c4` |
| `nacre/shell-tools/tests/test_shell_recovery.py` | `e3d0298` / `siverteh/shell-tools/tests/test_shell_recovery.py` | 548f0b4, 83b3531 | `c8bbbddd9b11d9907959251e7dae816b8f8d90ad17c02b1b93f8b7fd04c8cebf` |
| `nacre/shell-tools/tests/test_shell_state.py` | `5da1132` / `nacre/shell-tools/tests/test_shell_state.py` | none | `0269ea689daf752856a92e0182e64ed433f5e4a9a1cbb49fd4cd1fa9750c38fc` |
| `nacre/shell-tools/tests/test_top_hover.py` | `4c9d18e` / `siverteh/shell-tools/tests/test_top_hover.py` | 5da1132, 966ae9e, ea5653e, 548f0b4 | `c2ccfa937b563e8a8cc3a0565bebaca9958a8ab2d90a66455361bdf0a8cfaf29` |
| `nacre/shell-tools/tests/test_wallpaper_native.py` | `bc7c7e2` / `nacre/shell-tools/tests/test_wallpaper_native.py` | 02b2bda | `208c75f0d9685a3089b0a917dd8285dfd8ccb867bcafc955a8451276f96516bd` |
| `nacre/shell-tools/tests/test_wallpaper_picker_ui.py` | `06ffaf4` / `siverteh/shell-tools/tests/test_wallpaper_picker_ui.py` | 28707f7, eea01b9, bc7c7e2, 9a3b9a7, 548f0b4, 4886426, 1bee816, 83b3531, 5d0028f, 81827c1, ee6eeae | `6ee5eb13fd7ce303a74eb75f695f1260d9b6a138c697ad897f0810183c652c52` |
| `nacre/shell-tools/tests/test_wallpaper_rotation.py` | `4ea19d5` / `siverteh/shell-tools/tests/test_wallpaper_rotation.py` | 5da1132, 28707f7, eea01b9, 9a3b9a7, 548f0b4 | `da6a70446001087caf5e0f92d7d11c7d139bb6e33a3d52179db849c9af2aea48` |
| `nacre/shell-tools/tests/test_workspace_ui.py` | `ed8f1e1` / `nacre/shell-tools/tests/test_workspace_ui.py` | 02b2bda, ea5653e | `fea9078974ea62c52328c3086065cd4d7dae286465ca3fed86f5763f3a26b49d` |
| `tools/tests/test_app_files.py` | `86bebe6` / `tools/tests/test_app_files.py` | 548f0b4, a046f7b | `f0a107a8806e627674efe8207dff9be1353c4996d1a92c41e6353a9ede6770e3` |
| `tools/tests/test_bindings.py` | `9a435c3` / `tools/tests/test_bindings.py` | none | `3740b7c27b2ef5b9cd6dd120e09684d8c1d14d137621c293c9c1cdc37f1765f4` |
| `tools/tests/test_compositor_entrypoint.py` | `d3b5f5f` / `tools/tests/test_compositor_entrypoint.py` | none | `b2dc55ae75b7eb51dc205fba6cddfafa240f65908e59e020647ab5eea4feb409` |
| `tools/tests/test_motion_defaults.py` | `427a889` / `tools/tests/test_motion_defaults.py` | none | `cea538fa43d0a8a7d4e8f61e564c6c2173eee60c2a06e3954c7f2ab66ae07575` |
| `tools/tests/test_private_lua.py` | `bcdbd69` / `tools/tests/test_private_lua.py` | 548f0b4 | `59252bd11980e01b98c825511e2b7eafabd4d8c6e2c31485c8240875b0565155` |
| `tools/tests/test_session_cursor.py` | `0ffb982` / `tools/tests/test_session_cursor.py` | none | `53e3f37f1fbbe0a4ea235fbe5d4b1dd40b2d9a38d19c44db9c1d014b40b72dd9` |
| `tools/tests/test_session_startup.py` | `e90cf66` / `tools/tests/test_session_startup.py` | 36c35e0 | `0c4a11032c9281dc4dfc28c262ebe93e341649d640a4ce28ea3ae34947b2c491` |
| `tools/tests/test_window_routing.py` | `e944518` / `tools/tests/test_window_routing.py` | none | `4a3c77c42194ba3e9b0a404a7ca421d39782fddd35aa9357df428c765c7cd1b0` |

Validation: all 435 tests passed (72 tooling, 99 AI, 35 Brain, 229 shell), with
Ruff/native QML/Lua, palette CLI and JavaScript checks. Native Hyprland verification
passed; reviewed shell plan and config plan zero files/migrations. Installed
current/good UI and eight Brain files byte-exact, busy backend PID/start unchanged,
services and frame/palette IPC healthy, no compositor errors. Test-only correction
and audit records require no runtime deployment/restart. All remaining fixture
bodies now have explicit reviews; docs/notices and full comparison still open.
