# Desktop startup and installer current-source audit

2026-10-10 UTC. Eight complete current helper/unit bodies individually reviewed,
including installer full/code-only/restore paths, command routing, native runtime
checks, supervisor health/recovery and immutable Orient build/promotion.

Control/install/launch/provision helpers were authored for local deployment in
4874385. That commit also imported vendor shell/CLI, so first Git addition alone
is not evidence of independent origin. Traced local behavior changes and current
bodies use project-specific native command/data contracts; first-source normalized
five-line comparison against implementation peers in that mixed import snapshot
and the relevant later authoring snapshots found no copies. This supplements
history and body review rather than replacing final whole-upstream comparison.
Current control.sh is an added renamed path in 548f0b4; explicitly tracing the
previous siverteh path identifies its 4874385 origin and desktop/Brain/light routing
changes. The shell unit's detected copy from the locally authored Brain unit is
standard systemd service scaffolding; Brain implementation remains separate.

Supervisor/sidebar units first e3d0298 and native shortcut installer first 007d020
are local authoring. Provision's current immutable Orient generation/promotion
body is 5ecf556 with 0573f6b cache correction; native extraction was retired 47b06d4.
The current installer uses independently reviewed palette/font owners rather
than vendor generation algorithms. Current installed command/unit copies and
native IPC establish the actual startup chain; their existence does not certify
callee/helper/test origins.

Retain these independent bodies unchanged. Failed candidates are rejected before
source activation; good-source recovery retains rejected code and preferences.
Only validated immutable Orient candidates become active. Native binaries remain
pacman-owned; code-only deployment leaves busy AI workers alive and uses release
rollback/strict live-source checks. Private account/device/power actions are not
used for audit QA. Earlier exposure is acknowledged, without a legal clean-room
or final-license claim; notices and full-tree comparison remain open.

| Current source | Authoring/replacement basis | Later current-path changes | Current SHA-256 |
|---|---|---|---|
| `nacre/shell-tools/control.sh` | `548f0b4` | 1488f68 | `7b0fc6d6f6db8d5a5662c83369589aeca4461492620fcda26c9287f2d387da13` |
| `nacre/shell-tools/launch.sh` | `4874385` | 548f0b4, ac8be46, 79916a3, c0816b6, a1e6926, 47b06d4, 2fa3a95, a8b816f | `91085757d98fb57679f5c52dabed07eb45f6273bbf48095b529d7cfc061f3331` |
| `nacre/shell-tools/shell-supervisor.py` | `e3d0298` | 548f0b4, bb46dd6, 83b3531 | `1d984b695e3cdc321319abbd8df3d6cc28a72a74cac58da8d3001e96cf65e1cb` |
| `nacre/shell-tools/install.py` | `4874385` | 59c7202, 5ecf556, 548f0b4, 73092de, 4886426, 5df2e69, bcdbd69, 9397909, 07f5cdd, 47b06d4, 83b3531, 85316eb, 8bd5e65, 2fa3a95, e3d0298, 007d020, a9a683d, 746fc96, a8b816f, 8afd305, 3c1b16d, 42a8183 | `6351ecc6745611dc0b784205861f85bdb872ae112122cdda900784ce4d129382` |
| `nacre/shell-tools/install-extras.py` | `007d020` | 548f0b4, bcdbd69, 8ff30bc, a046f7b, 338417c, 30a52ae, 86bebe6, 5611be5, 83b3531, 2fa3a95 | `4593784b0fa12d24c38991df0ad7aa5944f1f3a7b21f5fa7c95f7c46bbb9b72a` |
| `nacre/shell-tools/provision.py` | `5ecf556` | 0573f6b | `8fc59f2013962056a53dc89a3197ecd13b298112cb68f5a7e63dbfbf3304c0fc` |
| `nacre/shell-tools/nacre-shell.service` | `4874385` | 548f0b4 | `c62043b3bd0b69c666c5d1feb66b44db3fb30a91e50f3a6b4b928aed4706d9cc` |
| `nacre/shell-tools/siverteh-sidebar-ai.service` | `e3d0298` | 548f0b4 | `20f17b1978b1d810d6291007d05da07fdde5332e0e3c9686d96e79b95fe0659e` |
