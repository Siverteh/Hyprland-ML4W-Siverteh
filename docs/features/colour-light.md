# Colour and light services

NacreColours preserves Orient's Natural/Harmony/preset output and mode. It validates
a complete role set before publishing colours and mode as one state. All role
values are native QColor values; compatibility m3/named aliases remain. Invalid
data keeps the last palette, with an own Orient Slate fallback at first startup.
NacrePresentation.active remains the matched wallpaper/palette authority; legacy
current.txt is fallback only when that authority is unavailable. Publication
disables role tweening for its frame, so cached colours appear with the wallpaper.
No extra palette generator, wallpaper writer or interpreter polling is introduced.

NacreBrightness owns sysfs/connector discovery shared with NacreKeyboardLight.
NacreBacklight holds a screen's NacreLightChannel: native maximum/current reads,
finite bounded user requests, latest-only 40 ms write coalescing, stale-generation
checks and actual read-back/error reporting. Backlight 0 clamps to 1; keyboard 0 is
valid. Keyboard-up cycles hardware levels; down clamps at 0. Display keys step 5%.
The indicator opens on explicit adjusted events, not initial file reads.

Native file reads run every 3 seconds only while controls/dashboard are visible,
with no repeated interpreter reads. DDC never polls: discovery/explicit refresh/
writes read the device. Mapping uses a unique DRM connector/bus and EDID hash,
rejecting ambiguity or changed devices. Unsupported hardware is unavailable.
brightnessctl owns sysfs permission handling; commands use validated argv and
deadlines. Errors appear below the controls and in state diagnostics. There is no
new sudo/polkit/udev change. Existing IPC/keys and nacre_shell shortcut names remain.

Old provider names are small forwarders. Known Monitor-typed callers now use
NacreBacklight. Spec/acceptance boundary:
[colour/light spec](../specs/colour-light-services.md). External physical DDC,
hotplug, next login and battery behavior require later hardware acceptance.
