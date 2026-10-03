hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 0,
        border_size = 1,
        col = {
            active_border = {
                colors = {var_primary, var_on_primary},
                angle = 90,
            },
            inactive_border = var_on_primary,
        },
        layout = "dwindle",
        resize_on_border = true,
    },
})
