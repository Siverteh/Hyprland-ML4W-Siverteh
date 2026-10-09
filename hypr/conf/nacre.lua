-- Nacre desktop layers and application dialog behavior.

-- Siverteh Shell
hl.layer_rule({
    name = "nacre-glass",
    match = { namespace = "^nacre-(drawers|topbar|lock-preview|left-menu-handle|right-menu-handle)$" },
    no_anim = true,
    blur = true,
    ignore_alpha = 0.5,
})

-- Lock preview stays proportional to its output and does not take a tiled slot.
hl.window_rule({
    name = "siverteh-lock-preview",
    match = {
        class = "^org.quickshell$",
        title = "^Siverteh lock screen preview$",
    },
    float = true,
    center = true,
    size = "70% 70%",
})

-- Pavucontrol
hl.window_rule({
    name = "pavucontrol",
    match = {
        class = "(.*org.pulseaudio.pavucontrol.*)",
    },
    float = true,
    center = true,
    pin = true,
    size = "700 600",
})

-- Newelle
hl.window_rule({
    name = "newelle",
    match = {
        class = "(io.github.qwersyk.Newelle)",
    },
    float = true,
    center = true,
    pin = true,
    size = "1000 700",
})

-- Siverteh Hub
hl.window_rule({
    name = "siverteh-hub",
    match = {
        class = "(com.siverteh.hub)",
    },
    float = true,
    center = true,
    size = "940 780",
})

-- Blueman Manager
hl.window_rule({
    name = "blueman-manager",
    match = {
        class = "(blueman-manager)",
    },
    float = true,
    center = true,
    size = "800 600",
})

-- nwg-look
hl.window_rule({
    name = "nwg-look",
    match = {
        class = "(nwg-look)",
    },
    float = true,
    center = true,
    size = "700 600",
})

-- nwg-displays
hl.window_rule({
    name = "nwg-displays",
    match = {
        class = "(nwg-displays)",
    },
    float = true,
    center = true,
    size = "900 600",
})

-- Gnome Calculator
hl.window_rule({
    name = "gnome-calculator",
    match = {
        class = "(org.gnome.Calculator)",
    },
    float = true,
    center = true,
    size = "700 600",
})

-- Hyprland Share Picker
hl.window_rule({
    name = "hyprland-share-picker",
    match = {
        class = "(hyprland-share-picker)",
    },
    float = true,
    pin = true,
    center = true,
    size = "600 400",
})

-- nm-connection-editor
hl.window_rule({
    name = "nm-connection-editor",
    match = {
        class = "(nm-connection-editor)",
    },
    float = true,
    center = true,
    size = "800 700",
})

-- Picture-in-Picture
hl.window_rule({
    name = "Picture-in-Picture",
    match = {
        title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$",
    },
    float = true,
    pin = true,
    center = true,
})

-- General floating
hl.window_rule({
    name = "dotfiles-floating",
    match = {
        class = "(dotfiles-floating)",
    },
    float = true,
    center = true,
    size = "1000 700",
})

-- Dotfiles Sidepad
hl.window_rule({
    name = "dotfiles-sidepad",
    match = {
        class = "(dotfiles-sidepad)",
    },
    float = true,
    pin = true,
    center = true,
    size = "1000 700",
})

-- Float and center file pickers

-- windowrule = float, class:xdg-desktop-portal-gtk, title:^(Open.*Files?|Save.*Files?|All Files|Save)

-- windowrule = center, class:xdg-desktop-portal-gtk, title:^(Open.*Files?|Save.*Files?|All Files|Save)

-- XWayland scaling is a compositor option; environment belongs to uwsm/.
hl.config({
    xwayland = { force_zero_scaling = true },
})

-- Native OS control windows
hl.window_rule({name="siverteh-controls",match={class="^(nacre-control)$"},float=true,center=true,size="720 500"})
