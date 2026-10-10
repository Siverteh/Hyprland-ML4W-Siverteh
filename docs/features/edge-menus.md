# Frame lips and edge menus

Nacre's frame has three permanent shallow curved lips: top-center for the full
dashboard, left-center for the assistant and right-center for the control center.
They overlay the existing reserved frame edges. Their protrusion adds no reserved
space and never changes application geometry. Lips are long, shallow and unoutlined, with uninterrupted joins to the frame. The existing dashboard features and AI backend are
retained; see [control center](control-center.md).

Hover mode opens the side lips and the 208px top lip column, including the full
bar above it up to the screen edge, without a keyboard grab. The rest of the bar and the surrounding side edges do not open panels. Status icons show passive,
click-through hints; clicking opens the corresponding control-center section.
Calendar remains a deliberate quick popup. Desktop → Edge menu activation offers
Hover lips or Click only. Both modes use the same visible targets and shared state.

Held buttons and true fullscreen block automatic entry. Explicit clicks/shortcuts
remain available. Dismissal blocks only the lip still under the pointer until it
leaves; it does not reopen a closing panel. A short exit grace allows travelling
from a lip into its panel. Hover is event-driven, without global pointer polling.

Opening the assistant leaves its pin false. Only its explicit pin control pins it;
a pinned assistant is preserved when the control center opens. Clicking an input
uses on-demand focus. Deliberately opened panels support Escape/outside click.
Closing releases their input region immediately while the clipped visual exit
finishes. Reduced motion settles directly. Per-output registration/release keeps
other and newer outputs intact. Full Settings retains its current modal behavior.

The notification popup stream is distinct from retained history. Transient and
narrowly identified screenshot/window feedback appears briefly without entering
history, unread counts or lock widgets. The shared notification policy preserves
actual messages, assistant completion and errors. Suppression releases hover/input
without deleting retained messages. Live popups remain attached to the frame.

Frame/input tests cover marked geometry, held-button/fullscreen guards, explicit
rearming, output replacement and native curved/iridescent pixels. Actual compositor
focus, repeated hover/close/application-click behavior and scaling need live gates;
headless tests alone cannot establish them.
