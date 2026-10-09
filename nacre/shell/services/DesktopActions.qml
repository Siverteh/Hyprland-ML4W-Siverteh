pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    readonly property var list: [
        {
            name: "New chat",
            description: "Start with your default assistant",
            icon: "add_comment",
            action: "new"
        },
        {
            name: "Resume latest chat",
            description: "Continue your latest conversation",
            icon: "history",
            action: "resume"
        },
        {
            name: "Load chat",
            description: "Browse all saved chats and hosts",
            icon: "forum",
            action: "load"
        },
        {
            name: "AI workspace",
            description: "Assistant settings, accounts and usage",
            icon: "terminal",
            action: "tasks"
        },
        {
            name: "Search brain",
            description: "Find knowledge in the left drawer",
            icon: "neurology",
            action: "left"
        },
        {
            name: "Open brain",
            description: "Explore the full knowledge map",
            icon: "neurology",
            action: "brain"
        },
        {
            name: "Capture thought",
            description: "Save a note in your brain",
            icon: "edit_note",
            action: "capture"
        },
        {
            name: "Applications",
            description: "Open the app grid",
            icon: "apps",
            action: "apps"
        },
        {
            name: "Windows",
            description: "Workspace and window overview",
            icon: "view_quilt",
            action: "overview"
        },
        {
            name: "Clipboard",
            description: "Text and screenshot history",
            icon: "content_paste",
            action: "clipboard"
        },
        {
            name: "Keyboard shortcuts",
            description: "Search current keybindings",
            icon: "keyboard",
            action: "keys"
        },
        {
            name: "Desktop settings",
            description: "Displays, gaps, effects and frame",
            icon: "settings",
            action: "settings"
        },
        {
            name: "Wallpaper",
            description: "Browse your wallpaper collection",
            icon: "wallpaper",
            action: "wallpaper"
        },
        {
            name: "Sound settings",
            description: "Output devices and application volume",
            icon: "volume_up",
            action: "sound"
        },
        {
            name: "Wi-Fi",
            description: "Choose a wireless connection",
            icon: "wifi",
            action: "wifi"
        },
        {
            name: "Bluetooth",
            description: "Manage Bluetooth devices",
            icon: "bluetooth",
            action: "bluetooth"
        },
        {
            name: DesktopSettings.data.animations === false ? "Enable animations" : "Disable animations",
            description: "Window and shell motion",
            icon: "animation",
            action: "toggle-setting",
            value: "animations"
        },
        {
            name: DesktopSettings.data.blur === false ? "Enable blur" : "Disable blur",
            description: "Window background blur",
            icon: "blur_on",
            action: "toggle-setting",
            value: "blur"
        },
        {
            name: DesktopSettings.data.shadow === false ? "Enable shadows" : "Disable shadows",
            description: "Window shadows",
            icon: "shadow",
            action: "toggle-setting",
            value: "shadow"
        },
        {
            name: "Do not disturb",
            description: "Toggle notification popups",
            icon: "notifications_off",
            action: "dnd"
        },
        {
            name: "Normal desktop",
            description: "Restore your saved normal preferences",
            icon: "desktop_windows",
            action: "preset",
            value: "normal"
        },
        {
            name: "Focused desktop",
            description: "Quiet notifications and reduce effects",
            icon: "center_focus_strong",
            action: "preset",
            value: "focused"
        },
        {
            name: "Presentation desktop",
            description: "Hide the frame and notification popups",
            icon: "present_to_all",
            action: "preset",
            value: "presentation"
        },
        {
            name: "Minimal desktop",
            description: "Small gaps and a quiet top bar",
            icon: "crop_square",
            action: "preset",
            value: "minimal"
        },
        {
            name: "Light theme",
            description: "Wallpaper palette in light mode",
            icon: "light_mode",
            action: "light"
        },
        {
            name: "Dark theme",
            description: "Wallpaper palette in dark mode",
            icon: "dark_mode",
            action: "dark"
        },
        {
            name: "Power menu",
            description: "Lock, log out, restart or power off",
            icon: "power_settings_new",
            action: "power"
        }
    ]
    IpcHandler {
        target: "desktopActions"
        function run(action: string, value: string): void {
            root.execute(action, value);
        }
    }
    function execute(action, value) {
        const v = Visibilities.getForActive();
        if (!v)
            return;
        v.previewOnly = false;
        v.launcher = false;
        v.left = false;
        v.leftPinned = false;
        if (["apps", "palette", "overview", "clipboard", "keys", "wallpaper"].includes(action)) {
            Visibilities.openMode(action);
            return;
        }
        if (action === "settings") {
            Visibilities.openSettings();
            return;
        }
        if (action === "left") {
            v.left = true;
            return;
        }
        if (action === "preset") {
            DesktopSettings.request(["preset", value]);
            return;
        }
        if (action === "toggle-setting" && ["animations", "blur", "shadow"].includes(value)) {
            DesktopSettings.set(value, !DesktopSettings.data[value]);
            return;
        }
        if (action === "dnd") {
            DesktopSettings.set("dnd", !DesktopSettings.data.dnd);
            return;
        }
        if (action === "light" || action === "dark") {
            Colours.setMode(action);
            return;
        }
        if (action === "power") {
            v.session = true;
            return;
        }
        const commands = {
            load: ["kitty", "--class", "siverteh-ai-task", "--title", "Load chat", "--", "siverteh-ai", "window", "--worker-command", "sessions"],
            sound: ["pavucontrol"],
            new: ["nacre-shell", "new"],
            resume: ["nacre-shell", "resume"],
            tasks: ["nacre-shell", "tasks"],
            brain: ["nacre-shell", "brain"],
            capture: ["nacre-shell", "capture"],
            wifi: ["nacre-shell", "wifi"],
            bluetooth: ["nacre-shell", "bluetooth"]
        };
        if (commands[action])
            AppLaunch.run(commands[action]);
    }
}
