-- UWSM is the single source of cursor theme and size.
hl.on("hyprland.start", function()
    local theme = os.getenv("XCURSOR_THEME")
    local size = tonumber(os.getenv("XCURSOR_SIZE"))
    if theme and theme:match("^[%w_.-]+$") and size and size > 0 then
        hl.exec_cmd("hyprctl setcursor " .. theme .. " " .. tostring(size))
    end
end)
