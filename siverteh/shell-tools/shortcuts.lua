-- Native desktop tools. Existing app, workspace and power shortcuts stay in place.
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell palette"))
hl.bind("SUPER + K", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell keys"))
hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell left"))

-- Passive hover surfaces do not steal keyboard focus. Escape still reaches apps.
hl.bind("Escape", hl.dsp.global("siverteh_shell:dismissHoverEdges"), { non_consuming = true })
