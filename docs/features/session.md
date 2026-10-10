# Session

[System overview](../overview.md) · [Deployment and recovery](../maintenance.md)

## Session ownership and readable source

UWSM owns graphical environment setup through `uwsm/env` and `env-hyprland`.
Keep XDG session identity with UWSM; avoid forced SDL backends and deprecated
scaling/backend variables. Hypridle uses its distribution-supplied user service;
the enabled desktop service does not also need a Hyprland startup command.
`startup-apps.sh` invokes the existing idempotent startup helper. One shared
Updates service owns package checking regardless of monitor count.

Quickshell 0.3.1 uses `qs.` module imports; relative JavaScript and asset URLs stay
within the configuration root. `.qmlls.ini` is host-generated and ignored. Use
multiline code: `qmlformat -i` for QML and `ruff format --target-version py313`
for Python. Keep formatter-only changes separate and run checks before and after.
Fixture adapters remove complete QML objects rather than assuming one-line code.

`tools/check.py` also detects conflicting class-wide routing/floating rules,
including witnessed overlaps of literal alternations and case pairs. Different
extra selectors, such as dialog titles, are scoped separately. This static check
never executes configuration and is not a proof of arbitrary PCRE intersection;
the compositor parser and real application checks remain necessary.

Fish symlink migration requires explicit `--migrate-owned`, verified tracked file
hashes or a recognized source tree, and a private backup. It preserves personal
Fish configuration. The release transaction forwards the flag through preflight
and application and captures the previous link for rollback.

The live migration imported only the reviewed toolkit/cursor variables and tested
actual launcher inheritance. A complete new login, physical Fn-row behavior and
real 15-minute password unlock still require checks on the actual session; avoid
logging out active workers merely to claim those tests passed. See the
[overview](../overview.md) and [optional boundary proposal](../repository-boundaries.md).

Dynamic chooser tiles now show the selected local video or animated GIF rather
than just its still poster. Selection settles for 180 ms before a player starts;
rapid browsing cancels that work. Carousel, Spotlight and the masked hexagon
view share the same silent preview component. Only the selected tile decodes,
and the desktop motion pauses while the chooser is open, so this does not run
a video grid or add a second active desktop decoder. Closing, changing tabs or
manual pause destroys the preview player. Static thumbnails remain underneath
until a video frame arrives. Decoder errors retain the still preview.


## Workflow presets and sidebar drafts

Focused/Presentation/Minimal now accompany Meeting/Music/Docked. Use Personal
workflow setup to save current audio defaults, connected display geometry and
selected startup apps for a preset. Missing devices are skipped; microphone mute
is preserved. These choices remain private, and selecting a preset never closes
working apps or chats.

Sidebar drafts are stored per native conversation with private permissions.
Attach selects local files; image attachments use native Codex image input,
other files are provided as user-selected local paths. Screenshot requests area
selection and stores the result privately. Sending is explicit. Message/code copy
buttons use the clipboard only when clicked. Attachment controls become available
when the updated assistant backend advertises support.


## Independent base appearance and tool rules

Nacre's base misc/decoration/tool Lua files are independently authored from the
current live options and maintained app contracts. Private host/desktop/palette
settings still load afterward. Shell glass excludes wallpaper/input-only surfaces.
Current mixer, Bluetooth/network editor, share picker, controls, preview and PiP
rules stay; unreferenced old ML4W app/hub/dotfiles rules are retired. Installed nwg
tools remain available but no longer receive inherited special window placement.
The lock preview rule now matches its actual Nacre title.

Attachment additions retain their originating composer key across queued and
in-flight file/picker/screenshot jobs. Results from an old composer are ignored;
current results merge through Qt-supported Map APIs. Existing draft save/load
revision behavior and backend full-access permission policy remain unchanged.
