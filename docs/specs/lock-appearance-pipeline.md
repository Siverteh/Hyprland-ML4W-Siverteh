# Lock appearance generation, cached data and preparation

Spec ready, 2026-10-10 UTC. Bounded area: shell-tools/lock-config.py,
lock-info.py, lock-dashboard.py, lock-prepare.py and maintained tests
{test_lock_widgets,test_lock_ready,test_lock_dashboard}.py. Follow origins
a0090ce, layout corrections 80a23f2/8ff30bc, single-tile dashboard 55fbe20,
call-time-home bb46dd6, formatter 83b3531 and namespace 548f0b4. The dashboard's
Caelestia-style visual reference is not proof of copied or independent code:
investigate actual source/template/artwork ancestry, preserve preferred current
appearance and separately record native/Pillow/font/media dependencies.

Authentication, password entry, lock-before-sleep, power/lid hooks and Hyprlock
session ownership stay unchanged. Do not replace the trusted lock backend with
a Quickshell animation or test by locking/suspending/logging out the busy user.
Native appearance previews use owned temporary windows/data and close only those
processes. No private weather/location/account/notification content committed.

Record public producer/caller schemas, required palette roles, monitor/layout
keys, panel/scaling bounds, cached information freshness, artwork/error fallbacks,
prepared asset/cache keys and output file permissions. Capture actual outputs
under isolated HOME/fake IPC/network/process owners; do not consult old/upstream
bodies while writing replacements. Trace local source: retain verified own code,
otherwise capture/spec first, delete inherited/uncertain bodies, implement fresh
from public Hyprlock/SVG/Pillow/Qt/data APIs. A low match score or new filename
alone cannot certify origin. Previous exposure recorded honestly, no legal
clean-room/final-license claim, notices retained pending complete evidence.

Keep media controls inside their cards and correctly aligned, transparent logo,
weather unavailable handling, bounded notification/resource text, fast prepared
loading and correct multi-monitor scaling. Cached/prepared assets should reuse
unchanged data, not repeatedly spawn processes or fetch remote data on every
render. Font/artwork licenses and source dependencies require explicit evidence;
no private copies in Git. Preserve palette choices, rotation deadline, user host
layout/private overrides, busy AI worker and full-access/skipreview policies.

Acceptance: existing meaningful actual owner/render/layout/data/cache tests,
additional tests only for demonstrated gaps; syntax/native preview/render/visual
inspection at relevant sizes, full checks/Hyprland and provenance integrity.
Production changes require reviewed plan/apply/source/IPC/private-state/worker
and safe preview gates; audit-only records keep already proven installed bytes.
No actual auth/session/power action for QA. Exact-main CI, explicit cold-login/
physical hardware and authentication proof limits. Login/branding/Thunar and
other generators/assets/tests remain separately scoped, whole originality goal
active until every required current-tree item is proven complete.
