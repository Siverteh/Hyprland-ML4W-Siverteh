-- Native desktop tools. Existing app, workspace and power shortcuts stay in place.
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell palette"))
hl.bind("SUPER + K", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell keys"))
hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell left"))

-- Native graphical Files trial; directory associations retain Dolphin.
hl.unbind("SUPER + SHIFT + F")
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell thunar"))
hl.window_rule({
    name = "siverteh-thunar-trial",
    match = { class = "^([Tt]hunar)$" },
    float = true,
    center = true,
    size = "70% 75%",
})
