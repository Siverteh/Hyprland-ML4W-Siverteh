var shortcuts = [
    {key:"Super + A", title:"Find an application", detail:"The bottom launcher starts with your favorites. Type to search, or browse all apps."},
    {key:"Super + W", title:"Choose a wallpaper", detail:"Search your collection, switch gallery layouts and choose static or dynamic scenes."},
    {key:"Super + S", title:"Open Settings", detail:"Appearance, displays, sound, connections, lock screen and maintenance in one place."},
    {key:"Super + Shift + F", title:"Open Files", detail:"Dolphin browses folders and ZIP archives. Super + F is fullscreen."},
    {key:"Super + Shift + T", title:"Open a terminal", detail:"Kitty follows your current wallpaper colors."},
    {key:"Super + Q", title:"Put a window away", detail:"Restore the last window with Super + Shift + Q. Super + Ctrl + Q closes it."},
    {key:"Super + 1–7", title:"Change workspace", detail:"Add Shift to move the current window to that workspace."},
    {key:"Super + arrows", title:"Move focus", detail:"Add Shift to move the window. Super + left/right mouse drags or resizes."},
    {key:"Print", title:"Capture an area", detail:"Pick a region to copy to the clipboard. Super + Print saves the whole screen."},
    {key:"Super + V", title:"Clipboard history", detail:"Find something copied earlier and paste it again."},
    {key:"Super + Ctrl + B", title:"Open the AI sidebar", detail:"Keep a conversation next to your work. AI is an optional part of Nacre."},
    {key:"Super + Escape", title:"Lock the desktop", detail:"Your existing lock screen handles authentication."}
];
var apps = [
    {title:"Nacre Settings", icon:"settings", detail:"Set up your desktop, displays, connections and everyday preferences.", action:"settings:desktop", availability:"", logo:"settings"},
    {title:"Nacre Colors", icon:"palette", detail:"Explore the real colors in a wallpaper. Compare modes, preview, then apply or export.", action:"colors", availability:"", logo:"colors"},
    {title:"Nacre AI", icon:"neurology", detail:"Your assistant workspace and ongoing conversations. Uses your existing accounts.", action:"ai", availability:"ai", logo:"ai"},
    {title:"Nacre Brain", icon:"neurology", detail:"Browse and search your private notes, knowledge and memories.", action:"brain", availability:"brain", logo:"brain"}
];
var help = [
    {title:"A panel is in the way", detail:"Press Escape to dismiss a launcher or wallpaper picker. Unpin the AI sidebar if you want it to close when you leave."},
    {title:"The desktop needs attention", detail:"Open Maintenance in Settings for health checks, updates, releases and recovery. Save your work before restarting or restoring."},
    {title:"Make the desktop comfortable", detail:"Settings has display scaling and a reduced-motion option. Sound, Wi-Fi and Bluetooth controls also open their detailed pages."},
    {title:"Welcome on your terms", detail:"Turn off Show at login below. Welcome stays in the launcher, and nacre-welcome opens it whenever you need it."}
];
