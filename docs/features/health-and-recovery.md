# Health and recovery

Settings → Maintenance includes desktop/assistant services, sleep locking,
portal services and the knowledge-sync schedule. On-demand portal services are
labelled ready rather than failed when idle. Status is queried in one batch and
refreshes only on the Maintenance page. Repair failed portals restarts only
failed portal units, preserving an active screen-sharing service.

Knowledge synchronization records its state, last attempt, last successful sync
and next retry in private local state. Offline SSH connections back off; identity
and protocol failures remain distinct errors. Local notes remain available and
three-way merging preserves conflicts. Retry knowledge sync bypasses the delay.
Existing SSH/Tailscale settings own connectivity; the sync helper does not turn
VPN links on automatically. Transport recovery and a successful exchange are
separate facts.

Display geometry/DPR changes settle before affected output UI surfaces are
recreated. Shared services, assistant workers and wallpaper decoders stay alive.
Panel flags, launcher selections, editable controls and scroll positions are
restored. Chat scroll uses message IDs and drafts retain their conversation key.
Password controls and rendered message/note bodies are excluded from generic
view snapshots. Removed outputs retain a private in-memory view for reattachment.

A missing replacement surface triggers full renderer recovery. The fallback
snapshot travels on stdin into a private runtime file, never in process arguments;
a detached user service survives the shell restart, restores the view and removes
that file. Lock-screen geometry is refreshed. The existing twenty-second display
Keep/Revert safeguard remains separate and unchanged. Physical dock, suspend and
multi-output acceptance must be recorded honestly; IPC probes do not establish
that physical hardware was tested.
