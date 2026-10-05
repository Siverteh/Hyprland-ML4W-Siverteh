-- Additive Observatory appearance and routing. Existing terminal configuration stays intact.
hl.config({
    general = {
        gaps_in = 6, gaps_out = 12, border_size = 1,
    },
    decoration = {
        rounding = 10,
        active_opacity = 1, inactive_opacity = 1,
        blur = {enabled = true, size = 3, passes = 2, xray = false},
        shadow = {enabled = true, range = 20, render_power = 3},
    },
})
hl.window_rule({name="observatory-brain", match={class="^(siverteh-brain)$"}, workspace="6 silent",fullscreen_state="0 0",suppress_event="fullscreen maximize"})
hl.window_rule({name="observatory-brain-chrome", match={class="^chrome-127[.]0[.]0[.]1__-Default$"}, workspace="6 silent",fullscreen_state="0 0",suppress_event="fullscreen maximize"})
hl.window_rule({name="observatory-obsidian", match={class="^(obsidian|Obsidian)$"}, workspace="6 silent"})
hl.window_rule({name="observatory-workers", match={class="^(siverteh-ai-task|siverteh-ai-dashboard)$"}, workspace="2 silent"})
hl.window_rule({name="observatory-controls", match={class="^(siverteh-os-control)$"}, float=true,center=true,size="720 500"})
hl.window_rule({name="observatory-editors", match={class="^(Code|code|com.microsoft.VSCode|VSCodium|cursor|Cursor)$"}, workspace="7 silent"})
hl.bind("SUPER + 7", hl.dsp.focus({workspace=7,on_current_monitor=true}))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({workspace="7"}))
hl.bind("SUPER + B", hl.dsp.exec_cmd("~/.local/bin/siverteh-observatory brain"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("~/.local/bin/siverteh-observatory capture"))
