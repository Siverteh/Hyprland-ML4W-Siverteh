# Appearance

[System overview](../overview.md) · [Deployment and recovery](../maintenance.md)

## Appearance rotation and fixed palettes

Appearance groups the current wallpaper, rotation, desktop colors and a collapsed
collection grid. Rotation defaults to off, with a recommended 30-minute interval.
Presets offer 15, 30, 60 and 120 minutes; the custom interval accepts 5–1440 minutes.
The pool can include all, static or dynamic wallpapers. Shuffle walks through the
pool before repeating; ordered rotation follows the catalog. Manual selection
starts a fresh interval. Sleep, lock, the picker, Settings and an in-flight commit
pause the one-shot timer but preserve its absolute deadline. Returning resumes
the remaining interval, or makes one overdue change without catch-up bursts.
There is one timer in the NacreWallpapers singleton, independent of monitor
count, and it uses the existing serialized commit queue. No polling worker or
second wallpaper manager is installed.

Thirty fixed palettes provide complete light/dark roles, including readable
foreground pairs. Vivid covers twelve saturated rainbow accents (including Super
Red and Cobalt Blue); Soft includes eighteen gentler choices, preserving the
original six. The page filters Vivid, Soft or All colors. Vivid accents preserve
saturation while ensuring header and button contrast; light mode uses deeper
accents for readable text. Regenerate the precomputed file with the maintained
runtime's Python and `nacre/shell-tools/generate-palettes.py`; output lives in
`nacre/shell-tools/palette-presets.json`. The same generator also writes
`reference-style.json`, the unconfigured/fallback palette, so its container colors
and engine identity stay consistent with Orient. Regeneration does not change
private wallpaper or palette selections. Match wallpaper restores image-derived
colors. Private picker preferences also hold rotation options, the fixed preset
and its chosen mode. `classic-state.py` resolves fixed colors inside the existing
publisher before updating shell presentation, frame, GTK, Qt, terminal, lock and
login assets. Wallpaper changes still publish the new poster together with the
chosen colors, preserving image/palette synchronization. The CLI remains the
scheme owner; fixed presets do not introduce a second scheme installation.

The temporary wallpaper tournament is separate from maintained desktop code.
Completed user results and archived originals remain private; its launcher,
shortcut, isolated worktree and scratch files can be removed after completion.


## Publishing a palette safely

The toolkit publisher validates the complete palette before it writes consumer
files. Missing roles, invalid color strings or unsupported modes fail without
replacing the current presentation. Direct calls and prepared selections share
the CLI's commit lock; an inherited CLI descriptor is checked rather than trusting
its environment marker alone. Prepared publication can re-enter the same owner.

Each output is replaced atomically and normal publication is serialized. This
prevents readers from seeing half-written files or simultaneous publishers from
interleaving. It does not make the whole collection of application settings a
single filesystem crash transaction. Private sidebar/history writes keep their
existing lightweight atomic primitive; no new polling or per-keystroke disk sync.

The active KDE color scheme is named Nacre. Existing private schemes are
preserved, including the earlier Siverteh.colors file. Palette-matched folder
overlays repair recognized stale source links; custom index files and regular
artwork overrides stay untouched. Valid cache indexes are reused without writes.

Folder artwork is supplied by the installed [Papirus icon theme](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme),
under its retained [GPL-3.0 license](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/blob/master/LICENSE).
The overlay links to that package artwork; it does not make the icons original
Nacre art or copy them into this repository.


## Rotation deadlines

Rotation deadlines derive from persistent successful photo timestamps and the
saved rotation enable/interval/filter anchor, so renderer restarts and unrelated
picker/color preferences cannot postpone them indefinitely. Old private records
migrate using their existing modification time, without changing the selected
wallpaper. The publisher preserves the photo timestamp for color-only commits.
Only a successful wallpaper change advances it; failures retry after one minute.
Settings shows the real schedule or specific pause reason, and `wallpaper.state`
IPC includes timer-running, due-time, remaining-seconds and pause-reason fields.
There is still one one-shot timer, no recurring countdown polling and no new
wallpaper owner. Deadline values are epoch milliseconds, independent of timezone.
