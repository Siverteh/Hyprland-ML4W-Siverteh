-- Native desktop tools. Existing app, workspace and power shortcuts stay in place.
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell palette"))
hl.bind("SUPER + K", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell keys"))
hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell left"))

-- Thunar uses the shared Files route bound in keybinding.lua.
hl.window_rule({
    name = "siverteh-thunar-files",
    match = { class = "^([Tt]hunar)$" },
    float = true,
    center = true,
    size = "70% 75%",
})
