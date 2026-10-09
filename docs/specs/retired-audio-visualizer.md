# Retire the unreachable legacy audio visualizer

2026-10-09. The tracked reference inventory isolates four paths:
`nacre/shell/services/Cava.qml`, `nacre/shell/widgets/Spectrum.qml`,
`nacre/shell/utils/scripts/beat.js`, and
`nacre/shell-tools/tests/test_beats.mjs`. No maintained view, command or type
registration refers to the visualizer. Cava has no live process on the target host.
The current independently implemented media views use the native player provider.

History followed through renames identifies Cava's introduction in the original
reference integration (`4874385`). Spectrum was locally introduced in `a8b816f`,
and beat utility/test in `0f06bab` for the retired cat visualizer. These adjacent
files are unused local code, not automatically inherited because of their age.

Delete this unreachable group without reading or reusing its implementation.
Remove only its obsolete Node test invocation; retain Brain JavaScript syntax,
media/provider tests and all other suites. Add the four retired paths to the
integrity guard. Do not remove the system cava package, change playback, add a
replacement visualizer or alter sound output. Previous contract/history exposure
is acknowledged; no upstream source consultation or legal clean-room claim.

Acceptance: full checks/native Hyprland, reviewed shell-only plan/apply, exact
active source and absent retired paths. Open actual Media and overview pages,
check player readiness and Escape/input return, and retain wallpaper/appearance
preview checks. Record private preference/history hashes and worker identity.
Do not send playback commands or change radio/volume/hardware/account state.
Keep notices and rollback backups; whole-tree and dependency review remain open.
