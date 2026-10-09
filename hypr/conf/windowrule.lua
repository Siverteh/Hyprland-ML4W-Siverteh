-- Workspace map: browser, AI, Discord, Spotify, mail, Brain, editors.

-- Workspace 1: Browser
hl.window_rule({
    name = "browser-chrome",
    match = { class = "^([Gg]oogle-chrome)$" },
    workspace = "1 silent",
})
hl.window_rule({
    name = "browser-chromium",
    match = { class = "^([Cc]hromium)$" },
    workspace = "1 silent",
})
hl.window_rule({
    name = "browser-firefox",
    match = { class = "^([Ff]irefox)$" },
    workspace = "1 silent",
})

-- Workspace 2: AI
hl.window_rule({
    name = "ai-workers",
    match = { class = "^(siverteh-ai-task|siverteh-ai-dashboard)$" },
    workspace = "2 silent",
})

-- Workspace 3: Discord
hl.window_rule({
    name = "discord",
    match = { class = "^([Dd]iscord)$" },
    workspace = "3 silent",
})

-- Workspace 4: Spotify
hl.window_rule({
    name = "spotify",
    match = { class = "^([Ss]potify)$" },
    workspace = "4 silent",
})

-- Workspace 5: Mail
hl.window_rule({
    name = "mail-evolution",
    match = { class = "^(evolution|org[.]gnome[.]Evolution)$" },
    workspace = "5 silent",
})

-- Workspace 6: Brain
-- Dedicated Brain routing is in brain.lua.

-- Workspace 7: Editors
hl.window_rule({
    name = "editor-code",
    match = { class = "^([Cc]ode|com[.]microsoft[.]VSCode)$" },
    workspace = "7 silent",
})
hl.window_rule({
    name = "editor-codium",
    match = { class = "^([Vv][Ss][Cc]odium)$" },
    workspace = "7 silent",
})
hl.window_rule({
    name = "editor-cursor",
    match = { class = "^([Cc]ursor)$" },
    workspace = "7 silent",
})

-- Thunar uses the shared Files route bound in keybinding.lua.
hl.window_rule({
    name = "nacre-thunar-files",
    match = { class = "^([Tt]hunar)$" },
    float = true,
    center = true,
    size = "70% 75%",
})

