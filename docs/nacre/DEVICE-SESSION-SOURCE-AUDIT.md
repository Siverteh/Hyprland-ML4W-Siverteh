# Device and session helper current-source audit

2026-10-10 UTC. Seventeen complete current helper/unit bodies and eleven specific
Python test sources individually reviewed against local authoring/replacement
histories and native producers/consumers. Other helpers/fixtures remain separate.

Existing independent light/network/resource replacements retained. Local desktop
routing, device actions/location, timezone/weather, power/idle migration, session/
process/startup/title/workflow integrations traced through current changes.
Added-during-rename session unit explicitly followed to its earlier local unit;
power unit follows siverteh-manual-power.service. First-source peer comparisons
found only standard native IPC/nmcli query sequences shared with own earlier
helpers. These metrics supplement actual history/body/API review, not sole proof
or final whole-upstream comparison. Prior exposure acknowledged; no legal
clean-room/final-license claim. Native system packages/APIs remain dependencies.

A real command boundary mismatch was corrected: the action builder counted SSID
characters whereas discovery/native NetworkManager validates bytes. New pure
regression failed old oversized multibyte input; fd2c9ff aligns the builder with
UTF-8 bytes, preserving valid 32-byte ASCII/two-byte/four-byte values and control
rejection. No actual network connection/rescan was executed. Public protocol
limits, not native vendor code, informed the own one-line correction.

Reviewed fixtures use fake commands/sysfs/DDC/location/time/root directories,
pure startup plans and labelled session records. Real lock/suspend/power/device/
location/timezone/account/AI launch actions are not verification tools. Existing
private timeouts, same-user process handling, busy workers, user app routing and
full-access/skipreview policy preserved. Referenced desktop-settings/AI providers,
remaining tests/assets/packaging and licensing comparison stay separately scoped.

[NetworkManager SSID data contract](https://networkmanager.dev/docs/api/latest/settings-802-11-wireless.html)
and [native byte-length validation](https://github.com/NetworkManager/NetworkManager/blob/main/src/libnm-core-impl/nm-setting-wireless.c).

| Current source | Authoring/replacement basis | Later path changes | Current SHA-256 |
|---|---|---|---|
| `nacre/shell-tools/desktop-actions.py` | `ba5e48f` | 548f0b4 | `ce3c17a7a34d4dc684c2225f76fc46625ba6e56b5d65ed00c7de8ceb9abcaf0f` |
| `nacre/shell-tools/device-actions.py` | `a0090ce` | fd2c9ff, 548f0b4, 2c1d2ca, 51eb6e1, 83b3531 | `d6271970ce161b5ccf045a775546da112a7418b1307d3b82b678b07e5382d22a` |
| `nacre/shell-tools/device-location.py` | `b8be61e` | 548f0b4 | `ce85154df6f9ab9ae26fc8710e6423acd6cc77eb44faf2109457643c35656f5b` |
| `nacre/shell-tools/light-devices.py` | `02b2bda` | unchanged | `62c811ea4161816bbe465e8eb84e7a23ea367779b39dc83c03f9d5f7af31a5cf` |
| `nacre/shell-tools/network-state.py` | `977f628` | unchanged | `1893bacddfc6a079fc8bc37a1cbd11d21e28d15a0d47f902902331987598af1a` |
| `nacre/shell-tools/resource-state.py` | `18d8aab` | unchanged | `1deb2ef06307ac4b97925ac2c46a2e4b2c43e46d97c9af817137674f702797c0` |
| `nacre/shell-tools/timezone.py` | `9dd732a` | 548f0b4, b8be61e, 83b3531 | `e8d2aa3c1c68979e888039db3d2583edad9fb8ed9069b25260a4c26a07a8d611` |
| `nacre/shell-tools/weather.py` | `a0090ce` | 548f0b4, 55fbe20, 83b3531 | `10eecde6b92f9eb653c88e928dcf134aaac2bd478e5983810652811b4473a7c1` |
| `nacre/shell-tools/power-button-policy.py` | `73092de` | 548f0b4 | `b5ad8c604e5e174c7cdafffa3be31dd467479596eb2c35a16b90d11cb26e9b54` |
| `nacre/shell-tools/idle-policy.py` | `5df2e69` | 548f0b4, 6f88e53 | `ff605d417624074ab2f82f69134986508429fb70e9583f0e0c4faa3ef385f02d` |
| `nacre/shell-tools/nacre-power-key.service` | `73092de` | 548f0b4 | `1e3949a116c2e17c75f5c0763b8408593850e05a00b3d87b5858718c102df96c` |
| `nacre/shell-tools/nacre-session-watch.service` | `548f0b4` | unchanged | `3fbabd619eb90087226d795d492eac5cc4a0ef5728f0a4a3ea6941d4ec5d5668` |
| `nacre/shell-tools/session-watch.py` | `8bd5e65` | 548f0b4, bb46dd6, 83b3531, 8a32ba0 | `c29fc22793eae4491b67e9fc60fb1deabfe40690440fc557f420ff998d9b9ae9` |
| `nacre/shell-tools/isolate-apps.py` | `007d020` | 548f0b4, 83b3531 | `2dbb34fc8f1567355d58511e9982f1767ad98d52d949ba59b4e18367767e528f` |
| `nacre/shell-tools/startup-apps.py` | `b0632b9` | 548f0b4, 83b3531, 8bd5e65, 2fa3a95 | `21b37b6e73426b016804bc2e0b3976addad481901304a7e0ac6cc4e1781e4c13` |
| `nacre/shell-tools/window-chat-title.py` | `be81bf0` | 548f0b4, 83b3531, 007d020 | `82e9285ee732aa4675a954445453f59afaea70eb62308a9d4b0b686a1e5c81b0` |
| `nacre/shell-tools/workflow-profiles.py` | `8bd5e65` | 548f0b4, 83b3531, 8a32ba0 | `742dbbc6ab552dab095487f190a44667e3fe285193a8aaa561093dfb06c2de73` |
| `nacre/shell-tools/tests/test_desktop_actions.py` | `ba5e48f` | 548f0b4 | `229b22ca0864ff2f422c5e0e1b165a3bbcda1ab794c09afd731d12fd4d09e759` |
| `nacre/shell-tools/tests/test_device_location.py` | `b8be61e` | 548f0b4 | `0519b191bf014166f633b794abcb7be3034a65736300635f0d5c0140fb34c789` |
| `nacre/shell-tools/tests/test_network_state.py` | `977f628` | unchanged | `d73c5f2d091823f5bacfc224093160e80f3d61e71c20ee831ac43f5f31fde4e5` |
| `nacre/shell-tools/tests/test_light_devices.py` | `02b2bda` | unchanged | `e339456880d4aea64bda5fac76403a7a8d8edb6f6c9be8d8c4f04c8cc7319629` |
| `nacre/shell-tools/tests/test_resource_state.py` | `18d8aab` | unchanged | `d1f112514858d4b74a6632e3555f6880338548843f9b1c033f04a7e4fb3cd4dc` |
| `nacre/shell-tools/tests/test_timezone.py` | `9dd732a` | 548f0b4, b8be61e, 83b3531 | `9182a7fbe396f1c2bd504d2ccf60f864ca86d70cdd57f68335631a6d96d3058a` |
| `nacre/shell-tools/tests/test_session_workflows.py` | `8bd5e65` | 548f0b4, 83b3531 | `b1e9e2fe0fa4749e4a424ec43a720b4b35cc4970c19643f8a77ab2c13fc17125` |
| `nacre/shell-tools/tests/test_power_button.py` | `73092de` | 548f0b4 | `c395dd28ca11441df6e2c250cdfef4a7acf749c8d909262804abb3df3efba8db` |
| `nacre/shell-tools/tests/test_idle_policy.py` | `5df2e69` | 548f0b4 | `dde7b27cbbefa13a7bdb4eb32dbd7a51c2d15b7ec4b39f097d61b6ea5ba940da` |
| `nacre/shell-tools/tests/test_startup_apps.py` | `b0632b9` | 548f0b4, 83b3531 | `5e4d43999d060aae43eb0fe0612abb0cb12b1957e6cf734cef3d76d773262eb1` |
| `nacre/shell-tools/tests/test_device_actions.py` | `fd2c9ff` | unchanged | `d49053fc78e4eae7098e743888f8d57f5c8a05eb3d90621378bb188de3f094bd` |
