-- Nacre shortcut composition; private routes load afterwards.
local function construct(row)
    local factory = hl.dsp
    for part in row[2]:gmatch("[^.]+") do
        factory = factory[part]
    end
    if row[3] == nil then
        return factory()
    end
    return factory(row[3])
end

local function install(rows)
    for _, row in ipairs(rows) do
        hl.bind(row[1], construct(row), row[4])
    end
end

-- Device keys and capture routes.
install({
    { "XF86AudioMute", "exec_cmd", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true } },
    { "XF86AudioLowerVolume", "exec_cmd", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", { locked = true, repeating = true } },
    { "XF86AudioRaiseVolume", "exec_cmd", "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+", { locked = true, repeating = true } },
    { "XF86AudioMicMute", "exec_cmd", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
    { "XF86PowerOff", "exec_cmd", "loginctl lock-session", { locked = true } },
    { "XF86MonBrightnessDown", "exec_cmd", "~/.local/bin/nacre-shell brightness down" },
    { "XF86MonBrightnessUp", "exec_cmd", "~/.local/bin/nacre-shell brightness up" },
    { "XF86KbdBrightnessUp", "exec_cmd", "~/.local/bin/nacre-shell keyboard-light up" },
    { "XF86KbdBrightnessDown", "exec_cmd", "~/.local/bin/nacre-shell keyboard-light down" },
    { "SUPER + period", "exec_cmd", "~/.local/bin/nacre-app emoji" },
    {
        "Print", "exec_cmd",
        "grim -g \"$(slurp)\" - | wl-copy && notify-send \"Screenshot\" \"Copied to clipboard\"",
    },
    {
        "SUPER + Print", "exec_cmd",
        "grim ~/Pictures/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png && notify-send \"Screenshot\" \"Saved to Pictures/Screenshots\"",
    },
})

-- Window lifetime helpers preserve the current trash/restore behavior.
install({
    { "SUPER + Q", "exec_cmd", "~/.config/hypr/scripts/window-trash.sh trash" },
    { "SUPER + SHIFT + Q", "exec_cmd", "~/.config/hypr/scripts/window-trash.sh restore-last" },
    { "SUPER + ALT + Q", "exec_cmd", "~/.config/hypr/scripts/window-trash.sh restore-all" },
    { "SUPER + CTRL + Q", "exec_cmd", "~/.config/hypr/scripts/window-close.sh" },
    { "SUPER + CTRL + SHIFT + Q", "exec_cmd", "~/.config/hypr/scripts/window-close.sh force" },
    { "SUPER + H", "exec_cmd", "~/.config/hypr/scripts/window-minimize.sh hide" },
    { "SUPER + SHIFT + H", "exec_cmd", "~/.config/hypr/scripts/window-minimize.sh restore-last" },
    { "SUPER + ALT + H", "exec_cmd", "~/.config/hypr/scripts/window-minimize.sh restore-current" },
    { "SUPER + F", "window.fullscreen", { mode = "fullscreen" } },
    { "SUPER + M", "window.fullscreen", { mode = "maximized" } },
    { "SUPER + T", "window.float", { action = "toggle" } },
    { "SUPER + P", "window.pin" },
    { "SUPER + SHIFT + P", "window.pseudo" },
    { "SUPER + G", "group.toggle" },
    { "SUPER + bracketleft", "group.prev" },
    { "SUPER + bracketright", "group.next" },
    { "SUPER + J", "layout", "togglesplit" },
    { "SUPER + mouse:272", "window.drag", nil, { mouse = true } },
    { "SUPER + mouse:273", "window.resize", nil, { mouse = true } },
    { "ALT + TAB", "window.cycle_next", { next = true } },
    { "ALT + SHIFT + TAB", "window.cycle_next", { next = false } },
})

-- Numbered workspaces have matching focus and move combinations.
for workspace = 1, 7 do
    install({
        { "SUPER + " .. workspace, "focus", { workspace = workspace, on_current_monitor = true } },
        { "SUPER + SHIFT + " .. workspace, "window.move", { workspace = workspace } },
    })
end
install({
    { "SUPER + TAB", "focus", { workspace = "m+1", on_current_monitor = true } },
    { "SUPER + SHIFT + TAB", "focus", { workspace = "m-1", on_current_monitor = true } },
    { "SUPER + mouse_down", "focus", { workspace = "e+1", on_current_monitor = true } },
    { "SUPER + mouse_up", "focus", { workspace = "e-1", on_current_monitor = true } },
    { "SUPER + CTRL + SHIFT + left", "window.move", { workspace = "r-1" } },
    { "SUPER + CTRL + SHIFT + right", "window.move", { workspace = "r+1" } },
    { "SUPER + grave", "workspace.toggle_special", "" },
    { "SUPER + SHIFT + grave", "window.move", { workspace = "special" } },
})

local directions = {
    { "left", -30, 0 }, { "right", 30, 0 }, { "up", 0, -30 }, { "down", 0, 30 },
}
for _, direction in ipairs(directions) do
    install({
        { "SUPER + " .. direction[1], "focus", { direction = direction[1] } },
        { "SUPER + SHIFT + " .. direction[1], "window.move", { direction = direction[1] } },
        { "SUPER + ALT + " .. direction[1], "window.resize", { x = direction[2], y = direction[3], relative = true }, { repeating = true } },
    })
end
install({ { "SUPER + R", "submap", "resize" } })
hl.define_submap("resize", function()
    for _, direction in ipairs(directions) do
        install({
            { direction[1], "window.resize", { x = direction[2], y = direction[3], relative = true }, { repeating = true } },
        })
    end
    install({
        { "escape", "submap", "reset" },
        { "return", "submap", "reset" },
        { "SUPER + R", "submap", "reset" },
    })
end)

-- Desktop surfaces and explicit session actions.
install({
    { "SUPER + A", "exec_cmd", "~/.local/bin/nacre-shell launcher" },
    { "SUPER + D", "exec_cmd", "~/.local/bin/nacre-shell overview" },
    { "SUPER + V", "exec_cmd", "~/.local/bin/nacre-shell clipboard" },
    { "SUPER + W", "exec_cmd", "~/.local/bin/nacre-shell wallpaper" },
    { "SUPER + Z", "exec_cmd", "~/.local/bin/nacre-shell hide" },
    { "SUPER + O", "exec_cmd", "~/.local/bin/nacre-shell toggle" },
    { "SUPER + S", "exec_cmd", "~/.local/bin/nacre-settings" },
    { "SUPER + SHIFT + O", "exec_cmd", "~/.local/bin/nacre-settings" },
    { "SUPER + ALT + K", "exec_cmd", "~/.local/bin/nacre-settings" },
    { "SUPER + X", "exec_cmd", "~/.local/bin/nacre-shell session" },
    { "SUPER + ESCAPE", "exec_cmd", "loginctl lock-session" },
    { "SUPER + SHIFT + R", "exec_cmd", "hyprctl reload" },
    { "SUPER + CTRL + M", "exec_cmd", "~/.config/hypr/scripts/matrix-rest.sh" },
    { "SUPER + ALT + C", "exec_cmd", "~/.config/hypr/scripts/startup-apps.sh" },
})

-- Personal application choices remain separate from the desktop's UI routes.
install({
    { "SUPER + SHIFT + T", "exec_cmd", "uwsm app -- kitty" },
    { "SUPER + SHIFT + B", "exec_cmd", "uwsm app -- google-chrome-stable" },
    { "SUPER + SHIFT + C", "exec_cmd", "uwsm app -- code" },
    { "SUPER + SHIFT + V", "exec_cmd", "uwsm app -- cursor" },
    { "SUPER + SHIFT + D", "exec_cmd", "uwsm app -- discord" },
    { "SUPER + SHIFT + S", "exec_cmd", "uwsm app -- spotify" },
    { "SUPER + SHIFT + F", "exec_cmd", "~/.local/bin/nacre-app files" },
})
