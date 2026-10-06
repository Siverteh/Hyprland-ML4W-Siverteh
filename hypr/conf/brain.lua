-- Brain windows and actions; desktop appearance lives in window.lua/decoration.lua.
hl.window_rule({name="observatory-brain", match={class="^(siverteh-brain)$"}, workspace="6 silent",fullscreen_state="0 0",suppress_event="fullscreen maximize"})
hl.window_rule({name="observatory-brain-chrome", match={class="^chrome-127[.]0[.]0[.]1__-Default$"}, workspace="6 silent",fullscreen_state="0 0",suppress_event="fullscreen maximize"})
hl.window_rule({name="observatory-obsidian", match={class="^([Oo]bsidian)$"}, workspace="6 silent"})
hl.bind("SUPER + B", hl.dsp.exec_cmd("~/.local/bin/siverteh-brain-ui brain"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("~/.local/bin/siverteh-brain-ui capture"))
