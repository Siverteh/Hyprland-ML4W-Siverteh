-- -----------------------------------------------------

-- Key bindings

-- name: "Default"

-- -----------------------------------------------------

-- SUPER KEY

-- =====================================================

-- ASUS Zenbook 14 OLED - With OSD Indicators

-- =====================================================

-- -------------------- Audio Controls (with OSD) --------------------

-- Media key: Mute/Unmute
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
    locked = true,
})

-- Media key: Volume Down
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
    repeating = true,
    locked = true,
})

-- Media key: Volume Up
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), {
    repeating = true,
    locked = true,
})

-- Lock on the initial power-button press. Firmware retains emergency hold-to-off.
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("loginctl lock-session"), {locked = true})

-- -------------------- Screen Brightness (with OSD) --------------------

-- F5 = Brightness Down
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell brightness down"))

-- F6 = Brightness Up
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell brightness up"))

-- -------------------- Keyboard Backlight (with OSD) --------------------

-- F4 = Keyboard brightness up
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell keyboard-light up"))
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell keyboard-light down"))

-- -------------------- Emoji picker --------------------

-- Emoji picker
hl.bind("SUPER + period", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-app emoji"))

-- -------------------- Microphone Controls (with OSD) --------------------

-- F9 = Mute/Unmute Microphone
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

-- -------------------- Screenshot Tools --------------------
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy && notify-send \"Screenshot\" \"Copied to clipboard\""))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("grim ~/Pictures/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png && notify-send \"Screenshot\" \"Saved to Pictures/Screenshots\""))

-- =====================================================

-- Mouse functionality

-- =====================================================
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), {
    mouse = true,
})
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), {
    mouse = true,
})

-- =====================================================

-- WORKSPACE NAVIGATION (Most Important - No Modifiers!)

-- =====================================================
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = 1, on_current_monitor = true }))
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = 2, on_current_monitor = true }))
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = 3, on_current_monitor = true }))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = 4, on_current_monitor = true }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = 5, on_current_monitor = true }))
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = 6, on_current_monitor = true }))
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = 7, on_current_monitor = true }))

-- Workspace cycling
hl.bind("SUPER + TAB", hl.dsp.focus({ workspace = "m+1", on_current_monitor = true }))
hl.bind("SUPER + SHIFT + TAB", hl.dsp.focus({ workspace = "m-1", on_current_monitor = true }))

-- Mouse wheel workspace cycling
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1", on_current_monitor = true }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1", on_current_monitor = true }))

-- Move windows to workspaces
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))

-- Move to adjacent workspace
hl.bind("SUPER + CTRL + SHIFT + left", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind("SUPER + CTRL + SHIFT + right", hl.dsp.window.move({ workspace = "r+1" }))

-- =====================================================

-- WINDOW MANAGEMENT (SUPER + Letter - Fast Access)

-- =====================================================

-- Window trash (30-second undo)
hl.bind("SUPER + Q", hl.dsp.exec_cmd("~/.config/hypr/scripts/window-trash.sh trash"))
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd("~/.config/hypr/scripts/window-trash.sh restore-last"))
hl.bind("SUPER + ALT + Q", hl.dsp.exec_cmd("~/.config/hypr/scripts/window-trash.sh restore-all"))
hl.bind("SUPER + CTRL + Q", hl.dsp.exec_cmd("~/.config/hypr/scripts/window-close.sh"))
hl.bind("SUPER + CTRL + SHIFT + Q", hl.dsp.exec_cmd("~/.config/hypr/scripts/window-close.sh force"))

-- Fullscreen modes
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Window minimize/restore
hl.bind("SUPER + H", hl.dsp.exec_cmd("~/.config/hypr/scripts/window-minimize.sh hide"))
hl.bind("SUPER + SHIFT + H", hl.dsp.exec_cmd("~/.config/hypr/scripts/window-minimize.sh restore-last"))
hl.bind("SUPER + ALT + H", hl.dsp.exec_cmd("~/.config/hypr/scripts/window-minimize.sh restore-current"))

-- Display settings
hl.bind("SUPER + ALT + K", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell settings"))

-- Window states
hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pin())
hl.bind("SUPER + SHIFT + P", hl.dsp.window.pseudo())

-- Window groups
hl.bind("SUPER + G", hl.dsp.group.toggle())
hl.bind("SUPER + bracketleft", hl.dsp.group.prev())
hl.bind("SUPER + bracketright", hl.dsp.group.next())

-- Split toggle
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))

-- Resize mode
hl.bind("SUPER + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), {
    repeating = true,
})
    hl.bind("left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), {
    repeating = true,
})
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), {
    repeating = true,
})
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), {
    repeating = true,
})
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("return", hl.dsp.submap("reset"))
    hl.bind("SUPER + R", hl.dsp.submap("reset"))
end)

-- =====================================================

-- WINDOW FOCUS & MOVEMENT (Arrow Keys)

-- =====================================================

-- Focus windows
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

-- Move windows
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Resize windows
hl.bind("SUPER + ALT + right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), {
    repeating = true,
})
hl.bind("SUPER + ALT + left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), {
    repeating = true,
})
hl.bind("SUPER + ALT + up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), {
    repeating = true,
})
hl.bind("SUPER + ALT + down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), {
    repeating = true,
})

-- =====================================================

-- OPEN APPLICATIONS (SUPER + SHIFT + Letter)

-- =====================================================
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("uwsm app -- kitty"))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("uwsm app -- google-chrome-stable"))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("uwsm app -- code"))
hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("uwsm app -- cursor"))
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("uwsm app -- discord"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("uwsm app -- spotify"))
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-app files"))

-- =====================================================

-- LAUNCHERS & UTILITIES

-- =====================================================

-- Categorized bottom launcher; require an explicit chord.
hl.bind("SUPER + A", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell launcher"))

-- Window picker
hl.bind("SUPER + D", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell overview"))

-- Scratchpad
hl.bind("SUPER + grave", hl.dsp.workspace.toggle_special(""))
hl.bind("SUPER + SHIFT + grave", hl.dsp.window.move({ workspace = "special" }))

-- Clipboard manager
hl.bind("SUPER + V", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell clipboard"))

-- =====================================================

-- SYSTEM CONTROLS

-- =====================================================
hl.bind("SUPER + X", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell session"))
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- bind = SUPER SHIFT, E, exit

-- =====================================================

-- UTILITIES & TOOLS

-- =====================================================
hl.bind("SUPER + W", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell wallpaper"))
hl.bind("SUPER + Z", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell hide"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell toggle"))
hl.bind("SUPER + SHIFT + O", hl.dsp.exec_cmd("~/.local/bin/siverteh-os-shell settings"))
hl.bind("SUPER + CTRL + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/matrix-rest.sh"))

-- =====================================================

-- CLASSIC ALT+TAB

-- =====================================================
hl.bind("ALT + TAB", hl.dsp.window.cycle_next({ next = true }))
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ next = false }))

-- =====================================================

-- SUPER COMMANDS (Multi-Workspace Setups)

-- =====================================================
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd("~/.config/hypr/scripts/startup-apps.sh"))
