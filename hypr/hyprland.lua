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

-- Private overrides retain this order; one broken file must not stop later ones.
local function load_private(name)
    local path = os.getenv("HOME") .. "/.config/siverteh-shell/" .. name .. ".lua"
    local file = io.open(path, "r")
    if not file then return end
    file:close()
    local ok, err = pcall(dofile, path)
    if not ok then
        hl.notification.create({ text = "Siverteh: " .. name .. " failed: " .. tostring(err), timeout = 15000, icon = "error" })
    end
end
load_private("monitor")
-- Siverteh committed wallpaper palette
load_private("palette")
-- Siverteh desktop settings
load_private("desktop")
-- Siverteh native desktop shortcuts
load_private("shortcuts")
-- Optional private host behavior.
load_private("host")
