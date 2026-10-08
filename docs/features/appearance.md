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
There is one timer in the existing Wallpapers singleton, independent of monitor
count, and it uses the existing serialized commit queue. No polling worker or
second wallpaper manager is installed.

Thirty fixed palettes provide complete light/dark roles, including readable
foreground pairs. Vivid covers twelve saturated rainbow accents (including Super
Red and Cobalt Blue); Soft includes eighteen gentler choices, preserving the
original six. The page filters Vivid, Soft or All colors. Vivid accents preserve
saturation while ensuring header and button contrast; light mode uses deeper
accents for readable text. Regenerate the precomputed file with the maintained
runtime's Python and `siverteh/shell-tools/generate-palettes.py`; output lives in
`siverteh/shell-tools/palette-presets.json`. Match wallpaper restores image-derived
colors. Private picker preferences also hold rotation options, the fixed preset
and its chosen mode. `classic-state.py` resolves fixed colors inside the existing
publisher before updating shell presentation, frame, GTK, Qt, terminal, lock and
login assets. Wallpaper changes still publish the new poster together with the
chosen colors, preserving image/palette synchronization. The CLI remains the
scheme owner; fixed presets do not introduce a second scheme installation.

The temporary wallpaper tournament is separate from maintained desktop code.
Completed user results and archived originals remain private; its launcher,
shortcut, isolated worktree and scratch files can be removed after completion.

