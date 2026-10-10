# Desktop startup and installation source audit

2026-10-10 UTC. Audit the complete current bodies of shell-tools control.sh,
launch.sh, shell-supervisor.py, install.py, install-extras.py, provision.py,
nacre-shell.service and siverteh-sidebar-ai.service. Trace their first authoring
and later changes, including explicit native package and palette ownership.
Consumer edits/change pointers alone do not certify an installer. Qt compatibility,
font ownership, palette publication and release/configuration tools have separate
source boundaries and reviews; do not certify them by association.

Capture command/data contracts first. The service starts the supervisor and one
Quickshell renderer using native system packages; launcher compatibility aliases
do not create another desktop owner. Failed startup remains visible and recovery
uses validated good source. Source deployment preserves host overrides and private
preferences/accounts/workers; code-only deployment must not reinstall credentials
or restart a busy AI backend. Provisioning owns only its private palette Python
environment, not private copies of system Qt/Quickshell/Thunar libraries.

Retain verified independently authored code with per-file SHA/basis/later-history
evidence. For uncertain inherited bodies, extend the behavior spec before deletion
and implement fresh from producer/caller schemas, tests and public APIs without
upstream/old-body consultation while writing replacements. Record earlier exposure
honestly. Retain notices pending final comparison; no legal clean-room claim.

Acceptance: current source/history evidence and existing meaningful installation,
recovery/provision/native-runtime tests; corrections only for demonstrated gaps.
Full checks/native Hyprland, plan, installed source/helper/IPC/private/worker
evidence and exact-main CI. Audit-only documentation retains the good runtime;
real source corrections require plan/apply/strict release and input gates.
Never perform actual account/device/power/auth actions solely for verification.
Other helpers/login/tests/workflow/packaging and final comparison stay open;
the complete originality goal remains active.
