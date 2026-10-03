-- =====================================================

-- Laptop Mode: Siverteh Workspace Map

-- =====================================================

-- Workspace 1: Browser
hl.window_rule({
    match = {
        class = "^(Google-chrome)$",
    },
    workspace = "1 silent",
})
hl.window_rule({
    match = {
        class = "^(google-chrome)$",
    },
    workspace = "1 silent",
})
hl.window_rule({
    match = {
        class = "^(chromium)$",
    },
    workspace = "1 silent",
})
hl.window_rule({
    match = {
        class = "^(firefox)$",
    },
    workspace = "1 silent",
})
hl.window_rule({
    match = {
        class = "^(Firefox)$",
    },
    workspace = "1 silent",
})

-- Workspace 2: Code
hl.window_rule({
    match = {
        class = "^(Code)$",
    },
    workspace = "2 silent",
})
hl.window_rule({
    match = {
        class = "^(code)$",
    },
    workspace = "2 silent",
})
hl.window_rule({
    match = {
        class = "^(VSCodium)$",
    },
    workspace = "2 silent",
})
hl.window_rule({
    match = {
        class = "^(cursor)$",
    },
    workspace = "2 silent",
})
hl.window_rule({
    match = {
        class = "^(Cursor)$",
    },
    workspace = "2 silent",
})

-- Workspace 3: Discord
hl.window_rule({
    match = {
        class = "^(discord)$",
    },
    workspace = "3 silent",
})
hl.window_rule({
    match = {
        class = "^(Discord)$",
    },
    workspace = "3 silent",
})

-- Workspace 4: Spotify
hl.window_rule({
    match = {
        class = "^(Spotify)$",
    },
    workspace = "4 silent",
})
hl.window_rule({
    match = {
        class = "^(spotify)$",
    },
    workspace = "4 silent",
})

-- Workspace 5: Mail
hl.window_rule({
    match = {
        class = "^(evolution)$",
    },
    workspace = "5 silent",
})
hl.window_rule({
    match = {
        class = "^(org.gnome.Evolution)$",
    },
    workspace = "5 silent",
})

-- Workspace 6: System and misc
hl.window_rule({
    match = {
        class = "^(mission-center)$",
    },
    workspace = "6 silent",
})
hl.window_rule({
    match = {
        class = "^(mission-center)$",
    },
    float = false,
})
hl.window_rule({
    match = {
        class = "^(io.missioncenter.MissionCenter)$",
    },
    workspace = "6 silent",
})
hl.window_rule({
    match = {
        class = "^(io.missioncenter.MissionCenter)$",
    },
    float = false,
})
