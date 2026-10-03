-- ___       __           __           __

-- / _ |__ __/ /____  ___ / /____ _____/ /_

-- / __ / // / __/ _ \(_-</ __/ _ `/ __/ __/

-- /_/ |_\_,_/\__/\___/___/\__/\_,_/_/  \__/

--

-- Start Listeners
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/siverteh/core/listeners.sh --startall")
end)

-- Start Polkit
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)

-- Load Wallpaper
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.local/bin/siverteh-observatory restore-wallpaper")
end)

-- Load Notification Daemon
hl.on("hyprland.start", function()
    hl.exec_cmd("swaync")
end)

-- Load GTK settings
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/scripts/gtk.sh")
end)

-- Using hypridle to start hyprlock
hl.on("hyprland.start", function()
    hl.exec_cmd("hypridle")
end)

-- Load cliphist history
hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --watch cliphist store")
end)

-- Start autostart cleanup
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/scripts/cleanup.sh")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("kanshi")
    hl.exec_cmd("~/.config/hypr/scripts/monitor-rules.sh")
    hl.exec_cmd("~/.local/bin/siverteh-observatory start")
    hl.exec_cmd("~/.config/hypr/scripts/cleanup-locks.sh")
    -- Calendar is integrated in the Observatory panel.
    -- Observatory owns the center dropdown.
    hl.exec_cmd("~/.config/hypr/scripts/coding-setup.sh")
end)
