-- Nacre's personal application map; Brain and title-scoped helpers remain separate.
local routes = {
    { "browser-chrome", "^([Gg]oogle-chrome)$", 1 },
    { "browser-chromium", "^([Cc]hromium)$", 1 },
    { "browser-firefox", "^([Ff]irefox)$", 1 },
    { "ai-workers", "^(siverteh-ai-task|siverteh-ai-dashboard)$", 2 },
    { "discord", "^([Dd]iscord)$", 3 },
    { "spotify", "^([Ss]potify)$", 4 },
    { "mail-evolution", "^(evolution|org[.]gnome[.]Evolution)$", 5 },
    { "editor-code", "^([Cc]ode|com[.]microsoft[.]VSCode)$", 7 },
    { "editor-codium", "^([Vv][Ss][Cc]odium)$", 7 },
    { "editor-cursor", "^([Cc]ursor)$", 7 },
}
for _, route in ipairs(routes) do
    hl.window_rule({
        name = route[1],
        match = { class = route[2] },
        workspace = tostring(route[3]) .. " silent",
    })
end

-- Files stays an unpinned popup on the current workspace.
hl.window_rule({
    name = "nacre-thunar-files",
    match = { class = "^([Tt]hunar)$" },
    float = true,
    center = true,
    size = "70% 75%",
})

-- Dolphin opens wider for its Places sidebar and file grid, on the current workspace.
hl.window_rule({
    name = "nacre-dolphin-files",
    match = { class = "^(org[.]kde[.]dolphin|[Dd]olphin)$" },
    float = true,
    center = true,
    size = { "monitor_w*0.8", "monitor_h*0.75" },
})
