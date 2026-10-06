-- Siverteh OS compositor configuration. Host overrides load after defaults.
-- -----------------------------------------------------
-- Monitor
-- -----------------------------------------------------
require("conf.monitor")
-- -----------------------------------------------------
-- Cursor
-- -----------------------------------------------------
require("conf.cursor")
require("conf.cursor-behavior")
-- -----------------------------------------------------
-- Keyboard
-- -----------------------------------------------------
require("conf.keyboard")
-- -----------------------------------------------------
-- Load color file
-- -----------------------------------------------------
-- Neutral boot defaults; the committed palette is loaded after base rules.
var_primary="rgba(808080ff)"
var_on_primary="rgba(f0f0f0ff)"

-- -----------------------------------------------------
-- Autostart
-- -----------------------------------------------------
require("conf.autostart")
-- -----------------------------------------------------
-- Load configuration files
-- -----------------------------------------------------
require("conf.window")
require("conf.decoration")
require("conf.layout")
require("conf.misc")
require("conf.keybinding")
require("conf.windowrule")
-- -----------------------------------------------------
-- Animation
-- -----------------------------------------------------
require("conf.animation")
-- -----------------------------------------------------
-- Shared Desktop Rules
-- -----------------------------------------------------
require("conf.siverteh")

-- Siverteh Observatory
require("conf.brain")

-- Host-specific monitor overrides stay private; native display settings load last.
local monitor_path = os.getenv("HOME") .. "/.config/siverteh-shell/monitor.lua"
local monitor_file = io.open(monitor_path, "r")
if monitor_file then monitor_file:close(); dofile(monitor_path) end

-- Siverteh committed wallpaper palette
local palette_path = os.getenv("HOME") .. "/.config/siverteh-shell/palette.lua"
local palette_file = io.open(palette_path, "r")
if palette_file then palette_file:close(); dofile(palette_path) end

-- Siverteh desktop settings
local desktop_path = os.getenv("HOME") .. "/.config/siverteh-shell/desktop.lua"
local desktop_file = io.open(desktop_path, "r")
if desktop_file then desktop_file:close(); dofile(desktop_path) end

-- Siverteh native desktop shortcuts
local shortcuts_path = os.getenv("HOME") .. "/.config/siverteh-shell/shortcuts.lua"
local shortcuts_file = io.open(shortcuts_path, "r")
if shortcuts_file then shortcuts_file:close(); dofile(shortcuts_path) end
