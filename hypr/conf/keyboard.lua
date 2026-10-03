-- -----------------------------------------------------

-- Keyboard Layout

-- https://wiki.hyprland.org/Configuring/Variables/#input

-- -----------------------------------------------------
hl.config({
    input = {
        kb_layout = "no",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        numlock_by_default = true,
        follow_mouse = 1,
        mouse_refocus = false,
        touchpad = {
            natural_scroll = true,
            scroll_factor = 0.25,
            disable_while_typing = false,
        },
        sensitivity = 0,
    },
})
