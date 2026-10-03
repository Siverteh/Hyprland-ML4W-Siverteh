-- _   _                  _                 _

-- | | | |_   _ _ __  _ __| | __ _ _ __   __| |

-- | |_| | | | | '_ \| '__| |/ _` | '_ \ / _` |

-- |  _  | |_| | |_) | |  | | (_| | | | | (_| |

-- |_| |_|\__, | .__/|_|  |_|\__,_|_| |_|\__,_|

-- |___/|_|

--

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
require("colors")
var_color8 = var_primary

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

-- Environment for xdg-desktop-portal-hyprland

-- -----------------------------------------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

-- -----------------------------------------------------

-- Shared Desktop Rules

-- -----------------------------------------------------
require("conf.siverteh")

-- Siverteh Observatory
require("conf.observatory")

-- Siverteh committed wallpaper palette
local palette_path = os.getenv("HOME") .. "/.config/siverteh-shell/palette.lua"
local palette_file = io.open(palette_path, "r")
if palette_file then palette_file:close(); dofile(palette_path) end
