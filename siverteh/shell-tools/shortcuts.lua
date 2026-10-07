-- Native desktop tools. Existing app, workspace and power shortcuts stay in place.
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell palette"))
hl.bind("SUPER + K", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell keys"))
hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell left"))

-- Temporary keyboard-only Files trial. The GUI Files route remains unchanged.
hl.unbind("SUPER + SHIFT + F")
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell yazi"))
