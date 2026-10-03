-- -----------------------------------------------------

-- Layouts

-- name: "Default"

-- -----------------------------------------------------
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

-- new_status = master
hl.config({
    binds = {
        workspace_back_and_forth = false,
        allow_workspace_cycles = true,
        pass_mouse_when_bound = false,
    },
})

-- Laptop touchpad gestures:
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})
